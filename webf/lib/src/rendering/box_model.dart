/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'box_overflow.dart';
import 'debug_overlay.dart';
import 'package:webf/src/accessibility/semantics.dart';

// The hashCode of all the renderBox which is in layout.
List<int> renderBoxInLayoutHashCodes = [];

class RenderLayoutParentData extends ContainerBoxParentData<RenderBox> {
  // Row index of child when wrapping
  int runIndex = 0;

  // Semantic index of this child within its parent.
  // Populated by RenderLayoutBox.visitChildrenForSemantics so nodes can set
  // SemanticsConfiguration.indexInParent without expensive DOM sibling scans.
  int? semanticsIndex;

  @override
  String toString() {
    return '${super.toString()}; runIndex: $runIndex;';
  }
}

// Applies the layout transform up the tree to `ancestor`.
//
// Return getLayoutTransformTolocal layout coordinate system to the
// coordinate system of `ancestor`.
Offset getLayoutTransformTo(RenderObject current, RenderObject ancestor,
    {bool excludeScrollOffset = false}) {
  final List<RenderObject> renderers = <RenderObject>[];
  for (RenderObject renderer = current;
      renderer != ancestor;
      renderer = renderer.parent!) {
    renderers.add(renderer);
    assert(renderer.parent != null);
  }
  renderers.add(ancestor);
  List<Offset> stackOffsets = [];

  for (int index = renderers.length - 1; index > 0; index -= 1) {
    RenderObject parentRenderer = renderers[index];
    RenderObject childRenderer = renderers[index - 1];
    // Apply the layout transform for renderBoxModel and fallback to paint transform for other renderObject type.
    if (parentRenderer is RenderBoxModel) {
      // If the next renderBox has a fixed position,
      // the outside scroll offset won't affect the actual results because of its fixed positioning.
      if (childRenderer is RenderBoxModel && childRenderer.isFixedToViewport) {
        stackOffsets.clear();
      }

      stackOffsets.add(parentRenderer.obtainLayoutTransform(
          childRenderer, excludeScrollOffset));
    } else if (childRenderer is RenderIndexedSemantics &&
        childRenderer.parentData is SliverMultiBoxAdaptorParentData) {
      assert(childRenderer.parent == parentRenderer);

      // For sliver elements in a ListView, the layoutOffset from SliverMultiBoxAdaptorParentData
      // is already viewport-relative and accounts for scroll position.
      double layoutOffset =
          (childRenderer.parentData as SliverMultiBoxAdaptorParentData)
                  .layoutOffset ??
              0.0;

      // Determine scroll direction - default to vertical
      Axis scrollDirection = Axis.vertical;
      if (ancestor is RenderWidget &&
          ancestor.renderStyle.target is WebFListViewElement) {
        scrollDirection =
            (ancestor.renderStyle.target as WebFListViewElement).axis;
      }

      Offset sliverScrollOffset = scrollDirection == Axis.vertical
          ? Offset(0, layoutOffset)
          : Offset(layoutOffset, 0);

      stackOffsets.add(sliverScrollOffset);
    } else if (parentRenderer is RenderBox) {
      assert(childRenderer.parent == parentRenderer);
      if (childRenderer.parentData is BoxParentData) {
        stackOffsets.add((childRenderer.parentData as BoxParentData).offset);
      }
    }
  }

  if (stackOffsets.isEmpty) return Offset.zero;

  return stackOffsets.reduce((prev, next) => prev + next);
}

mixin RenderBoxModelBase on RenderBox {
  CSSRenderStyle get renderStyle;
}

