/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

/// RenderBox of a widget element whose content is rendering by Flutter Widgets.
class RenderWidget extends RenderBoxModel
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>> {
  RenderWidget({required super.renderStyle});

  // Cache sticky children to calculate the base offset of sticky children
  final Set<RenderBoxModel> stickyChildren = {};

  @override
  BoxSizeType get widthSizeType {
    bool widthDefined =
        renderStyle.width.isNotAuto || renderStyle.minWidth.isNotAuto;
    return widthDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }

  @override
  BoxSizeType get heightSizeType {
    bool heightDefined =
        renderStyle.height.isNotAuto || renderStyle.minHeight.isNotAuto;
    return heightDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }

  @override
  void setupParentData(RenderBox child) {
    child.parentData = RenderLayoutParentData();
  }

  RenderViewportBox? getViewportBox() {
    RenderObject? current = parent;
    while (current != null) {
      if (current is RenderViewportBox) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  void _layoutChild(RenderBox child) {
    // Ensure logical content sizes are computed from CSS before deriving constraints
    // so that explicit width/height (e.g. h-8) can be honored.
    renderStyle.computeContentBoxLogicalWidth();
    renderStyle.computeContentBoxLogicalHeight();

    // Base child constraints come from our content box constraints.
    // For inline-block with auto width, avoid clamping to the viewport so
    // children can determine natural width and we shrink-wrap accordingly.
    final bool isInlineBlockAutoWidth =
        renderStyle.effectiveDisplay == CSSDisplay.inlineBlock &&
            renderStyle.width.isAuto;

    // When the widget element has an explicit inline-size (width/min-width/max-width),
    // we should not additionally clamp the child to the viewport. Let it size up to
    // the content constraints so that explicit widths (e.g., 500px) can overflow and
    // participate in scrollable sizing, matching regular RenderBoxModel behavior.
    final bool hasExplicitInlineWidth = renderStyle.width.isNotAuto ||
        renderStyle.minWidth.isNotAuto ||
        renderStyle.maxWidth.isNotNone;

    RenderViewportBox viewportBox =
        getViewportBox() ?? renderStyle.target.getRootViewport()!;
    Size viewportSize = viewportBox.viewportSize;
    // The content box of this RenderWidget is the area available to the hosted
    // Flutter widget after accounting for CSS padding and borders. When we clamp
    // the child's height against the viewport, we must subtract our own vertical
    // padding and borders so that the resulting border-box (child content +
    // padding + border) never exceeds the viewport height. Otherwise, elements
    // like WebFListView would grow taller than the root viewport by exactly the
    // amount of their vertical padding.
    final double verticalPadding = renderStyle.paddingTop.computedValue +
        renderStyle.paddingBottom.computedValue;
    final double verticalBorder =
        renderStyle.effectiveBorderTopWidth.computedValue +
            renderStyle.effectiveBorderBottomWidth.computedValue;
    final double contentViewportHeight =
        math.max(0.0, viewportSize.height - verticalPadding - verticalBorder);

    BoxConstraints childConstraints;
    if (isInlineBlockAutoWidth || hasExplicitInlineWidth) {
      childConstraints = BoxConstraints(
          minWidth: contentConstraints!.minWidth,
          maxWidth: contentConstraints!.maxWidth,
          minHeight: contentConstraints!.minHeight,
          maxHeight: (contentConstraints!.hasTightHeight ||
                  (renderStyle.target as WidgetElement).allowsInfiniteHeight)
              ? contentConstraints!.maxHeight
              : math.min(contentViewportHeight, contentConstraints!.maxHeight));
    } else {
      childConstraints = BoxConstraints(
          minWidth: contentConstraints!.minWidth,
          maxWidth: (contentConstraints!.hasTightWidth ||
                  (renderStyle.target as WidgetElement).allowsInfiniteWidth)
              ? contentConstraints!.maxWidth
              : math.min(viewportSize.width, contentConstraints!.maxWidth),
          minHeight: contentConstraints!.minHeight,
          maxHeight: (contentConstraints!.hasTightHeight ||
                  (renderStyle.target as WidgetElement).allowsInfiniteHeight)
              ? contentConstraints!.maxHeight
              : math.min(contentViewportHeight, contentConstraints!.maxHeight));
    }

    // If an explicit CSS width is specified (non-auto), tighten the child's
    // constraints on the main axis to that used content width, clamped within
    // our content constraints. This allows widget containers to honor fixed
    // widths (e.g., 500px) even when the viewport is narrower, letting them
    // overflow and participate in scrollable sizing like regular layout boxes.
    if (renderStyle.width.isNotAuto) {
      final double? logicalContentWidth = renderStyle.contentBoxLogicalWidth;
      if (logicalContentWidth != null && logicalContentWidth.isFinite) {
        final double clampedWidth = logicalContentWidth.clamp(
            contentConstraints!.minWidth, contentConstraints!.maxWidth);
        childConstraints = childConstraints.tighten(width: clampedWidth);
      }
    }

    // If an explicit CSS height is specified (non-auto), tighten the child's
    // constraints on the cross axis to that used content height, clamped
    // within our content constraints. This makes classes like `h-8` take effect
    // for RenderWidget containers within flex/flow contexts.
    // Note: contentBoxLogicalHeight is the content-box height (excluding padding/border).
    if (renderStyle.height.isNotAuto) {
      final double? logicalContentHeight = renderStyle.contentBoxLogicalHeight;
      if (logicalContentHeight != null && logicalContentHeight.isFinite) {
        // Clamp to the available content constraints to avoid exceeding parent limits.
        final double clampedHeight = logicalContentHeight.clamp(
            contentConstraints!.minHeight, contentConstraints!.maxHeight);
        childConstraints = childConstraints.tighten(height: clampedHeight);
      }
    }

    // Deflate border constraints.
    // childConstraints = renderStyle.deflateBorderConstraints(childConstraints);
    // Deflate padding constraints.
    // childConstraints = renderStyle.deflatePaddingConstraints(childConstraints);

    child.layout(childConstraints, parentUsesSize: true);

    Size childSize = child.size;

    setMaxScrollableSize(childSize);
    size = getBoxSize(childSize);

    minContentWidth = renderStyle.intrinsicWidth;
    minContentHeight = renderStyle.intrinsicHeight;

    _setChildrenOffset(child);
  }

  void _setChildrenOffset(RenderBox child) {
    double borderLeftWidth = renderStyle.borderLeftWidth?.computedValue ?? 0.0;
    double borderTopWidth = renderStyle.borderTopWidth?.computedValue ?? 0.0;

    double paddingLeftWidth = renderStyle.paddingLeft.computedValue;
    double paddingTopWidth = renderStyle.paddingTop.computedValue;

    Offset offset = Offset(
        borderLeftWidth + paddingLeftWidth, borderTopWidth + paddingTopWidth);
    // Apply position relative offset change.
    CSSPositionedLayout.applyRelativeOffset(offset, child);
  }

  // Compute painting order using CSS stacking categories:
  // negatives → normal-flow → positioned(auto/0) → positives.
  List<RenderBox> _computePaintingOrder() {
    if (childCount == 0) return const [];
    if (childCount == 1) return <RenderBox>[firstChild as RenderBox];

    List<RenderBox> normal = [];
    List<RenderBoxModel> negatives = [];
    List<RenderBoxModel> positionedAutoOrZero = [];
    List<RenderBoxModel> positives = [];

    bool subtreeHasAutoOrZeroParticipant(RenderBox node, [int depth = 0]) {
      if (depth > 12) return false;
      if (node is RenderBoxModel) {
        final rs = node.renderStyle;
        final int? zi = rs.zIndex;
        final bool positioned = rs.position != CSSPositionType.static;
        if (zi == 0 || (positioned && zi == null)) return true;
      }
      if (node is RenderObjectWithChildMixin<RenderBox>) {
        final RenderBox? c = (node as dynamic).child as RenderBox?;
        if (c != null && subtreeHasAutoOrZeroParticipant(c, depth + 1))
          return true;
      }
      if (node is RenderLayoutBox) {
        RenderBox? c = node.firstChild;
        while (c != null) {
          if (subtreeHasAutoOrZeroParticipant(c, depth + 1)) return true;
          final RenderLayoutParentData pd =
              c.parentData as RenderLayoutParentData;
          c = pd.nextSibling;
        }
      }
      return false;
    }

    visitChildren((RenderObject c) {
      if (c is RenderBoxModel) {
        final rs = c.renderStyle;
        final int? zi = rs.zIndex;
        final bool positioned = rs.position != CSSPositionType.static;
        if (zi != null && zi < 0) {
          negatives.add(c);
        } else if (zi != null && zi > 0) {
          if (!(renderStyle).suppressPositiveStackingFromDescendants) {
            positives.add(c);
          }
        } else if (zi == 0) {
          positionedAutoOrZero.add(c);
        } else if (positioned && zi == null) {
          positionedAutoOrZero.add(c);
        } else {
          // If subtree contains any z-index:0 or auto-positioned participants,
          // elevate this container to the auto/0 layer for global ordering.
          if (subtreeHasAutoOrZeroParticipant(c)) {
            positionedAutoOrZero.add(c);
          } else {
            normal.add(c);
          }
        }
      } else {
        normal.add(c as RenderBox);
      }
    });

    // Promote descendant stacking context roots with positive z-index so they can
    // participate in ordering at this level (e.g., widget container hosting <body>
    // vs absolutely-positioned under <html>).
    void collectPositiveStackingContexts(
        RenderBox node, List<RenderBoxModel> out,
        [int depth = 0]) {
      if (depth > 64) return;
      if (node is RenderBoxModel) {
        final CSSRenderStyle rs = node.renderStyle;
        if (rs.establishesStackingContext) {
          final int? zi = rs.zIndex;
          if (zi != null && zi > 0) out.add(node);
          return;
        }
      }
      if (node is RenderObjectWithChildMixin<RenderBox>) {
        final RenderBox? c = (node as dynamic).child as RenderBox?;
        if (c != null) collectPositiveStackingContexts(c, out, depth + 1);
      }
      if (node is RenderLayoutBox) {
        RenderBox? c = node.firstChild;
        while (c != null) {
          collectPositiveStackingContexts(c, out, depth + 1);
          final RenderLayoutParentData pd =
              c.parentData as RenderLayoutParentData;
          c = pd.nextSibling;
        }
      }
    }

    for (final RenderBox nf in normal) {
      collectPositiveStackingContexts(nf, positives);
    }

    // Compare two render boxes by full document tree order using DOM compareDocumentPosition.
    int compareTreeOrder(RenderBoxModel a, RenderBoxModel b) {
      final Node aNode = a.renderStyle.target;
      final Node bNode = b.renderStyle.target;
      final DocumentPosition pos = aNode.compareDocumentPosition(bNode);
      if (pos == DocumentPosition.FOLLOWING) return -1; // a before b
      if (pos == DocumentPosition.PRECEDING) return 1; // a after b
      return 0;
    }

    // Negative z-index first (ascending)
    negatives.sort((a, b) {
      final int az = a.renderStyle.zIndex ?? 0;
      final int bz = b.renderStyle.zIndex ?? 0;
      if (az != bz) return az.compareTo(bz);
      return compareTreeOrder(a, b);
    });

    // Positioned auto/0 by DOM order
    positionedAutoOrZero.sort(compareTreeOrder);

    // Positive z-index ascending
    positives.sort((a, b) {
      final int az = a.renderStyle.zIndex ?? 0;
      final int bz = b.renderStyle.zIndex ?? 0;
      if (az != bz) return az.compareTo(bz);
      return compareTreeOrder(a, b);
    });

    final List<RenderBox> ordered = [];
    ordered.addAll(negatives.cast<RenderBox>());
    ordered.addAll(normal);
    ordered.addAll(positionedAutoOrZero.cast<RenderBox>());
    ordered.addAll(positives.cast<RenderBox>());
    return ordered;
  }

  List<RenderBox>? _cachedPaintingOrder;

  List<RenderBox> get paintingOrder {
    _cachedPaintingOrder ??= _computePaintingOrder();
    return _cachedPaintingOrder!;
  }

  void markChildrenNeedsSort() {
    _cachedPaintingOrder = null;
  }

  // Intrinsic sizing for WidgetElement containers: forward to the primary
  // non-positioned child, including paddings and borders.
  @override
  double computeMinIntrinsicWidth(double height) {
    double content = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData pd =
          child.parentData as RenderLayoutParentData;
      final bool positioned = child is RenderBoxModel &&
          ((child).renderStyle.isSelfPositioned() ||
              (child).renderStyle.isSelfStickyPosition());
      if (!positioned) {
        content = child.getMinIntrinsicWidth(height);
        break; // Only the primary flow child contributes to intrinsic width.
      }
      child = pd.nextSibling;
    }
    final double padding = (renderStyle.paddingLeft.computedValue +
        renderStyle.paddingRight.computedValue);
    final double border = (renderStyle.effectiveBorderLeftWidth.computedValue +
        renderStyle.effectiveBorderRightWidth.computedValue);
    if (content == 0.0)
      content = super.computeMinIntrinsicWidth(height) - padding - border;
    return content + padding + border;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double content = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData pd =
          child.parentData as RenderLayoutParentData;
      final bool positioned = child is RenderBoxModel &&
          ((child).renderStyle.isSelfPositioned() ||
              (child).renderStyle.isSelfStickyPosition());
      if (!positioned) {
        content = child.getMinIntrinsicHeight(width);
        break;
      }
      child = pd.nextSibling;
    }
    final double padding = (renderStyle.paddingTop.computedValue +
        renderStyle.paddingBottom.computedValue);
    final double border = (renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue);
    if (content == 0.0)
      content = super.computeMinIntrinsicHeight(width) - padding - border;
    return content + padding + border;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double content = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData pd =
          child.parentData as RenderLayoutParentData;
      final bool positioned = child is RenderBoxModel &&
          ((child).renderStyle.isSelfPositioned() ||
              (child).renderStyle.isSelfStickyPosition());
      if (!positioned) {
        content = child.getMaxIntrinsicWidth(height);
        break;
      }
      child = pd.nextSibling;
    }
    final double padding = (renderStyle.paddingLeft.computedValue +
        renderStyle.paddingRight.computedValue);
    final double border = (renderStyle.effectiveBorderLeftWidth.computedValue +
        renderStyle.effectiveBorderRightWidth.computedValue);
    if (content == 0.0)
      content = super.computeMaxIntrinsicWidth(height) - padding - border;
    return content + padding + border;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double content = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData pd =
          child.parentData as RenderLayoutParentData;
      final bool positioned = child is RenderBoxModel &&
          ((child).renderStyle.isSelfPositioned() ||
              (child).renderStyle.isSelfStickyPosition());
      if (!positioned) {
        content = child.getMaxIntrinsicHeight(width);
        break;
      }
      child = pd.nextSibling;
    }
    final double padding = (renderStyle.paddingTop.computedValue +
        renderStyle.paddingBottom.computedValue);
    final double border = (renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue);
    if (content == 0.0)
      content = super.computeMaxIntrinsicHeight(width) - padding - border;
    return content + padding + border;
  }

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
  void move(RenderBox child, {RenderBox? after}) {
    super.move(child, after: after);
    _cachedPaintingOrder = null;
  }

  @override
  void performLayout() {
    beforeLayout();

    List<RenderBoxModel> positionedChildren = [];
    List<RenderBox> nonPositionedChildren = [];
    List<RenderBoxModel> stickyChildren = [];

    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel &&
          (child.renderStyle.isSelfPositioned() ||
              child.renderStyle.isSelfStickyPosition())) {
        positionedChildren.add(child);
      } else {
        nonPositionedChildren.add(child);
        if (child is RenderBoxModel && CSSPositionedLayout.isSticky(child)) {
          stickyChildren.add(child);
        }
      }
      child = childParentData.nextSibling;
    }

    // Need to layout out of flow positioned element before normal flow element
    // cause the size of RenderPositionPlaceholder in flex layout needs to use
    // the size of its original RenderBoxModel.
    for (RenderBoxModel child in positionedChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, child);
    }

    if (nonPositionedChildren.isNotEmpty) {
      _layoutChild(nonPositionedChildren.first);
    } else {
      performResize();
    }

    for (RenderBoxModel child in positionedChildren) {
      CSSPositionedLayout.applyPositionedChildOffset(this, child);
      // Apply sticky offset after setting base offset (no-op for non-sticky).
      CSSPositionedLayout.applyStickyChildOffset(this, child);
    }

    // Sticky children in this widget may also need dynamic paint offsets if they were not
    // classified as positioned at build-time. Apply here as a best-effort.
    for (RenderBoxModel stickyChild in stickyChildren) {
      CSSPositionedLayout.applyStickyChildOffset(this, stickyChild);
    }

    calculateBaseline();
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height),
        Rect.fromLTRB(0, 0, size.width, size.height));
    didLayout();
  }

  @override
  void performResize() {
    double width = 0, height = 0;
    final Size attempingSize = constraints.biggest;
    if (attempingSize.width.isFinite) {
      width = attempingSize.width;
    }
    if (attempingSize.height.isFinite) {
      height = attempingSize.height;
    }

    Size attemptedSize = Size(width, height);
    size = scrollableSize = getBoxSize(attemptedSize);
    assert(size.isFinite);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    final cached = computeCssLastBaselineOf(baseline);
    if (cached != null) return cached;
    double marginTop = renderStyle.marginTop.computedValue;
    double marginBottom = renderStyle.marginBottom.computedValue;
    // Use margin-bottom as baseline if layout has no children
    return computeCssFirstBaseline() ??
        marginTop + boxSize!.height + marginBottom;
  }

  @override
  void dispose() {
    super.dispose();
    stickyChildren.clear();
  }

  /// This class mixin [RenderProxyBoxMixin], which has its' own paint method,
  /// override it to layout box model paint.
  @override
  void paint(PaintingContext context, Offset offset) {
    // Check if the widget element has disabled box model painting
    if (renderStyle.target is WidgetElement) {
      final widgetElement = renderStyle.target as WidgetElement;
      if (widgetElement.disableBoxModelPaint) {
        // Call performPaint directly without box model painting
        performPaint(context, offset);
        return;
      }
    }

    // Default behavior: paint with box model
    paintBoxModel(context, offset);
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    // Report FCP/LCP when RenderWidget with contentful Flutter widget is first painted
    if (renderStyle.target is WidgetElement &&
        firstChild != null &&
        hasSize &&
        !size.isEmpty) {
      final widgetElement = renderStyle.target as WidgetElement;

      // Check if the widget contains contentful content and get the actual visible area
      double contentfulArea = _getContentfulPaintArea(widgetElement);
      if (contentfulArea > 0) {
        // Report FP first (if not already reported)
        widgetElement.ownerDocument.controller.reportFP();
        widgetElement.ownerDocument.controller.reportFCP();

        // Report LCP candidate with the actual contentful area
        widgetElement.ownerDocument.controller
            .reportLCPCandidate(widgetElement, contentfulArea);
      }
    }

    Offset accumulateOffsetFromDescendant(
        RenderObject descendant, RenderObject ancestor) {
      Offset sum = Offset.zero;
      RenderObject? cur = descendant;
      while (cur != null && cur != ancestor) {
        final Object? pd = (cur is RenderBox) ? (cur.parentData) : null;
        if (pd is ContainerBoxParentData) {
          sum += (pd).offset;
        } else if (pd is RenderLayoutParentData) {
          sum += (pd).offset;
        }
        cur = cur.parent;
      }
      return sum;
    }

    for (final RenderBox child in paintingOrder) {
      if (isPositionPlaceholder(child)) continue;
      final RenderLayoutParentData pd =
          child.parentData as RenderLayoutParentData;
      if (!child.hasSize) continue;

      bool restoreFlag = false;
      bool previous = false;
      final bool promoteHere = (renderStyle).isDocumentRootBox();
      if (promoteHere && child is RenderBoxModel) {
        final CSSRenderStyle rs = child.renderStyle;
        final int? zi = rs.zIndex;
        final bool isPositive = zi != null && zi > 0;
        if (!isPositive) {
          previous = rs.suppressPositiveStackingFromDescendants;
          rs.suppressPositiveStackingFromDescendants = true;
          if (child is RenderLayoutBox) {
            child.markChildrenNeedsSort();
          } else if (child is RenderWidget) {
            child.markChildrenNeedsSort();
          }
          restoreFlag = true;
        }
      }

      final bool direct = identical(child.parent, this);
      final Offset localOffset =
          direct ? pd.offset : accumulateOffsetFromDescendant(child, this);
      context.paintChild(child, offset + localOffset);

      if (restoreFlag && child is RenderBoxModel) {
        (child.renderStyle).suppressPositiveStackingFromDescendants = previous;
        if (child is RenderLayoutBox) {
          child.markChildrenNeedsSort();
        } else if (child is RenderWidget) {
          child.markChildrenNeedsSort();
        }
      }
    }
  }

  /// Gets the total visible area of contentful paint children.
  /// Returns 0 if no contentful paint is found.
  double _getContentfulPaintArea(WidgetElement widgetElement) {
    // Only check render objects created directly by the WidgetElement's state build() method
    // This uses a special method that skips any RenderBoxModel or RenderWidget children
    return ContentfulWidgetDetector.getContentfulPaintAreaFromFlutterWidget(
        firstChild);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    if (renderStyle.transformMatrix != null) {
      return hitTestIntrinsicChild(result, firstChild, position!);
    }

    RenderBox? child = lastChild;
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;

      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position!,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);

          if (child is RenderBoxModel) {
            CSSPositionType positionType = child.renderStyle.position;
            if (positionType == CSSPositionType.fixed) {
              // Keep hit testing in sync with RenderBoxModel.paintBoxModel.
              final Offset o = child.getFixedScrollCompensation();
              if (o.dx != 0.0 || o.dy != 0.0) transformed -= o;
            }
          }

          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }

      child = childParentData.previousSibling;
    }

    return false;
  }

  @override
  void calculateBaseline() {
    // Baselines returned by children are relative to the child's local
    // coordinate system. RenderWidget paints its child offset by its own
    // border+padding; include that offset so cached CSS baselines are
    // relative to the RenderWidget's border box top (CSS expectation).
    double borderTop = renderStyle.effectiveBorderTopWidth.computedValue;
    double paddingTop = renderStyle.paddingTop.computedValue;
    double topInset = borderTop + paddingTop;

    double? firstBaseline =
        firstChild?.getDistanceToBaseline(TextBaseline.alphabetic);
    double? lastBaseline =
        lastChild?.getDistanceToBaseline(TextBaseline.alphabetic);

    if (firstBaseline != null) firstBaseline += topInset;
    if (lastBaseline != null) lastBaseline += topInset;
    setCssBaselines(first: firstBaseline, last: lastBaseline);
  }
}

class RenderRepaintBoundaryWidget extends RenderWidget {
  RenderRepaintBoundaryWidget({required super.renderStyle});

  @override
  bool get isRepaintBoundary => true;
}
