/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:path/path.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart';

import 'box_overflow.dart';
import 'debug_overlay.dart';

// The hashCode of all the renderBox which is in layout.
List<int> renderBoxInLayoutHashCodes = [];

class RenderLayoutParentData extends ContainerBoxParentData<RenderBox> {
  // Row index of child when wrapping
  int runIndex = 0;

  @override
  String toString() {
    return '${super.toString()}; runIndex: $runIndex;';
  }
}

// Applies the layout transform up the tree to `ancestor`.
//
// Return getLayoutTransformTolocal layout coordinate system to the
// coordinate system of `ancestor`.
Offset getLayoutTransformTo(RenderObject current, RenderObject ancestor, {bool excludeScrollOffset = false}) {
  final List<RenderObject> renderers = <RenderObject>[];
  for (RenderObject renderer = current; renderer != ancestor; renderer = renderer.parent!) {
    renderers.add(renderer);
    assert(renderer.parent != null);
  }
  renderers.add(ancestor);
  List<Offset> stackOffsets = [];
  final Matrix4 transform = Matrix4.identity();

  for (int index = renderers.length - 1; index > 0; index -= 1) {
    RenderObject parentRenderer = renderers[index];
    RenderObject childRenderer = renderers[index - 1];
    // Apply the layout transform for renderBoxModel and fallback to paint transform for other renderObject type.
    if (parentRenderer is RenderBoxModel) {
      // If the next renderBox has a fixed position,
      // the outside scroll offset won't affect the actual results because of its fixed positioning.
      if (childRenderer is RenderBoxModel && childRenderer.renderStyle.position == CSSPositionType.fixed) {
        stackOffsets.clear();
      }

      stackOffsets.add(parentRenderer.obtainLayoutTransform(childRenderer, excludeScrollOffset));
    } else if (childRenderer is RenderIndexedSemantics && childRenderer.parentData is SliverMultiBoxAdaptorParentData) {
      assert(childRenderer.parent == parentRenderer);

      Axis scrollDirection = Axis.vertical;

      if (ancestor is RenderWidget && ancestor.renderStyle.target is WebFListViewElement) {
        scrollDirection = (ancestor.renderStyle.target as WebFListViewElement).scrollDirection;
      }

      double layoutOffset = (childRenderer.parentData as SliverMultiBoxAdaptorParentData).layoutOffset ?? 0.0;
      Offset sliverScrollOffset = scrollDirection == Axis.vertical ? Offset(0, layoutOffset) : Offset(layoutOffset, 0);

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

/// Modified from Flutter rendering/box.dart.
/// A mixin that provides useful default behaviors for boxes with children
/// managed by the [ContainerRenderObjectMixin] mixin.
///
/// By convention, this class doesn't override any members of the superclass.
/// Instead, it provides helpful functions that subclasses can call as
/// appropriate.
mixin RenderBoxContainerDefaultsMixin<ChildType extends RenderBox,
        ParentDataType extends ContainerBoxParentData<ChildType>>
    implements ContainerRenderObjectMixin<ChildType, ParentDataType> {
  /// Returns the baseline of the first child with a baseline.
  ///
  /// Useful when the children are displayed vertically in the same order they
  /// appear in the child list.
  double? defaultComputeDistanceToFirstActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType? childParentData = child.parentData as ParentDataType?;
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      final double? result = child.getDistanceToActualBaseline(baseline);
      if (result != null) return result + childParentData!.offset.dy;
      child = childParentData!.nextSibling;
    }
    return null;
  }

  /// Returns the minimum baseline value among every child.
  ///
  /// Useful when the vertical position of the children isn't determined by the
  /// order in the child list.
  double? defaultComputeDistanceToHighestActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    double? result;
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType childParentData = child.parentData as ParentDataType;
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      double? candidate = child.getDistanceToActualBaseline(baseline);
      if (candidate != null) {
        candidate += childParentData.offset.dy;
        if (result != null)
          result = math.min(result, candidate);
        else
          result = candidate;
      }
      child = childParentData.nextSibling;
    }
    return result;
  }

  /// Performs a hit test on each child by walking the child list backwards.
  ///
  /// Stops walking once after the first child reports that it contains the
  /// given point. Returns whether any children contain the given point.
  ///
  /// See also:
  ///
  ///  * [defaultPaint], which paints the children appropriate for this
  ///    hit-testing strategy.
  bool defaultHitTestChildren(BoxHitTestResult result, {Offset? position}) {
    // The x, y parameters have the top left of the node's box as the origin.

    // The z-index needs to be sorted, and higher-level nodes are processed first.
    List<RenderObject?> paintingOrder = (this as RenderLayoutBox).paintingOrder;
    for (int i = paintingOrder.length - 1; i >= 0; i--) {
      ChildType child = paintingOrder[i] as ChildType;
      // Ignore detached render object.
      if (!child.attached) {
        continue;
      }
      final ParentDataType childParentData = child.parentData as ParentDataType;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset == Offset.zero ? null : childParentData.offset,
        position: position!,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);

          if (child is RenderBoxModel && child.renderStyle.position == CSSPositionType.fixed) {
            Offset scrollOffset = child.getTotalScrollOffset();
            transformed -= scrollOffset;
          }

          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
    }

    return false;
  }

  /// Paints each child by walking the child list forwards.
  ///
  /// See also:
  ///
  ///  * [defaultHitTestChildren], which implements hit-testing of the children
  ///    in a manner appropriate for this painting strategy.
  void defaultPaint(PaintingContext context, Offset offset) {
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType childParentData = child.parentData as ParentDataType;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }
  }

  /// Returns a list containing the children of this render object.
  ///
  /// This function is useful when you need random-access to the children of
  /// this render object. If you're accessing the children in order, consider
  /// walking the child list directly.
  List<ChildType> getChildren() {
    final List<ChildType> result = <ChildType>[];
    visitChildren((child) {
      if (child is! RenderPositionPlaceholder) {
        result.add(child as ChildType);
      }
    });
    return result;
  }
}

