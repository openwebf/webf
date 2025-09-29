/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/foundation/logger.dart';
import 'package:webf/src/foundation/positioned_layout_logging.dart';

// CSS Positioned Layout: https://drafts.csswg.org/css-position/

// RenderPositionHolder may be affected by overflow: scroller offset.
// We need to reset these offset to keep positioned elements render at their original position.
// @NOTE: Attention that renderObjects in tree may not all subtype of RenderBoxModel, use `is` to identify.
Offset? _getRenderPositionHolderScrollOffset(RenderPositionPlaceholder holder, RenderObject root) {
  RenderObject? current = holder.parent;
  while (current != null && current != root) {
    if (current is RenderBoxModel) {
      if (current.clipX || current.clipY) {
        return Offset(current.scrollLeft, current.scrollTop);
      }
    }
    current = current.parent;
  }
  return null;
}

// Get the offset of the RenderPlaceholder of positioned element to its parent RenderBoxModel.
Offset _getPlaceholderToParentOffset(RenderPositionPlaceholder? placeholder, RenderBoxModel parent,
    {bool excludeScrollOffset = false}) {
  if (placeholder == null || !placeholder.attached) {
    return Offset.zero;
  }
  Offset positionHolderScrollOffset = _getRenderPositionHolderScrollOffset(placeholder, parent) ?? Offset.zero;
  // Offset of positioned element should exclude scroll offset to its containing block.
  Offset toParentOffset =
      placeholder.getOffsetToAncestor(Offset.zero, parent, excludeScrollOffset: excludeScrollOffset);
  Offset placeholderOffset = positionHolderScrollOffset + toParentOffset;

  return placeholderOffset;
}

class CSSPositionedLayout {
  static Offset? getRelativeOffset(RenderStyle renderStyle) {
    CSSLengthValue left = renderStyle.left;
    CSSLengthValue right = renderStyle.right;
    CSSLengthValue top = renderStyle.top;
    CSSLengthValue bottom = renderStyle.bottom;
    if (renderStyle.position == CSSPositionType.relative) {
      double? dx;
      double? dy;

      if (left.isNotAuto) {
        dx = renderStyle.left.computedValue;
      } else if (right.isNotAuto) {
        double _dx = renderStyle.right.computedValue;
        dx = -_dx;
      }

      if (top.isNotAuto) {
        dy = renderStyle.top.computedValue;
      } else if (bottom.isNotAuto) {
        double _dy = renderStyle.bottom.computedValue;
        dy = -_dy;
      }

      if (dx != null || dy != null) {
        return Offset(dx ?? 0, dy ?? 0);
      }
    }
    return null;
  }

  static void applyRelativeOffset(Offset? relativeOffset, RenderBox renderBox) {
    RenderLayoutParentData? boxParentData = renderBox.parentData as RenderLayoutParentData?;

    if (boxParentData != null) {
      Offset? styleOffset;
      // Text node does not have relative offset
      if (renderBox is RenderBoxModel) {
        styleOffset = getRelativeOffset(renderBox.renderStyle);
      }

      if (relativeOffset != null) {
        if (styleOffset != null) {
          boxParentData.offset = relativeOffset.translate(styleOffset.dx, styleOffset.dy);
        } else {
          boxParentData.offset = relativeOffset;
        }
      } else {
        boxParentData.offset = styleOffset!;
      }
    }
  }

  static bool isSticky(RenderBoxModel child) {
    final renderStyle = child.renderStyle;
    return renderStyle.position == CSSPositionType.sticky &&
        (renderStyle.top.isNotAuto ||
            renderStyle.left.isNotAuto ||
            renderStyle.bottom.isNotAuto ||
            renderStyle.right.isNotAuto);
  }

  // Set horizontal offset of sticky element.
  static bool _applyStickyChildHorizontalOffset(
    RenderBoxModel scrollContainer,
    RenderBoxModel child,
    Offset childOriginalOffset,
    Offset childToScrollContainerOffset,
  ) {
    bool isHorizontalFixed = false;
    double offsetX = childOriginalOffset.dx;
    double childWidth = child.boxSize!.width;
    double scrollContainerWidth = scrollContainer.boxSize!.width;
    // Dynamic offset to scroll container
    double offsetLeftToScrollContainer = childToScrollContainerOffset.dx;
    double offsetRightToScrollContainer = scrollContainerWidth - childWidth - offsetLeftToScrollContainer;
    RenderStyle childRenderStyle = child.renderStyle;
    RenderStyle? scrollContainerRenderStyle = scrollContainer.renderStyle;

    if (childRenderStyle.left.isNotAuto) {
      // Sticky offset to scroll container must include padding and border
      double stickyLeft = childRenderStyle.left.computedValue +
          scrollContainerRenderStyle.paddingLeft.computedValue +
          scrollContainerRenderStyle.effectiveBorderLeftWidth.computedValue;
      isHorizontalFixed = offsetLeftToScrollContainer < stickyLeft;
      if (isHorizontalFixed) {
        offsetX += stickyLeft - offsetLeftToScrollContainer;
        // Sticky child can not exceed the left boundary of its parent container
        RenderBoxModel parentContainer = child.parent as RenderBoxModel;
        double maxOffsetX = parentContainer.scrollableSize.width - childWidth;
        if (offsetX > maxOffsetX) {
          offsetX = maxOffsetX;
        }
      }
    } else if (childRenderStyle.left.isNotAuto) {
      // Sticky offset to scroll container must include padding and border
      double stickyRight = childRenderStyle.right.computedValue +
          scrollContainerRenderStyle.paddingRight.computedValue +
          scrollContainerRenderStyle.effectiveBorderRightWidth.computedValue;
      isHorizontalFixed = offsetRightToScrollContainer < stickyRight;
      if (isHorizontalFixed) {
        offsetX += offsetRightToScrollContainer - stickyRight;
        // Sticky element can not exceed the right boundary of its parent container
        double minOffsetX = 0;
        if (offsetX < minOffsetX) {
          offsetX = minOffsetX;
        }
      }
    }

    RenderLayoutParentData boxParentData = child.parentData as RenderLayoutParentData;
    boxParentData.offset = Offset(
      offsetX,
      boxParentData.offset.dy,
    );
    return isHorizontalFixed;
  }