abstract class RenderBoxModel extends RenderBox
    with
        RenderBoxModelBase,
        RenderBoxDecorationMixin,
        RenderBoxOverflowLayout,
        RenderTransformMixin,
        RenderOverflowMixin,
        RenderOpacityMixin,
        ResizeObserverMixin,
        RenderIntersectionObserverMixin,
        RenderContentVisibilityMixin {
  RenderBoxModel({
    required this.renderStyle,
  }) : super();

  // Cached CSS baselines computed during this render object's own layout.
  // These represent distances from the top padding edge (including border-top) to the text baselines
  // according to CSS semantics (first/last line box when applicable).
  double? _cssFirstBaseline;
  double? _cssLastBaseline;

  // Expose read-only accessors for parents to consume during their layout
  // without triggering any new baseline computation.
  double? computeCssFirstBaseline() => _cssFirstBaseline;

  double? computeCssLastBaseline() => _cssLastBaseline;

  // Baseline accessor by type; currently returns the same cached values for
  // both alphabetic and ideographic, and can be specialized as support grows.
  double? computeCssFirstBaselineOf(TextBaseline baseline) => _cssFirstBaseline;

  double? computeCssLastBaselineOf(TextBaseline baseline) => _cssLastBaseline;

  // Utilities for children to update baseline caches during their own layout.
  @protected
  void setCssBaselines({double? first, double? last}) {
    _cssFirstBaseline = first;
    _cssLastBaseline = last ?? first;
  }

  @override
  bool get alwaysNeedsCompositing {
    return intersectionObserverAlwaysNeedsCompositing() ||
        opacityAlwaysNeedsCompositing();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    // Apply ARIA → Semantics mapping for generic WebF elements.
    WebFAccessibility.applyToRenderBoxModel(this, config);
    // Apply overflow scrolling semantics (scrollPosition/extents/actions) so
    // assistive technologies can track focus/geometry while scrolling.
    describeOverflowSemantics(config);
  }

  RenderPositionPlaceholder? renderPositionPlaceholder;

  bool _debugShouldPaintOverlay = false;

  @override
  late CSSRenderStyle renderStyle;

  bool get debugShouldPaintOverlay => _debugShouldPaintOverlay;

  set debugShouldPaintOverlay(bool value) {
    if (_debugShouldPaintOverlay != value) {
      _debugShouldPaintOverlay = value;
      markNeedsPaint();
    }
  }

  BoxConstraints? contentConstraints;

  bool _needsRecalculateStyle = false;

  void markNeedsRecalculateRenderStyle() {
    if (_needsRecalculateStyle) return;
    _needsRecalculateStyle = true;
  }

  // Positioned children are now handled directly during the containing
  // block's layout; no cached set is maintained at this level.

  @override
  String toStringShort() {
    return '${super.toStringShort()} ${renderStyle.target}';
  }

  bool get isSizeTight {
    bool isDefinedSize = (renderStyle.width.value != null &&
        renderStyle.height.value != null &&
        renderStyle.width.isPrecise &&
        renderStyle.height.isPrecise);
    bool isFixedMinAndMaxSize =
        (renderStyle.minWidth.value == renderStyle.maxWidth.value &&
                renderStyle.minWidth.value != null &&
                renderStyle.minWidth.isPrecise) &&
            (renderStyle.minHeight.value == renderStyle.maxHeight.value &&
                renderStyle.minHeight.value != null &&
                renderStyle.minHeight.isPrecise);

    return isDefinedSize || isFixedMinAndMaxSize;
  }

  BoxSizeType get widthSizeType {
    return renderStyle.width.isAuto
        ? BoxSizeType.automatic
        : BoxSizeType.specified;
  }

  BoxSizeType get heightSizeType {
    return renderStyle.height.isAuto
        ? BoxSizeType.automatic
        : BoxSizeType.specified;
  }

  // Cache additional offset of scrolling box in horizontal direction
  // to be used in paint of fixed children
  double? _additionalPaintOffsetX;

  double? get additionalPaintOffsetX => _additionalPaintOffsetX;

  set additionalPaintOffsetX(double? value) {
    if (value == null) return;
    if (_additionalPaintOffsetX != value) {
      _additionalPaintOffsetX = value;
      markNeedsPaint();
    }
  }

  // Cache scroll offset of scrolling box in vertical direction
  // to be used in paint of fixed children
  double? _additionalPaintOffsetY;

  double? get additionalPaintOffsetY => _additionalPaintOffsetY;

  set additionalPaintOffsetY(double? value) {
    if (value == null) return;
    if (_additionalPaintOffsetY != value) {
      _additionalPaintOffsetY = value;
      markNeedsPaint();
    }
  }

  // Position of sticky element changes between relative and fixed of scroll container
  StickyPositionType stickyStatus = StickyPositionType.relative;

  // Positioned holder box ref.
  RenderPositionPlaceholder? positionedHolder;

  /// Whether current box is the root of the document which corresponds to HTML element in dom tree.
  bool get isDocumentRootBox {
    // Get the outer box of overflow scroll box
    return renderStyle.target is HTMLElement ||
        renderStyle.target is RouterLinkElement;
  }

  // Width/height is overrided by flex-grow or flex-shrink in flex layout.
  bool hasOverrideContentLogicalWidth = false;
  bool hasOverrideContentLogicalHeight = false;

  // --- Intrinsic sizing -----------------------------------------------------
  // Provide conservative intrinsic size estimates based on CSS box properties
  // and known intrinsic hints on the render style.
  @override
  double computeMinIntrinsicWidth(double height) {
    // Prefer explicit width if available, else min-width, else intrinsic hint.
    double content = 0.0;
    try {
      if (renderStyle.width.isNotAuto) {
        final double w = renderStyle.width.computedValue;
        if (w.isFinite && w > 0) content = w;
      } else if (renderStyle.minWidth.isNotAuto) {
        final double w = renderStyle.minWidth.computedValue;
        if (w.isFinite && w > 0) content = math.max(content, w);
      } else if (renderStyle.intrinsicWidth.isFinite &&
          renderStyle.intrinsicWidth > 0) {
        content = math.max(content, renderStyle.intrinsicWidth);
      }
    } catch (_) {}

    // Add horizontal paddings and borders to reach border-box for RenderBox.
    final double padding = (renderStyle.paddingLeft.computedValue +
        renderStyle.paddingRight.computedValue);
    final double border = (renderStyle.effectiveBorderLeftWidth.computedValue +
        renderStyle.effectiveBorderRightWidth.computedValue);
    return content + padding + border;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double content = 0.0;
    try {
      if (renderStyle.height.isNotAuto) {
        final double h = renderStyle.height.computedValue;
        if (h.isFinite && h > 0) content = h;
      } else if (renderStyle.minHeight.isNotAuto) {
        final double h = renderStyle.minHeight.computedValue;
        if (h.isFinite && h > 0) content = math.max(content, h);
      } else if (renderStyle.intrinsicHeight.isFinite &&
          renderStyle.intrinsicHeight > 0) {
        content = math.max(content, renderStyle.intrinsicHeight);
      }
    } catch (_) {}

    final double padding = (renderStyle.paddingTop.computedValue +
        renderStyle.paddingBottom.computedValue);
    final double border = (renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue);
    return content + padding + border;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double content = 0.0;
    try {
      if (renderStyle.width.isNotAuto) {
        final double w = renderStyle.width.computedValue;
        if (w.isFinite && w > 0) content = w;
      } else if (renderStyle.maxWidth.isNotNone) {
        final double w = renderStyle.maxWidth.computedValue;
        if (w.isFinite && w > 0) content = math.max(content, w);
      } else if (renderStyle.intrinsicWidth.isFinite &&
          renderStyle.intrinsicWidth > 0) {
        content = math.max(content, renderStyle.intrinsicWidth);
      }
    } catch (_) {}

    final double padding = (renderStyle.paddingLeft.computedValue +
        renderStyle.paddingRight.computedValue);
    final double border = (renderStyle.effectiveBorderLeftWidth.computedValue +
        renderStyle.effectiveBorderRightWidth.computedValue);
    return content + padding + border;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double content = 0.0;
    try {
      if (renderStyle.height.isNotAuto) {
        final double h = renderStyle.height.computedValue;
        if (h.isFinite && h > 0) content = h;
      } else if (renderStyle.maxHeight.isNotNone) {
        final double h = renderStyle.maxHeight.computedValue;
        if (h.isFinite && h > 0) content = math.max(content, h);
      } else if (renderStyle.intrinsicHeight.isFinite &&
          renderStyle.intrinsicHeight > 0) {
        content = math.max(content, renderStyle.intrinsicHeight);
      }
    } catch (_) {}

    final double padding = (renderStyle.paddingTop.computedValue +
        renderStyle.paddingBottom.computedValue);
    final double border = (renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue);
    return content + padding + border;
  }

  void clearOverrideContentSize() {
    hasOverrideContentLogicalWidth = false;
    hasOverrideContentLogicalHeight = false;
  }

  // Nominally, the smallest size a box could take that doesn’t lead to overflow that could be avoided by choosing
  // a larger size. Formally, the size of the box when sized under a min-content constraint.
  // https://www.w3.org/TR/css-sizing-3/#min-content
  double minContentWidth = 0;
  double minContentHeight = 0;

  // Flag indicating this element is being relaid out by flex layout and only contains text.
  // When true, RenderTextBox children will use infinite width constraints to prevent
  // box constraint errors during flex item resizing. This flag is automatically cleared
  // after the text box reads it in getConstraints().
  bool isFlexRelayout = false;

  // Whether it needs relayout due to percentage calculation.
  bool needsRelayout = false;

  // Mark parent as needs relayout used in cases such as
  // child has percentage length and parent's size can not be calculated by style
  // thus parent needs relayout for its child calculate percentage length.
  void markParentNeedsRelayout() {
    RenderObject? parent = renderStyle
        .getAttachedRenderParentRenderStyle()
        ?.attachedRenderBoxModel;
    if (parent is RenderBoxModel) {
      parent.needsRelayout = true;
    }
  }

  void markNeedsRelayout() {
    needsRelayout = true;
  }

  // A flag to detect the size of this renderBox had changed during this layout.
  bool isSelfSizeChanged = false;

  /// Mark children needs layout when drop child as Flutter did
  ///
  @override
  void dropChild(RenderObject child) {
    super.dropChild(child);
  }

  void calculateBaseline();

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    renderBoxInLayoutHashCodes.add(hashCode);
    super.layout(constraints, parentUsesSize: parentUsesSize);

    renderBoxInLayoutHashCodes.remove(hashCode);
    // Clear length cache when no renderBox is in layout.
    if (renderBoxInLayoutHashCodes.isEmpty) {
      clearComputedValueCache();
    }
  }

  // Calculate constraints of renderBoxModel on layout stage and
  // only needed to be executed once on every layout.
  BoxConstraints getConstraints() {
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isDisplayInline = effectiveDisplay == CSSDisplay.inline;

    double? minWidth =
        renderStyle.minWidth.isAuto ? null : renderStyle.minWidth.computedValue;
    double? maxWidth =
        renderStyle.maxWidth.isNone ? null : renderStyle.maxWidth.computedValue;
    double? minHeight = renderStyle.minHeight.isAuto
        ? null
        : renderStyle.minHeight.computedValue;
    double? maxHeight = renderStyle.maxHeight.isNone
        ? null
        : renderStyle.maxHeight.computedValue;

    // Need to calculated logic content size on every layout.
    renderStyle.computeContentBoxLogicalWidth();
    renderStyle.computeContentBoxLogicalHeight();

    // Width should be not smaller than border and padding in horizontal direction
    // when box-sizing is border-box which is only supported.
    double minConstraintWidth =
        renderStyle.effectiveBorderLeftWidth.computedValue +
            renderStyle.effectiveBorderRightWidth.computedValue +
            renderStyle.paddingLeft.computedValue +
            renderStyle.paddingRight.computedValue;

    double? parentBoxContentConstraintsWidth;
    if (renderStyle.isParentRenderBoxModel() &&
        (renderStyle.isSelfRenderLayoutBox() ||
            renderStyle.isSelfRenderWidget())) {
      RenderBoxModel parentRenderBoxModel = (renderStyle
          .getAttachedRenderParentRenderStyle()!
          .attachedRenderBoxModel!);

      // Inline-block shrink-to-fit: when the parent is inline-block with auto width,
      // do not bound block children by the parent's finite content width. This allows
      // the child to compute its own natural width and lets the parent shrink-wrap.
      bool parentIsInlineBlockAutoWidth =
          parentRenderBoxModel.renderStyle.effectiveDisplay ==
                  CSSDisplay.inlineBlock &&
              parentRenderBoxModel.renderStyle.width.isAuto;

      if (parentIsInlineBlockAutoWidth) {
        parentBoxContentConstraintsWidth = double.infinity;
      } else {
        // Prefer the actual layout parent's content constraints if available,
        // because CSS parent may not yet have computed contentConstraints during IFC layout.
        BoxConstraints? candidate;
        if (parent is RenderBoxModel) {
          candidate = (parent as RenderBoxModel).contentConstraints;
        }
        candidate ??= parentRenderBoxModel.contentConstraints;

        if (candidate != null) {
          // When using CSS parent constraints, deflate with the current element's margins
          // to match previous behavior; otherwise use the raw layout parent's constraints.
          if (identical(candidate, parentRenderBoxModel.contentConstraints)) {
            parentBoxContentConstraintsWidth = parentRenderBoxModel.renderStyle
                .deflateMarginConstraints(candidate)
                .maxWidth;
          } else {
            parentBoxContentConstraintsWidth = candidate.maxWidth;
          }

          // When inner minimal content size are larger that parent's constraints,
          // still use parent constraints but ensure minConstraintWidth is properly handled later
          if (parentBoxContentConstraintsWidth < minConstraintWidth) {
            // Keep parentBoxContentConstraintsWidth; resolution happens below.
          }
        }
      }

      // Flex context adjustments
      if (renderStyle.isParentRenderFlexLayout()) {
        final RenderFlexLayout flexParent = renderStyle
            .getAttachedRenderParentRenderStyle()!
            .attachedRenderBoxModel! as RenderFlexLayout;
        // FlexItems with flex:none won't inherit parent box's constraints
        if (flexParent.isFlexNone(this)) {
          parentBoxContentConstraintsWidth = null;
        }

        // In a column-direction flex container, a flex item with auto cross-size (width)
        // that is not stretched in the cross axis should not inherit the container's
        // bounded width during its own constraint computation. Let it shrink-to-fit
        // its contents instead (so percentage paddings resolve against the item's
        // own width rather than the container width).
        final bool isColumn = !CSSFlex.isHorizontalFlexDirection(
            flexParent.renderStyle.flexDirection);
        if (isColumn) {
          // Determine if this flex item would be stretched in the cross axis.
          final AlignSelf self = renderStyle.alignSelf;
          final bool parentStretch =
              flexParent.renderStyle.alignItems == AlignItems.stretch;
          final bool shouldStretch = self == AlignSelf.auto
              ? parentStretch
              : self == AlignSelf.stretch;
          final bool crossAuto = renderStyle.width.isAuto;

          if (!shouldStretch && crossAuto) {
            // Do not adopt the parent's bounded width; use intrinsic sizing.
            parentBoxContentConstraintsWidth = null;
          }
        }
      }
      // For absolutely/fixed positioned elements inside a flex container, avoid collapsing
      // their intrinsic width to 0 solely because the flex item has a content constraint
      // width of 0 (e.g., auto-width flex item whose only child is out-of-flow).
      // In such cases, the containing block still exists, but the abspos box should size
      // from its own content rather than the flex item's zero content width.
      final bool isAbsOrFixed =
          renderStyle.position == CSSPositionType.absolute ||
              renderStyle.position == CSSPositionType.fixed;
      if (isAbsOrFixed &&
          renderStyle.width.isAuto &&
          renderStyle.isParentRenderFlexLayout() &&
          parentBoxContentConstraintsWidth != null &&
          parentBoxContentConstraintsWidth == 0) {
        parentBoxContentConstraintsWidth = null;
      }
    } else if (isDisplayInline && parent is RenderFlowLayout) {
      // For inline elements inside a flow layout, check if we should inherit parent's constraints
      RenderFlowLayout parentFlow = parent as RenderFlowLayout;

      // Skip constraint inheritance if parent is a flex item with flex: none (flex-grow: 0, flex-shrink: 0)
      if (parentFlow.renderStyle.isParentRenderFlexLayout()) {
        RenderFlexLayout flexParent = parentFlow.renderStyle
            .getAttachedRenderParentRenderStyle()!
            .attachedRenderBoxModel as RenderFlexLayout;
        if (flexParent.isFlexNone(parentFlow)) {
          // Don't inherit constraints for flex: none items
          parentBoxContentConstraintsWidth = null;
        } else {
          double parentContentWidth =
              parentFlow.renderStyle.contentMaxConstraintsWidth;
          if (parentContentWidth != double.infinity) {
            parentBoxContentConstraintsWidth = parentContentWidth;
          }
        }
      } else {
        // Not in a flex context, inherit parent's content width constraint normally
        double parentContentWidth =
            parentFlow.renderStyle.contentMaxConstraintsWidth;
        if (parentContentWidth != double.infinity) {
          parentBoxContentConstraintsWidth = parentContentWidth;
        }
      }
    }

    // CSS abspos width for non-replaced boxes with width:auto follows the
    // shrink-to-fit algorithm in CSS 2.1 §10.3.7 / CSS Position 3, except when
    // both left and right are non-auto (in which case width is solved directly
    // from the insets equation).
    //
    // Approximation: when width:auto and not (left & right both non-auto),
    // do not clamp the positioned box by the parent's content max-width.
    // Let the box measure to its intrinsic content width (subject to any
    // explicit min/max-width), which matches shrink-to-fit in the common
    // case where content width <= available width.
    final bool absOrFixedForWidth =
        renderStyle.position == CSSPositionType.absolute ||
            renderStyle.position == CSSPositionType.fixed;
    final bool widthAutoForAbs = renderStyle.width.isAuto;
    final bool bothLRNonAuto =
        renderStyle.left.isNotAuto && renderStyle.right.isNotAuto;
    if (absOrFixedForWidth &&
        !bothLRNonAuto &&
        widthAutoForAbs &&
        !renderStyle.isSelfRenderReplaced() &&
        renderStyle.borderBoxLogicalWidth == null &&
        parentBoxContentConstraintsWidth != null) {
      parentBoxContentConstraintsWidth = null;
    }

    double maxConstraintWidth = renderStyle.borderBoxLogicalWidth ??
        parentBoxContentConstraintsWidth ??
        double.infinity;

    // For absolutely/fixed positioned non-replaced elements with both left and right specified
    // and width:auto, compute the used border-box width from the containing block at layout time.
    // This handles cases where style-tree logical widths are unavailable (e.g., parent inline-block
    // with auto width) but the containing block has been measured. See:
    // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
    final bool isAbsOrFixed =
        renderStyle.position == CSSPositionType.absolute ||
            renderStyle.position == CSSPositionType.fixed;
    if (maxConstraintWidth == double.infinity &&
        isAbsOrFixed &&
        !renderStyle.isSelfRenderReplaced() &&
        renderStyle.width.isAuto &&
        renderStyle.left.isNotAuto &&
        renderStyle.right.isNotAuto &&
        parent is RenderBoxModel) {
      final RenderBoxModel cb = parent as RenderBoxModel;
      double? parentPaddingBoxWidth;
      // Use the parent's content constraints (plus padding) as the containing block width.
      // Avoid using parent.size or style-tree logical widths here to prevent feedback loops
      // in flex/inline-block shrink-to-fit scenarios.
      final BoxConstraints? pcc = cb.contentConstraints;
      if (pcc != null && pcc.maxWidth.isFinite) {
        parentPaddingBoxWidth = pcc.maxWidth +
            cb.renderStyle.paddingLeft.computedValue +
            cb.renderStyle.paddingRight.computedValue;
      }
      if (parentPaddingBoxWidth != null && parentPaddingBoxWidth.isFinite) {
        // Solve the horizontal insets equation for the child border-box width.
        double solvedBorderBoxWidth = parentPaddingBoxWidth -
            renderStyle.left.computedValue -
            renderStyle.right.computedValue -
            renderStyle.marginLeft.computedValue -
            renderStyle.marginRight.computedValue;
        // Guard against negative sizes.
        solvedBorderBoxWidth = math.max(0, solvedBorderBoxWidth);
        // Use a tight width so empty positioned boxes still fill the available space.
        minConstraintWidth = solvedBorderBoxWidth;
        maxConstraintWidth = solvedBorderBoxWidth;
      }
    }
    // Height should be not smaller than border and padding in vertical direction
    // when box-sizing is border-box which is only supported.
    double minConstraintHeight =
        renderStyle.effectiveBorderTopWidth.computedValue +
            renderStyle.effectiveBorderBottomWidth.computedValue +
            renderStyle.paddingTop.computedValue +
            renderStyle.paddingBottom.computedValue;
    double maxConstraintHeight =
        renderStyle.borderBoxLogicalHeight ?? double.infinity;

    // // Apply maxHeight constraint if specified
    // if (maxHeight != null && maxHeight < maxConstraintHeight) {
    //   maxConstraintHeight = maxHeight;
    // }

    if (parent is RenderFlexLayout) {
      double? flexBasis = renderStyle.flexBasis == CSSLengthValue.auto
          ? null
          : renderStyle.flexBasis?.computedValue;
      RenderBoxModel? parentRenderBoxModel = parent as RenderBoxModel?;
      // In flex layout, flex basis takes priority over width/height if set.
      // Flex-basis cannot be smaller than its content size which happens can not be known
      // in constraints apply stage, so flex-basis acts as min-width in constraints apply stage.
      if (flexBasis != null) {
        if (CSSFlex.isHorizontalFlexDirection(
            parentRenderBoxModel!.renderStyle.flexDirection)) {
          minWidth =
              minWidth != null ? math.max(flexBasis, minWidth) : flexBasis;
        } else {
          minHeight =
              minHeight != null ? math.max(flexBasis, minHeight) : flexBasis;
        }
      }
    }

    // Apply min/max width constraints for all display types
    if (minWidth != null && !isDisplayInline) {
      minConstraintWidth =
          minConstraintWidth < minWidth ? minWidth : minConstraintWidth;
      maxConstraintWidth =
          maxConstraintWidth < minWidth ? minWidth : maxConstraintWidth;
    }

    // Apply maxWidth constraint for all elements (including inline)
    if (maxWidth != null) {
      // Ensure maxConstraintWidth respects maxWidth, but don't reduce minConstraintWidth below border+padding
      maxConstraintWidth =
          maxConstraintWidth > maxWidth ? maxWidth : maxConstraintWidth;
      // Only reduce minConstraintWidth if maxWidth is larger than border+padding requirements
      double borderPadding =
          renderStyle.effectiveBorderLeftWidth.computedValue +
              renderStyle.effectiveBorderRightWidth.computedValue +
              renderStyle.paddingLeft.computedValue +
              renderStyle.paddingRight.computedValue;
      if (maxWidth >= borderPadding) {
        minConstraintWidth =
            minConstraintWidth > maxWidth ? maxWidth : minConstraintWidth;
      }
    }

    // Apply min/max height constraints when display is not inline
    if (!isDisplayInline) {
      if (minHeight != null) {
        minConstraintHeight =
            minConstraintHeight < minHeight ? minHeight : minConstraintHeight;
        maxConstraintHeight =
            maxConstraintHeight < minHeight ? minHeight : maxConstraintHeight;
      }
      if (maxHeight != null) {
        minConstraintHeight =
            minConstraintHeight > maxHeight ? maxHeight : minConstraintHeight;
        maxConstraintHeight =
            maxConstraintHeight > maxHeight ? maxHeight : maxConstraintHeight;
      }
    }

    // Normalize constraints to satisfy Flutter's requirement: min <= max.
    // This can happen when the computed minimum width from border/padding
    // exceeds the available max width from the parent (e.g., inline-block
    // with large horizontal padding inside a narrow container). In such
    // cases, cap the minimum to the maximum so constraints are valid.
    if (minConstraintWidth > maxConstraintWidth) {
      minConstraintWidth = maxConstraintWidth;
    }
    if (minConstraintHeight > maxConstraintHeight) {
      minConstraintHeight = maxConstraintHeight;
    }

    BoxConstraints constraints = BoxConstraints(
      minWidth: minConstraintWidth,
      maxWidth: maxConstraintWidth,
      minHeight: minConstraintHeight,
      maxHeight: maxConstraintHeight,
    );

    return constraints;
  }

  /// Set the size of scrollable overflow area of renderBoxModel
  void setMaxScrollableSize(Size contentSize) {
    // Scrollable area includes trailing (end) padding per axis.
    // When there is no child content, the scrollable overflow region should
    // extend to include end-side padding so that the container can scroll
    // enough for its padded edge to be reachable. Using the leading padding
    // here (left/top) was incorrect and could overestimate the visible start
    // and leave extra space at the bottom/right.
    scrollableSize = Size(
      contentSize.width + renderStyle.paddingRight.computedValue,
      contentSize.height + renderStyle.paddingBottom.computedValue,
    );
  }

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size? _boxSize;

  Size? get boxSize {
    assert(_boxSize != null, 'box does not have laid out.');
    return _boxSize;
  }

  @override
  set size(Size value) {
    _boxSize = value;

    Size? previousSize = hasSize ? super.size : null;
    if (previousSize != null && previousSize != value) {
      isSelfSizeChanged = true;
    }

    super.size = value;
  }

  Size getBoxSize(Size contentSize) {
    _contentSize = contentConstraints!.constrain(contentSize);
    Size paddingBoxSize = renderStyle.wrapPaddingSize(_contentSize!);
    Size borderBoxSize = renderStyle.wrapBorderSize(paddingBoxSize);
    return constraints.constrain(borderBoxSize);
  }

  Size wrapOutContentSizeRight(Size contentSize) {
    Size paddingBoxSize = renderStyle.wrapPaddingSizeRight(contentSize);
    return renderStyle.wrapBorderSizeRight(paddingBoxSize);
  }

  Size wrapOutContentSize(Size contentSize) {
    Size paddingBoxSize = renderStyle.wrapPaddingSize(contentSize);
    return renderStyle.wrapBorderSize(paddingBoxSize);
  }

  // The contentSize of layout box
  Size? _contentSize;

  Size get contentSize {
    return _contentSize ?? Size.zero;
  }

  double get clientWidth {
    double width = contentSize.width;
    width += renderStyle.padding.horizontal;
    return width;
  }

  double get clientHeight {
    double height = contentSize.height;
    height += renderStyle.padding.vertical;
    return height;
  }

  // Base layout methods to compute content constraints before content box layout.
  // Call this method before content box layout.
  void beforeLayout() {
    BoxConstraints contentConstraints = (parent is RenderEventListener
            ? (parent as RenderEventListener).parent
            : parent) is RenderBoxModel
        ? constraints
        : getConstraints();

    // Deflate border constraints.
    contentConstraints =
        renderStyle.deflateBorderConstraints(contentConstraints);
    // Deflate padding constraints.
    contentConstraints =
        renderStyle.deflatePaddingConstraints(contentConstraints);

    // Fix for text-overflow ellipsis: when content constraints become unbounded
    // but the original constraints were bounded, and the element needs ellipsis,
    // restore bounded width to allow proper text truncation.
    if (renderStyle.effectiveOverflowX != CSSOverflowType.visible &&
        renderStyle.effectiveTextOverflow == TextOverflow.ellipsis &&
        contentConstraints.maxWidth.isInfinite &&
        constraints.hasBoundedWidth) {
      // Recalculate the content constraints using the original bounded constraints
      BoxConstraints boundedConstraints =
          renderStyle.deflateBorderConstraints(constraints);
      boundedConstraints =
          renderStyle.deflatePaddingConstraints(boundedConstraints);

      contentConstraints = BoxConstraints(
        minWidth: contentConstraints.minWidth,
        maxWidth: boundedConstraints.maxWidth,
        minHeight: contentConstraints.minHeight,
        maxHeight: contentConstraints.maxHeight,
      );
    }

    this.contentConstraints = contentConstraints;
    clearOverflowLayout();
    isSelfSizeChanged = false;

    // Reset cached CSS baselines before a new layout pass. They will be
    // updated by subclasses that can establish inline formatting context
    // or have well-defined CSS baselines (e.g., replaced elements).
    _cssFirstBaseline = null;
    _cssLastBaseline = null;
  }

  /// Find scroll container
  RenderBoxModel? findScrollContainer() {
    RenderBoxModel? scrollContainer;
    RenderObject? parent = this.parent;

    while (parent != null) {
      if (parent is RenderLayoutBox &&
          (parent.renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
              parent.renderStyle.effectiveOverflowY !=
                  CSSOverflowType.visible)) {
        // Scroll container should has definite constraints
        scrollContainer = parent;
        break;
      }
      if (parent is RenderWidget &&
          (parent.renderStyle.target as WidgetElement).isScrollingElement) {
        scrollContainer = parent;
        break;
      }
      parent = parent.parent;
    }
    return scrollContainer;
  }

  /// Finds the nearest [RenderWidgetElementChild] ancestor in the render tree.
  ///
  /// This method traverses up the render tree looking for a [RenderWidgetElementChild]
  /// which is used to pass Flutter widget constraints to WebF HTML elements.
  ///
  /// The search stops when it either:
  /// - Finds a [RenderWidgetElementChild] and returns it
  /// - Encounters a [RenderWidget] (indicating no [WebFWidgetElementChild] was used in the build method)
  /// - Reaches the root of the render tree
  ///
  /// Returns null if no [RenderWidgetElementChild] is found in the ancestor chain.
  ///
  /// This is used to access parent constraints for layout calculations, allowing HTML elements
  /// to be aware of their Flutter widget container constraints for proper sizing and layout.
  RenderWidgetElementChild? findWidgetElementChild() {
    RenderObject? parent = this.parent;
    while (parent != null) {
      if (parent is RenderWidgetElementChild) {
        return parent;
      }
      // There were no WebFWidgetElementChild in the build() of WebFWidgetElementState
      if (parent is RenderWidget) {
        return null;
      }
      parent = parent.parent;
    }
    return null;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    super.applyPaintTransform(child, transform);
    applyOverflowPaintTransform(child, transform);
    applyEffectiveTransform(child, transform);
  }

  // Forked from RenderBox.applyPaintTransform, add scroll offset exclude logic.
  void applyLayoutTransform(
      RenderObject child, Matrix4 transform, bool excludeScrollOffset) {
    assert(child.parent == this);
    assert(child.parentData is BoxParentData);
    final BoxParentData childParentData = child.parentData! as BoxParentData;
    Offset offset = childParentData.offset;
    if (excludeScrollOffset) {
      offset -= Offset(scrollLeft, scrollTop);
    }
    transform.translate(offset.dx, offset.dy);
  }

  Offset obtainLayoutTransform(RenderObject child, bool excludeScrollOffset) {
    assert(child.parent == this);
    assert(child.parentData is BoxParentData);
    final BoxParentData childParentData = child.parentData! as BoxParentData;
    Offset offset = childParentData.offset;
    if (!excludeScrollOffset) {
      if (this is RenderWidget) {
        offset -=
            Offset(renderStyle.target.scrollLeft, renderStyle.target.scrollTop);
      } else {
        offset -= Offset(scrollLeft, scrollTop);
      }
    }
    return offset;
  }

  // The max scrollable size.
  Size _maxScrollableSize = Size.zero;

  Size get scrollableSize => _maxScrollableSize;

  set scrollableSize(Size value) {
    assert(value.isFinite);
    _maxScrollableSize = value;
  }

  Size scrollableViewportSize = Size.zero;

  /// Extend max scrollable size of renderBoxModel by offset of positioned child,
  /// get the max scrollable size of children of normal flow and single positioned child.
  void extendMaxScrollableSize(RenderBoxModel child) {
    Size? childScrollableSize;
    RenderStyle childRenderStyle = child.renderStyle;
    CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
    CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;
    // Only non scroll container need to use scrollable size, otherwise use its own size
    if (overflowX == CSSOverflowType.visible &&
        overflowY == CSSOverflowType.visible) {
      childScrollableSize = child.scrollableSize;
    } else {
      childScrollableSize = child.boxSize;
    }

    Matrix4? transform = (childRenderStyle as CSSRenderStyle).transformMatrix;

    // Determine container content box size for positioned computations.
    double containerContentWidth = _contentSize!.width;
    double containerContentHeight = _contentSize!.height;
    if (parent is RenderBoxModel) {
      final RenderBoxModel p = parent as RenderBoxModel;
      if (p.widthSizeType == BoxSizeType.specified) {
        containerContentWidth = p.renderStyle.width.computedValue -
            p.renderStyle.effectiveBorderLeftWidth.computedValue -
            p.renderStyle.effectiveBorderRightWidth.computedValue;
      }
      if (p.heightSizeType == BoxSizeType.specified) {
        containerContentHeight = p.renderStyle.height.computedValue -
            p.renderStyle.effectiveBorderTopWidth.computedValue -
            p.renderStyle.effectiveBorderBottomWidth.computedValue;
      }
    }

    // Compute positioned box edges relative to the content (padding) box origin.
    final Size childSize = childScrollableSize!;
    double childLeft;
    if (childRenderStyle.left.isNotAuto) {
      childLeft = childRenderStyle.left.computedValue;
    } else if (childRenderStyle.right.isNotAuto) {
      childLeft = containerContentWidth -
          childSize.width -
          childRenderStyle.right.computedValue;
    } else {
      childLeft = 0;
    }
    double childTop;
    if (childRenderStyle.top.isNotAuto) {
      childTop = childRenderStyle.top.computedValue;
    } else if (childRenderStyle.bottom.isNotAuto) {
      childTop = containerContentHeight -
          childSize.height -
          childRenderStyle.bottom.computedValue;
    } else {
      childTop = 0;
    }

    if (transform != null) {
      childLeft += transform.getTranslation()[0];
      childTop += transform.getTranslation()[1];
    }

    final double childRight = childLeft + childSize.width;
    final double childBottom = childTop + childSize.height;

    // Extend scroll area when the positioned box reaches or crosses the
    // scrollport (padding box) boundary.
    // For LTR, treat boxes that start exactly at the trailing edge as contributing
    // (<=) so users can scroll to reveal them. For RTL, keep strict (<) to avoid
    // shifting initial visual alignment for cases like right:-N content.
    final bool parentIsRTL = renderStyle.direction == TextDirection.rtl;
    final bool intersectsH = childRight > 0 &&
        (parentIsRTL
            ? (childLeft < containerContentWidth)
            : (childLeft <= containerContentWidth));
    final bool intersectsV =
        childBottom > 0 && childTop <= containerContentHeight;

    double maxScrollableX = scrollableSize.width;
    double maxScrollableY = scrollableSize.height;

    if (intersectsH) {
      maxScrollableX =
          math.max(maxScrollableX, math.max(containerContentWidth, childRight));
    }
    // Only extend vertical scroll when the positioned box also intersects (or
    // reaches) the scrollport horizontally. Purely off-axis content should not
    // create scroll in the other axis.
    if (intersectsV && intersectsH) {
      maxScrollableY = math.max(
          maxScrollableY, math.max(containerContentHeight, childBottom));
    }

    scrollableSize = Size(maxScrollableX, maxScrollableY);
  }

  // iterate add child to overflowLayout
  void addOverflowLayoutFromChildren(List<RenderBox> children) {
    for (var child in children) {
      addOverflowLayoutFromChild(child);
    }
  }

  void addOverflowLayoutFromChild(RenderBox child) {
    final RenderLayoutParentData childParentData =
        child.parentData as RenderLayoutParentData;
    if (!child.hasSize ||
        (child is! RenderBoxModel && child is! RenderReplaced)) {
      return;
    }
    // Out-of-flow positioned descendants (absolute/fixed) do not expand the
    // scrollable overflow area of a scroll container per CSS overflow/positioning
    // expectations. They are clipped to the padding edge and scrolled as a part
    // of the content, but must not affect the scroll range calculation.
    final RenderBoxModel self = this;
    final bool isScrollContainer =
        self.renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
            self.renderStyle.effectiveOverflowY != CSSOverflowType.visible;
    if (isScrollContainer &&
        child is RenderBoxModel &&
        child.renderStyle.isSelfPositioned()) {
      return;
    }

    CSSRenderStyle style = (child as RenderBoxModel).renderStyle;
    Rect overflowRect = Rect.fromLTWH(childParentData.offset.dx,
        childParentData.offset.dy, child.boxSize!.width, child.boxSize!.height);

    if (style.effectiveTransformOffset != null) {
      overflowRect = overflowRect.shift(style.effectiveTransformOffset!);
    }
    // child overflowLayout effect parent overflowLayout when child effectiveOverflow is visible or auto
    if (child.renderStyle.effectiveOverflowX == CSSOverflowType.visible ||
        child.renderStyle.effectiveOverflowX == CSSOverflowType.auto ||
        child.renderStyle.effectiveOverflowY == CSSOverflowType.auto ||
        child.renderStyle.effectiveOverflowY == CSSOverflowType.visible) {
      Rect childOverflowLayoutRect = child.overflowRect!.shift(Offset.zero);

      // child overflowLayout rect need transform for parent`s cartesian coordinates
      final Matrix4 transform = Matrix4.identity();
      applyLayoutTransform(child, transform, false);
      Offset tlOffset = MatrixUtils.transformPoint(transform,
          Offset(childOverflowLayoutRect.left, childOverflowLayoutRect.top));
      overflowRect = Rect.fromLTRB(
          math.min(overflowRect.left, tlOffset.dx),
          math.min(overflowRect.top, tlOffset.dy),
          math.max(
              overflowRect.right, tlOffset.dx + childOverflowLayoutRect.width),
          math.max(overflowRect.bottom,
              tlOffset.dy + childOverflowLayoutRect.height));
    }

    addLayoutOverflow(overflowRect);
  }

  // Hooks when content box had layout.
  void didLayout() {
    scrollableViewportSize = constraints.constrain(Size(
        _contentSize!.width +
            renderStyle.paddingLeft.computedValue +
            renderStyle.paddingRight.computedValue,
        _contentSize!.height +
            renderStyle.paddingTop.computedValue +
            renderStyle.paddingBottom.computedValue));

    setUpOverflowScroller(scrollableSize, scrollableViewportSize);

    if (positionedHolder != null &&
        renderStyle.position != CSSPositionType.sticky) {
      // Make position holder preferred size equal to current element boundary size except sticky element.
      positionedHolder!.preferredSize = Size.copy(size);
    }

    dispatchResize(contentSize, boxSize ?? Size.zero);

    if (isSelfSizeChanged) {
      renderStyle.markTransformMatrixNeedsUpdate();
      // Rebuild box decoration when size changes so percentage-based border-radius
      // (and other size-dependent decoration fields) recompute with the new box size.
      renderStyle.resetBoxDecoration();
    }
  }

  /// [RenderLayoutBox] real paint things after basiclly paint box model.
  /// Override which to paint layout or intrinsic things.
  /// Used by [RenderReplaced], [RenderFlowLayout], [RenderFlexLayout].
  void performPaint(PaintingContext context, Offset offset) {
    throw FlutterError('Please impl performPaint of $runtimeType.');
  }

  bool get shouldPaint => !renderStyle.isVisibilityHidden;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!shouldPaint) {
      return;
    }

    // Paint layout error message if there was an exception during layout
    if (layoutExceptions != null) {
      _paintLayoutError(context, offset);
      return;
    }

    paintBoxModel(context, offset);
  }

  String? layoutExceptions;

  void reportException(String method, Object exception, StackTrace stack) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: exception,
      stack: stack,
      library: 'rendering library',
      context: ErrorDescription('during $method()'),
      informationCollector: () => <DiagnosticsNode>[
        // debugCreator should always be null outside of debugMode, but we want
        // the tree shaker to notice this.
        if (kDebugMode && debugCreator != null)
          DiagnosticsDebugCreator(debugCreator!),
        describeForError(
            'The following RenderObject was being processed when the exception was fired'),
        // TODO(jacobr): this error message has a code smell. Consider whether
        // displaying the truncated children is really useful for command line
        // users. Inspector users can see the full tree by clicking on the
        // render object so this may not be that useful.
        describeForError('RenderObject',
            style: DiagnosticsTreeStyle.truncateChildren),
      ],
    ));
  }

  // Paint error message when layout throws an exception
  void _paintLayoutError(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    // Determine the maximum area we can use to display the error.
    // Prefer the viewport size; fall back to our current size.
    final Size viewportSize =
        renderStyle.target.ownerView.currentViewport?.boxSize ?? size;

    // Expand within the visible viewport starting from our own paint origin.
    final double maxPaintWidth = math.max(0, viewportSize.width - offset.dx);
    final double maxPaintHeight = math.max(0, viewportSize.height - offset.dy);

    // Prepare error text
    final String errorSummary =
        layoutExceptions!.split('\n').take(3).join('\n');
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: 'LAYOUT ERROR\n$errorSummary',
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    // Layout text with expanded width budget
    const double kPadding = 10.0;
    final double textMaxWidth = math.max(0, maxPaintWidth - kPadding * 2);
    textPainter.layout(maxWidth: textMaxWidth);

    // Compute background height to fit text, clamp to viewport height
    final double bgHeight =
        math.min(maxPaintHeight, textPainter.height + kPadding * 2);

    // Draw a red translucent background spanning the expanded area
    final Paint errorPaint = Paint()
      ..color = const Color(0xFFFF0000).withAlpha((0.7 * 255).round());
    final Rect bgRect =
        Rect.fromLTWH(offset.dx, offset.dy, maxPaintWidth, bgHeight);
    canvas.drawRect(bgRect, errorPaint);

    // Paint error text with padding
    textPainter.paint(canvas, offset + const Offset(kPadding, kPadding));
  }

  void debugPaintOverlay(PaintingContext context, Offset offset) {
    Rect overlayRect =
        Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    context.addLayer(InspectorOverlayLayer(
      overlayRect: overlayRect,
    ));
  }

  // Repaint native EngineLayer sources with LayerHandle.
  final LayerHandle<ColorFilterLayer> _colorFilterLayer =
      LayerHandle<ColorFilterLayer>();

  void paintColorFilter(PaintingContext context, Offset offset,
      PaintingContextCallback callback) {
    ColorFilter? colorFilter = renderStyle.colorFilter;
    if (colorFilter != null) {
      _colorFilterLayer.layer = context.pushColorFilter(
          offset, colorFilter, callback,
          oldLayer: _colorFilterLayer.layer);
    } else {
      callback(context, offset);
    }
  }

  void paintNothing(PaintingContext context, Offset offset) {}

  void paintBoxModel(PaintingContext context, Offset offset) {
    // If opacity to zero, only paint intersection observer.
    if (alpha == 0) {
      paintIntersectionObserver(context, offset, paintNothing);
    } else {
      // Apply additional paint offsets:
      // - `position: fixed`: scroll-compensation based on the effective containing block.
      // - `position: sticky`: sticky delta computed by positioned layout.
      // - others: any runtime paint adjustments.
      final Offset add = renderStyle.position == CSSPositionType.fixed
          ? getFixedScrollCompensation()
          : Offset(additionalPaintOffsetX ?? 0.0, additionalPaintOffsetY ?? 0.0);
      if (add.dx != 0.0 || add.dy != 0.0) {
        offset = offset.translate(add.dx, add.dy);
      }
      _paintFilteredContent(context, offset);
    }
  }

  void _paintFilteredContent(PaintingContext context, Offset offset,
      {bool skipDropShadow = false}) {
    final bool previous = _paintingFilterContent;
    if (skipDropShadow) {
      _paintingFilterContent = true;
    }
    paintColorFilter(context, offset, _chainPaintImageFilter);
    if (skipDropShadow) {
      _paintingFilterContent = previous;
    }
  }

  final LayerHandle<ImageFilterLayer> _imageFilterLayer =
      LayerHandle<ImageFilterLayer>();
  bool _paintingFilterContent = false;

  void paintImageFilter(PaintingContext context, Offset offset,
      PaintingContextCallback callback) {
    if (renderStyle.imageFilter != null) {
      _imageFilterLayer.layer ??= ImageFilterLayer();
      _imageFilterLayer.layer!.imageFilter = renderStyle.imageFilter;
      context.pushLayer(_imageFilterLayer.layer!, callback, offset);
    } else {
      callback(context, offset);
    }
  }

  void _chainPaintImageFilter(PaintingContext context, Offset offset) {
    paintImageFilter(context, offset, _chainPaintFilterDropShadow);
  }

  void _chainPaintFilterDropShadow(PaintingContext context, Offset offset) {
    if (_paintingFilterContent) {
      _chainPaintIntersectionObserver(context, offset);
      return;
    }

    final List<CSSBoxShadow>? dropShadows = renderStyle.filterDropShadows;
    if (dropShadows == null || dropShadows.isEmpty) {
      _chainPaintIntersectionObserver(context, offset);
      return;
    }

    for (final CSSBoxShadow shadow in dropShadows) {
      _paintFilterDropShadow(context, offset, shadow);
    }

    _chainPaintIntersectionObserver(context, offset);
  }

  void _paintFilterDropShadow(
      PaintingContext context, Offset offset, CSSBoxShadow shadow) {
    final double dx = shadow.offsetX?.computedValue ?? 0.0;
    final double dy = shadow.offsetY?.computedValue ?? 0.0;
    final double blurRadius = shadow.blurRadius?.computedValue ?? 0.0;
    final double sigma = blurRadius > 0 ? blurRadius : 0.0;
    final Color color = shadow.color ?? const Color(0xFF000000);

    // spread radius currently ignored

    final Offset shadowOffset = offset + Offset(dx, dy);

    void drawContent(PaintingContext innerContext, Offset innerOffset) {
      _paintFilteredContent(innerContext, innerOffset, skipDropShadow: true);
    }

    final ColorFilterLayer tintLayer = ColorFilterLayer(
      colorFilter: ColorFilter.matrix(_createDropShadowColorMatrix(color)),
    );

    context.pushLayer(tintLayer, (colorContext, colorLayerOffset) {
      if (sigma > 0) {
        final ImageFilterLayer blurLayer = ImageFilterLayer()
          ..imageFilter = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
        colorContext.pushLayer(blurLayer, drawContent, colorLayerOffset);
      } else {
        drawContent(colorContext, colorLayerOffset);
      }
    }, shadowOffset);
  }

  List<double> _createDropShadowColorMatrix(Color color) {
    final double r = color.r;
    final double g = color.g;
    final double b = color.b;
    final double a = color.a;
    return <double>[
      0,
      0,
      0,
      r,
      0,
      0,
      0,
      0,
      g,
      0,
      0,
      0,
      0,
      b,
      0,
      0,
      0,
      0,
      a,
      0,
    ];
  }

  void _chainPaintIntersectionObserver(PaintingContext context, Offset offset) {
    paintIntersectionObserver(context, offset, _chainPaintTransform);
  }

  void _chainPaintTransform(PaintingContext context, Offset offset) {
    paintTransform(context, offset, _chainPaintOpacity);
  }

  void _chainPaintOpacity(PaintingContext context, Offset offset) {
    paintOpacity(context, offset, _chainPaintDecoration);
  }

  void _chainPaintDecoration(PaintingContext context, Offset offset) {
    paintDecoration(context, offset, _chainPaintOverflow);
  }

  void _chainPaintOverflow(PaintingContext context, Offset offset) {
    EdgeInsets borderEdge = EdgeInsets.fromLTRB(
        renderStyle.effectiveBorderLeftWidth.computedValue,
        renderStyle.effectiveBorderTopWidth.computedValue,
        renderStyle.effectiveBorderRightWidth.computedValue,
        renderStyle.effectiveBorderBottomWidth.computedValue);
    CSSBoxDecoration? decoration = renderStyle.decoration;

    bool hasLocalAttachment = _hasLocalBackgroundImage(renderStyle);
    if (hasLocalAttachment) {
      paintOverflow(
          context, offset, borderEdge, decoration, _chainPaintBackground);
    } else {
      paintOverflow(context, offset, borderEdge, decoration,
          _chainPaintContentVisibility);
    }
  }

  void _chainPaintBackground(PaintingContext context, Offset offset) {
    EdgeInsets resolvedPadding = renderStyle.padding.resolve(TextDirection.ltr);
    paintBackground(context, offset, resolvedPadding);
    _chainPaintContentVisibility(context, offset);
  }

  void _chainPaintContentVisibility(PaintingContext context, Offset offset) {
    paintContentVisibility(context, offset, _chainPaintOverlay);
  }

  void _chainPaintOverlay(PaintingContext context, Offset offset) {
    performPaint(context, offset);

    if (_debugShouldPaintOverlay) {
      debugPaintOverlay(context, offset);
    }
  }

  // Get the layout offset of renderObject to its ancestor which does not include the paint offset
  // such as scroll or transform.getLayoutTransformTo
  Offset getOffsetToAncestor(Offset point, RenderBoxModel ancestor,
      {bool excludeScrollOffset = false,
      bool excludeAncestorBorderTop = true}) {
    Offset ancestorBorderWidth = Offset.zero;
    if (excludeAncestorBorderTop) {
      double ancestorBorderTop =
          ancestor.renderStyle.borderTopWidth?.computedValue ?? 0;
      double ancestorBorderLeft =
          ancestor.renderStyle.borderLeftWidth?.computedValue ?? 0;
      ancestorBorderWidth = Offset(ancestorBorderLeft, ancestorBorderTop);
    }

    return getLayoutTransformTo(this, ancestor,
            excludeScrollOffset: excludeScrollOffset) +
        point -
        ancestorBorderWidth;
  }

  bool _hasLocalBackgroundImage(CSSRenderStyle renderStyle) {
    if (renderStyle.backgroundImage == null) return false;
    // Prefer checking raw comma-separated list so that any layer with 'local'
    // opts this element into the overflow painting path that scrolls backgrounds
    // with content. Falls back to single computed value when raw is absent.
    final String raw =
        renderStyle.target.style.getPropertyValue(BACKGROUND_ATTACHMENT);
    if (raw.isEmpty) {
      return renderStyle.backgroundAttachment ==
          CSSBackgroundAttachmentType.local;
    }
    for (final t in raw.split(',')) {
      if (CSSBackground.resolveBackgroundAttachment(t.trim()) ==
          CSSBackgroundAttachmentType.local) {
        return true;
      }
    }
    return false;
  }

  bool _disposed = false;

  bool get disposed => _disposed;

  /// Called when its corresponding element disposed
  @override
  @mustCallSuper
  void dispose() {
    _disposed = true;
    super.dispose();

    // Dispose scroll behavior
    disposeScrollable();

    // Clear all paint layers
    _colorFilterLayer.layer = null;
    _imageFilterLayer.layer = null;
    disposeTransformLayer();
    disposeOpacityLayer();
    disposeIntersectionObserverLayer();

    // Dispose box decoration painter.
    disposePainter();
    // Evict render decoration image cache.
    renderStyle.backgroundImage?.image?.evict();

    // no-op: no positioned children cache
  }

  Offset getTotalScrollOffset() {
    double top = scrollTop;
    double left = scrollLeft;
    RenderObject? parentNode = parent;
    while (parentNode != null) {
      if (parentNode is RenderBoxModel) {
        top += parentNode.scrollTop;
        left += parentNode.scrollLeft;
      }
      parentNode = parentNode.parent;
    }
    return Offset(left, top);
  }

  // Computes the scroll-compensation offset for a `position: fixed` element.
  //
  // - For viewport-fixed elements, compensate all ancestor scroll offsets so the box
  //   stays anchored to the visual viewport.
  // - For fixed elements with a non-viewport containing block (e.g. due to `transform`
  //   or `filter`), compensate only the containing block's own scroll offsets so the
  //   box stays anchored within that containing block.
  Offset getFixedScrollCompensation() {
    if (renderStyle.position != CSSPositionType.fixed) return Offset.zero;

    if (isFixedToViewport) {
      return getTotalScrollOffset();
    }

    final cbElement = renderStyle.target.holderAttachedContainingBlockElement;
    final cbRenderer = cbElement?.attachedRenderer;
    if (cbRenderer is RenderBoxModel) {
      return Offset(cbRenderer.scrollLeft, cbRenderer.scrollTop);
    }
    return Offset.zero;
  }

  // Whether this fixed-position box is fixed to the viewport (initial containing block).
  //
  // Per CSS Position, `position: fixed` uses the viewport unless an ancestor establishes
  // a fixed-position containing block (e.g. via `transform`, `filter`, etc.).
  // When not fixed to the viewport, fixed-position behaves more like abspos relative
  // to that ancestor, and should not receive scroll-compensation.
  bool get isFixedToViewport {
    if (renderStyle.position != CSSPositionType.fixed) return false;
    final target = renderStyle.target;
    final viewportElement = target.ownerDocument.documentElement;
    final cb = target.holderAttachedContainingBlockElement;
    // Default to viewport behavior if we haven't attached a containing block yet.
    return cb == null || identical(cb, viewportElement);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hasSize ||
        !contentVisibilityHitTest(result, position: position) ||
        renderStyle.isVisibilityHidden) {
      return false;
    }

    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                'Cannot hit test a render box that has never been laid out.'),
            describeForError(
                'The hitTest() method was called on this RenderBox'),
            ErrorDescription(
                "Unfortunately, this object's geometry is not known at this time, "
                'probably because it has never been laid out. '
                'This means it cannot be accurately hit-tested.'),
            ErrorHint('If you are trying '
                'to perform a hit test during the layout phase itself, make sure '
                "you only hit test nodes that have completed layout (e.g. the node's "
                'children, after their layout() method has been called).'),
          ]);
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot hit test a render box with no size.'),
          describeForError('The hitTest() method was called on this RenderBox'),
          ErrorDescription(
              'Although this node is not marked as needing layout, '
              'its size is not set.'),
          ErrorHint('A RenderBox object must have an '
              'explicit size before it can be hit-tested. Make sure '
              'that the RenderBox in question sets its size during layout.'),
        ]);
      }
      return true;
    }());

    bool isHit = result.addWithPaintTransform(
      transform: renderStyle.effectiveTransformMatrix,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformPosition) {
        // Apply the same paint scroll offset used during painting so hit testing aligns in RTL/LTR.
        final Offset scrollPaintOffset = paintScrollOffset;
        return result.addWithPaintOffset(
            offset: (scrollPaintOffset.dx != 0.0 || scrollPaintOffset.dy != 0.0)
                ? scrollPaintOffset
                : null,
            position: transformPosition,
            hitTest: (BoxHitTestResult result, Offset position) {
              // CSSPositionType positionType = renderStyle.position;
              // if (positionType == CSSPositionType.fixed) {
              //   Offset totalScrollOffset = getTotalScrollOffset();
              //   position -= totalScrollOffset;
              //   transformPosition -= totalScrollOffset;
              // }

              // Determine whether the hittest position is within the visible area of the node in scroll.
              if ((clipX || clipY) && !size.contains(transformPosition)) {
                return false;
              }

              // addWithPaintOffset is to add an offset to the child node, the calculation itself does not need to bring an offset.
              if (hasSize && hitTestChildren(result, position: position) ||
                  hitTestSelf(transformPosition)) {
                result.add(BoxHitTestEntry(this, position));
                return true;
              }
              return false;
            });
      },
    );

    return isHit;
  }

  /// Calculates the visible area of this element within the viewport.
  /// Returns the area in pixels that is visible, or 0 if the element is not visible.
  double calculateVisibleArea() {
    if (!hasSize || !attached) return 0;

    // Get the viewport using the element's getRootViewport method
    RenderViewportBox? viewport = renderStyle.target.getRootViewport();
    if (viewport == null || !viewport.hasSize) return 0;

    // Get the element's position relative to viewport
    Offset elementOffset = localToGlobal(Offset.zero, ancestor: viewport);

    // Get element and viewport bounds
    Rect elementBounds = elementOffset & size;
    Rect viewportBounds = Offset.zero & viewport.size;

    // Calculate intersection
    Rect? intersection = elementBounds.intersect(viewportBounds);
    if (intersection.width <= 0 || intersection.height <= 0) return 0;

    return intersection.width * intersection.height;
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  Future<Image> toImage({double pixelRatio = 1.0}) {
    assert(layer != null);
    assert(isRepaintBoundary);
    final OffsetLayer offsetLayer = layer as OffsetLayer;
    return offsetLayer.toImage(Offset.zero & size, pixelRatio: pixelRatio);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    if (scrollablePointerListener != null) {
      scrollablePointerListener!(event);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(renderStyle.toDiagnosticsNode(name: 'renderStyle'));
    properties.add(DiagnosticsProperty('creatorElement', renderStyle.target));
    properties.add(DiagnosticsProperty('contentSize', _contentSize));
    properties.add(DiagnosticsProperty('contentConstraints', contentConstraints,
        missingIfNull: true));
    properties.add(DiagnosticsProperty('maxScrollableSize', scrollableSize,
        missingIfNull: true));
    properties.add(DiagnosticsProperty(
        'scrollableViewportSize', scrollableViewportSize,
        missingIfNull: true));
    properties.add(DiagnosticsProperty('isSizeTight', isSizeTight));
    properties.add(DiagnosticsProperty('additionalPaintOffset',
        Offset(additionalPaintOffsetX ?? 0.0, additionalPaintOffsetY ?? 0.0)));
    if (renderPositionPlaceholder != null) {
      properties.add(DiagnosticsProperty(
          'renderPositionHolder', renderPositionPlaceholder));
    }
    debugOverflowProperties(properties);
    debugOpacityProperties(properties);
  }
}