class RenderLayoutBox extends RenderBoxModel
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  RenderLayoutBox({required CSSRenderStyle renderStyle}) : super(renderStyle: renderStyle);

  void markChildrenNeedsSort() {
    _cachedPaintingOrder = null;
  }

  // Sort children by zIndex, used for paint and hitTest.
  List<RenderBox> _computePaintingOrder() {
    RenderLayoutBox containerLayoutBox = this;

    if (containerLayoutBox.childCount == 0) {
      // No child.
      return const [];
    } else if (containerLayoutBox.childCount == 1) {
      // Only one child.
      final List<RenderBox> order = <RenderBox>[containerLayoutBox.firstChild as RenderBox];
      return order;
    } else {
      // Sort by zIndex.
      List<RenderBox> children = [];
      List<RenderBox> negativeStackingChildren = [];
      List<RenderBoxModel> stackingChildren = [];
      containerLayoutBox.visitChildren((RenderObject child) {
        if (child is RenderBoxModel) {
          bool isNeedsStacking = child.renderStyle.needsStacking;
          if (child.renderStyle.zIndex != null && child.renderStyle.zIndex! < 0) {
            negativeStackingChildren.add(child);
          } else if (isNeedsStacking) {
            stackingChildren.add(child);
          } else {
            children.add(child);
          }
        } else {
          children.add(child as RenderBox);
        }
      });

      stackingChildren.sort((RenderBoxModel left, RenderBoxModel right) {
        return (left.renderStyle.zIndex ?? 0) <= (right.renderStyle.zIndex ?? 0) ? -1 : 1;
      });

      children.insertAll(0, negativeStackingChildren);
      children.addAll(stackingChildren);

      return children;
    }
  }

  List<RenderBox>? _cachedPaintingOrder;
  List<RenderBox> get paintingOrder {
    _cachedPaintingOrder ??= _computePaintingOrder();
    return _cachedPaintingOrder!;
  }

  // No need to override [all] and [addAll] method cause they invoke [insert] method eventually.
  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child, after: after);
    _cachedPaintingOrder = null;
  }

  @override
  void remove(RenderBox child) {
    super.remove(child);
    _cachedPaintingOrder = null;
  }

  @override
  void removeAll() {
    super.removeAll();
    _cachedPaintingOrder = null;
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    super.move(child, after: after);
    _cachedPaintingOrder = null;
  }

  @override
  BoxConstraints getConstraints() {
    BoxConstraints boxConstraints = super.getConstraints();
    return boxConstraints;
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    for (int i = 0; i < paintingOrder.length; i++) {
      RenderBox child = paintingOrder[i];
      if (!isPositionPlaceholder(child)) {
        final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
        if (child.hasSize) {
          context.paintChild(child, childParentData.offset + offset);
        }
      }
    }
  }

  // Get all children as a list and detach them all.
  List<RenderBox> detachChildren() {
    List<RenderBox> children = getChildren();
    removeAll();
    return children;
  }

  // Cache sticky children to calculate the base offset of sticky children
  final Set<RenderBoxModel> stickyChildren = {};

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  /// Baseline rule is as follows:
  /// 1. Loop children to find baseline, if child is block-level find the nearest non block-level children's height
  /// as baseline
  /// 2. If child is text-box, use text's baseline
  double? computeDistanceToHighestActualBaseline(TextBaseline baseline) {
    double? result;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;

      // Whether child is inline-level including text box
      bool isChildInline = true;
      if (child is RenderBoxModel) {
        CSSDisplay? childTransformedDisplay = child.renderStyle.effectiveDisplay;
        if (childTransformedDisplay == CSSDisplay.block || childTransformedDisplay == CSSDisplay.flex) {
          isChildInline = false;
        }
      }

      // Block level and positioned element doesn't involve in baseline alignment
      if (child is RenderBoxModel && child.renderStyle.isSelfPositioned()) {
        child = childParentData.nextSibling;
        continue;
      }

      double? childDistance = child.getDistanceToActualBaseline(baseline);
      // Use child's height if child has no baseline and not block-level
      // Text box always has baseline
      if (childDistance == null && isChildInline && child is RenderBoxModel) {
        // Flutter only allow access size of direct children, so cannot use child.size
        Size childSize = child.getBoxSize(child.contentSize);
        childDistance = childSize.height;
      }

      if (childDistance != null) {
        childDistance += childParentData.offset.dy;
        if (result != null)
          result = math.min(result, childDistance);
        else
          result = childDistance;
      }
      child = childParentData.nextSibling;
    }
    return result;
  }

  bool get isNegativeMarginChangeHSize {
    return renderStyle.width.isAuto && isMarginNegativeHorizontal();
  }

  bool isMarginNegativeVertical() {
    double? marginBottom = renderStyle.marginBottom.computedValue;
    double? marginTop = renderStyle.marginTop.computedValue;
    return marginBottom < 0 || marginTop < 0;
  }

  bool isMarginNegativeHorizontal() {
    double? marginLeft = renderStyle.marginLeft.computedValue;
    double? marginRight = renderStyle.marginRight.computedValue;
    return marginLeft < 0 || marginRight < 0;
  }

  /// Common layout content size (including flow and flexbox layout) calculation logic
  Size getContentSize({
    required double contentWidth,
    required double contentHeight,
  }) {
    double finalContentWidth = contentWidth;
    double finalContentHeight = contentHeight;

    // Size which is specified by sizing styles
    double? specifiedContentWidth = renderStyle.contentBoxLogicalWidth;
    double? specifiedContentHeight = renderStyle.contentBoxLogicalHeight;

    // Margin negative will set element which is static && not set width, size bigger
    double? marginLeft = renderStyle.marginLeft.computedValue;
    double? marginRight = renderStyle.marginRight.computedValue;
    double? marginAddSizeLeft = 0;
    double? marginAddSizeRight = 0;
    if(isNegativeMarginChangeHSize) {
      marginAddSizeRight = marginLeft < 0 ? -marginLeft : 0;
      marginAddSizeLeft = marginRight < 0 ? -marginRight : 0;
    }
    // Flex basis takes priority over main size in flex item when flex-grow or flex-shrink not work.
    if (renderStyle.isParentRenderFlexLayout()) {
      CSSRenderStyle? parentRenderStyle = renderStyle.getParentRenderStyle();
      double? flexBasis = renderStyle.flexBasis == CSSLengthValue.auto ? null : renderStyle.flexBasis?.computedValue;
      if (flexBasis != null) {
        if (CSSFlex.isHorizontalFlexDirection(parentRenderStyle!.flexDirection)) {
          if (!hasOverrideContentLogicalWidth) {
            specifiedContentWidth = _getContentWidth(flexBasis);
          }
        } else {
          if (!hasOverrideContentLogicalHeight) {
            specifiedContentHeight = _getContentHeight(flexBasis);
          }
        }
      }
    }

    if (specifiedContentWidth != null) {
      finalContentWidth = math.max(specifiedContentWidth, contentWidth);
    }
    if(parent is RenderFlexLayout && marginAddSizeLeft > 0 && marginAddSizeRight > 0 ||
        parent is RenderFlowLayout && (marginAddSizeRight > 0 || marginAddSizeLeft > 0)) {
      finalContentWidth += marginAddSizeLeft;
      finalContentWidth += marginAddSizeRight;
    }
    if (specifiedContentHeight != null) {
      finalContentHeight = math.max(specifiedContentHeight, contentHeight);
    }

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isInlineBlock = effectiveDisplay == CSSDisplay.inlineBlock;
    bool isNotInline = effectiveDisplay != CSSDisplay.inline;
    double? width = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
    double? height = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;
    double? minWidth = renderStyle.minWidth.isAuto ? null : renderStyle.minWidth.computedValue;
    double? maxWidth = renderStyle.maxWidth.isNone ? null : renderStyle.maxWidth.computedValue;
    double? minHeight = renderStyle.minHeight.isAuto ? null : renderStyle.minHeight.computedValue;
    double? maxHeight = renderStyle.maxHeight.isNone ? null : renderStyle.maxHeight.computedValue;

    // Constrain to min-width or max-width if width not exists.
    if (isInlineBlock && maxWidth != null && width == null) {
      double maxContentWidth = _getContentWidth(maxWidth);
      finalContentWidth = finalContentWidth > maxContentWidth ? maxContentWidth : finalContentWidth;
    } else if (isInlineBlock && minWidth != null && width == null) {
      double minContentWidth = _getContentWidth(minWidth);
      finalContentWidth = finalContentWidth < minContentWidth ? minContentWidth : finalContentWidth;
    }

    // Constrain to min-height or max-height if height not exists.
    if (isNotInline && maxHeight != null && height == null) {
      double maxContentHeight = _getContentHeight(maxHeight);
      finalContentHeight = finalContentHeight > maxContentHeight ? maxContentHeight : finalContentHeight;
    } else if (isNotInline && minHeight != null && height == null) {
      double minContentHeight = _getContentWidth(minHeight);
      finalContentHeight = finalContentHeight < minContentHeight ? minContentHeight : finalContentHeight;
    }

    Size finalContentSize = Size(finalContentWidth, finalContentHeight);
    return finalContentSize;
  }

  double _getContentWidth(double width) {
    return width -
        (renderStyle.borderLeftWidth?.computedValue ?? 0) -
        (renderStyle.borderRightWidth?.computedValue ?? 0) -
        renderStyle.paddingLeft.computedValue -
        renderStyle.paddingRight.computedValue;
  }

  double _getContentHeight(double height) {
    return height -
        (renderStyle.borderTopWidth?.computedValue ?? 0) -
        (renderStyle.borderBottomWidth?.computedValue ?? 0) -
        renderStyle.paddingTop.computedValue -
        renderStyle.paddingBottom.computedValue;
  }

  /// Convert to [RenderFlexLayout]
  RenderFlexLayout toFlexLayout() {
    RenderFlexLayout flexLayout = RenderFlexLayout(
      renderStyle: renderStyle,
    );
    copyWith(flexLayout);
    flexLayout.addAll(detachChildren());
    return flexLayout;
  }

  /// Convert to [RenderRepaintBoundaryFlexLayout]
  RenderRepaintBoundaryFlexLayout toRepaintBoundaryFlexLayout() {
    RenderRepaintBoundaryFlexLayout repaintBoundaryFlexLayout = RenderRepaintBoundaryFlexLayout(
      renderStyle: renderStyle,
    );
    copyWith(repaintBoundaryFlexLayout);

    repaintBoundaryFlexLayout.addAll(detachChildren());
    return repaintBoundaryFlexLayout;
  }

  /// Convert to [RenderFlowLayout]
  RenderFlowLayout toFlowLayout() {
    RenderFlowLayout flowLayout = RenderFlowLayout(
      renderStyle: renderStyle,
    );
    copyWith(flowLayout);

    flowLayout.addAll(detachChildren());
    return flowLayout;
  }

  /// Convert to [RenderRepaintBoundaryFlowLayout]
  RenderRepaintBoundaryFlowLayout toRepaintBoundaryFlowLayout() {
    RenderRepaintBoundaryFlowLayout repaintBoundaryFlowLayout = RenderRepaintBoundaryFlowLayout(
      renderStyle: renderStyle,
    );
    copyWith(repaintBoundaryFlowLayout);

    repaintBoundaryFlowLayout.addAll(detachChildren());
    return repaintBoundaryFlowLayout;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('paintingOrder', paintingOrder));
  }

  @override
  void dispose() {
    super.dispose();

    stickyChildren.clear();
  }
}