  // Set vertical offset of sticky element.
  static bool _applyStickyChildVerticalOffset(
    RenderBoxModel scrollContainer,
    RenderBoxModel child,
    Offset childOriginalOffset,
    Offset childToScrollContainerOffset,
  ) {
    bool isVerticalFixed = false;
    double offsetY = childOriginalOffset.dy;
    double childHeight = child.boxSize!.height;
    double scrollContainerHeight = scrollContainer.boxSize!.height;
    // Dynamic offset to scroll container
    double offsetTopToScrollContainer = childToScrollContainerOffset.dy;
    double offsetBottomToScrollContainer = scrollContainerHeight - childHeight - offsetTopToScrollContainer;
    RenderStyle childRenderStyle = child.renderStyle;
    RenderStyle? scrollContainerRenderStyle = scrollContainer.renderStyle;

    if (childRenderStyle.top.isNotAuto) {
      // Sticky offset to scroll container must include padding and border
      double stickyTop = childRenderStyle.top.computedValue +
          scrollContainerRenderStyle.paddingTop.computedValue +
          scrollContainerRenderStyle.effectiveBorderTopWidth.computedValue;
      isVerticalFixed = offsetTopToScrollContainer < stickyTop;
      if (isVerticalFixed) {
        offsetY += stickyTop - offsetTopToScrollContainer;
        // Sticky child can not exceed the bottom boundary of its parent container
        // RenderBoxModel parentContainer = child.parent as RenderBoxModel;
        RenderBoxModel parentContainer = child.renderStyle.getParentRenderStyle()!.attachedRenderBoxModel!;
        double maxOffsetY = parentContainer.scrollableSize.height - childHeight;
        if (offsetY > maxOffsetY) {
          offsetY = maxOffsetY;
        }
      }
    } else if (childRenderStyle.bottom.isNotAuto) {
      // Sticky offset to scroll container must include padding and border
      double stickyBottom = childRenderStyle.bottom.computedValue +
          scrollContainerRenderStyle.paddingBottom.computedValue +
          scrollContainerRenderStyle.effectiveBorderBottomWidth.computedValue;
      isVerticalFixed = offsetBottomToScrollContainer < stickyBottom;
      if (isVerticalFixed) {
        offsetY += offsetBottomToScrollContainer - stickyBottom;
        // Sticky child can not exceed the upper boundary of its parent container
        double minOffsetY = 0;
        if (offsetY < minOffsetY) {
          offsetY = minOffsetY;
        }
      }
    }

    RenderLayoutParentData boxParentData = child.parentData as RenderLayoutParentData;
    boxParentData.offset = Offset(
      boxParentData.offset.dx,
      offsetY,
    );
    return isVerticalFixed;
  }

