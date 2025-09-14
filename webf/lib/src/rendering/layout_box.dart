/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
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
      ancestor = ancestor.parent as RenderObject?;
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
    if (isNegativeMarginChangeHSize) {
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

  @override
  void dispose() {
    super.dispose();

    stickyChildren.clear();
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