mixin RenderBoxModelBase on RenderBox {
  late CSSRenderStyle renderStyle;
  Size? boxSize;
}

class RenderBoxModel extends RenderBox
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

  @override
  bool get alwaysNeedsCompositing {
    return intersectionObserverAlwaysNeedsCompositing() || opacityAlwaysNeedsCompositing();
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

  BoxConstraints? _contentConstraints;

  BoxConstraints? get contentConstraints {
    return _contentConstraints;
  }

  set contentConstraints(BoxConstraints? constraints) {
    _contentConstraints = constraints;
  }

  bool _needsRecalculateStyle = false;

  void markNeedsRecalculateRenderStyle() {
    if (_needsRecalculateStyle) return;
    _needsRecalculateStyle = true;
  }

  // Cached positioned children for apply offsets when self had layout
  final Set<RenderBoxModel> positionedChildren = {};

  @override
  String toStringShort() {
    return super.toStringShort() +
        ' ${renderStyle.target}[managedByFlutter=${renderStyle.target.managedByFlutterWidget}]';
  }

  bool get isSizeTight {
    bool isDefinedSize = (renderStyle.width.value != null &&
        renderStyle.height.value != null &&
        renderStyle.width.isPrecise &&
        renderStyle.height.isPrecise);
    bool isFixedMinAndMaxSize = (renderStyle.minWidth.value == renderStyle.maxWidth.value &&
            renderStyle.minWidth.value != null &&
            renderStyle.minWidth.isPrecise) &&
        (renderStyle.minHeight.value == renderStyle.maxHeight.value &&
            renderStyle.minHeight.value != null &&
            renderStyle.minHeight.isPrecise);

    return isDefinedSize || isFixedMinAndMaxSize;
  }

  BoxSizeType get widthSizeType {
    return renderStyle.width.isAuto ? BoxSizeType.automatic : BoxSizeType.specified;
  }

  BoxSizeType get heightSizeType {
    return renderStyle.height.isAuto ? BoxSizeType.automatic : BoxSizeType.specified;
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

  T copyWith<T extends RenderBoxModel>(T copiedRenderBoxModel) {
    if (renderPositionPlaceholder != null) {
      renderPositionPlaceholder!.positioned = copiedRenderBoxModel;
    }

    scrollOffsetX?.removeListener(scrollXListener);
    scrollOffsetY?.removeListener(scrollYListener);

    RenderIntersectionObserverMixin.copyTo(this, copiedRenderBoxModel);

    return copiedRenderBoxModel
      // Copy render style
      ..renderStyle = renderStyle

      // Copy overflow
      ..scrollListener = scrollListener
      ..scrollablePointerListener = scrollablePointerListener
      ..scrollOffsetX = scrollOffsetX
      ..scrollOffsetY = scrollOffsetY

      // Copy renderPositionHolder
      ..renderPositionPlaceholder = renderPositionPlaceholder

      // Copy parentData
      ..parentData = parentData;
  }

  /// Whether current box is the root of the document which corresponds to HTML element in dom tree.
  bool get isDocumentRootBox {
    // Get the outer box of overflow scroll box
    RenderBoxModel currentBox = this;
    // Root element of document is the child of viewport.
    return currentBox.parent is RootRenderViewportBox || currentBox.parent is RouterViewViewportBox;
  }

  // Width/height is overrided by flex-grow or flex-shrink in flex layout.
  bool hasOverrideContentLogicalWidth = false;
  bool hasOverrideContentLogicalHeight = false;

  void clearOverrideContentSize() {
    hasOverrideContentLogicalWidth = false;
    hasOverrideContentLogicalHeight = false;
  }

  // Nominally, the smallest size a box could take that doesn’t lead to overflow that could be avoided by choosing
  // a larger size. Formally, the size of the box when sized under a min-content constraint.
  // https://www.w3.org/TR/css-sizing-3/#min-content
  double minContentWidth = 0;
  double minContentHeight = 0;

  // Whether it needs relayout due to percentage calculation.
  bool needsRelayout = false;

  // Mark parent as needs relayout used in cases such as
  // child has percentage length and parent's size can not be calculated by style
  // thus parent needs relayout for its child calculate percentage length.
  void markParentNeedsRelayout() {
    RenderObject? parent = renderStyle.getParentRenderStyle()?.attachedRenderBoxModel;
    if (parent is RenderBoxModel) {
      parent.needsRelayout = true;
    }
  }

  // Mirror debugDoingThisLayout flag in flutter.
  // [debugDoingThisLayout] indicate whether [performLayout] for this render object is currently running.
  bool doingThisLayout = false;

  // A flag to detect the size of this renderBox had changed during this layout.
  bool isSelfSizeChanged = false;

  // Mirror debugNeedsLayout flag in Flutter to use in layout performance optimization
  bool needsLayout = false;

  @override
  void markNeedsLayout() {
    if (doingThisLayout) {
      // Push delay the [markNeedsLayout] after owner [PipelineOwner] finishing current [flushLayout].
      SchedulerBinding.instance.addPostFrameCallback((_) {
        markNeedsLayout();
      });
      SchedulerBinding.instance.scheduleFrame();
    } else {
      needsLayout = true;
      super.markNeedsLayout();
      if ((!isSizeTight) && parent != null) {
        markParentNeedsLayout();
      }
    }
  }

  /// Mark children needs layout when drop child as Flutter did
  ///
  @override
  void dropChild(RenderObject child) {
    super.dropChild(child);
    // Loop to mark all the children to needsLayout as flutter did
    _syncChildNeedsLayoutFlag(child);
  }

  // @HACK: sync _needsLayout flag in Flutter to do performance opt.
  void syncNeedsLayoutFlag() {
    needsLayout = true;
    visitChildren(_syncChildNeedsLayoutFlag);
  }

  /// Mark specified renderBoxModel needs layout
  void _syncChildNeedsLayoutFlag(RenderObject child) {
    if (child is RenderBoxModel) {
      child.syncNeedsLayoutFlag();
    } else if (child is RenderTextBox) {
      child.syncNeedsLayoutFlag();
    }
  }

  LogicInlineBox createLogicInlineBox() {
    return LogicInlineBox(renderObject: this);
  }

  @override
  void layout(Constraints newConstraints, {bool parentUsesSize = false}) {
    renderBoxInLayoutHashCodes.add(hashCode);

    if (hasSize) {
      // Constraints changes between tight and no tight will cause reLayoutBoundary change
      // which will then cause its children to be marked as needsLayout in Flutter
      if ((newConstraints.isTight && !constraints.isTight) || (!newConstraints.isTight && constraints.isTight)) {
        syncNeedsLayoutFlag();
      }
    }
    super.layout(newConstraints, parentUsesSize: parentUsesSize);

    renderBoxInLayoutHashCodes.remove(hashCode);
    // Clear length cache when no renderBox is in layout.
    if (renderBoxInLayoutHashCodes.isEmpty) {
      clearComputedValueCache();
    }
  }

  void markAdjacentRenderParagraphNeedsLayout() {
    if (parent != null && parent is RenderFlowLayout && parentData is RenderLayoutParentData) {
      if ((parentData as RenderLayoutParentData).nextSibling is RenderTextBox) {
        ((parentData as RenderLayoutParentData).nextSibling as RenderTextBox).markRenderParagraphNeedsLayout();
      }

      if ((parentData as RenderLayoutParentData).previousSibling is RenderTextBox) {
        ((parentData as RenderLayoutParentData).previousSibling as RenderTextBox).markRenderParagraphNeedsLayout();
      }
    }
  }

  // Calculate constraints of renderBoxModel on layout stage and
  // only needed to be executed once on every layout.
  BoxConstraints getConstraints() {
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isDisplayInline = effectiveDisplay == CSSDisplay.inline;

    double? minWidth = renderStyle.minWidth.isAuto ? null : renderStyle.minWidth.computedValue;
    double? maxWidth = renderStyle.maxWidth.isNone ? null : renderStyle.maxWidth.computedValue;
    double? minHeight = renderStyle.minHeight.isAuto ? null : renderStyle.minHeight.computedValue;
    double? maxHeight = renderStyle.maxHeight.isNone ? null : renderStyle.maxHeight.computedValue;

    // Need to calculated logic content size on every layout.
    renderStyle.computeContentBoxLogicalWidth();
    renderStyle.computeContentBoxLogicalHeight();

    // Width should be not smaller than border and padding in horizontal direction
    // when box-sizing is border-box which is only supported.
    double minConstraintWidth = renderStyle.effectiveBorderLeftWidth.computedValue +
        renderStyle.effectiveBorderRightWidth.computedValue +
        renderStyle.paddingLeft.computedValue +
        renderStyle.paddingRight.computedValue;

    double? parentBoxContentConstraintsWidth;
    if (parent is RenderBoxModel && this is RenderLayoutBox) {
      RenderBoxModel parentRenderBoxModel = (parent as RenderBoxModel);
      parentBoxContentConstraintsWidth =
          parentRenderBoxModel.renderStyle.deflateMarginConstraints(parentRenderBoxModel.contentConstraints!).maxWidth;

      // When inner minimal content size are larger that parent's constraints.
      if (parentBoxContentConstraintsWidth < minConstraintWidth) {
        parentBoxContentConstraintsWidth = null;
      }

      // FlexItems with flex:none won't inherit parent box's constraints
      if (parent is RenderFlexLayout && (parent as RenderFlexLayout).isFlexNone(this)) {
        parentBoxContentConstraintsWidth = null;
      }
    }

    double maxConstraintWidth =
        renderStyle.borderBoxLogicalWidth ?? parentBoxContentConstraintsWidth ?? double.infinity;
    // Height should be not smaller than border and padding in vertical direction
    // when box-sizing is border-box which is only supported.
    double minConstraintHeight = renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue +
        renderStyle.paddingTop.computedValue +
        renderStyle.paddingBottom.computedValue;
    double maxConstraintHeight = renderStyle.borderBoxLogicalHeight ?? double.infinity;

    if (parent is RenderFlexLayout) {
      double? flexBasis = renderStyle.flexBasis == CSSLengthValue.auto ? null : renderStyle.flexBasis?.computedValue;
      RenderBoxModel? parentRenderBoxModel = parent as RenderBoxModel?;
      // In flex layout, flex basis takes priority over width/height if set.
      // Flex-basis cannot be smaller than its content size which happens can not be known
      // in constraints apply stage, so flex-basis acts as min-width in constraints apply stage.
      if (flexBasis != null) {
        if (CSSFlex.isHorizontalFlexDirection(parentRenderBoxModel!.renderStyle.flexDirection)) {
          minWidth = minWidth != null ? math.max(flexBasis, minWidth) : flexBasis;
        } else {
          minHeight = minHeight != null ? math.max(flexBasis, minHeight) : flexBasis;
        }
      }
    }

    // Clamp constraints by min/max size when display is not inline.
    if (!isDisplayInline) {
      if (minWidth != null) {
        minConstraintWidth = minConstraintWidth < minWidth ? minWidth : minConstraintWidth;
        maxConstraintWidth = maxConstraintWidth < minWidth ? minWidth : maxConstraintWidth;
      }
      if (maxWidth != null) {
        minConstraintWidth = minConstraintWidth > maxWidth ? maxWidth : minConstraintWidth;
        maxConstraintWidth = maxConstraintWidth > maxWidth ? maxWidth : maxConstraintWidth;
      }
      if (minHeight != null) {
        minConstraintHeight = minConstraintHeight < minHeight ? minHeight : minConstraintHeight;
        maxConstraintHeight = maxConstraintHeight < minHeight ? minHeight : maxConstraintHeight;
      }
      if (maxHeight != null) {
        minConstraintHeight = minConstraintHeight > maxHeight ? maxHeight : minConstraintHeight;
        maxConstraintHeight = maxConstraintHeight > maxHeight ? maxHeight : maxConstraintHeight;
      }
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
    // Scrollable area includes right and bottom padding
    scrollableSize = Size(contentSize.width + renderStyle.paddingLeft.computedValue,
        contentSize.height + renderStyle.paddingTop.computedValue);
  }

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size? _boxSize;

  @override
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

  Size wrapOutContentSizeRight (Size contentSize) {
    Size paddingBoxSize = renderStyle.wrapPaddingSizeRight(contentSize);
    return renderStyle.wrapBorderSizeRight(paddingBoxSize);
  }

  Size wrapOutContentSize (Size contentSize) {
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
    BoxConstraints contentConstraints = parent is RenderBoxModel ? constraints : getConstraints();

    // Deflate border constraints.
    contentConstraints = renderStyle.deflateBorderConstraints(contentConstraints);
    // Deflate padding constraints.
    contentConstraints = renderStyle.deflatePaddingConstraints(contentConstraints);
    _contentConstraints = contentConstraints;
    clearOverflowLayout();
    isSelfSizeChanged = false;
  }

  /// Find scroll container
  RenderBoxModel? findScrollContainer() {
    RenderBoxModel? scrollContainer;
    RenderObject? parent = this.parent;

    while (parent != null) {
      if (parent is RenderLayoutBox &&
          (parent.renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
              parent.renderStyle.effectiveOverflowY != CSSOverflowType.visible)) {
        // Scroll container should has definite constraints
        scrollContainer = parent;
        break;
      }
      if (parent is RenderWidget && (parent.renderStyle.target as WidgetElement).isScrollingElement) {
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
  void applyLayoutTransform(RenderObject child, Matrix4 transform, bool excludeScrollOffset) {
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
    if (excludeScrollOffset) {
      if (this is RenderWidget) {
        offset -= Offset(renderStyle.target.scrollLeft, renderStyle.target.scrollTop);
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

  Size _scrollableViewportSize = Size.zero;

  Size get scrollableViewportSize => _scrollableViewportSize;

  set scrollableViewportSize(Size value) {
    _scrollableViewportSize = value;
  }

  /// Extend max scrollable size of renderBoxModel by offset of positioned child,
  /// get the max scrollable size of children of normal flow and single positioned child.
  void extendMaxScrollableSize(RenderBoxModel child) {
    Size? childScrollableSize;
    RenderStyle childRenderStyle = child.renderStyle;
    CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
    CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;
    // Only non scroll container need to use scrollable size, otherwise use its own size
    if (overflowX == CSSOverflowType.visible && overflowY == CSSOverflowType.visible) {
      childScrollableSize = child.scrollableSize;
    } else {
      childScrollableSize = child.boxSize;
    }

    Matrix4? transform = (childRenderStyle as CSSRenderStyle).transformMatrix;
    double maxScrollableX = childRenderStyle.left.computedValue + childScrollableSize!.width;

    // maxScrollableX could be infinite due to the percentage value which depends on the parent box size,
    // but in this stage, the parent's size will always to zero during the first initial layout.
    if (maxScrollableX.isInfinite) return;

    if (transform != null) {
      maxScrollableX += transform.getTranslation()[0];
    }

    if (childRenderStyle.right.isNotAuto && parent is RenderBoxModel) {
      if ((parent as RenderBoxModel).widthSizeType == BoxSizeType.specified) {
        RenderBoxModel overflowContainerBox = parent as RenderBoxModel;
        maxScrollableX = math.max(
            maxScrollableX,
            -childRenderStyle.right.computedValue +
                overflowContainerBox.renderStyle.width.computedValue -
                overflowContainerBox.renderStyle.effectiveBorderLeftWidth.computedValue -
                overflowContainerBox.renderStyle.effectiveBorderRightWidth.computedValue);
      } else {
        maxScrollableX = math.max(maxScrollableX, -childRenderStyle.right.computedValue + _contentSize!.width);
      }
    }

    double maxScrollableY = childRenderStyle.top.computedValue + childScrollableSize.height;

    // maxScrollableX could be infinite due to the percentage value which depends on the parent box size,
    // but in this stage, the parent's size will always to zero during the first initial layout.
    if (maxScrollableY.isInfinite) return;

    if (transform != null) {
      maxScrollableY += transform.getTranslation()[1];
    }
    if (childRenderStyle.bottom.isNotAuto && parent is RenderBoxModel) {
      if ((parent as RenderBoxModel).heightSizeType == BoxSizeType.specified) {
        RenderBoxModel overflowContainerBox = parent as RenderBoxModel;
        maxScrollableY = math.max(
            maxScrollableY,
            -childRenderStyle.bottom.computedValue +
                overflowContainerBox.renderStyle.height.computedValue -
                overflowContainerBox.renderStyle.effectiveBorderTopWidth.computedValue -
                overflowContainerBox.renderStyle.effectiveBorderBottomWidth.computedValue);
      } else {
        maxScrollableY = math.max(maxScrollableY, -childRenderStyle.bottom.computedValue + _contentSize!.height);
      }
    }

    maxScrollableX = math.max(maxScrollableX, scrollableSize.width);
    maxScrollableY = math.max(maxScrollableY, scrollableSize.height);

    scrollableSize = Size(maxScrollableX, maxScrollableY);
  }

  // iterate add child to overflowLayout
  void addOverflowLayoutFromChildren(List<RenderBox> children) {
    children.forEach((child) {
      addOverflowLayoutFromChild(child);
    });
  }

  void addOverflowLayoutFromChild(RenderBox child) {
    final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
    // TODO not support custom element and inline element overflowRect
    if (!child.hasSize || (child is! RenderBoxModel && child is! RenderReplaced)) {
      return;
    }
    CSSRenderStyle style = (child as RenderBoxModel).renderStyle;
    Rect overflowRect = Rect.fromLTWH(
        childParentData.offset.dx, childParentData.offset.dy, child.boxSize!.width, child.boxSize!.height);

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
      Offset tlOffset =
          MatrixUtils.transformPoint(transform, Offset(childOverflowLayoutRect.left, childOverflowLayoutRect.top));
      overflowRect = Rect.fromLTRB(
          math.min(overflowRect.left, tlOffset.dx),
          math.min(overflowRect.top, tlOffset.dy),
          math.max(overflowRect.right, tlOffset.dx + childOverflowLayoutRect.width),
          math.max(overflowRect.bottom, tlOffset.dy + childOverflowLayoutRect.height));
    }

    addLayoutOverflow(overflowRect);
  }

  // Hooks when content box had layout.
  void didLayout() {
    for (RenderBoxModel child in positionedChildren) {
      if (child.attached) {
        CSSPositionedLayout.applyPositionedChildOffset(this, child);
      }
    }

    scrollableViewportSize = constraints.constrain(Size(
        _contentSize!.width + renderStyle.paddingLeft.computedValue + renderStyle.paddingRight.computedValue,
        _contentSize!.height + renderStyle.paddingTop.computedValue + renderStyle.paddingBottom.computedValue));

    setUpOverflowScroller(scrollableSize, scrollableViewportSize);

    if (positionedHolder != null && renderStyle.position != CSSPositionType.sticky) {
      // Make position holder preferred size equal to current element boundary size except sticky element.
      positionedHolder!.preferredSize = Size.copy(size);
    }

    // // Positioned renderBoxModel will not trigger parent to relayout. Needs to update it's offset for itself.
    // if (parentData is RenderLayoutParentData) {
    //   RenderLayoutParentData selfParentData = parentData as RenderLayoutParentData;
    //   RenderObject? parentBox = parent;
    //   if (parentBox is RenderEventListener) {
    //     parentBox = parentBox.parent;
    //   }
    //
    //   if (selfParentData.isPositioned && parentBox is RenderBoxModel && parentBox.hasSize) {
    //     CSSPositionedLayout.applyPositionedChildOffset(this, parentBox);
    //   }
    // }

    needsLayout = false;
    dispatchResize(contentSize, boxSize ?? Size.zero);

    if (isSelfSizeChanged) {
      renderStyle.markTransformMatrixNeedsUpdate();
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

    paintBoxModel(context, offset);
  }

  void debugPaintOverlay(PaintingContext context, Offset offset) {
    Rect overlayRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    context.addLayer(InspectorOverlayLayer(
      overlayRect: overlayRect,
    ));
  }

  // Repaint native EngineLayer sources with LayerHandle.
  final LayerHandle<ColorFilterLayer> _colorFilterLayer = LayerHandle<ColorFilterLayer>();

  void paintColorFilter(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    ColorFilter? colorFilter = renderStyle.colorFilter;
    if (colorFilter != null) {
      _colorFilterLayer.layer =
          context.pushColorFilter(offset, colorFilter, callback, oldLayer: _colorFilterLayer.layer);
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
      // Paint fixed element to fixed position by compensating scroll offset
      double offsetY = additionalPaintOffsetY != null ? offset.dy + additionalPaintOffsetY! : offset.dy;
      double offsetX = additionalPaintOffsetX != null ? offset.dx + additionalPaintOffsetX! : offset.dx;
      offset = Offset(offsetX, offsetY);
      paintColorFilter(context, offset, _chainPaintImageFilter);
    }
  }

  final LayerHandle<ImageFilterLayer> _imageFilterLayer = LayerHandle<ImageFilterLayer>();

  void paintImageFilter(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (renderStyle.imageFilter != null) {
      _imageFilterLayer.layer ??= ImageFilterLayer();
      _imageFilterLayer.layer!.imageFilter = renderStyle.imageFilter;
      context.pushLayer(_imageFilterLayer.layer!, callback, offset);
    } else {
      callback(context, offset);
    }
  }

  void _chainPaintImageFilter(PaintingContext context, Offset offset) {
    paintImageFilter(context, offset, _chainPaintIntersectionObserver);
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
        renderStyle.effectiveBorderLeftWidth.computedValue);
    CSSBoxDecoration? decoration = renderStyle.decoration;

    bool hasLocalAttachment = _hasLocalBackgroundImage(renderStyle);
    if (hasLocalAttachment) {
      paintOverflow(context, offset, borderEdge, decoration, _chainPaintBackground);
    } else {
      paintOverflow(context, offset, borderEdge, decoration, _chainPaintContentVisibility);
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

  /// Compute distance to baseline
  double? computeDistanceToBaseline() {
    return null;
  }

  // Get the layout offset of renderObject to its ancestor which does not include the paint offset
  // such as scroll or transform.getLayoutTransformTo
  Offset getOffsetToAncestor(Offset point, RenderBoxModel ancestor,
      {bool excludeScrollOffset = false, bool excludeAncestorBorderTop = true}) {
    Offset ancestorBorderWidth = Offset.zero;
    if (excludeAncestorBorderTop) {
      double ancestorBorderTop = ancestor.renderStyle.borderTopWidth?.computedValue ?? 0;
      double ancestorBorderLeft = ancestor.renderStyle.borderLeftWidth?.computedValue ?? 0;
      ancestorBorderWidth = Offset(ancestorBorderLeft, ancestorBorderTop);
    }

    return getLayoutTransformTo(this, ancestor, excludeScrollOffset: excludeScrollOffset) + point - ancestorBorderWidth;
  }

  Offset getOffsetToRenderObjectAncestor(Offset point, RenderObject ancestor, {bool excludeScrollOffset = false}) {
    return getLayoutTransformTo(this, ancestor, excludeScrollOffset: excludeScrollOffset) + point;
  }

  bool _hasLocalBackgroundImage(CSSRenderStyle renderStyle) {
    return renderStyle.backgroundImage != null && renderStyle.backgroundAttachment == CSSBackgroundAttachmentType.local;
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

    positionedChildren.clear();
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

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hasSize || !contentVisibilityHitTest(result, position: position) || renderStyle.isVisibilityHidden) {
      return false;
    }

    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Cannot hit test a render box that has never been laid out.'),
            describeForError('The hitTest() method was called on this RenderBox'),
            ErrorDescription("Unfortunately, this object's geometry is not known at this time, "
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
          ErrorDescription('Although this node is not marked as needing layout, '
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
        return result.addWithPaintOffset(
            offset: (scrollLeft != 0.0 || scrollTop != 0.0) ? Offset(-scrollLeft, -scrollTop) : null,
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
              if (hasSize && hitTestChildren(result, position: position) || hitTestSelf(transformPosition)) {
                result.add(BoxHitTestEntry(this, position));
                return true;
              }
              return false;
            });
      },
    );

    return isHit;
  }

  /// Get the root box model of document which corresponds to html element.
  RenderBoxModel? getRootBoxModel() {
    RenderBoxModel _self = this;
    while (_self.parent != null && _self.parent is! RootRenderViewportBox) {
      _self = _self.parent as RenderBoxModel;
    }
    return _self.parent is RootRenderViewportBox ? _self : null;
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
    properties.add(DiagnosticsProperty('contentConstraints', _contentConstraints, missingIfNull: true));
    properties.add(DiagnosticsProperty('maxScrollableSize', scrollableSize, missingIfNull: true));
    properties.add(DiagnosticsProperty('scrollableViewportSize', scrollableViewportSize, missingIfNull: true));
    properties.add(DiagnosticsProperty('needsLayout', needsLayout, missingIfNull: true));
    properties.add(DiagnosticsProperty('isSizeTight', isSizeTight));
    properties.add(DiagnosticsProperty(
        'additionalPaintOffset', Offset(additionalPaintOffsetX ?? 0.0, additionalPaintOffsetY ?? 0.0)));
    if (renderPositionPlaceholder != null)
      properties.add(DiagnosticsProperty('renderPositionHolder', renderPositionPlaceholder));
    renderStyle.debugFillProperties(properties);
    debugOverflowProperties(properties);
    debugOpacityProperties(properties);
  }
}