  // Set sticky child offset according to scroll offset and direction,
  // when axisDirection param is null compute the both axis direction.
  // Sticky positioning is similar to relative positioning except
  // the offsets are automatically calculated in reference to the nearest scrollport.
  // https://www.w3.org/TR/css-position-3/#stickypos-insets
  static void applyStickyChildOffset(RenderBoxModel scrollContainer, RenderBoxModel child) {
    RenderPositionPlaceholder? childRenderPositionHolder = child.renderStyle.getSelfPositionPlaceHolder();
    if (childRenderPositionHolder == null) return;
    RenderLayoutParentData? childPlaceHolderParentData = childRenderPositionHolder.parentData as RenderLayoutParentData?;
    if (childPlaceHolderParentData == null) return;
    // Original offset of sticky child in relative status
    Offset childOriginalOffset = childPlaceHolderParentData.offset;

    // Offset of sticky child to scroll container
    Offset childToScrollContainerOffset =
        childRenderPositionHolder.getOffsetToAncestor(Offset.zero, scrollContainer, excludeScrollOffset: true);

    bool isVerticalFixed = false;
    bool isHorizontalFixed = false;
    RenderStyle childRenderStyle = child.renderStyle;

    if (childRenderStyle.left.isNotAuto || childRenderStyle.right.isNotAuto) {
      isHorizontalFixed =
          _applyStickyChildHorizontalOffset(scrollContainer, child, childOriginalOffset, childToScrollContainerOffset);
    }
    if (childRenderStyle.top.isNotAuto || childRenderStyle.bottom.isNotAuto) {
      isVerticalFixed =
          _applyStickyChildVerticalOffset(scrollContainer, child, childOriginalOffset, childToScrollContainerOffset);
    }

    if (isVerticalFixed || isHorizontalFixed) {
      // Change sticky status to fixed
      child.stickyStatus = StickyPositionType.fixed;
      child.markNeedsPaint();
      try {
        final pd = child.parentData as RenderLayoutParentData;
        PositionedLayoutLog.log(
          impl: PositionedImpl.layout,
          feature: PositionedFeature.sticky,
          message: () => '<${child.renderStyle.target.tagName.toLowerCase()}>'
              ' sticky fixed(h=${isHorizontalFixed}, v=${isVerticalFixed}) at '
              '(${pd.offset.dx.toStringAsFixed(2)},${pd.offset.dy.toStringAsFixed(2)}) '
              'within <${scrollContainer.renderStyle.target.tagName.toLowerCase()}>',
        );
      } catch (_) {}
    } else {
      // Change sticky status to relative
      if (child.stickyStatus == StickyPositionType.fixed) {
        child.stickyStatus = StickyPositionType.relative;
        // Reset child offset to its original offset
        child.markNeedsPaint();
        try {
          final pd = child.parentData as RenderLayoutParentData;
          PositionedLayoutLog.log(
            impl: PositionedImpl.layout,
            feature: PositionedFeature.sticky,
            message: () => '<${child.renderStyle.target.tagName.toLowerCase()}>'
                ' sticky relative at '
                '(${pd.offset.dx.toStringAsFixed(2)},${pd.offset.dy.toStringAsFixed(2)}) '
                'within <${scrollContainer.renderStyle.target.tagName.toLowerCase()}>',
          );
        } catch (_) {}
      }
    }
  }

  static void layoutPositionedChild(RenderBoxModel parent, RenderBoxModel child, {bool needsRelayout = false}) {
    BoxConstraints childConstraints = child.getConstraints();

    // Whether child need to layout
    bool isChildNeedsLayout = true;
    if (child.hasSize && !needsRelayout && (childConstraints == child.constraints) && (!child.needsLayout)) {
      isChildNeedsLayout = false;
    }

    if (isChildNeedsLayout) {
      try {
        PositionedLayoutLog.log(
          impl: PositionedImpl.layout,
          feature: PositionedFeature.layout,
          message: () => '<${child.renderStyle.target.tagName.toLowerCase()}> layout start '
              'constraints=(${childConstraints.minWidth.toStringAsFixed(1)}..${childConstraints.maxWidth.isFinite ? childConstraints.maxWidth.toStringAsFixed(1) : '∞'}, '
              '${childConstraints.minHeight.toStringAsFixed(1)}..${childConstraints.maxHeight.isFinite ? childConstraints.maxHeight.toStringAsFixed(1) : '∞'})',
        );
      } catch (_) {}
      // Should create relayoutBoundary for positioned child.
      child.layout(childConstraints, parentUsesSize: false);
      try {
        final Size s = child.size;
        PositionedLayoutLog.log(
          impl: PositionedImpl.layout,
          feature: PositionedFeature.layout,
          message: () => '<${child.renderStyle.target.tagName.toLowerCase()}> layout done size=${s.width.toStringAsFixed(2)}×${s.height.toStringAsFixed(2)}',
        );
      } catch (_) {}
    }
  }

