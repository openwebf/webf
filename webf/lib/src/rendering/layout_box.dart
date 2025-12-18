/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';

abstract class RenderLayoutBox extends RenderBoxModel
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>>
    implements RenderAbstractViewport {
  RenderLayoutBox({required super.renderStyle});

  void markChildrenNeedsSort() {
    _cachedPaintingOrder = null;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    // Assign stable child indices for scroll semantics (indexInParent / scrollIndex).
    // This mirrors how Flutter's scroll views wrap children in RenderIndexedSemantics.
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final RenderLayoutParentData parentData = child.parentData as RenderLayoutParentData;
      parentData.semanticsIndex = index;
      visitor(child);
      child = parentData.nextSibling;
      index++;
    }
  }

  // Aggregate intrinsic sizing over non-positioned children.
  @override
  double computeMinIntrinsicWidth(double height) {
    double content = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      final bool positioned = child is RenderBoxModel &&
          ((child).renderStyle.isSelfPositioned() ||
              (child).renderStyle.isSelfStickyPosition());
      if (!positioned) {
        content = math.max(content, child.getMinIntrinsicWidth(height));
      }
      child = pd.nextSibling;
    }
    // Include paddings and borders to form the border-box size.
    final double padding = (renderStyle.paddingLeft.computedValue + renderStyle.paddingRight.computedValue);
    final double border = (renderStyle.effectiveBorderLeftWidth.computedValue +
        renderStyle.effectiveBorderRightWidth.computedValue);
    // Fallback to base if no children contributed.
    if (content == 0.0) content = super.computeMinIntrinsicWidth(height) - padding - border;
    return content + padding + border;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double content = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      final bool positioned = child is RenderBoxModel &&
          ((child).renderStyle.isSelfPositioned() ||
              (child).renderStyle.isSelfStickyPosition());
      if (!positioned) {
        content += child.getMinIntrinsicHeight(width);
      }
      child = pd.nextSibling;
    }
    final double padding = (renderStyle.paddingTop.computedValue + renderStyle.paddingBottom.computedValue);
    final double border = (renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue);
    if (content == 0.0) content = super.computeMinIntrinsicHeight(width) - padding - border;
    return content + padding + border;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double content = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      final bool positioned = child is RenderBoxModel &&
          ((child).renderStyle.isSelfPositioned() ||
              (child).renderStyle.isSelfStickyPosition());
      if (!positioned) {
        content = math.max(content, child.getMaxIntrinsicWidth(height));
      }
      child = pd.nextSibling;
    }
    final double padding = (renderStyle.paddingLeft.computedValue + renderStyle.paddingRight.computedValue);
    final double border = (renderStyle.effectiveBorderLeftWidth.computedValue +
        renderStyle.effectiveBorderRightWidth.computedValue);
    if (content == 0.0) content = super.computeMaxIntrinsicWidth(height) - padding - border;
    return content + padding + border;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double content = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      final bool positioned = child is RenderBoxModel &&
          ((child).renderStyle.isSelfPositioned() ||
              (child).renderStyle.isSelfStickyPosition());
      if (!positioned) {
        content += child.getMaxIntrinsicHeight(width);
      }
      child = pd.nextSibling;
    }
    final double padding = (renderStyle.paddingTop.computedValue + renderStyle.paddingBottom.computedValue);
    final double border = (renderStyle.effectiveBorderTopWidth.computedValue +
        renderStyle.effectiveBorderBottomWidth.computedValue);
    if (content == 0.0) content = super.computeMaxIntrinsicHeight(width) - padding - border;
    return content + padding + border;
  }

  // RenderAbstractViewport impl so Scrollable.ensureVisible can compute reveal offsets
  @override
  RevealedOffset getOffsetToReveal(RenderObject target, double alignment, {Rect? rect, Axis? axis}) {
    // WebF elements can scroll in both axes, but this method needs to work per axis
    // Determine which axis to use based on the axis parameter or default to vertical
    axis ??= Axis.vertical;

    // Get the rect in target's coordinate space
    rect ??= target.paintBounds;

    // If target is not our descendant, return current scroll position
    RenderObject? ancestor = target;
    while (ancestor != null && ancestor != this) {
      ancestor = ancestor.parent;
    }
    if (ancestor == null) {
      // Target is not our descendant, return current position
      return RevealedOffset(
        offset: axis == Axis.vertical ? scrollTop : scrollLeft,
        rect: rect,
      );
    }

    // Transform the rect from target's coordinate system to our coordinate system
    final Matrix4 transform = target.getTransformTo(this);
    Rect targetRect = MatrixUtils.transformRect(transform, rect);

    // The targetRect is now in our viewport's coordinate system (already accounts for current scroll)
    // To calculate the scroll offset needed, we need to work with the absolute position
    // Add the current scroll offset to get the position in content space
    final Rect targetInContentSpace = targetRect.translate(scrollLeft, scrollTop);

    // Get our viewport size (visible area)
    final Size viewportSize = scrollableViewportSize;

    // Calculate the target offset based on alignment and axis
    double targetOffset;
    if (axis == Axis.vertical) {
      // Vertical scrolling
      final double targetTop = targetInContentSpace.top;
      final double targetBottom = targetInContentSpace.bottom;
      final double targetHeight = targetInContentSpace.height;
      final double viewportHeight = viewportSize.height;

      // Calculate position based on alignment (0.0 = top, 0.5 = center, 1.0 = bottom)
      // For alignment=1.0 (bottom), we want the target at the bottom of the viewport
      if (targetHeight >= viewportHeight) {
        // Target is larger than viewport
        if (alignment == 1.0) {
          // Show the bottom of the target
          targetOffset = targetBottom - viewportHeight;
        } else if (alignment == 0.0) {
          // Show the top of the target
          targetOffset = targetTop;
        } else {
          // Center as much as possible
          targetOffset = targetTop + (targetHeight - viewportHeight) * alignment;
        }
      } else {
        // Target fits within viewport
        if (alignment == 1.0) {
          // Position target at bottom of viewport
          targetOffset = targetBottom - viewportHeight;
        } else if (alignment == 0.0) {
          // Position target at top of viewport
          targetOffset = targetTop;
        } else {
          // Position based on alignment
          final double availableSpace = viewportHeight - targetHeight;
          targetOffset = targetTop - (availableSpace * alignment);
        }
      }

      // Clamp to valid scroll range
      final double maxScroll = math.max(0.0, scrollableSize.height - viewportHeight);
      targetOffset = targetOffset.clamp(0.0, maxScroll);
    } else {
      // Horizontal scrolling
      final double targetLeft = targetInContentSpace.left;
      final double targetRight = targetInContentSpace.right;
      final double targetWidth = targetInContentSpace.width;
      final double viewportWidth = viewportSize.width;

      if (alignment == 1.0) {
        // Align right of target with right of viewport
        targetOffset = targetRight - viewportWidth;
      } else if (alignment == 0.0) {
        // Align left of target with left of viewport
        targetOffset = targetLeft;
      } else {
        // General alignment
        final double alignmentOffset = (viewportWidth - targetWidth) * alignment;
        targetOffset = targetLeft - alignmentOffset;
      }

      // Clamp to valid scroll range
      final double maxScroll = math.max(0.0, scrollableSize.width - viewportWidth);
      targetOffset = targetOffset.clamp(0.0, maxScroll);
    }

    // Calculate the rect position in viewport space after scrolling
    final Rect revealedRect;
    if (axis == Axis.vertical) {
      // After scrolling to targetOffset, the element will appear at:
      // its content space position minus the new scroll offset
      revealedRect = targetInContentSpace.translate(0.0, -targetOffset);
    } else {
      revealedRect = targetInContentSpace.translate(-targetOffset, 0.0);
    }

    return RevealedOffset(
      offset: targetOffset,
      rect: revealedRect,
    );
  }

  // Sort children into CSS painting order, used for paint and hitTest.
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
      // Implement CSS painting order buckets for a stacking context.
      List<RenderBox> normalFlow = [];
      List<RenderBoxModel> negatives = [];
      List<RenderBoxModel> positionedAutoOrZero = [];
      List<RenderBoxModel> positives = [];

      bool subtreeHasAutoOrZeroParticipant(RenderBox node, [int depth = 0]) {
        if (depth > 12) return false;
        // Check this node if it's a RenderBoxModel participant itself
        if (node is RenderBoxModel) {
          final rs = node.renderStyle;
          final int? zi = rs.zIndex;
          final bool positioned = rs.position != CSSPositionType.static;
          // z-index: 0 (including flex/grid items) or positioned with z-index:auto
          if (zi == 0 || (positioned && zi == null)) return true;
        }
        // Unwrap single-child wrappers
        if (node is RenderObjectWithChildMixin<RenderBox>) {
          final RenderBox? c = (node as dynamic).child as RenderBox?;
          if (c != null && subtreeHasAutoOrZeroParticipant(c, depth + 1)) return true;
        }
        // Iterate container children
        if (node is RenderLayoutBox) {
          RenderBox? c = node.firstChild;
          while (c != null) {
            if (subtreeHasAutoOrZeroParticipant(c, depth + 1)) return true;
            final RenderLayoutParentData pd = c.parentData as RenderLayoutParentData;
            c = pd.nextSibling;
          }
        }
        return false;
      }

      containerLayoutBox.visitChildren((RenderObject child) {
        if (child is RenderBoxModel) {
          final rs = child.renderStyle;
          final int? zi = rs.zIndex;
          final bool positioned = rs.position != CSSPositionType.static;
          if (zi != null && zi < 0) {
            negatives.add(child);
          } else if (zi != null && zi > 0) {
            positives.add(child);
          } else if (zi == 0) {
            // z-index: 0 establishes a stacking level similar to positioned auto/0,
            // including for flex/grid items which can have z-index without being positioned.
            positionedAutoOrZero.add(child);
          } else if (positioned && zi == null) {
            // Positioned with z-index: auto
            positionedAutoOrZero.add(child);
          } else {
            // Non-positioned descendants: if subtree contains any z-index:0 or auto-positioned participants,
            // elevate this container to the auto/0 layer so those participants paint in the correct phase
            // relative to siblings (e.g., flex item with z-index:0 vs. abspos auto).
            if (subtreeHasAutoOrZeroParticipant(child)) {
              positionedAutoOrZero.add(child);
            } else {
              normalFlow.add(child);
            }
          }
        } else {
          normalFlow.add(child as RenderBox);
        }
      });

      // Promote descendant stacking context roots with positive z-index into the
      // current container's positive bucket so that ordering can be resolved
      // across non-stacking ancestors — only for the document root stacking context.
      void collectPositiveStackingContexts(RenderBox node, List<RenderBoxModel> out, [int depth = 0]) {
        // Avoid degenerate deep recursion.
        if (depth > 64) return;
        if (node is RenderBoxModel) {
          final CSSRenderStyle rs = node.renderStyle;
          // If this node establishes its own stacking context, treat it as a
          // single participant at this level and do not descend further.
          if (rs.establishesStackingContext) {
            final int? zi = rs.zIndex;
            if (zi != null && zi > 0) out.add(node);
            return;
          }
        }
        // Descend into containers/wrappers that don't establish a stacking context.
        if (node is RenderObjectWithChildMixin<RenderBox>) {
          final RenderBox? c = (node as dynamic).child as RenderBox?;
          if (c != null) collectPositiveStackingContexts(c, out, depth + 1);
        }
        if (node is RenderLayoutBox) {
          RenderBox? c = node.firstChild;
          while (c != null) {
            collectPositiveStackingContexts(c, out, depth + 1);
            final RenderLayoutParentData pd = c.parentData as RenderLayoutParentData;
            c = pd.nextSibling;
          }
        }
      }

      // Only promote at the document root (<html>), to avoid interfering with normal
      // stacking of nested flex/grid containers.
      final bool promoteAtThisLevel = (renderStyle).isDocumentRootBox();
      if (promoteAtThisLevel) {
        for (final RenderBox nf in normalFlow) {
          collectPositiveStackingContexts(nf, positives);
        }
      }

      // Compare two render boxes by full document tree order using DOM compareDocumentPosition.
      int compareTreeOrder(RenderBoxModel a, RenderBoxModel b) {
        final Node aNode = a.renderStyle.target;
        final Node bNode = b.renderStyle.target;
        final DocumentPosition pos = aNode.compareDocumentPosition(bNode);
        // FOLLOWING means `a` is before `b` in document order.
        if (pos == DocumentPosition.FOLLOWING) return -1;
        if (pos == DocumentPosition.PRECEDING) return 1;
        // For disconnected/equivalent (shouldn't happen for normal nodes), fall back to stable order.
        return 0;
      }

      negatives.sort((a, b) {
        final int az = a.renderStyle.zIndex ?? 0;
        final int bz = b.renderStyle.zIndex ?? 0;
        if (az != bz) return az.compareTo(bz);
        return compareTreeOrder(a, b);
      });

      // For positioned with auto/0 z-index, order strictly by document tree order.
      positionedAutoOrZero.sort(compareTreeOrder);

      positives.sort((a, b) {
        final int az = a.renderStyle.zIndex ?? 0;
        final int bz = b.renderStyle.zIndex ?? 0;
        if (az != bz) return az.compareTo(bz);
        return compareTreeOrder(a, b);
      });

      final List<RenderBox> ordered = [];
      ordered.addAll(negatives.cast<RenderBox>());
      ordered.addAll(normalFlow);
      ordered.addAll(positionedAutoOrZero.cast<RenderBox>());
      ordered.addAll(positives.cast<RenderBox>());

      return ordered;
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
    Offset accumulateOffsetFromDescendant(RenderObject descendant, RenderObject ancestor) {
      Offset sum = Offset.zero;
      RenderObject? cur = descendant;
      while (cur != null && cur != ancestor) {
        final Object? pd = (cur is RenderBox) ? (cur.parentData) : null;
        if (pd is ContainerBoxParentData) {
          final Offset o = (pd).offset;
          sum += o;
        } else if (pd is RenderLayoutParentData) {
          sum += (pd).offset;
        }
        cur = cur.parent;
      }
      return sum;
    }

    for (int i = 0; i < paintingOrder.length; i++) {
      RenderBox child = paintingOrder[i];
      if (isPositionPlaceholder(child)) continue;

      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (!child.hasSize) continue;

      bool restoreFlag = false;
      bool previous = false;
      final bool promoteHere = (renderStyle).isDocumentRootBox();
      if (promoteHere && child is RenderBoxModel) {
        final CSSRenderStyle rs = child.renderStyle;
        final int? zi = rs.zIndex;
        final bool isPositive = zi != null && zi > 0;
        // Suppress painting of descendant positive stacking contexts when painting
        // normal-flow/auto/zero buckets; those positives are promoted to be painted
        // at this ancestor level to resolve cross-parent ordering.
        if (!isPositive) {
          previous = rs.suppressPositiveStackingFromDescendants;
          rs.suppressPositiveStackingFromDescendants = true;
          // Invalidate cached painting order on this child so suppression takes effect.
          if (child is RenderLayoutBox) {
            child.markChildrenNeedsSort();
          } else if (child is RenderWidget) {
            child.markChildrenNeedsSort();
          }
          restoreFlag = true;
        }
      }

      // Compute correct paint offset even if the render box to paint is not a direct child
      // of this container (e.g., promoted positive stacking contexts).
      final bool direct = identical(child.parent, this);
      final Offset localOffset = direct ? childParentData.offset : accumulateOffsetFromDescendant(child, this);
      context.paintChild(child, localOffset + offset);

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

  // Get all children as a list and detach them all.
  List<RenderBox> detachChildren() {
    List<RenderBox> children = getChildren();
    removeAll();
    return children;
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
    try {
      // Keep for future diagnostic hooks (no-op by default).
      final tag = renderStyle.target.tagName.toLowerCase();
      final disp = renderStyle.effectiveDisplay;
      final pType = parent?.runtimeType.toString() ?? 'null';
      final _ = '[BoxSize] <$tag> getContentSize in='
          '${contentWidth.toStringAsFixed(2)}×${contentHeight.toStringAsFixed(2)} '
          'display=$disp parent=$pType';
    } catch (_) {}
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
    if (isNegativeMarginChangeHSize) {
      marginAddSizeRight = marginLeft < 0 ? -marginLeft : 0;
      marginAddSizeLeft = marginRight < 0 ? -marginRight : 0;
    }
    // Flex items: when flex-basis is specified (not 'auto'), it overrides the
    // main-size property (width/height) for the base size per CSS Flexbox.
    // Use the resolved flex-basis as the specified content size on the main axis
    // so the item measures to its base size during intrinsic layout.
    if (renderStyle.isParentRenderFlexLayout()) {
      final CSSRenderStyle? parentRenderStyle = renderStyle.getAttachedRenderParentRenderStyle();
      final CSSLengthValue? flexBasisLV = renderStyle.flexBasis;
      final bool isFlexBasisContent = flexBasisLV?.type == CSSLengthType.CONTENT;
      final double? flexBasis = (flexBasisLV == null || flexBasisLV == CSSLengthValue.auto || isFlexBasisContent)
          ? null
          : flexBasisLV.computedValue;

      if (flexBasis != null && parentRenderStyle != null) {
        // Determine main-axis orientation with writing-mode awareness.
        final CSSWritingMode wm = parentRenderStyle.writingMode;
        final bool inlineIsHorizontal = (wm == CSSWritingMode.horizontalTb);
        final bool parentRow = parentRenderStyle.flexDirection == FlexDirection.row ||
            parentRenderStyle.flexDirection == FlexDirection.rowReverse;
        final bool isMainAxisHorizontal = parentRow ? inlineIsHorizontal : !inlineIsHorizontal;
        final bool isParentMainDefinite = isMainAxisHorizontal
            ? parentRenderStyle.contentBoxLogicalWidth != null
            : parentRenderStyle.contentBoxLogicalHeight != null;
      final bool isPctBasis = flexBasisLV!.type == CSSLengthType.PERCENTAGE;

      // Follow CSS spec: percentage flex-basis resolves against the flex container's main size;
      // if that size is indefinite, the used value is 'content'. In that case, do not override
      // the specified content size here—let content determine sizing.
      if (isPctBasis && !isParentMainDefinite) {
        // Skip overriding specified content size.
      } else if (flexBasis > 0) {
        // Only apply positive, resolvable flex-basis to content sizing here.
          if (isMainAxisHorizontal) {
            if (!hasOverrideContentLogicalWidth) {
              specifiedContentWidth = _getContentWidth(flexBasis);
            }
          } else {
            if (!hasOverrideContentLogicalHeight) {
              specifiedContentHeight = _getContentHeight(flexBasis);
            }
          }
        } else {
          // Non-positive flex-basis should not clamp intrinsic content to zero here.
        }
      }
    }

    // If an explicit content width is specified via CSS (width/min/max already
    // resolved above), it should determine the used content width. Do not
    // auto-expand to accommodate measured content here — overflow handling
    // should deal with larger content per CSS. Using max() causes blocks inside
    // unbounded containers (e.g. horizontal slivers) to incorrectly expand to
    // ancestor viewport widths instead of honoring the specified width.
    if (specifiedContentWidth != null) {
      finalContentWidth = specifiedContentWidth;
    }
    if (parent is RenderFlexLayout && marginAddSizeLeft > 0 && marginAddSizeRight > 0 ||
        parent is RenderFlowLayout && (marginAddSizeRight > 0 || marginAddSizeLeft > 0)) {
      finalContentWidth += marginAddSizeLeft;
      finalContentWidth += marginAddSizeRight;
    }
    // Same rule for height: honor the specified content height if provided
    // rather than expanding to measured content height here.
    if (specifiedContentHeight != null) {
      finalContentHeight = specifiedContentHeight;
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
      double minContentHeight = _getContentHeight(minHeight);
      finalContentHeight = finalContentHeight < minContentHeight ? minContentHeight : finalContentHeight;
    }

    Size finalContentSize = Size(finalContentWidth, finalContentHeight);

    try {
      // Keep for future diagnostic hooks (no-op by default).
      final tag = renderStyle.target.tagName.toLowerCase();
      final paddL = renderStyle.paddingLeft.computedValue;
      final paddR = renderStyle.paddingRight.computedValue;
      final bordL = renderStyle.effectiveBorderLeftWidth.computedValue;
      final bordR = renderStyle.effectiveBorderRightWidth.computedValue;
      final _ = '[BoxSize] <$tag> getContentSize out='
          '${finalContentSize.width.toStringAsFixed(2)}×${finalContentSize.height.toStringAsFixed(2)} '
          'padH=${(paddL + paddR).toStringAsFixed(2)} borderH=${(bordL + bordR).toStringAsFixed(2)}';
    } catch (_) {}
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('paintingOrder', paintingOrder));
  }

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
        if (result != null) {
          result = math.min(result, candidate);
        } else {
          result = candidate;
        }
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