  // Position of positioned element involves inset, size , margin and its containing block size.
  // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
  static void applyPositionedChildOffset(
    RenderBoxModel parent,
    RenderBoxModel child,
  ) {
    RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
    Size size = child.boxSize!;
    Size parentSize = parent.boxSize!;

    RenderStyle parentRenderStyle = parent.renderStyle;

    CSSLengthValue parentBorderLeftWidth = parentRenderStyle.effectiveBorderLeftWidth;
    CSSLengthValue parentBorderRightWidth = parentRenderStyle.effectiveBorderRightWidth;
    CSSLengthValue parentBorderTopWidth = parentRenderStyle.effectiveBorderTopWidth;
    CSSLengthValue parentBorderBottomWidth = parentRenderStyle.effectiveBorderBottomWidth;
    CSSLengthValue parentPaddingLeft = parentRenderStyle.paddingLeft;
    CSSLengthValue parentPaddingTop = parentRenderStyle.paddingTop;

    // The containing block of not an inline box is formed by the padding edge of the ancestor.
    // Thus the final offset of child need to add the border of parent.
    // https://www.w3.org/TR/css-position-3/#def-cb
    Size containingBlockSize = Size(
        parentSize.width - parentBorderLeftWidth.computedValue - parentBorderRightWidth.computedValue,
        parentSize.height - parentBorderTopWidth.computedValue - parentBorderBottomWidth.computedValue);

    CSSRenderStyle childRenderStyle = child.renderStyle;
    CSSLengthValue left = childRenderStyle.left;
    CSSLengthValue right = childRenderStyle.right;
    CSSLengthValue top = childRenderStyle.top;
    CSSLengthValue bottom = childRenderStyle.bottom;
    CSSLengthValue marginLeft = childRenderStyle.marginLeft;
    CSSLengthValue marginRight = childRenderStyle.marginRight;
    CSSLengthValue marginTop = childRenderStyle.marginTop;
    CSSLengthValue marginBottom = childRenderStyle.marginBottom;

    // Fix side effects by render portal.
    if (child is RenderEventListener && child.child is RenderBoxModel) {
      child = child.child as RenderBoxModel;
      childParentData = child.parentData as RenderLayoutParentData;
    }

    // The static position of positioned element is its offset when its position property had been static
    // which equals to the position of its placeholder renderBox.
    // https://www.w3.org/TR/CSS2/visudet.html#static-position
    RenderPositionPlaceholder? ph = child.renderStyle.getSelfPositionPlaceHolder();
    Offset staticPositionOffset = _getPlaceholderToParentOffset(ph, parent,
        excludeScrollOffset: child.renderStyle.position != CSSPositionType.fixed);

    try {
      final pTag = parent.renderStyle.target.tagName.toLowerCase();
      final cTag = child.renderStyle.target.tagName.toLowerCase();
      final phOff = (ph != null && ph.parentData is RenderLayoutParentData)
          ? (ph.parentData as RenderLayoutParentData).offset
          : null;
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.staticPosition,
        message: () => '<$cTag> static from placeholder: raw=${phOff == null ? 'null' : '${phOff.dx.toStringAsFixed(2)},${phOff.dy.toStringAsFixed(2)}'} '
            'toParent=${staticPositionOffset.dx.toStringAsFixed(2)},${staticPositionOffset.dy.toStringAsFixed(2)} parent=<$pTag>',
      );
    } catch (_) {}

    // Ensure static position accuracy for W3C compliance
    // W3C requires static position to represent where element would be in normal flow
    Offset adjustedStaticPosition = _ensureAccurateStaticPosition(
      staticPositionOffset,
      child,
      parent,
      left,
      right,
      top,
      bottom,
      parentBorderLeftWidth,
      parentBorderRightWidth,
      parentBorderTopWidth,
      parentBorderBottomWidth,
      parentPaddingLeft,
      parentPaddingTop
    );

    // If the containing block is the document root (<html>) and the placeholder lives
    // under the block formatting context of <body>, align the static position vertically
    // with the first in-flow block-level child’s collapsed top (ignoring parent collapse).
    // This matches browser behavior where the first in-flow child’s top margin effectively
    // offsets the visible content from the root. The positioned element’s static position
    // should reflect that visual start so the out-of-flow element and the following in-flow
    // element align vertically when no insets are specified.
    if (parent.isDocumentRootBox && ph != null) {
      final RenderObject? phParent = ph.parent;
      if (phParent is RenderBoxModel) {
        final RenderBoxModel phContainer = phParent;
        final RenderStyle cStyle = phContainer.renderStyle;
        final bool qualifiesBFC =
            cStyle.isLayoutBox() &&
            cStyle.effectiveDisplay == CSSDisplay.block &&
            (cStyle.effectiveOverflowY == CSSOverflowType.visible || cStyle.effectiveOverflowY == CSSOverflowType.clip) &&
            cStyle.paddingTop.computedValue == 0 &&
            cStyle.effectiveBorderTopWidth.computedValue == 0;

        // Only adjust when placeholder is the first attached child (no previous in-flow block)
        final bool isFirstChild = (ph.parentData is RenderLayoutParentData) &&
            ((ph.parentData as RenderLayoutParentData).previousSibling == null);

        if (qualifiesBFC && isFirstChild) {
          final RenderBoxModel? firstFlow = _resolveNextInFlowSiblingModel(ph);
          if (firstFlow != null) {
            final double childTopIgnoringParent = firstFlow.renderStyle.collapsedMarginTopIgnoringParent;
            if (childTopIgnoringParent != 0) {
              adjustedStaticPosition = adjustedStaticPosition.translate(0, childTopIgnoringParent);
              try {
                PositionedLayoutLog.log(
                  impl: PositionedImpl.layout,
                  feature: PositionedFeature.staticPosition,
                  message: () => 'adjust static pos by first in-flow child top(${childTopIgnoringParent.toStringAsFixed(2)}) '
                      '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
                );
              } catch (_) {}
            }
          }
        }
      }
    }

    try {
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.staticPosition,
        message: () => 'adjusted static pos = (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
      );
    } catch (_) {}

    // Child renderObject is reparented under its containing block at build time,
    // and staticPositionOffset is already measured relative to the containing block.
    // No additional ancestor offset adjustment is needed.
    Offset ancestorOffset = Offset.zero;

    // ScrollTop and scrollLeft will be added to offset of renderBox in the paint stage
    // for positioned fixed element.
    if (childRenderStyle.position == CSSPositionType.fixed) {
      Offset scrollOffset = child.getTotalScrollOffset();
      child.additionalPaintOffsetX = scrollOffset.dx;
      child.additionalPaintOffsetY = scrollOffset.dy;
      try {
        PositionedLayoutLog.log(
          impl: PositionedImpl.layout,
          feature: PositionedFeature.fixed,
          message: () => '<${child.renderStyle.target.tagName.toLowerCase()}>'
              ' fixed paintOffset=(${scrollOffset.dx.toStringAsFixed(2)},${scrollOffset.dy.toStringAsFixed(2)})',
        );
      } catch (_) {}
    }

    // When the parent is a scroll container (overflow on either axis not visible),
    // convert positioned offsets to the scrolling content box coordinate space.
    // Overflow paint translates children relative to the content edge, so offsets
    // computed from the padding edge must exclude border and padding for alignment.
    final bool parentIsScrollContainer =
        parent.renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        parent.renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    double x = _computePositionedOffset(
      Axis.horizontal,
      false,
      parentBorderLeftWidth,
      parentPaddingLeft,
      containingBlockSize.width,
      size.width,
      adjustedStaticPosition.dx,
      left,
      right,
      marginLeft,
      marginRight,
    );

    double y = _computePositionedOffset(
      Axis.vertical,
      false,
      parentBorderTopWidth,
      parentPaddingTop,
      containingBlockSize.height,
      size.height,
      adjustedStaticPosition.dy,
      top,
      bottom,
      marginTop,
      marginBottom,
    );
    try {
      final dir = parent.renderStyle.direction;
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.offsets,
        message: () => 'compute offset for <${child.renderStyle.target.tagName.toLowerCase()}>'
            ' dir=$dir parentScroll=$parentIsScrollContainer left=${left.cssText()} right=${right.cssText()} '
            'top=${top.cssText()} bottom=${bottom.cssText()} → (${x.toStringAsFixed(2)},${y.toStringAsFixed(2)})',
      );
    } catch (_) {}

    final Offset finalOffset = Offset(x, y) - ancestorOffset;
    // If this positioned element is wrapped (e.g., by RenderEventListener), ensure
    // the wrapper is placed at the positioned offset so its background/border align
    // with the child content. The child uses internal offsets relative to the wrapper.
    bool placedWrapper = false;
    final RenderObject? directParent = child.parent;
    if (directParent is RenderEventListener) {
      final RenderLayoutParentData pd = directParent.parentData as RenderLayoutParentData;
      pd.offset = finalOffset;
      placedWrapper = true;
    }
    if (!placedWrapper) {
      childParentData.offset = finalOffset;
    }

    try {
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.offsets,
        message: () => 'apply offset final=(${finalOffset.dx.toStringAsFixed(2)},${finalOffset.dy.toStringAsFixed(2)}) '
            'from x=${x.toStringAsFixed(2)} y=${y.toStringAsFixed(2)} ancestor=(${ancestorOffset.dx.toStringAsFixed(2)},${ancestorOffset.dy.toStringAsFixed(2)})',
      );
    } catch (_) {}
  }

  // Resolve the next in-flow block-level RenderBoxModel sibling after a placeholder.
  // Skips wrappers (RenderEventListener) and ignores other placeholders.
  static RenderBoxModel? _resolveNextInFlowSiblingModel(RenderPositionPlaceholder ph) {
    RenderObject? current = ph;
    // Move to next sibling in the parent's child list
    if (ph.parentData is! RenderLayoutParentData) return null;
    RenderObject? next = (ph.parentData as RenderLayoutParentData).nextSibling as RenderObject?;
    while (next != null) {
      if (next is RenderPositionPlaceholder) {
        // Skip other placeholders
        current = next;
        next = (next.parentData as RenderLayoutParentData?)?.nextSibling as RenderObject?;
        continue;
      }
      if (next is RenderBoxModel) {
        final rs = next.renderStyle;
        if ((rs.effectiveDisplay == CSSDisplay.block || rs.effectiveDisplay == CSSDisplay.flex) && !rs.isSelfPositioned()) {
          return next;
        }
      }
      if (next is RenderEventListener) {
        final RenderBox? inner = next.child as RenderBox?;
        if (inner is RenderBoxModel) {
          final rs = inner.renderStyle;
          if ((rs.effectiveDisplay == CSSDisplay.block || rs.effectiveDisplay == CSSDisplay.flex) && !rs.isSelfPositioned()) {
            return inner;
          }
        }
      }
      // Fallback: advance to subsequent sibling
      current = next;
      next = (current.parentData as RenderLayoutParentData?)?.nextSibling as RenderObject?;
    }
    return null;
  }

  // Compute the offset of positioned element in one axis.
  static double _computePositionedOffset(
    Axis axis,
    bool isParentScrollingContentBox,
    CSSLengthValue parentBorderBeforeWidth,
    CSSLengthValue parentPaddingBefore,
    double containingBlockLength,
    double length,
    double staticPosition,
    CSSLengthValue insetBefore,
    CSSLengthValue insetAfter,
    CSSLengthValue marginBefore,
    CSSLengthValue marginAfter,
  ) {
    // Offset of positioned element in one axis.
    double offset;

    // Take horizontal axis for example.
    // left + margin-left + width + margin-right + right = width of containing block
    // Refer to the table of `Summary of rules for dir=ltr in horizontal writing modes` in following spec.
    // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
    if (insetBefore.isAuto && insetAfter.isAuto) {
      // If all three of left, width, and right are auto: First set any auto values for margin-left
      // and margin-right to 0. Then, if the direction property of the element establishing the
      // static-position containing block is ltr set left to the static position.
      offset = staticPosition;
    } else {
      if (insetBefore.isNotAuto && insetAfter.isNotAuto) {
        double freeSpace = containingBlockLength - length - insetBefore.computedValue - insetAfter.computedValue;
        double marginBeforeValue;

        if (marginBefore.isAuto && marginAfter.isAuto) {
          // Note: There is difference for auto margin resolve rule of horizontal and vertical axis.
          // margin-left is resolved as 0 only in horizontal axis and resolved as equal values of free space
          // in vertical axis, refer to following doc in the spec:
          //
          // If both margin-left and margin-right are auto, solve the equation under the extra constraint
          // that the two margins get equal values, unless this would make them negative, in which case
          // when direction of the containing block is ltr (rtl), set margin-left (margin-right) to 0
          // and solve for margin-right (margin-left).
          // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
          //
          // If both margin-top and margin-bottom are auto, solve the equation under the extra constraint
          // that the two margins get equal values.
          // https://www.w3.org/TR/css-position-3/#abs-non-replaced-height
          if (freeSpace < 0 && axis == Axis.horizontal) {
            // margin-left → '0', solve the above equation for margin-right
            marginBeforeValue = 0;
          } else {
            // margins split positive free space
            marginBeforeValue = freeSpace / 2;
          }
        } else if (marginBefore.isAuto && marginAfter.isNotAuto) {
          // If one of margin-left or margin-right is auto, solve the equation for that value.
          // Solve for margin-left in this case.
          marginBeforeValue = freeSpace - marginAfter.computedValue;
        } else {
          // If one of margin-left or margin-right is auto, solve the equation for that value.
          // Use specified margin-left in this case.
          marginBeforeValue = marginBefore.computedValue;
        }
        offset = parentBorderBeforeWidth.computedValue + insetBefore.computedValue + marginBeforeValue;
      } else if (insetBefore.isAuto && insetAfter.isNotAuto) {
        // If left/top is auto, width/height and right/bottom are not auto, then solve for left/top.
        // For vertical axis with bottom specified, we need to calculate position from the bottom edge
        double insetBeforeValue = containingBlockLength -
            length -
            insetAfter.computedValue -
            marginBefore.computedValue -
            marginAfter.computedValue;
        offset = parentBorderBeforeWidth.computedValue + insetBeforeValue + marginBefore.computedValue;
      } else {
        // If right is auto, left and width are not auto, then solve for right.
        offset = parentBorderBeforeWidth.computedValue + insetBefore.computedValue + marginBefore.computedValue;
      }

      // Convert position relative to scrolling content box.
      // Scrolling content box positions relative to the content edge of its parent.
      if (isParentScrollingContentBox) {
        offset = offset - parentBorderBeforeWidth.computedValue - parentPaddingBefore.computedValue;
      }
    }

    return offset;
  }

  /// Ensures accurate static position calculation for W3C compliance.
  ///
  /// According to W3C CSS Position Level 3, static position represents "an approximation
  /// of the position the box would have had if it were position: static".
  ///
  /// This method corrects cases where the placeholder-based static position calculation
  /// includes unwanted flow layout artifacts that don't represent true normal flow position.
  static Offset _ensureAccurateStaticPosition(
    Offset staticPositionOffset,
    RenderBoxModel child,
    RenderBoxModel parent,
    CSSLengthValue left,
    CSSLengthValue right,
    CSSLengthValue top,
    CSSLengthValue bottom,
    CSSLengthValue parentBorderLeftWidth,
    CSSLengthValue parentBorderRightWidth,
    CSSLengthValue parentBorderTopWidth,
    CSSLengthValue parentBorderBottomWidth,
    CSSLengthValue parentPaddingLeft,
    CSSLengthValue parentPaddingTop,
  ) {
    // Only process absolutely positioned elements
    if (child.renderStyle.position != CSSPositionType.absolute) {
      return staticPositionOffset;
    }

    RenderPositionPlaceholder? placeholder = child.renderStyle.getSelfPositionPlaceHolder();
    // Placeholder may live under a different parent than the containing block (e.g., under inline ancestor);
    // still valid: we can compute its offset to the containing block.
    if (placeholder == null) {
      return staticPositionOffset;
    }

    // Detect whether the placeholder is laid out inside a flex container.
    final bool placeholderInFlex = placeholder.parent is RenderFlexLayout;

    // W3C: When insets are auto, use static position. We may refine horizontal/vertical
    // axes when the placeholder’s current offset is known to be inaccurate, but by
    // default we keep the computed placeholder offset.
    bool shouldUseAccurateHorizontalPosition = left.isAuto && right.isAuto;
    bool shouldUseAccurateVerticalPosition = top.isAuto && bottom.isAuto;

    if (!shouldUseAccurateHorizontalPosition && !shouldUseAccurateVerticalPosition) {
      return staticPositionOffset;
    }

    // Check if current static position may be inaccurate due to flow layout artifacts
    bool needsCorrection = _staticPositionNeedsCorrection(placeholder, staticPositionOffset, parent);

    // Special-case: Inline Formatting Context containing block with no in-flow anchor
    // For absolutely positioned non-replaced elements with all insets auto, when the
    // containing block establishes an IFC and there is no in-flow sibling before the
    // placeholder (i.e., nothing to anchor in normal flow), browsers place the box at
    // the bottom-right corner of the padding box. Constrain within padding edges.
    final bool isIFCContainingBlock = parent is RenderFlowLayout && (parent as RenderFlowLayout).establishIFC;
    if (!placeholderInFlex && isIFCContainingBlock && left.isAuto && right.isAuto && top.isAuto && bottom.isAuto) {
      if (placeholder.parentData is RenderLayoutParentData) {
        final RenderLayoutParentData pd = placeholder.parentData as RenderLayoutParentData;
        if (pd.previousSibling == null) {
          final double padLeft = parentBorderLeftWidth.computedValue + parentPaddingLeft.computedValue;
          final double padTop = parentBorderTopWidth.computedValue + parentPaddingTop.computedValue;
          final Size parentSize = parent.boxSize ?? Size.zero;
          final Size childSize = child.boxSize ?? Size.zero;
          final double rightEdge = parentSize.width - parentBorderRightWidth.computedValue;
          final double bottomEdge = parentSize.height - parentBorderBottomWidth.computedValue;
          final double bx = math.max(padLeft, rightEdge - childSize.width);
          final double by = math.max(padTop, bottomEdge - childSize.height);
          return Offset(bx, by);
        }
      }
    }

    // Calculate the true normal flow position following W3C static position rules
    double contentAreaX = parentBorderLeftWidth.computedValue + parentPaddingLeft.computedValue;

    // For horizontal axis: use content area start only when a correction is necessary.
    double correctedX = (shouldUseAccurateHorizontalPosition && needsCorrection)
        ? contentAreaX
        : staticPositionOffset.dx;

    // Vertical axis: decide whether placeholder offset already accounts for the
    // element's own vertical margins. In normal flow (RenderFlowLayout), placeholders
    // are 0×0 and aligned to the following in-flow sibling without adding the positioned
    // element's own margins, so we must add the element's margin-top to reach the margin box.
    double correctedY = staticPositionOffset.dy +
        ((shouldUseAccurateVerticalPosition && !placeholderInFlex)
            ? child.renderStyle.marginTop.computedValue
            : 0);

    // Special handling for flex containers: if both top/bottom are auto and the
    // container aligns items to the center on the cross axis, align the static
    // position to the flex centering result using the container's content box.
    // This matches browser behavior where an abspos with all insets auto in a
    // row-direction flex container visually centers vertically when align-items:center.
    // For flex containers, refine the vertical static position when top/bottom are auto
    // and cross-axis centering applies (align-self/align-items center). The placeholder
    // is 0-height and is placed at the cross-axis center; we need to subtract half of the
    // child's box height so the top edge is positioned correctly.
    if (placeholderInFlex && (shouldUseAccurateVerticalPosition || shouldUseAccurateHorizontalPosition)) {
      // Use the flex container (placeholder's parent) to determine direction and alignment.
      final RenderFlexLayout flexContainer = placeholder.parent as RenderFlexLayout;
      final CSSRenderStyle pStyle = flexContainer.renderStyle;
      final FlexDirection dir = pStyle.flexDirection;
      final bool isRowDirection = (dir == FlexDirection.row || dir == FlexDirection.rowReverse);
      // Effective cross-axis alignment respects child's align-self when specified,
      // otherwise falls back to container's align-items.
      final AlignSelf self = child.renderStyle.alignSelf;
      final AlignItems parentAlignItems = pStyle.alignItems;
      final bool isCenter = self == AlignSelf.center || (self == AlignSelf.auto && parentAlignItems == AlignItems.center);
      final bool isEnd = self == AlignSelf.flexEnd || (self == AlignSelf.auto && parentAlignItems == AlignItems.flexEnd);
      final bool isStart = self == AlignSelf.flexStart || (self == AlignSelf.auto && parentAlignItems == AlignItems.flexStart);

      if (isRowDirection && shouldUseAccurateVerticalPosition) {
        // Compute from the flex container’s content box in the containing block’s
        // coordinate space: containerOffset + padding/border + alignment.
        final RenderLayoutParentData? phPD = placeholder.parentData as RenderLayoutParentData?;
        final Offset phOffsetInFlex = phPD?.offset ?? Offset.zero;
        // staticPositionOffset = flexOffsetToCB + placeholderOffsetInFlex
        final Offset flexOffsetToCB = staticPositionOffset - phOffsetInFlex;

        final double fcBorderTop = pStyle.effectiveBorderTopWidth.computedValue;
        final double fcBorderBottom = pStyle.effectiveBorderBottomWidth.computedValue;
        final double fcPadTop = pStyle.paddingTop.computedValue;
        final double fcPadBottom = pStyle.paddingBottom.computedValue;
        final Size fcSize = flexContainer.boxSize ?? Size.zero;
        final double fcContentH = (fcSize.height - fcBorderTop - fcBorderBottom - fcPadTop - fcPadBottom).clamp(0.0, double.infinity);
        final double childH = child.boxSize?.height ?? 0;
        final double contentTopInCB = flexOffsetToCB.dy + fcBorderTop + fcPadTop;
        if (isCenter) {
          correctedY = contentTopInCB + (fcContentH - childH) / 2.0;
        } else if (isEnd) {
          correctedY = contentTopInCB + (fcContentH - childH);
        } else if (isStart) {
          correctedY = contentTopInCB;
        }
      } else if (!isRowDirection && shouldUseAccurateHorizontalPosition) {
        // Column direction: cross-axis is horizontal. Compute left from the flex
        // container content box so the abspos element centers and updates when width changes.
        final RenderLayoutParentData? phPD = placeholder.parentData as RenderLayoutParentData?;
        final Offset phOffsetInFlex = phPD?.offset ?? Offset.zero;
        final Offset flexOffsetToCB = staticPositionOffset - phOffsetInFlex;

        final double fcBorderLeft = pStyle.effectiveBorderLeftWidth.computedValue;
        final double fcBorderRight = pStyle.effectiveBorderRightWidth.computedValue;
        final double fcPadLeft = pStyle.paddingLeft.computedValue;
        final double fcPadRight = pStyle.paddingRight.computedValue;
        final Size fcSize = flexContainer.boxSize ?? Size.zero;
        final double fcContentW = (fcSize.width - fcBorderLeft - fcBorderRight - fcPadLeft - fcPadRight).clamp(0.0, double.infinity);
        final double childW = child.boxSize?.width ?? 0;
        final double contentLeftInCB = flexOffsetToCB.dx + fcBorderLeft + fcPadLeft;
        if (isCenter) {
          correctedX = contentLeftInCB + (fcContentW - childW) / 2.0;
        } else if (isEnd) {
          correctedX = contentLeftInCB + (fcContentW - childW);
        } else if (isStart) {
          correctedX = contentLeftInCB;
        }
      }
    }

    // For non-flex containers, keep the placeholder-computed position with optional margin compensation.

    return Offset(correctedX, correctedY);
  }

  /// Determines if static position calculation needs correction to be W3C compliant.
  ///
  /// Checks for cases where flow layout artifacts may have affected the placeholder
  /// position in ways that don't represent true normal flow position.
  static bool _staticPositionNeedsCorrection(
    RenderPositionPlaceholder placeholder,
    Offset staticPositionOffset,
    RenderBoxModel parent,
  ) {
    if (placeholder.parentData is! RenderLayoutParentData) {
      return false;
    }

    RenderLayoutParentData placeholderData = placeholder.parentData as RenderLayoutParentData;
    RenderBox? previousSibling = placeholderData.previousSibling;

    if (previousSibling == null) {
      return false;
    }

    // Static position may need correction if it follows certain layout patterns
    // that can introduce unwanted offsets not representative of normal flow

    // Case 1: Direct replaced element
    if (previousSibling is RenderReplaced) {
      return _hasSignificantOffset(staticPositionOffset, parent);
    }

    // Case 2: Interactive replaced element (wrapped in RenderEventListener)
    if (previousSibling is RenderEventListener &&
        previousSibling.child is RenderReplaced) {
      return _hasSignificantOffset(staticPositionOffset, parent);
    }

    return false;
  }

  /// Calculates the true vertical static position by considering the normal document flow.
  ///
  /// Unlike horizontal positioning which typically starts at the content area,
  /// vertical positioning must account for where the element would actually appear
  /// in the normal flow after previous siblings.
  static double _calculateTrueVerticalStaticPosition(
    RenderPositionPlaceholder placeholder,
    RenderBoxModel parent,
    Offset currentStaticPosition,
  ) {
    // Static position should reflect where the element would appear in normal
    // flow without collapsing with the parent. Use the element's own top margin
    // collapsed only with its first in-flow child (if any), i.e., ignoring
    // parent collapse, so positioned elements' margins do not disappear.
    final RenderBoxModel? positioned = placeholder.positioned;
    if (positioned != null) {
      // For absolutely positioned elements, the static position uses the box's
      // own used margin values (no margin-collapsing with descendants).
      // Use the specified margin-top to offset from the placeholder position.
      final double ownTopMargin = positioned.renderStyle.marginTop.computedValue;
      return currentStaticPosition.dy + ownTopMargin;
    }
    return currentStaticPosition.dy;
  }

  /// Checks if the static position has significant offset that may indicate
  /// flow layout artifacts rather than true normal flow position.
  static bool _hasSignificantOffset(Offset staticPosition, RenderBoxModel parent) {
    RenderStyle parentStyle = parent.renderStyle;
    double expectedX = parentStyle.effectiveBorderLeftWidth.computedValue +
                      parentStyle.paddingLeft.computedValue;
    double expectedY = parentStyle.effectiveBorderTopWidth.computedValue +
                      parentStyle.paddingTop.computedValue;

    // Allow small tolerance for rounding differences
    const double tolerance = 1.0;

    // If static position is significantly different from content area start,
    // it may need correction
    bool hasUnexpectedHorizontalOffset = (staticPosition.dx - expectedX).abs() > tolerance;
    bool hasUnexpectedVerticalOffset = (staticPosition.dy - expectedY).abs() > tolerance;

    return hasUnexpectedHorizontalOffset || hasUnexpectedVerticalOffset;
  }
}
