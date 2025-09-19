/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/src/html/text.dart';
import 'package:webf/src/foundation/logger.dart';

// Enable verbose baseline logging for flex baseline alignment.
// Toggle at runtime: import 'package:webf/rendering.dart' and set to true.
bool debugLogFlexBaselineEnabled = false;
// Verbose logging for flex sizing and constraints; toggle at runtime.
bool debugLogFlexEnabled = false;

String _fmtC(BoxConstraints c) =>
    'C[minW=${c.minWidth.toStringAsFixed(1)}, maxW=${c.maxWidth.isFinite ? c.maxWidth.toStringAsFixed(1) : '∞'}, '
    'minH=${c.minHeight.toStringAsFixed(1)}, maxH=${c.maxHeight.isFinite ? c.maxHeight.toStringAsFixed(1) : '∞'}]';

String _fmtS(Size s) => 'S(${s.width.toStringAsFixed(1)}×${s.height.toStringAsFixed(1)})';

String _childDesc(RenderBox child) {
  if (child is RenderBoxModel) {
    final el = child.renderStyle.target;
    final tag = el.tagName.toLowerCase();
    final id = (el.id != null && el.id!.isNotEmpty) ? '#${el.id}' : '';
    final cls = (el.className.isNotEmpty) ? '.${el.className}' : '';
    return '$tag$id$cls@${child.hashCode.toRadixString(16)}';
  }
  return '${child.runtimeType}@${child.hashCode.toRadixString(16)}';
}

// Position and size info of each run (flex line) in flex layout.
// https://www.w3.org/TR/css-flexbox-1/#flex-lines
class _RunMetrics {
  _RunMetrics(
    this.mainAxisExtent,
    this.crossAxisExtent,
    double totalFlexGrow,
    double totalFlexShrink,
    this.baselineExtent,
    this.runChildren,
    double remainingFreeSpace,
  )   : _totalFlexGrow = totalFlexGrow,
        _totalFlexShrink = totalFlexShrink,
        _remainingFreeSpace = remainingFreeSpace;

  // Main size extent of the run.
  double mainAxisExtent;

  // Cross size extent of the run.
  double crossAxisExtent;

  // Total flex grow factor in the run.
  double get totalFlexGrow => _totalFlexGrow;
  double _totalFlexGrow;

  set totalFlexGrow(double value) {
    if (_totalFlexGrow != value) {
      _totalFlexGrow = value;
    }
  }

  // Total flex shrink factor in the run.
  double get totalFlexShrink => _totalFlexShrink;
  double _totalFlexShrink;

  set totalFlexShrink(double value) {
    if (_totalFlexShrink != value) {
      _totalFlexShrink = value;
    }
  }

  // Max extent above each flex items in the run.
  final double baselineExtent;

  // All the children RenderBox of layout in the run.
  final Map<int?, _RunChild> runChildren;

  // Remaining free space in the run.
  double get remainingFreeSpace => _remainingFreeSpace;
  double _remainingFreeSpace = 0;

  set remainingFreeSpace(double value) {
    if (_remainingFreeSpace != value) {
      _remainingFreeSpace = value;
    }
  }
}

// Infos about flex item in the run.
class _RunChild {
  _RunChild(
    RenderBox child,
    double originalMainSize,
    double flexedMainSize,
    bool frozen,
  )   : _child = child,
        _originalMainSize = originalMainSize,
        _flexedMainSize = flexedMainSize,
        _frozen = frozen;

  // Render object of flex item.
  RenderBox get child => _child;
  RenderBox _child;

  set child(RenderBox value) {
    if (_child != value) {
      _child = value;
    }
  }

  // Original main size on first layout.
  double get originalMainSize => _originalMainSize;
  double _originalMainSize;

  set originalMainSize(double value) {
    if (_originalMainSize != value) {
      _originalMainSize = value;
    }
  }

  // Adjusted main size after flexible length resolve algorithm.
  double get flexedMainSize => _flexedMainSize;
  double _flexedMainSize;

  set flexedMainSize(double value) {
    if (_flexedMainSize != value) {
      _flexedMainSize = value;
    }
  }

  // Whether flex item should be frozen in flexible length resolve algorithm.
  bool get frozen => _frozen;
  bool _frozen = false;

  set frozen(bool value) {
    if (_frozen != value) {
      _frozen = value;
    }
  }
}

/// ## Layout algorithm
///
/// _This section describes how the framework causes [RenderFlowLayout] to position
/// its children._
///
/// Layout for a [RenderFlowLayout] proceeds in 7 steps:
///
/// 1. Layout positioned (eg. absolute/fixed) child first cause the size of position placeholder renderObject which is
///    layouted later depends on the size of its original RenderBoxModel.
/// 2. Layout flex items (not including position child and its position placeholder renderObject)
///    with no constraints and compute information of flex lines.
/// 3. Relayout children if flex factor styles (eg. flex-grow/flex-shrink) or cross axis stretch style (eg. align-items) exist.
/// 4. Set flex container depends on children size and container size styles.
/// 5. Set children offset based on flex container size and flex alignment styles (eg. justify-content).
/// 6. Layout and set offset of all the positioned placeholder renderObjects based on flex container size and
///    flex alignment styles cause positioned placeholder renderObject layout in a separated layer which is different
///    from flow layout algorithm.
/// 7. Set positioned child offset based on flex container size and its offset styles (eg. top/right/bottom/left).
///
class RenderFlexLayout extends RenderLayoutBox {
  RenderFlexLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle) {
    addAll(children);
  }

  // Flex line boxes of flex layout.
  // https://www.w3.org/TR/css-flexbox-1/#flex-lines
  List<_RunMetrics> _flexLineBoxMetrics = <_RunMetrics>[];

  // Cache the intrinsic size of children before flex-grow/flex-shrink
  // to avoid relayout when style of flex items changes.
  final Map<int, double> _childrenIntrinsicMainSizes = {};

  // Cache original constraints of children on the first layout.
  final Map<int, BoxConstraints> _childrenOldConstraints = {};

  @override
  void dispose() {
    super.dispose();

    // Do not forget to clear reference variables, or it will cause memory leaks!
    _flexLineBoxMetrics.clear();
    _childrenIntrinsicMainSizes.clear();
    _childrenOldConstraints.clear();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  bool get _isHorizontalFlexDirection {
    return CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection);
  }

  // Get start/end padding in the main axis according to flex direction.
  double _flowAwareMainAxisPadding({bool isEnd = false}) {
    if (_isHorizontalFlexDirection) {
      return isEnd ? renderStyle.paddingRight.computedValue : renderStyle.paddingLeft.computedValue;
    } else {
      return isEnd ? renderStyle.paddingBottom.computedValue : renderStyle.paddingTop.computedValue;
    }
  }

  // Get start/end padding in the cross axis according to flex direction.
  double _flowAwareCrossAxisPadding({bool isEnd = false}) {
    if (_isHorizontalFlexDirection) {
      return isEnd ? renderStyle.paddingBottom.computedValue : renderStyle.paddingTop.computedValue;
    } else {
      return isEnd ? renderStyle.paddingRight.computedValue : renderStyle.paddingLeft.computedValue;
    }
  }

  // Get start/end border in the main axis according to flex direction.
  double _flowAwareMainAxisBorder({bool isEnd = false}) {
    if (_isHorizontalFlexDirection) {
      return isEnd
          ? renderStyle.effectiveBorderRightWidth.computedValue
          : renderStyle.effectiveBorderLeftWidth.computedValue;
    } else {
      return isEnd
          ? renderStyle.effectiveBorderBottomWidth.computedValue
          : renderStyle.effectiveBorderTopWidth.computedValue;
    }
  }

  // Get start/end border in the cross axis according to flex direction.
  double _flowAwareCrossAxisBorder({bool isEnd = false}) {
    if (_isHorizontalFlexDirection) {
      return isEnd
          ? renderStyle.effectiveBorderBottomWidth.computedValue
          : renderStyle.effectiveBorderTopWidth.computedValue;
    } else {
      return isEnd
          ? renderStyle.effectiveBorderRightWidth.computedValue
          : renderStyle.effectiveBorderLeftWidth.computedValue;
    }
  }

  // Get start/end margin of child in the main axis according to flex direction.
  double? _flowAwareChildMainAxisMargin(RenderBox child, {bool isEnd = false}) {
    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      childRenderBoxModel = child.positioned;
    }
    if (childRenderBoxModel == null) {
      return 0;
    }

    if (_isHorizontalFlexDirection) {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginRight.computedValue
          : childRenderBoxModel.renderStyle.marginLeft.computedValue;
    } else {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginBottom.computedValue
          : childRenderBoxModel.renderStyle.marginTop.computedValue;
    }
  }

  double _calculateMainAxisMarginForJustContentType(double margin) {
    if (renderStyle.justifyContent == JustifyContent.spaceBetween && margin < 0) {
      return margin / 2;
    }
    return margin;
  }

  // Get start/end margin of child in the cross axis according to flex direction.
  double? _flowAwareChildCrossAxisMargin(RenderBox child, {bool isEnd = false}) {
    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      childRenderBoxModel = child.positioned;
    }

    if (childRenderBoxModel == null) {
      return 0;
    }
    if (_isHorizontalFlexDirection) {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginBottom.computedValue
          : childRenderBoxModel.renderStyle.marginTop.computedValue;
    } else {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginRight.computedValue
          : childRenderBoxModel.renderStyle.marginLeft.computedValue;
    }
  }

  bool isFlexNone(RenderBox child) {
    // Placeholder have the safe effect to flex: none.
    if (child is RenderPositionPlaceholder) {
      return true;
    }
    double flexGrow = _getFlexGrow(child);
    double flexShrink = _getFlexShrink(child);
    double? flexBasis = _getFlexBasis(child);
    return flexBasis == null && flexGrow == 0 && flexShrink == 0;
  }

  double _getFlexGrow(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element.
    if (child is RenderPositionPlaceholder) {
      return 0;
    }
    return child is RenderBoxModel ? child.renderStyle.flexGrow : 0.0;
  }

  double _getFlexShrink(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element.
    if (child is RenderPositionPlaceholder) {
      return 0;
    }
    return child is RenderBoxModel ? child.renderStyle.flexShrink : 0.0;
  }

  double? _getFlexBasis(RenderBox child) {
    if (child is RenderBoxModel && child.renderStyle.flexBasis != CSSLengthValue.auto) {
      // flex-basis: content → base size is content-based; do not return a numeric value here
      if (child.renderStyle.flexBasis?.type == CSSLengthType.CONTENT) {
        return null;
      }
      double? flexBasis = child.renderStyle.flexBasis?.computedValue;

      // Clamp flex-basis by min and max size.
      if (flexBasis != null) {
        double? minWidth = child.renderStyle.minWidth.isAuto ? null : child.renderStyle.minWidth.computedValue;
        double? minHeight = child.renderStyle.minHeight.isAuto ? null : child.renderStyle.minHeight.computedValue;
        double? maxWidth = child.renderStyle.maxWidth.isNone ? null : child.renderStyle.maxWidth.computedValue;
        double? maxHeight = child.renderStyle.maxHeight.isNone ? null : child.renderStyle.maxHeight.computedValue;
        double? minMainSize = _isHorizontalFlexDirection ? minWidth : minHeight;
        double? maxMainSize = _isHorizontalFlexDirection ? maxWidth : maxHeight;

        if (minMainSize != null && flexBasis < minMainSize) flexBasis = minMainSize;
        if (maxMainSize != null && flexBasis > maxMainSize) flexBasis = maxMainSize;
      }

      ///  https://www.w3.org/TR/2018/CR-css-flexbox-1-20181119/#flex-basis-property
      ///  percentage values of flex-basis are resolved against the flex item’s containing block (i.e. its flex container);
      ///  and if that containing block’s size is indefinite, the used value for flex-basis is content.
      // Note: When flex-basis is 0%, it should remain 0, not be changed to minContentWidth
      // The commented code below was incorrectly setting flexBasis to minContentWidth for 0% values
      if (flexBasis != null && flexBasis == 0 && child.renderStyle.flexBasis?.type == CSSLengthType.PERCENTAGE) {
        // When the flex container’s main size is indefinite, CSS says the used
        // value of a percentage flex-basis becomes 'content'. Defer to content-based
        // sizing by returning null here so the item measures itself naturally first.
        // This avoids prematurely substituting an uninitialized min-content size (0).
        bool isMainSizeDefinite = _isHorizontalFlexDirection
            ? renderStyle.contentBoxLogicalWidth != null
            : renderStyle.contentBoxLogicalHeight != null;
        if (!isMainSizeDefinite) {
          return null;
        }
      }

      return flexBasis;
    }
    return null;
  }

  AlignSelf _getAlignSelf(RenderBox child) {
    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      childRenderBoxModel = child.positioned;
    }
    if (childRenderBoxModel != null) {
      return childRenderBoxModel.renderStyle.alignSelf;
    }
    return AlignSelf.auto;
  }

  double _getMaxMainAxisSize(RenderBox child) {
    double? maxMainSize;
    if (child is RenderBoxModel) {
      if (_isHorizontalFlexDirection) {
        maxMainSize = child.renderStyle.maxWidth.isNone ? null : child.renderStyle.maxWidth.computedValue;
      } else {
        maxMainSize = child.renderStyle.maxHeight.isNone ? null : child.renderStyle.maxHeight.computedValue;
      }
    }
    return maxMainSize ?? double.infinity;
  }

  double _getMinMainAxisSize(RenderBox child) {
    double? minMainSize;
    if (child is RenderBoxModel) {
      double autoMinSize = _getAutoMinSize(child);
      if (_isHorizontalFlexDirection) {
        minMainSize = child.renderStyle.minWidth.isAuto ? autoMinSize : child.renderStyle.minWidth.computedValue;
      } else {
        minMainSize = child.renderStyle.minHeight.isAuto ? autoMinSize : child.renderStyle.minHeight.computedValue;
      }
    }

    return minMainSize ?? 0;
  }

  // Find and mark elements that only contain text boxes for flex relayout optimization.
  // This enables text boxes to use infinite width during flex layout to expand naturally,
  // preventing box constraint errors when flex items are resized.
  void _markFlexRelayoutForTextOnly(RenderBoxModel boxModel) {
    if (boxModel is RenderEventListener) {
      RenderObject? child = boxModel.child;
      if (child is RenderTextBox) {
        // RenderEventListener directly contains a text box - mark it for flex relayout
        _setFlexRelayoutForTextParent(boxModel);
      } else if (child is RenderLayoutBox) {
        // RenderEventListener contains a layout box - check if that layout box only contains text
        _markRenderLayoutBoxForTextOnly(child);
      }
    } else if (boxModel is RenderLayoutBox) {
      // Check if this layout box only contains text
      _markRenderLayoutBoxForTextOnly(boxModel);
    }
  }

  // Mark a RenderLayoutBox for flex relayout if it contains only a single RenderTextBox child.
  // This optimization allows the text to use flexible width constraints during flex layout,
  // preventing constraint violations when the flex container adjusts item sizes.
  // Only apply when the flex container itself has indefinite width.
  void _markRenderLayoutBoxForTextOnly(RenderLayoutBox layoutBox) {
    if (layoutBox.childCount == 1) {
      RenderObject? firstChild = layoutBox.firstChild;
      if (firstChild is RenderEventListener) {
        RenderObject? child = firstChild.child;
        if (child is RenderTextBox) {
          _setFlexRelayoutForTextParent(firstChild);
        } else if (child is RenderLayoutBox) {
          _markRenderLayoutBoxForTextOnly(child);
        }
      } else if (firstChild is RenderTextBox) {
        _setFlexRelayoutForTextParent(layoutBox);
      }
    }
  }

  void _setFlexRelayoutForTextParent(RenderBoxModel textParentBoxModel) {
    if( textParentBoxModel.renderStyle.display == CSSDisplay.flex &&
        textParentBoxModel.renderStyle.width.isAuto &&
        !textParentBoxModel.constraints.hasBoundedWidth) {
      textParentBoxModel.isFlexRelayout = true;
    }
  }

  @override
  bool get isNegativeMarginChangeHSize {
    double? marginLeft = renderStyle.marginLeft.computedValue;
    double? marginRight = renderStyle.marginRight.computedValue;
    return renderStyle.width.isAuto && marginLeft < 0 && marginRight < 0;
  }

  // Calculate automatic minimum size of flex item.
  // Refer to https://www.w3.org/TR/css-flexbox-1/#min-size-auto for detail rules
  double _getAutoMinSize(RenderBoxModel child) {
    RenderStyle? childRenderStyle = child.renderStyle;
    double? childAspectRatio = childRenderStyle.aspectRatio;
    double? childLogicalWidth = child.renderStyle.borderBoxLogicalWidth;
    double? childLogicalHeight = child.renderStyle.borderBoxLogicalHeight;

    // If the item’s computed main size property is definite, then the specified size suggestion is that size
    // (clamped by its max main size property if it’s definite). It is otherwise undefined.
    // https://www.w3.org/TR/css-flexbox-1/#specified-size-suggestion
    double? specifiedSize = _isHorizontalFlexDirection ? childLogicalWidth : childLogicalHeight;

    // If the item has an intrinsic aspect ratio and its computed cross size property is definite, then the
    // transferred size suggestion is that size (clamped by its min and max cross size properties if they
    // are definite), converted through the aspect ratio. It is otherwise undefined.
    // https://www.w3.org/TR/css-flexbox-1/#transferred-size-suggestion
    double? transferredSize;
    if (childAspectRatio != null) {
      if (_isHorizontalFlexDirection && childLogicalHeight != null) {
        transferredSize = childLogicalHeight * childAspectRatio;
      } else if (!_isHorizontalFlexDirection && childLogicalWidth != null) {
        transferredSize = childLogicalWidth / childAspectRatio;
      }
    }

    // The content size suggestion is the min-content size in the main axis, clamped, if it has an aspect ratio,
    // by any definite min and max cross size properties converted through the aspect ratio, and then further
    // clamped by the max main size property if that is definite.
    // https://www.w3.org/TR/css-flexbox-1/#content-size-suggestion
    double contentSize = _isHorizontalFlexDirection ? child.minContentWidth : child.minContentHeight;

    CSSLengthValue childCrossSize = _isHorizontalFlexDirection ? childRenderStyle.height : childRenderStyle.width;

    if (childCrossSize.isNotAuto && transferredSize != null) {
      contentSize = transferredSize;
    }

    // Transferred min and max size.
    // https://www.w3.org/TR/css-sizing-4/#aspect-ratio-size-transfers
    double? transferredMinSize;
    double? transferredMaxSize;
    if (childAspectRatio != null) {
      if (_isHorizontalFlexDirection) {
        if (childRenderStyle.minHeight.isNotAuto) {
          transferredMinSize = childRenderStyle.minHeight.computedValue * childAspectRatio;
        } else if (childRenderStyle.maxHeight.isNotNone) {
          transferredMaxSize = childRenderStyle.maxHeight.computedValue * childAspectRatio;
        }
      } else if (!_isHorizontalFlexDirection) {
        if (childRenderStyle.minWidth.isNotAuto) {
          transferredMinSize = childRenderStyle.minWidth.computedValue / childAspectRatio;
        } else if (childRenderStyle.maxWidth.isNotNone) {
          transferredMaxSize = childRenderStyle.maxWidth.computedValue * childAspectRatio;
        }
      }
    }

    // Clamped by any definite min and max cross size properties converted through the aspect ratio.
    if (transferredMinSize != null && contentSize < transferredMinSize) {
      contentSize = transferredMinSize;
    }
    if (transferredMaxSize != null && contentSize > transferredMaxSize) {
      contentSize = transferredMaxSize;
    }

    double? crossSize =
        _isHorizontalFlexDirection ? renderStyle.contentBoxLogicalHeight : renderStyle.contentBoxLogicalWidth;

    // Content size suggestion of replaced flex item will use the cross axis preferred size which came from flexbox's
    // fixed cross size in newer version of Blink and Gecko which is different from the behavior of WebKit.
    // https://github.com/w3c/csswg-drafts/issues/6693
    bool isChildCrossSizeStretched = _needToStretchChildCrossSize(child) && crossSize != null;

    if (isChildCrossSizeStretched && transferredSize != null) {
      contentSize = transferredSize;
    }

    CSSLengthValue maxMainLength = _isHorizontalFlexDirection ? childRenderStyle.maxWidth : childRenderStyle.maxHeight;

    // Further clamped by the max main size property if that is definite.
    if (maxMainLength.isNotNone) {
      contentSize = math.min(contentSize, maxMainLength.computedValue);
    }

    // Automatic Minimum Size of Flex Items.
    // https://www.w3.org/TR/css-flexbox-1/#min-size-auto
    double autoMinSize;

    if (specifiedSize != null) {
      // In general, the content-based minimum size of a flex item is the smaller of its content size suggestion
      // and its specified size suggestion.
      autoMinSize = math.min(contentSize, specifiedSize);
    } else {
      if (childAspectRatio != null) {
        // However, if the box has an aspect ratio and no specified size, its content-based minimum size is the smaller
        // of its content size suggestion and its transferred size suggestion.
        autoMinSize = math.min(contentSize, transferredSize!);
      } else {
        // If the box has neither a specified size suggestion nor an aspect ratio, its content-based minimum size is the
        // content size suggestion.
        autoMinSize = contentSize;
      }
    }
    return autoMinSize;
  }

  double _getShrinkConstraints(RenderBox child, Map<int?, _RunChild> runChildren, double remainingFreeSpace) {
    double totalWeightedFlexShrink = 0;
    runChildren.forEach((int? hashCode, _RunChild runChild) {
      RenderBox child = runChild.child;
      if (!runChild.frozen) {
        double childFlexShrink = _getFlexShrink(child);
        // Use flexBasis for weight calculation, consistent with CSS spec
        double? flexBasis = _getFlexBasis(child);
        double baseSize = flexBasis ?? runChild.originalMainSize;
        totalWeightedFlexShrink += baseSize * childFlexShrink;
      }
    });
    if (totalWeightedFlexShrink == 0) {
      return 0;
    }

    int? childNodeId;
    if (child is RenderTextBox) {
      childNodeId = child.hashCode;
    } else if (child is RenderBoxModel) {
      childNodeId = child.hashCode;
    }

    _RunChild current = runChildren[childNodeId]!;
    double currentFlexShrink = _getFlexShrink(current.child);

    // Use flexBasis if available, otherwise use originalMainSize
    double? flexBasis = _getFlexBasis(current.child);
    double baseSize = flexBasis ?? current.originalMainSize;

    double currentExtent = currentFlexShrink * baseSize;
    double minusConstraints = (currentExtent / totalWeightedFlexShrink) * remainingFreeSpace;

    return minusConstraints;
  }

  // Get constraints suited for intrinsic sizing of flex items.
  //
  // Goals:
  // - Ignore percentage-based max constraints during the initial (intrinsic)
  //   measurement so we don't prematurely clamp to the container.
  // - For auto main-size in the flex main axis, avoid inheriting the flex
  //   container's main-axis max constraint. This lets items size to their
  //   content (min/max-content) rather than the container width/height,
  //   matching CSS flex-basis:auto behavior.
  BoxConstraints _getIntrinsicConstraints(RenderBox child) {
    if (_isPlaceholderPositioned(child)) {
      RenderBoxModel? positionedBox = (child as RenderPositionPlaceholder).positioned;
      if (positionedBox != null && positionedBox.hasSize == true) {
        Size realDisplayedBoxSize = positionedBox.getBoxSize(positionedBox.contentSize);
        return BoxConstraints(
          minWidth: realDisplayedBoxSize.width,
          maxWidth: realDisplayedBoxSize.width,
          minHeight: realDisplayedBoxSize.height,
          maxHeight: realDisplayedBoxSize.height,
        );
      } else {
        return BoxConstraints();
      }
    } else if (child is RenderBoxModel) {
      // Start with the child’s normal constraints
      BoxConstraints c = child.getConstraints();

      final RenderStyle s = child.renderStyle;
      final bool hasPctMaxW = s.maxWidth.type == CSSLengthType.PERCENTAGE;
      final bool hasPctMaxH = s.maxHeight.type == CSSLengthType.PERCENTAGE;

      // 1) Relax percentage-based maxima for intrinsic sizing
      if (hasPctMaxW || hasPctMaxH) {
        c = BoxConstraints(
          minWidth: c.minWidth,
          maxWidth: hasPctMaxW ? double.infinity : c.maxWidth,
          minHeight: c.minHeight,
          maxHeight: hasPctMaxH ? double.infinity : c.maxHeight,
        );
      }

      // 2) For flex main-axis auto size (or flex-basis: content), avoid inheriting the container’s
      //    main-axis cap so content can determine its natural size.
      //    This prevents items from measuring at full container width/height.
      //    Exception: replaced elements (e.g., <img>) should not be relaxed to ∞,
      //    otherwise they pick viewport-sized widths; keep their container-bounded constraints.
      final bool isFlexBasisContent = s.flexBasis?.type == CSSLengthType.CONTENT;
      final bool isReplaced = s.isSelfRenderReplaced();
      if (_isHorizontalFlexDirection) {
        if (!isReplaced && (s.width.isAuto || isFlexBasisContent)) {
          c = BoxConstraints(
            minWidth: c.minWidth,
            maxWidth: double.infinity,
            minHeight: c.minHeight,
            maxHeight: c.maxHeight,
          );
        }
      } else {
        // Column direction: main axis vertical, cross axis is width.
        // For intrinsic measurement of auto-width flex items, relax only the parent-imposed
        // width cap while preserving the item's own definite max-width/min-width.
        // This prevents runaway expansion to the container width but still honors
        // author-specified constraints like max-width: 100px.
        if (!isReplaced && (s.width.isAuto || isFlexBasisContent)) {
          // Determine if the container has a definite cross size (width).
          final bool containerCrossDefinite =
              (renderStyle.contentBoxLogicalWidth != null) || (contentConstraints?.hasTightWidth ?? false);

          double newMaxW;
          if (containerCrossDefinite) {
            // Clamp to the container's border-box width to ensure text wraps correctly.
            double containerMaxBorderW = constraints.maxWidth.isFinite ? constraints.maxWidth : double.infinity;
            newMaxW = containerMaxBorderW;
          } else {
            // No definite container width: let content determine size (shrink-to-fit scenarios).
            newMaxW = double.infinity;
          }
          // Also honor the child's own definite max-width (non-percentage) if any.
          if (s.maxWidth.isNotNone && s.maxWidth.type != CSSLengthType.PERCENTAGE) {
            newMaxW = math.min(newMaxW, s.maxWidth.computedValue);
          }

          c = BoxConstraints(
            minWidth: 0,
            maxWidth: newMaxW,
            minHeight: c.minHeight,
            maxHeight: double.infinity,
          );
        } else {
          // Preserve existing constraints for non-auto widths or replaced elements.
          c = BoxConstraints(
            minWidth: c.minWidth,
            maxWidth: c.maxWidth,
            minHeight: c.minHeight,
            maxHeight: c.maxHeight,
          );
        }
      }

      // 3) Honor explicit flex-basis for intrinsic sizing in the main axis.
      //    Per CSS Flexbox, the flex base size is the used value of flex-basis when it
      //    is a definite length. This includes 0. For percentage flex-basis with an
      //    indefinite main size, _getFlexBasis() returns null to defer to content sizing.
      //    We therefore clamp the main-axis constraints to the numeric basis whenever
      //    it’s non-null (including 0), letting later min-size:auto enforcement raise
      //    the size if needed.
      double? basis = _getFlexBasis(child);
      if (basis != null) {
        if (_isHorizontalFlexDirection) {
          c = BoxConstraints(
            minWidth: basis,
            maxWidth: basis,
            minHeight: c.minHeight,
            maxHeight: c.maxHeight,
          );
        } else {
          c = BoxConstraints(
            minWidth: c.minWidth,
            maxWidth: c.maxWidth,
            minHeight: basis,
            maxHeight: basis,
          );
        }
      }

      if (debugLogFlexEnabled) {
        final s = child.renderStyle;
        renderingLogger.finer('[Flex] intrinsicConstraints for ${_childDesc(child)} '
            'autoMain=${_isHorizontalFlexDirection ? s.width.isAuto : s.height.isAuto} -> ${_fmtC(c)}');
      }
      return c;
    } else {
      return BoxConstraints();
    }
  }

  double _getCrossAxisExtent(RenderBox? child) {
    double marginHorizontal = 0;
    double marginVertical = 0;

    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      // Position placeholder of flex item need to layout as its original renderBox
      // so it needs to add margin to its extent.
      childRenderBoxModel = child.positioned;
    }

    if (childRenderBoxModel != null) {
      marginHorizontal = childRenderBoxModel.renderStyle.marginLeft.computedValue +
          childRenderBoxModel.renderStyle.marginRight.computedValue;
      marginVertical = childRenderBoxModel.renderStyle.marginTop.computedValue +
          childRenderBoxModel.renderStyle.marginBottom.computedValue;
    }

    Size? childSize = _getChildSize(child);

    if (_isHorizontalFlexDirection) {
      return childSize!.height + marginVertical;
    } else {
      if (child is RenderLayoutBox && child.isNegativeMarginChangeHSize) {
        return _horizontalMarginNegativeSet(childSize!.width, child);
      }
      return childSize!.width + marginHorizontal;
    }
  }

  bool _isChildMainAxisClip(RenderBoxModel renderBoxModel) {
    if (renderBoxModel.renderStyle.isSelfRenderReplaced()) {
      return false;
    }
    if (_isHorizontalFlexDirection) {
      return renderBoxModel.renderStyle.overflowX != CSSOverflowType.visible;
    } else {
      return renderBoxModel.renderStyle.overflowY != CSSOverflowType.visible;
    }
  }

  double _horizontalMarginNegativeSet(double baseSize, RenderBoxModel box, {bool isHorizontal = false}) {
    CSSRenderStyle boxStyle = box.renderStyle;
    double? marginLeft = boxStyle.marginLeft.computedValue;
    double? marginRight = boxStyle.marginRight.computedValue;
    double? marginTop = boxStyle.marginTop.computedValue;
    double? marginBottom = boxStyle.marginBottom.computedValue;
    if (isHorizontal) {
      if (box is RenderLayoutBox && box.isNegativeMarginChangeHSize) {
        baseSize += marginLeft > 0 ? marginLeft : 0;
        baseSize += marginRight > 0 ? marginRight : 0;
        return baseSize;
      }
      return baseSize + box.renderStyle.margin.horizontal;
    }
    if (box is RenderLayoutBox && box.isMarginNegativeVertical()) {
      baseSize += marginTop > 0 ? marginTop : 0;
      baseSize += marginBottom > 0 ? marginBottom : 0;
      return baseSize;
    }
    return baseSize + box.renderStyle.margin.vertical;
  }

  double _getMainAxisExtent(RenderBox child, {bool shouldUseIntrinsicMainSize = false}) {
    double marginHorizontal = 0;
    double marginVertical = 0;

    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      // Position placeholder of flex item need to layout as its original renderBox
      // so it needs to add margin to its extent.
      childRenderBoxModel = child.positioned;
    }

    if (childRenderBoxModel != null) {
      marginHorizontal = childRenderBoxModel.renderStyle.marginLeft.computedValue +
          childRenderBoxModel.renderStyle.marginRight.computedValue;
      marginVertical = childRenderBoxModel.renderStyle.marginTop.computedValue +
          childRenderBoxModel.renderStyle.marginBottom.computedValue;
    }

    double baseSize = _getMainSize(child, shouldUseIntrinsicMainSize: shouldUseIntrinsicMainSize);
    if (_isHorizontalFlexDirection) {
      if (child is RenderLayoutBox && child.isNegativeMarginChangeHSize) {
        return _horizontalMarginNegativeSet(baseSize, child);
      }
      return baseSize + marginHorizontal;
    } else {
      return baseSize + marginVertical;
    }
  }

  double _getMainSize(RenderBox child, {bool shouldUseIntrinsicMainSize = false}) {
    Size? childSize = _getChildSize(child, shouldUseIntrinsicMainSize: shouldUseIntrinsicMainSize);
    if (_isHorizontalFlexDirection) {
      return childSize!.width;
    } else {
      return childSize!.height;
    }
  }

  // Get gap spacing for main axis (between flex items)
  double _getMainAxisGap() {
    CSSLengthValue gap = _isHorizontalFlexDirection
      ? renderStyle.columnGap
      : renderStyle.rowGap;
    if (gap.type == CSSLengthType.NORMAL) return 0;
    double? computedValue = gap.computedValue;
    return computedValue ?? 0;
  }

  // Get gap spacing for cross axis (between flex lines)
  double _getCrossAxisGap() {
    CSSLengthValue gap = _isHorizontalFlexDirection
      ? renderStyle.rowGap
      : renderStyle.columnGap;
    if (gap.type == CSSLengthType.NORMAL) return 0;
    double? computedValue = gap.computedValue;
    return computedValue ?? 0;
  }

  // Sort flex items by their order property (default order is 0), stably.
  // When multiple items have the same order, preserve their original DOM order.
  List<RenderBox> _getSortedFlexItems(List<RenderBox> children) {
    List<RenderBox> sortedChildren = List.from(children);

    // Map each child to its original index to ensure stability.
    final Map<RenderBox, int> originalIndex = {
      for (int i = 0; i < children.length; i++) children[i]: i
    };

    int getOrder(RenderBox box) {
      if (box is RenderBoxModel) {
        return box.renderStyle.order;
      }
      if (box is RenderEventListener) {
        final RenderBox? inner = box.child;
        if (inner is RenderBoxModel) {
          return inner.renderStyle.order;
        }
      }
      return 0;
    }

    sortedChildren.sort((a, b) {
      final int orderA = getOrder(a);
      final int orderB = getOrder(b);
      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      // Tie-breaker: original DOM order to make sort stable
      return originalIndex[a]!.compareTo(originalIndex[b]!);
    });

    return sortedChildren;
  }

  @override
  void performLayout() {
    try {
      doingThisLayout = true;

      _doPerformLayout();

      if (needsRelayout) {
        _doPerformLayout();
        needsRelayout = false;
      }
      doingThisLayout = false;
    } catch (e, stack) {
      if (!kReleaseMode) {
        layoutExceptions = '$e\n$stack';
        reportException('performLayout', e, stack);
      }
      doingThisLayout = false;
      rethrow;
    }
  }

  void _doPerformLayout() {
    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.beforeLayout');
    }

    beforeLayout();

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    List<RenderBoxModel> _positionedChildren = [];
    List<RenderPositionPlaceholder> _positionPlaceholderChildren = [];
    List<RenderBox> _flexItemChildren = [];
    List<RenderBoxModel> _stickyChildren = [];

    // Prepare children of different type for layout.
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel && child.renderStyle.isSelfPositioned()) {
        _positionedChildren.add(child);
      } else if (child is RenderPositionPlaceholder && _isPlaceholderPositioned(child)) {
        _positionPlaceholderChildren.add(child);
      } else {
        _flexItemChildren.add(child);
        if (child is RenderBoxModel && CSSPositionedLayout.isSticky(child)) {
          _stickyChildren.add(child);
        }
      }
      child = childParentData.nextSibling;
    }

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutPositionedChild');
    }

    // Need to layout out of flow positioned element before normal flow element
    // cause the size of RenderPositionPlaceholder in flex layout needs to use
    // the size of its original RenderBoxModel.
    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, child);
    }

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex._layoutFlexItems');
    }

    // Layout non positioned element (include element in normal flow and
    // placeholder of positioned element).
    // Sort flex items by their order property for visual reordering
    List<RenderBox> orderedChildren = _getSortedFlexItems(_flexItemChildren);
    _layoutFlexItems(orderedChildren);

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.adjustPositionChildren');
    }

    // init overflowLayout size
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

    // calculate all flexItem child overflow size
    addOverflowLayoutFromChildren(_flexItemChildren);

    // Every placeholder of positioned element should be layouted in a separated layer in flex layout
    // which is different from the placeholder in flow layout which layout in the same flow as
    // other elements in normal flow.
    for (RenderPositionPlaceholder child in _positionPlaceholderChildren) {
      _layoutPositionPlaceholder(child);
    }

    // Set offset of positioned element after flex box size is set.
    for (RenderBoxModel child in _positionedChildren) {
      Element? containingBlockElement = child.renderStyle.target.getContainingBlockElement();
      if (containingBlockElement == null || containingBlockElement.attachedRenderer == null) continue;

      if (child.renderStyle.position == CSSPositionType.absolute) {
        containingBlockElement.attachedRenderer!.positionedChildren.add(child);
        if (!containingBlockElement.attachedRenderer!.needsLayout) {
          CSSPositionedLayout.applyPositionedChildOffset(containingBlockElement.attachedRenderer!, child);
        }
      } else {
        CSSPositionedLayout.applyPositionedChildOffset(this, child);
      }
      // Position of positioned element affect the scroll size of container.
      extendMaxScrollableSize(child);
      addOverflowLayoutFromChild(child);
    }

    // Set offset of sticky element on each layout.
    for (RenderBoxModel child in _stickyChildren) {
      RenderLayoutBox scrollContainer = child.findScrollContainer()! as RenderLayoutBox;
      // Sticky offset depends on the layout of scroll container, delay the calculation of
      // sticky offset to the layout stage of  scroll container if its not layouted yet
      // due to the layout order of Flutter renderObject tree is from down to up.
      if (scrollContainer.hasSize) {
        CSSPositionedLayout.applyStickyChildOffset(scrollContainer, child);
      }
      scrollContainer.stickyChildren.add(child);
    }

    bool isScrollContainer = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    if (isScrollContainer) {
      // Calculate the offset of its sticky children.
      for (RenderBoxModel stickyChild in stickyChildren) {
        CSSPositionedLayout.applyStickyChildOffset(this, stickyChild);
      }
    }

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    didLayout();
  }

  // There are 4 steps for layout flex items.
  // 1. Layout children to generate flex line boxes metrics.
  // 2. Relayout children according to flex factor properties and alignment properties in cross axis.
  // 3. Set flex container size according to children size and its own size styles.
  // 4. Align children according to alignment properties.
  void _layoutFlexItems(List<RenderBox> children) {
    // If no child exists, stop layout.
    if (children.isEmpty) {
      _setContainerSizeWithNoChild();
      // Ensure CSS baselines are cached even when there are no flex items.
      // Needed so inline-flex placeholders get correct baseline (content-box bottom).
      calculateBaseline();
      return;
    }

    if (debugLogFlexEnabled) {
      final dir = renderStyle.flexDirection;
      final jc = renderStyle.justifyContent;
      final ai = renderStyle.alignItems;
      final ac = renderStyle.alignContent;
      final cw = renderStyle.contentBoxLogicalWidth;
      final ch = renderStyle.contentBoxLogicalHeight;
      renderingLogger.fine('[Flex] container start dir=$dir jc=$jc ai=$ai ac=$ac '
          'constraints=${_fmtC(constraints)} contentConstraints=${_fmtC(contentConstraints!)} '
          'logical=(w:${cw?.toStringAsFixed(1)}, h:${ch?.toStringAsFixed(1)})');
    }

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutFlexItems.computeRunMetrics',
          arguments: {'renderObject': describeIdentity(this)});
    }

    // Layout children to compute metrics of flex lines.
    List<_RunMetrics> _runMetrics = _computeRunMetrics(children);

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    // Set flex container size.
    _setContainerSize(_runMetrics);

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutFlexItems.adjustChildrenSize');
    }

    // Adjust children size based on flex properties which may affect children size.
    _adjustChildrenSize(_runMetrics);

    // After adjusting children sizes, recalculate both cross-axis and main-axis
    // extents so that spacing computation (remainingSpace, justify-content) uses
    // the final item sizes, including margins and gaps.
    for (_RunMetrics metrics in _runMetrics) {
      double maxCrossAxisExtent = 0;
      double newMainAxisExtent = 0;

      final List<_RunChild> runChildrenList = metrics.runChildren.values.toList();
      for (int i = 0; i < runChildrenList.length; i++) {
        final _RunChild runChild = runChildrenList[i];
        final RenderBox child = runChild.child;

        // Recompute cross-axis extent from final sizes
        final double childCrossAxisExtent = _getCrossAxisExtent(child);
        maxCrossAxisExtent = math.max(maxCrossAxisExtent, childCrossAxisExtent);

        // Recompute main-axis extent from final sizes (includes margins)
        if (i > 0) {
          newMainAxisExtent += _getMainAxisGap();
        }
        newMainAxisExtent += _getMainAxisExtent(child);
      }

      metrics.crossAxisExtent = maxCrossAxisExtent;
      metrics.mainAxisExtent = newMainAxisExtent;
    }

    // _runMetrics maybe update after adjust, set flex containerSize again
    _setContainerSize(_runMetrics);

    if (debugLogFlexEnabled) {
      renderingLogger.fine('[Flex] container sizes content=${_fmtS(contentSize)} box=${_fmtS(size)}');
    }

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutFlexItems.setChildrenOffset');
    }

    // Set children offset based on flex alignment properties.
    _setChildrenOffset(_runMetrics);

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutFlexItems.setMaxScrollableSize');
    }

    // Set the size of scrollable overflow area for flex layout.
    _setMaxScrollableSize(_runMetrics);

    // Set the baseline values for flex items
    calculateBaseline();

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }
  }

  @override
  void calculateBaseline() {
    // Cache CSS baselines for this flex container during layout to avoid cross-child baseline computation later.
    double? containerBaseline;
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isDisplayInline = effectiveDisplay != CSSDisplay.block && effectiveDisplay != CSSDisplay.flex;
    if (_flexLineBoxMetrics.isEmpty) {
      if (isDisplayInline) {
        // Inline flex container with no flex items: per CSS 2.1 §10.8.1 and
        // CSS Flexbox alignment rules, when no baseline can be taken from in-flow
        // content, synthesize the baseline from the bottom margin edge.
        //
        // Our cached CSS baselines are measured from the border-box top.
        // Bottom margin edge distance = borderBoxHeight + margin-bottom.
        final double borderBoxHeight = boxSize?.height ?? size.height;
        final double marginBottom = renderStyle.marginBottom.computedValue;
        containerBaseline = borderBoxHeight + marginBottom;
      }
    } else {
      // Baseline equals the first child's baseline plus its offset within the container.
      final _RunMetrics firstLineMetrics = _flexLineBoxMetrics[0];
      final List<_RunChild> firstRunChildren = firstLineMetrics.runChildren.values.toList();
      if (firstRunChildren.isNotEmpty) {
        final RenderBox child = firstRunChildren[0].child;
        final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
        final double? childBaseline = child.getDistanceToBaseline(TextBaseline.alphabetic);
        // Offset of the child's border-box top within the flex container's border-box.
        // Use the laid-out offset directly (includes margins) so the container baseline
        // derived from the child matches browser behavior for inline-flex baseline.
        double childOffsetY = childParentData.offset.dy;
        if (child is RenderBoxModel) {
          final Offset? relativeOffset = CSSPositionedLayout.getRelativeOffset(child.renderStyle);
          if (relativeOffset != null) {
            childOffsetY -= relativeOffset.dy;
          }
        }
        // Child baseline is relative to the child's border-box top; convert to the
        // container's border-box by adding the child's offset within the container.
        containerBaseline = (childBaseline ?? 0) + childOffsetY;
      }
    }
    setCssBaselines(first: containerBaseline, last: containerBaseline);
  }

  // Layout position placeholder.
  void _layoutPositionPlaceholder(RenderPositionPlaceholder child) {
    List<RenderBox> _positionPlaceholderChildren = [child];

    // Layout children to compute metrics of flex lines.
    List<_RunMetrics> _runMetrics = _computeRunMetrics(_positionPlaceholderChildren);

    // Set children offset based on flex alignment properties.
    _setChildrenOffset(_runMetrics);
  }

  // Layout children in normal flow order to calculate metrics of flex lines according to its constraints
  // and flex-wrap property.
  List<_RunMetrics> _computeRunMetrics(
    List<RenderBox> children,
  ) {
    List<_RunMetrics> _runMetrics = <_RunMetrics>[];
    if (children.isEmpty) return _runMetrics;

    // PASS 1: Layout children with intrinsic constraints (no percentage limits)
    // This establishes the parent's natural size
    Map<int, BoxConstraints> intrinsicConstraints = {};
    Map<int, Size> intrinsicSizes = {};

    for (RenderBox child in children) {
      BoxConstraints childConstraints = _getIntrinsicConstraints(child);
      intrinsicConstraints[child.hashCode] = childConstraints;

      child.layout(childConstraints, parentUsesSize: true);
      intrinsicSizes[child.hashCode] = child.size;

      if (debugLogFlexEnabled) {
        renderingLogger.finer('[Flex] intrinsic child ${_childDesc(child)} '
            'constraints=${_fmtC(childConstraints)} size=${_fmtS(child.size)}');
      }

      if (child is RenderBoxModel) {
        child.clearOverrideContentSize();
      }
    }

    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;

    // Determine used flex factor, size inflexible items, calculate free space.
    double totalFlexGrow = 0;
    double totalFlexShrink = 0;

    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;

    // Max length of each flex line
    double flexLineLimit = 0.0;

    // Use scrolling container to calculate flex line limit for scrolling content box
    RenderBoxModel? containerBox = this;
    if (_isHorizontalFlexDirection) {
      flexLineLimit = renderStyle.contentMaxConstraintsWidth;
    } else {
      flexLineLimit = containerBox!.contentConstraints!.maxHeight;
    }

    // Info about each flex item in each flex line
    Map<int?, _RunChild> runChildren = {};

    List<int> overflowHiddenNodeId = [];
    double overflowHiddenNodeTotalMinWidth = 0;
    double overflowNotHiddenNodeTotalWidth = 0;

    // PASS 2: Calculate run metrics using intrinsic sizes
    for (RenderBox child in children) {
      final RenderLayoutParentData? childParentData = child.parentData as RenderLayoutParentData?;
      int childNodeId = child.hashCode;

      // Use intrinsic size for run calculations
      Size childSize = intrinsicSizes[childNodeId]!;
      double intrinsicMain = _isHorizontalFlexDirection ? childSize.width : childSize.height;

      // Clamp intrinsic main size by child's min/max constraints before flexing,
      // so percentage max-width/height act as caps on the base size per spec.
      if (child is RenderBoxModel) {
        final CSSRenderStyle cs = child.renderStyle;
        // Determine min/max along the main axis
        double? minMain;
        double? maxMain;
        if (_isHorizontalFlexDirection) {
          if (cs.minWidth.isNotAuto) minMain = cs.minWidth.computedValue;
          if (!cs.maxWidth.isNone) maxMain = cs.maxWidth.computedValue;
        } else {
          if (cs.minHeight.isNotAuto) minMain = cs.minHeight.computedValue;
          if (!cs.maxHeight.isNone) maxMain = cs.maxHeight.computedValue;
        }

        // intrinsicMain is the border-box main size. In WebF (border-box model),
        // min-width/max-width are already specified for the border box. Do not
        // add padding/border again when clamping.
        if (maxMain != null && maxMain.isFinite && intrinsicMain > maxMain) {
          intrinsicMain = maxMain;
        }
        if (minMain != null && minMain.isFinite && intrinsicMain < minMain) {
          intrinsicMain = minMain;
        }
      }

      // If a flex item has percentage max-size and is truly empty, its base size should be
      // its padding+border box (do not expand to the percentage constraint).
      if (child is RenderBoxModel) {
        bool hasPctMaxMain = _isHorizontalFlexDirection
            ? child.renderStyle.maxWidth.type == CSSLengthType.PERCENTAGE
            : child.renderStyle.maxHeight.type == CSSLengthType.PERCENTAGE;
        bool hasAutoMain = _isHorizontalFlexDirection ? child.renderStyle.width.isAuto : child.renderStyle.height.isAuto;
        if (hasPctMaxMain && hasAutoMain) {
          double paddingBorderMain = _isHorizontalFlexDirection
              ? (child.renderStyle.effectiveBorderLeftWidth.computedValue +
                  child.renderStyle.effectiveBorderRightWidth.computedValue +
                  child.renderStyle.paddingLeft.computedValue +
                  child.renderStyle.paddingRight.computedValue)
              : (child.renderStyle.effectiveBorderTopWidth.computedValue +
                  child.renderStyle.effectiveBorderBottomWidth.computedValue +
                  child.renderStyle.paddingTop.computedValue +
                  child.renderStyle.paddingBottom.computedValue);

          // Check if this is an empty element (no content) using DOM-based detection
          bool isEmptyElement = false;
          if (child is RenderBoxModel) {
            Element domElement = child.renderStyle.target;
            isEmptyElement = !domElement.hasChildren();
          }

          // For empty elements, force intrinsic size to padding+border
          if (isEmptyElement) {
            intrinsicMain = paddingBorderMain;
          }
        }
      }

      if (debugLogFlexEnabled) {
        renderingLogger.finer('[Flex] base main-size ${_childDesc(child)} '
            'intrinsic=${(_isHorizontalFlexDirection ? childSize.width : childSize.height).toStringAsFixed(1)} '
            'clamped=${intrinsicMain.toStringAsFixed(1)}');
      }

      // Enforce automatic minimum main size (min-size:auto) so preserved sizes
      // never fall below min-content contributions in the main axis.
      if (child is RenderBoxModel) {
        final double autoMinMain = _getMinMainAxisSize(child);
        if (intrinsicMain < autoMinMain) {
          intrinsicMain = autoMinMain;
        }
      }

      _childrenIntrinsicMainSizes[child.hashCode] = intrinsicMain;

      Size? intrinsicChildSize = _getChildSize(child, shouldUseIntrinsicMainSize: true);

      double childMainAxisExtent = _getMainAxisExtent(child, shouldUseIntrinsicMainSize: true);
      double childCrossAxisExtent = _getCrossAxisExtent(child);
      // Include gap spacing in flex line limit check
      double gapSpacing = runChildren.isNotEmpty ? _getMainAxisGap() : 0;
      bool isExceedFlexLineLimit = runMainAxisExtent + gapSpacing + childMainAxisExtent > flexLineLimit;
      // calculate flex line
      if ((renderStyle.flexWrap == FlexWrap.wrap || renderStyle.flexWrap == FlexWrap.wrapReverse) &&
          runChildren.isNotEmpty &&
          isExceedFlexLineLimit) {
        _runMetrics.add(_RunMetrics(runMainAxisExtent, runCrossAxisExtent, totalFlexGrow, totalFlexShrink,
            maxSizeAboveBaseline, runChildren, 0));
        runChildren = {};
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        maxSizeAboveBaseline = 0.0;
        maxSizeBelowBaseline = 0.0;

        totalFlexGrow = 0;
        totalFlexShrink = 0;
      }
      // Add gap spacing between items (not before the first item)
      if (runChildren.isNotEmpty) {
        runMainAxisExtent += _getMainAxisGap();
      }
      runMainAxisExtent += childMainAxisExtent;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);

      // Vertical align is only valid for inline box.
      // Baseline alignment in column direction behave the same as flex-start.
      AlignSelf alignSelf = _getAlignSelf(child);
      bool isBaselineAlign = alignSelf == AlignSelf.baseline || renderStyle.alignItems == AlignItems.baseline;
      bool isHorizontal = _isHorizontalFlexDirection;
      if (isHorizontal && isBaselineAlign) {
        // Distance from top to baseline of child
        double childAscent = _getChildAscent(child);
        double? childMarginTop = 0;
        double? childMarginBottom = 0;
        if (child is RenderBoxModel) {
          childMarginTop = child.renderStyle.marginTop.computedValue;
          childMarginBottom = child.renderStyle.marginBottom.computedValue;
        }
        if (debugLogFlexBaselineEnabled) {
          final Size? ic = intrinsicChildSize;
          renderingLogger.finer('[FlexBaseline] PASS2 child='
              '${child.runtimeType}#${child.hashCode} '
              'intrinsicSize=${ic?.width.toStringAsFixed(2)}x${ic?.height.toStringAsFixed(2)} '
              'ascent=${childAscent.toStringAsFixed(2)} '
              'mT=${(childMarginTop ?? 0).toStringAsFixed(2)} mB=${(childMarginBottom ?? 0).toStringAsFixed(2)}');
        }
        maxSizeAboveBaseline = math.max(
          childAscent,
          maxSizeAboveBaseline,
        );
        maxSizeBelowBaseline = math.max(
          childMarginTop + childMarginBottom + intrinsicChildSize!.height - childAscent,
          maxSizeBelowBaseline,
        );
        runCrossAxisExtent = maxSizeAboveBaseline + maxSizeBelowBaseline;
        if (debugLogFlexBaselineEnabled) {
          renderingLogger.finer('[FlexBaseline] RUN update: maxAbove='
              '${maxSizeAboveBaseline.toStringAsFixed(2)} '
              'maxBelow=${maxSizeBelowBaseline.toStringAsFixed(2)} '
              'runCross=${runCrossAxisExtent.toStringAsFixed(2)}');
        }
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }

      // Use clamped intrinsic main size as original base size for flexing
      double _originalMainSize = intrinsicMain;
      runChildren[childNodeId] = _RunChild(
        child,
        _originalMainSize,
        0,
        false,
      );

      childParentData!.runIndex = _runMetrics.length;

      assert(child.parentData == childParentData);

      final double flexGrow = _getFlexGrow(child);
      final double flexShrink = _getFlexShrink(child);
      if (flexGrow > 0) {
        totalFlexGrow += flexGrow;
      }
      if (flexShrink > 0) {
        totalFlexShrink += flexShrink;
      }
      if (isHorizontal && child is RenderBoxModel) {
        if (child.renderStyle.overflowX == CSSOverflowType.hidden) {
          overflowHiddenNodeId.add(childNodeId);
          overflowHiddenNodeTotalMinWidth += child.contentConstraints?.minWidth ?? 0;
        } else {
          overflowNotHiddenNodeTotalWidth += _originalMainSize;
        }
      }
    }

    if (runChildren.isNotEmpty) {
      if (overflowHiddenNodeId.isNotEmpty &&
          runMainAxisExtent > flexLineLimit &&
          overflowHiddenNodeTotalMinWidth < flexLineLimit) {
        int _overflowNodeSize = overflowHiddenNodeId.length;
        double overWidth = flexLineLimit - overflowNotHiddenNodeTotalWidth;
        double avgOverWidth = overWidth / _overflowNodeSize;
        int index = 0;
        for (int nodeId in overflowHiddenNodeId) {
          _RunChild? _runChild = runChildren[nodeId];
          if (_runChild != null) {
            index += 1;
            if (overWidth <= 0) {
              // the remaining width is less than 0.
              BoxConstraints oldConstraints = _runChild.child.constraints;
              double _minWidth = oldConstraints.minWidth;
              _runChild.child.layout(
                  BoxConstraints(
                      minWidth: _minWidth,
                      maxWidth: _minWidth,
                      minHeight: oldConstraints.minHeight,
                      maxHeight: oldConstraints.maxHeight),
                  parentUsesSize: true);
              _runChild.originalMainSize = _minWidth;
              _childrenIntrinsicMainSizes[nodeId] = _minWidth;
            } else if (_runChild.originalMainSize <= avgOverWidth) {
              // the actual width of a subwidget is less than the average value of the remaining width.
              // The child does not need layout calculations; adjust the average value.
              overWidth -= _runChild.originalMainSize;
              avgOverWidth = overWidth / (_overflowNodeSize - index);
            } else {
              BoxConstraints oldConstraints = _runChild.child.constraints;
              double _minWidth = oldConstraints.minWidth;
              double _maxWidth = avgOverWidth;
              if (_minWidth > _maxWidth) {
                _maxWidth = _minWidth;
              }
              _runChild.child.layout(
                  BoxConstraints(
                      minWidth: _minWidth,
                      maxWidth: _maxWidth,
                      minHeight: oldConstraints.minHeight,
                      maxHeight: oldConstraints.maxHeight),
                  parentUsesSize: true);
              _runChild.originalMainSize = avgOverWidth;
              _childrenIntrinsicMainSizes[nodeId] = avgOverWidth;
            }
          }
        }
        runMainAxisExtent = flexLineLimit;
      }
      _runMetrics.add(_RunMetrics(
          runMainAxisExtent, runCrossAxisExtent, totalFlexGrow, totalFlexShrink, maxSizeAboveBaseline, runChildren, 0));

      if (debugLogFlexEnabled) {
        renderingLogger.fine('[Flex] run end main=${runMainAxisExtent.toStringAsFixed(1)} '
            'cross=${runCrossAxisExtent.toStringAsFixed(1)} flexGrow=$totalFlexGrow flexShrink=$totalFlexShrink '
            'limit=${flexLineLimit.isFinite ? flexLineLimit.toStringAsFixed(1) : '∞'}');
      }
    }

    _flexLineBoxMetrics = _runMetrics;

    // PASS 3: Store percentage constraints for later use in _adjustChildrenSize
    // This ensures they are calculated with the final parent dimensions
    for (RenderBox child in children) {
      if (child is RenderBoxModel) {
        bool hasPercentageMaxWidth = child.renderStyle.maxWidth.type == CSSLengthType.PERCENTAGE;
        bool hasPercentageMaxHeight = child.renderStyle.maxHeight.type == CSSLengthType.PERCENTAGE;

        if (hasPercentageMaxWidth || hasPercentageMaxHeight) {
          // Store the final constraints for use in _adjustChildrenSize
          BoxConstraints finalConstraints = child.getConstraints();
          _childrenOldConstraints[child.hashCode] = finalConstraints;
        }
      }
    }

    return _runMetrics;
  }

  // Compute the leading and between spacing of each flex line.
  Map<String, double> _computeRunSpacing(
    List<_RunMetrics> _runMetrics,
  ) {
    double? contentBoxLogicalWidth = renderStyle.contentBoxLogicalWidth;
    double? contentBoxLogicalHeight = renderStyle.contentBoxLogicalHeight;
    double containerCrossAxisExtent = 0.0;

    if (!_isHorizontalFlexDirection) {
      containerCrossAxisExtent = contentBoxLogicalWidth ?? 0;
    } else {
      containerCrossAxisExtent = contentBoxLogicalHeight ?? 0;
    }

    double runCrossSize = _getRunsCrossSize(_runMetrics);

    // Calculate leading and between space between flex lines.
    final double crossAxisFreeSpace = containerCrossAxisExtent - runCrossSize;
    final int runCount = _runMetrics.length;
    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;

    // Align-content only works in when flex-wrap is no nowrap.
    if (renderStyle.flexWrap == FlexWrap.wrap || renderStyle.flexWrap == FlexWrap.wrapReverse) {
      switch (renderStyle.alignContent) {
        case AlignContent.flexStart:
        case AlignContent.start:
          break;
        case AlignContent.flexEnd:
        case AlignContent.end:
          runLeadingSpace = crossAxisFreeSpace;
          break;
        case AlignContent.center:
          runLeadingSpace = crossAxisFreeSpace / 2.0;
          break;
        case AlignContent.spaceBetween:
          if (crossAxisFreeSpace < 0) {
            runBetweenSpace = 0;
          } else {
            runBetweenSpace = runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
          }
          break;
        case AlignContent.spaceAround:
          if (crossAxisFreeSpace < 0) {
            runLeadingSpace = crossAxisFreeSpace / 2.0;
            runBetweenSpace = 0;
          } else {
            runBetweenSpace = crossAxisFreeSpace / runCount;
            runLeadingSpace = runBetweenSpace / 2.0;
          }
          break;
        case AlignContent.spaceEvenly:
          if (crossAxisFreeSpace < 0) {
            runLeadingSpace = crossAxisFreeSpace / 2.0;
            runBetweenSpace = 0;
          } else {
            runBetweenSpace = crossAxisFreeSpace / (runCount + 1);
            runLeadingSpace = runBetweenSpace;
          }
          break;
        case AlignContent.stretch:
          runBetweenSpace = crossAxisFreeSpace / runCount;
          if (runBetweenSpace < 0) {
            runBetweenSpace = 0;
          }
          break;
      }
    }
    Map<String, double> _runSpacingMap = {'leading': runLeadingSpace, 'between': runBetweenSpace};
    return _runSpacingMap;
  }

  // Find the size in the cross axis of flex lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsCrossSize(
    List<_RunMetrics> _runMetrics,
  ) {
    double crossSize = 0;
    double crossAxisGap = _getCrossAxisGap();
    for (int i = 0; i < _runMetrics.length; i++) {
      crossSize += _runMetrics[i].crossAxisExtent;
      // Add gap spacing between lines (not after the last line)
      if (i < _runMetrics.length - 1) {
        crossSize += crossAxisGap;
      }
    }
    return crossSize;
  }

  // Find the max size in the main axis of flex lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsMaxMainSize(
    List<_RunMetrics> _runMetrics,
  ) {
    // Find the max size of flex lines.
    _RunMetrics maxMainSizeMetrics = _runMetrics.reduce((_RunMetrics curr, _RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    return maxMainSizeMetrics.mainAxisExtent;
  }

  // Resolve flex item length if flex-grow or flex-shrink exists.
  // https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  bool _resolveFlexibleLengths(
    _RunMetrics runMetric,
    Map<String, double> totalFlexFactor,
    double initialFreeSpace,
  ) {
    Map<int?, _RunChild> runChildren = runMetric.runChildren;
    double totalFlexGrow = totalFlexFactor['flexGrow']!;
    double totalFlexShrink = totalFlexFactor['flexShrink']!;
    bool isFlexGrow = initialFreeSpace > 0 && totalFlexGrow > 0;
    bool isFlexShrink = initialFreeSpace < 0 && totalFlexShrink > 0;

    double sumFlexFactors = isFlexGrow ? totalFlexGrow : totalFlexShrink;

    // If the sum of the unfrozen flex items’ flex factors is less than one,
    // multiply the initial free space by this sum as remaining free space.
    if (sumFlexFactors > 0 && sumFlexFactors < 1) {
      double remainingFreeSpace = initialFreeSpace;
      double fractional = initialFreeSpace * sumFlexFactors;
      if (fractional.abs() < remainingFreeSpace.abs()) {
        remainingFreeSpace = fractional;
      }
      runMetric.remainingFreeSpace = remainingFreeSpace;
    }

    List<_RunChild> minViolations = [];
    List<_RunChild> maxViolations = [];
    double totalViolation = 0;

    // Loop flex item to find min/max violations.
    runChildren.forEach((int? index, _RunChild runChild) {
      if (runChild.frozen) {
        return;
      }
      RenderBox child = runChild.child;
      int childNodeId = child.hashCode;

      _RunChild? current = runChildren[childNodeId];

      double? flexBasis = _getFlexBasis(child);
      double originalMainSize = flexBasis ?? current!.originalMainSize;

      double computedSize = originalMainSize;

      // Computed size by flex factor.
      double flexedMainSize = originalMainSize;

      // Adjusted size after min and max size clamp.
      double flexGrow = _getFlexGrow(child);
      double flexShrink = _getFlexShrink(child);

      double remainingFreeSpace = runMetric.remainingFreeSpace;
      if (isFlexGrow && flexGrow > 0) {
        final double spacePerFlex = totalFlexGrow > 0 ? (remainingFreeSpace / totalFlexGrow) : double.nan;
        final double flexGrow = _getFlexGrow(child);
        computedSize = originalMainSize + spacePerFlex * flexGrow;
      } else if (isFlexShrink && flexShrink > 0) {
        // If child's mainAxis have clips, it will create a new format context in it's children's.
        // so we do't need to care about child's size.
        if (child is RenderBoxModel && _isChildMainAxisClip(child)) {
          computedSize = originalMainSize + remainingFreeSpace > 0 ? originalMainSize + remainingFreeSpace : 0;
        } else {
          double shrinkValue = _getShrinkConstraints(child, runChildren, remainingFreeSpace);
          computedSize = originalMainSize + shrinkValue;
        }
      }

      flexedMainSize = computedSize;

      double minFlexPrecision = 0.5;
      // Find all the violations by comparing min and max size of flex items.
      if (child is RenderBoxModel && !_isChildMainAxisClip(child)) {
        double minMainAxisSize = _getMinMainAxisSize(child);
        double maxMainAxisSize = _getMaxMainAxisSize(child);
        if (computedSize < minMainAxisSize && (computedSize - minMainAxisSize).abs() >= minFlexPrecision) {
          flexedMainSize = minMainAxisSize;
        } else if (computedSize > maxMainAxisSize && (computedSize - minMainAxisSize).abs() >= minFlexPrecision) {
          flexedMainSize = maxMainAxisSize;
        }
      }

      double violation = (flexedMainSize - computedSize).abs() >= minFlexPrecision ? flexedMainSize - computedSize : 0;

      // Collect all the flex items with violations.
      if (violation > 0) {
        minViolations.add(runChild);
      } else if (violation < 0) {
        maxViolations.add(runChild);
      }
      runChild.flexedMainSize = flexedMainSize;
      totalViolation += violation;
    });

    // Freeze over-flexed items.
    if (totalViolation == 0) {
      // If total violation is zero, freeze all the flex items and exit loop.
      runChildren.forEach((int? index, _RunChild runChild) {
        runChild.frozen = true;
      });
    } else {
      List<_RunChild> violations = totalViolation < 0 ? maxViolations : minViolations;

      // Find all the violations, set main size and freeze all the flex items.
      for (int i = 0; i < violations.length; i++) {
        _RunChild runChild = violations[i];
        runChild.frozen = true;
        RenderBox child = runChild.child;
        runMetric.remainingFreeSpace -= runChild.flexedMainSize - runChild.originalMainSize;

        double flexGrow = _getFlexGrow(child);
        double flexShrink = _getFlexShrink(child);

        // If total violation is positive, freeze all the items with min violations.
        if (flexGrow > 0) {
          totalFlexFactor['flexGrow'] = totalFlexFactor['flexGrow']! - flexGrow;

          // If total violation is negative, freeze all the items with max violations.
        } else if (flexShrink > 0) {
          totalFlexFactor['flexShrink'] = totalFlexFactor['flexShrink']! - flexShrink;
        }
      }
    }

    return totalViolation != 0;
  }

  // Adjust children size (not include position placeholder) based on
  // flex factors (flex-grow/flex-shrink) and alignment in cross axis (align-items).
  //  https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  void _adjustChildrenSize(
    List<_RunMetrics> _runMetrics,
  ) {
    if (_runMetrics.isEmpty) return;
    // Compute spacing before and between each flex line.
    Map<String, double> _runSpacingMap = _computeRunSpacing(_runMetrics);

    double runBetweenSpace = _runSpacingMap['between']!;
    double? contentBoxLogicalWidth = renderStyle.contentBoxLogicalWidth;
    double? contentBoxLogicalHeight = renderStyle.contentBoxLogicalHeight;


    // Container's width specified by style or inherited from parent.
    double? containerWidth = 0;
    if (contentBoxLogicalWidth != null) {
      containerWidth = contentBoxLogicalWidth;
    } else if (contentConstraints!.hasTightWidth) {
      containerWidth = contentConstraints!.maxWidth;
    }

    // Container's height specified by style or inherited from parent.
    double? containerHeight = 0;
    if (contentBoxLogicalHeight != null) {
      containerHeight = contentBoxLogicalHeight;
    } else if (contentConstraints!.hasTightHeight) {
      containerHeight = contentConstraints!.maxHeight;
    }

    double? maxMainSize = _isHorizontalFlexDirection ? containerWidth : containerHeight;

    // Flexbox has several additional cases where a length can be considered definite.
    // https://www.w3.org/TR/css-flexbox-1/#definite-sizes
    bool isMainSizeDefinite =
        _isHorizontalFlexDirection ? contentBoxLogicalWidth != null : contentBoxLogicalHeight != null;

    for (int i = 0; i < _runMetrics.length; ++i) {
      final _RunMetrics metrics = _runMetrics[i];
      final double totalFlexGrow = metrics.totalFlexGrow;
      final double totalFlexShrink = metrics.totalFlexShrink;
      final Map<int?, _RunChild> runChildren = metrics.runChildren;
      final List<_RunChild> runChildrenList = runChildren.values.toList();

      double totalSpace = 0;
      // Flex factor calculation depends on flex-basis if exists.
      void calTotalSpace(int? hashCode, _RunChild runChild) {
        double childSpace = runChild.originalMainSize;
        RenderBox child = runChild.child;
        double marginHorizontal = 0;
        double marginVertical = 0;
        if (child is RenderBoxModel) {
          double? flexBasis = _getFlexBasis(child);
          marginHorizontal = child.renderStyle.marginLeft.computedValue + child.renderStyle.marginRight.computedValue;
          marginVertical = child.renderStyle.marginTop.computedValue + child.renderStyle.marginBottom.computedValue;
          if (flexBasis != null) {
            childSpace = flexBasis;
          }
        }
        double mainAxisMargin = _isHorizontalFlexDirection ? marginHorizontal : marginVertical;
        totalSpace += childSpace + mainAxisMargin;
      }

      runChildren.forEach(calTotalSpace);

      // Add gap spacing to total space calculation for flex-grow available space
      int itemCount = runChildren.length;
      if (itemCount > 1) {
        double totalGapSpacing = (itemCount - 1) * _getMainAxisGap();
        totalSpace += totalGapSpacing;
      }

      // Flexbox with no size on main axis should adapt the main axis size with children.
      double initialFreeSpace = isMainSizeDefinite ? (maxMainSize ?? 0) - totalSpace : 0;

      double layoutContentMainSize = _isHorizontalFlexDirection ? contentSize.width : contentSize.height;
      double minMainAxisSize = _getMinMainAxisSize(this);
      // Flexbox with minSize on main axis when maxMainSize < minSize && maxMainSize < RenderBox.Size, adapt freeSpace
      if (maxMainSize != null &&
          (maxMainSize < minMainAxisSize || maxMainSize < layoutContentMainSize) &&
          initialFreeSpace == 0) {
        maxMainSize = math.max(layoutContentMainSize, minMainAxisSize);

        double maxMainConstraints =
            _isHorizontalFlexDirection ? contentConstraints!.maxWidth : contentConstraints!.maxHeight;
        // determining isScrollingContentBox is to reduce the scope of influence
        if (renderStyle.isSelfScrollingContainer() && maxMainConstraints.isFinite) {
          maxMainSize = totalFlexShrink > 0 ? math.min(maxMainSize, maxMainConstraints) : maxMainSize;
          maxMainSize = totalFlexGrow > 0 ? math.max(maxMainSize, maxMainConstraints) : maxMainSize;
        }

        initialFreeSpace = maxMainSize - totalSpace;
      }

      bool isFlexGrow = initialFreeSpace > 0 && totalFlexGrow > 0;
      bool isFlexShrink = initialFreeSpace < 0 && totalFlexShrink > 0;

      if (isFlexGrow || isFlexShrink) {
        // remainingFreeSpace starts out at the same value as initialFreeSpace
        // but as we place and lay out flex items we subtract from it.
        metrics.remainingFreeSpace = initialFreeSpace;

        Map<String, double> totalFlexFactor = {
          'flexGrow': metrics.totalFlexGrow,
          'flexShrink': metrics.totalFlexShrink,
        };
        // Loop flex items to resolve flexible length of flex items with flex factor.
        while (_resolveFlexibleLengths(metrics, totalFlexFactor, initialFreeSpace)) {}
      }

      // Update run cross axis extent after flex item main size is adjusted which may
      // affect its cross size such as replaced element.
      metrics.crossAxisExtent = _recomputeRunCrossExtent(metrics);

      // Main axis size of children after child layouted.
      double mainAxisExtent = 0;

      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;

        double childMainAxisExtent = _getMainAxisExtent(child);

        // Non renderBoxModel and scrolling content box of renderBoxModel does not to adjust size.
        if (child is! RenderBoxModel) {
          mainAxisExtent += childMainAxisExtent;
          continue;
        }

        double flexGrow = _getFlexGrow(child);
        double flexShrink = _getFlexShrink(child);
        // Child main size adjusted due to flex-grow/flex-shrink style.
        double? childFlexedMainSize;
        if ((isFlexGrow && flexGrow > 0) || (isFlexShrink && flexShrink > 0)) {
          childFlexedMainSize = runChild.flexedMainSize;
        }

        // Original size of child.
        double childOldMainSize = _isHorizontalFlexDirection ? child.size.width : child.size.height;
        double childOldCrossSize = _isHorizontalFlexDirection ? child.size.height : child.size.width;


        // Child need to layout when main axis size or cross size has changed
        // due to flex-grow/flex-shrink/align-items/align-self specified.
        // If the flex algorithm produced a flexed main size, we must relayout the item
        // with tightened main-axis constraints so its descendants (e.g., block auto-width)
        // see a definite available width. Always trigger relayout for flexed items,
        // even if the numeric size matches the previous pass, to propagate constraints.
        bool childMainSizeChanged = childFlexedMainSize != null ||
            (childFlexedMainSize != null && childFlexedMainSize != childOldMainSize);

      bool childCrossSizeChanged = false;
      // Child cross size adjusted due to align-items/align-self style.
      double? childStretchedCrossSize;

      if (_needToStretchChildCrossSize(child)) {
        childStretchedCrossSize = _getChildStretchedCrossSize(child, metrics.crossAxisExtent, runBetweenSpace);
        if (child is RenderLayoutBox && child.isNegativeMarginChangeHSize) {
          double childCrossAxisMargin =
              _isHorizontalFlexDirection ? child.renderStyle.margin.vertical : child.renderStyle.margin.horizontal;
          childStretchedCrossSize += childCrossAxisMargin.abs();
        }
        childCrossSizeChanged = childStretchedCrossSize != childOldCrossSize;
      }

      // When not stretching, enforce the child's own min/max cross-size constraints.
      // If the measured cross size from the intrinsic pass exceeds a definite
      // max-width/max-height (absolute, not percentage), clamp and relayout.
      if (!_isHorizontalFlexDirection && child is RenderBoxModel && childStretchedCrossSize == null) {
        final RenderStyle cs = child.renderStyle;
        double measuredCross = childOldCrossSize; // width in column direction
        double clamped = measuredCross;
        if (cs.maxWidth.isNotNone && cs.maxWidth.type != CSSLengthType.PERCENTAGE) {
          clamped = math.min(clamped, cs.maxWidth.computedValue);
        }
        if (cs.minWidth.isNotAuto) {
          clamped = math.max(clamped, cs.minWidth.computedValue);
        }
        if (clamped != measuredCross) {
          childStretchedCrossSize = clamped;
          childCrossSizeChanged = true;
        }
      }

      // Removed: Do not propagate measured cross width to child render style.
      // This could freeze an unintended small width from the intrinsic pass
      // (e.g., padding-only width) and break later relayout/clamping.

        // Also relayout if our preserved intrinsic main size (from PASS 2) differs from current size
        double? desiredPreservedMain;
        if (childFlexedMainSize == null) {
          desiredPreservedMain = _childrenIntrinsicMainSizes[child.hashCode];
        }

        bool isChildNeedsLayout = childMainSizeChanged || childCrossSizeChanged || (child.needsRelayout);
        if (!isChildNeedsLayout && desiredPreservedMain != null && (desiredPreservedMain != childOldMainSize)) {
          isChildNeedsLayout = true;
        }

        // CSS Flexbox: When an item does not flex (no grow/shrink applied), its
        // used main size equals its flex base size. Even if the measured size from
        // the first pass equals that base size, we must relayout with a tight main-axis
        // constraint so inline formatting (IFC) inside the item uses the definite
        // available width for text alignment and line breaking.
        //
        // Previously, items with flex-basis in a row-direction container were laid out
        // initially with constraints like minW=flex-basis, maxW=∞. If the resulting
        // border-box width happened to equal flex-basis, we skipped relayout and the
        // IFC kept using unbounded width, breaking text-align semantics.
        //
        // Here we detect that situation (auto main-size, non-tight constraint) and
        // force a relayout to tighten the main-axis constraint to the preserved base size.
        if (!isChildNeedsLayout && desiredPreservedMain != null && childFlexedMainSize == null) {
          final BoxConstraints applied = child.constraints;
          final bool autoMain = _isHorizontalFlexDirection ? child.renderStyle.width.isAuto : child.renderStyle.height.isAuto;
          final bool wasNonTightMain = _isHorizontalFlexDirection
              ? !applied.hasTightWidth
              : !applied.hasTightHeight;
          if (autoMain && wasNonTightMain) {
            isChildNeedsLayout = true;
          }
        }

        // Special-case: empty flex items with percentage max-width/height should not expand
        // to the available main size when width/height is auto. They should size to padding+border only.
        // Force a relayout with preserved main size to clamp them correctly.
        if (!isChildNeedsLayout) {
          if (child is RenderBoxModel) {
            final CSSRenderStyle cs = child.renderStyle;
            bool hasPctMaxMain = _isHorizontalFlexDirection
                ? cs.maxWidth.type == CSSLengthType.PERCENTAGE
                : cs.maxHeight.type == CSSLengthType.PERCENTAGE;
            bool hasAutoMain = _isHorizontalFlexDirection ? cs.width.isAuto : cs.height.isAuto;
            if (hasPctMaxMain && hasAutoMain) {
              // Compute padding+border on main axis
              double paddingBorderMain = _isHorizontalFlexDirection
                  ? (cs.effectiveBorderLeftWidth.computedValue +
                      cs.effectiveBorderRightWidth.computedValue +
                      cs.paddingLeft.computedValue +
                      cs.paddingRight.computedValue)
                  : (cs.effectiveBorderTopWidth.computedValue +
                      cs.effectiveBorderBottomWidth.computedValue +
                      cs.paddingTop.computedValue +
                      cs.paddingBottom.computedValue);

              // Check if this is an empty element (no content)
              bool isEmptyElement = false;

              // Access the DOM element through renderStyle.target
              if (child is RenderBoxModel) {
                Element domElement = child.renderStyle.target;
                // Check if the DOM element has no child nodes
                isEmptyElement = !domElement.hasChildren();
              }

              if (isEmptyElement) {
                // Empty elements with percentage max-width should only size to their padding box
                desiredPreservedMain = paddingBorderMain;
                isChildNeedsLayout = true;
              }
            }
          }
        }


        if (!isChildNeedsLayout) {
          mainAxisExtent += childMainAxisExtent;
          continue;
        }

        // Find and mark the parent that only contains text boxes for flex relayout
        _markFlexRelayoutForTextOnly(child);

        BoxConstraints childConstraints = _getChildAdjustedConstraints(
          child,
          childFlexedMainSize,
          childStretchedCrossSize,
          preserveMainAxisSize: desiredPreservedMain,
        );

        child.layout(childConstraints, parentUsesSize: true);

        // Child main size needs to recalculated after layouted.
        childMainAxisExtent = _getMainAxisExtent(child);


        mainAxisExtent += childMainAxisExtent;
      }
      // Update run main axis & cross axis extent after child is relayouted.
      // Include main-axis gaps between items so remaining space calculation for
      // justify-content is based on (items + gaps), matching PASS 2 behavior.
      if (runChildrenList.length > 1) {
        mainAxisExtent += (runChildrenList.length - 1) * _getMainAxisGap();
      }
      metrics.mainAxisExtent = mainAxisExtent;
      metrics.crossAxisExtent = _recomputeRunCrossExtent(metrics);
    }
  }

  // Adjust flex line cross extent caused by flex item stretch due to alignment properties
  // in the cross axis (align-items/align-self).
  double _recomputeRunCrossExtent(_RunMetrics metrics) {
    final Map<int?, _RunChild> runChildren = metrics.runChildren;
    final List<_RunChild> runChildrenList = runChildren.values.toList();

    double runCrossAxisExtent = 0;

    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;

    for (_RunChild runChild in runChildrenList) {
      RenderBox child = runChild.child;
      double childMainSize = _isHorizontalFlexDirection ? child.size.width : child.size.height;
      double childCrossSize = _isHorizontalFlexDirection ? child.size.height : child.size.width;
      double childCrossMargin = 0;
      if (child is RenderBoxModel) {
        childCrossMargin = _isHorizontalFlexDirection
            ? child.renderStyle.marginTop.computedValue + child.renderStyle.marginBottom.computedValue
            : child.renderStyle.marginLeft.computedValue + child.renderStyle.marginRight.computedValue;
      }
      double childCrossExtent = childCrossSize + childCrossMargin;

      if (runChild.flexedMainSize != childMainSize &&
          child is RenderBoxModel &&
          child.renderStyle.isSelfRenderReplaced() &&
          child.renderStyle.aspectRatio != null) {
        double childAspectRatio = child.renderStyle.aspectRatio!;
        if (_isHorizontalFlexDirection && child.renderStyle.height.isAuto) {
          childCrossSize = runChild.flexedMainSize / childAspectRatio;
        } else if (!_isHorizontalFlexDirection && child.renderStyle.width.isAuto) {
          childCrossSize = runChild.flexedMainSize * childAspectRatio;
        }
        childCrossExtent = childCrossSize + childCrossMargin;
      }

      // Vertical align is only valid for inline box.
      // Baseline alignment in column direction behave the same as flex-start.
      AlignSelf alignSelf = _getAlignSelf(child);
      bool isBaselineAlign = alignSelf == AlignSelf.baseline || renderStyle.alignItems == AlignItems.baseline;

      if (_isHorizontalFlexDirection && isBaselineAlign) {
        // Distance from top to baseline of child
        double childAscent = _getChildAscent(child);
        double? childMarginTop = 0;
        double? childMarginBottom = 0;
        if (child is RenderBoxModel) {
          childMarginTop = child.renderStyle.marginTop.computedValue;
          childMarginBottom = child.renderStyle.marginBottom.computedValue;
        }
        maxSizeAboveBaseline = math.max(
          childAscent,
          maxSizeAboveBaseline,
        );
        maxSizeBelowBaseline = math.max(
          childMarginTop + childMarginBottom + childCrossSize - childAscent,
          maxSizeBelowBaseline,
        );
        runCrossAxisExtent = maxSizeAboveBaseline + maxSizeBelowBaseline;
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossExtent);
      }
    }

    return runCrossAxisExtent;
  }

  // Get constraints of flex items which needs to change size due to
  // flex-grow/flex-shrink or align-items stretch.
  BoxConstraints _getChildAdjustedConstraints(
    RenderBoxModel child,
    double? childFlexedMainSize,
    double? childStretchedCrossSize,
    {double? preserveMainAxisSize}
  ) {
    if (debugLogFlexEnabled) {
      renderingLogger.finer('[Flex] adjustConstraints ${_childDesc(child)} '
          'flexedMain=${childFlexedMainSize?.toStringAsFixed(1)} '
          'stretchedCross=${childStretchedCrossSize?.toStringAsFixed(1)} '
          'preserve=${preserveMainAxisSize?.toStringAsFixed(1)}');
    }
    if (childFlexedMainSize != null) {
      if (_isHorizontalFlexDirection) {
        _overrideChildContentBoxLogicalWidth(child, childFlexedMainSize);
      } else {
        _overrideChildContentBoxLogicalHeight(child, childFlexedMainSize);
      }
    }

    // Only override cross size when we have a positive stretched size.
    // Guard against passing 0 (or negative due to margins) which would
    // incorrectly tighten the child's cross-axis constraints to zero.
    if (childStretchedCrossSize != null && childStretchedCrossSize > 0) {
      if (_isHorizontalFlexDirection) {
        _overrideChildContentBoxLogicalHeight(child, childStretchedCrossSize);
      } else {
        _overrideChildContentBoxLogicalWidth(child, childStretchedCrossSize);
      }
    }

    if (child.renderStyle.isSelfRenderReplaced() && child.renderStyle.aspectRatio != null) {
      _overrideReplacedChildLength(child, childFlexedMainSize, childStretchedCrossSize);
    }

    // Use stored percentage constraints if available, otherwise use current constraints
    BoxConstraints oldConstraints = _childrenOldConstraints[child.hashCode] ?? child.constraints;

    double maxConstraintWidth = child.hasOverrideContentLogicalWidth
        ? math.max(0, child.renderStyle.borderBoxLogicalWidth!)
        : oldConstraints.maxWidth;
    double maxConstraintHeight = child.hasOverrideContentLogicalHeight
        ? math.max(0, child.renderStyle.borderBoxLogicalHeight!)
        : oldConstraints.maxHeight;

    double minConstraintWidth = child.hasOverrideContentLogicalWidth
        ? math.max(0, child.renderStyle.borderBoxLogicalWidth!)
        : (oldConstraints.minWidth > maxConstraintWidth ? maxConstraintWidth : oldConstraints.minWidth);
    double minConstraintHeight = child.hasOverrideContentLogicalHeight
        ? math.max(0, child.renderStyle.borderBoxLogicalHeight!)
        : (oldConstraints.minHeight > maxConstraintHeight ? maxConstraintHeight : oldConstraints.minHeight);

    // If a stretched cross size was computed for this item, apply it directly to
    // the child's constraints in the cross axis. This avoids relying on override
    // flags that can be obscured by wrappers like RenderEventListener.
    if (childStretchedCrossSize != null && childStretchedCrossSize > 0) {
      if (_isHorizontalFlexDirection) {
        minConstraintHeight = childStretchedCrossSize;
        maxConstraintHeight = childStretchedCrossSize;
      } else {
        minConstraintWidth = childStretchedCrossSize;
        maxConstraintWidth = childStretchedCrossSize;
      }
    }

    // For <text /> elements or any inline-level elements in horizontal flex layout,
    // avoid tight height constraints during secondary layout passes.
    // This allows text to properly reflow and adjust its height when width changes.
    bool isTextElement = child.renderStyle.isSelfRenderWidget() && child.renderStyle.target is WebFTextElement;
    bool isInlineElementWithText = (child.renderStyle.display == CSSDisplay.inline ||
            child.renderStyle.display == CSSDisplay.inlineBlock ||
            child.renderStyle.display == CSSDisplay.inlineFlex) &&
        (child.renderStyle.isSelfRenderFlowLayout() || child.renderStyle.isSelfRenderFlexLayout());
    bool isSecondaryLayoutPass = child.hasSize;

    // Allow dynamic height adjustment during secondary layout when width has changed and height is auto
    bool allowDynamicHeight = _isHorizontalFlexDirection &&
        isSecondaryLayoutPass &&
        (isTextElement || isInlineElementWithText) &&
        childFlexedMainSize != null &&
        child.renderStyle.height.isAuto;

    if (allowDynamicHeight) {
      // Remove tight height constraints to allow text to reflow properly
      minConstraintHeight = 0;
      maxConstraintHeight = double.infinity;
    }
    // Calculate minimum height needed for child's content (padding + border + content)
    double contentMinHeight = 0;
    if (!child.renderStyle.paddingTop.isAuto) {
      contentMinHeight += child.renderStyle.paddingTop.computedValue;
    }
    if (!child.renderStyle.paddingBottom.isAuto) {
      contentMinHeight += child.renderStyle.paddingBottom.computedValue;
    }
    contentMinHeight += child.renderStyle.effectiveBorderTopWidth.computedValue;
    contentMinHeight += child.renderStyle.effectiveBorderBottomWidth.computedValue;

    // Allow child to expand beyond parent's maxHeight if content requires it
    // This matches browser behavior where content can overflow constrained parents
    double adjustedMaxHeight = maxConstraintHeight;
    // Allow child to expand beyond parent's maxHeight if content requires it
    // This matches browser behavior where content can overflow constrained parents
    if (contentMinHeight > adjustedMaxHeight) {
      adjustedMaxHeight = contentMinHeight;
    }

    // If the child did not flex in the main axis, preserve its measured main size
    // to prevent block-level expansion to the available width when max-width is percentage
    // and there is no content. This matches the flex algorithm: items are laid out using
    // their resolved main size.
    // Preserve main-axis size only for row-direction containers to provide
    // a definite inline-size to descendants. For column-direction, do NOT
    // clamp height to the preserved base size; letting the item re-measure
    // after cross-axis width becomes definite is required for correct text wrapping.
    if (preserveMainAxisSize != null && childFlexedMainSize == null) {
      if (_isHorizontalFlexDirection) {
        // Preserve base main size for non-flexed items.
        // If a definite flex-basis is specified, it overrides width per spec.
        final bool hasDefiniteFlexBasis = _getFlexBasis(child) != null;
        if (hasDefiniteFlexBasis || (child.renderStyle.width.isAuto && !child.renderStyle.isSelfRenderReplaced())) {
          double clamped = preserveMainAxisSize.clamp(0, maxConstraintWidth);
          minConstraintWidth = clamped;
          maxConstraintWidth = clamped;
        }
      }
    }

    BoxConstraints childConstraints = BoxConstraints(
      minWidth: minConstraintWidth,
      maxWidth: maxConstraintWidth,
      minHeight: minConstraintHeight,
      maxHeight: adjustedMaxHeight,
    );

    if (debugLogFlexEnabled) {
      renderingLogger.finer('[Flex] -> childConstraints ${_childDesc(child)} ${_fmtC(childConstraints)}');
    }

    return childConstraints;
  }

  // When replaced element is stretched or shrinked only on one axis and
  // length is not specified on the other axis, the length needs to be
  // overrided in the other axis.
  void _overrideReplacedChildLength(
    RenderBoxModel child,
    double? childFlexedMainSize,
    double? childStretchedCrossSize,
  ) {
    assert(child.renderStyle.isSelfRenderReplaced());
    if (childFlexedMainSize != null && childStretchedCrossSize == null) {
      if (_isHorizontalFlexDirection) {
        _overrideReplacedChildHeight(child);
      } else {
        _overrideReplacedChildWidth(child);
      }
    }

    if (childFlexedMainSize == null && childStretchedCrossSize != null) {
      if (_isHorizontalFlexDirection) {
        _overrideReplacedChildWidth(child);
      } else {
        _overrideReplacedChildHeight(child);
      }
    }
  }

  // Override replaced child height when its height is auto.
  void _overrideReplacedChildHeight(
    RenderBoxModel child,
  ) {
    assert(child.renderStyle.isSelfRenderReplaced());
    if (child.renderStyle.height.isAuto) {
      double maxConstraintWidth = child.renderStyle.borderBoxLogicalWidth!;
      double maxConstraintHeight = maxConstraintWidth / child.renderStyle.aspectRatio!;
      // Clamp replaced element height by min/max height.
      if (child.renderStyle.minHeight.isNotAuto) {
        double minHeight = child.renderStyle.minHeight.computedValue;
        maxConstraintHeight = maxConstraintHeight < minHeight ? minHeight : maxConstraintHeight;
      }
      if (child.renderStyle.maxHeight.isNotNone) {
        double maxHeight = child.renderStyle.maxHeight.computedValue;
        maxConstraintHeight = maxConstraintHeight > maxHeight ? maxHeight : maxConstraintHeight;
      }
      _overrideChildContentBoxLogicalHeight(child, maxConstraintHeight);
    }
  }

  // Override replaced child width when its width is auto.
  void _overrideReplacedChildWidth(
    RenderBoxModel child,
  ) {
    assert(child.renderStyle.isSelfRenderReplaced());
    if (child.renderStyle.width.isAuto) {
      double maxConstraintHeight = child.renderStyle.borderBoxLogicalHeight!;
      double maxConstraintWidth = maxConstraintHeight * child.renderStyle.aspectRatio!;
      // Clamp replaced element width by min/max width.
      if (child.renderStyle.minWidth.isNotAuto) {
        double minWidth = child.renderStyle.minWidth.computedValue;
        maxConstraintWidth = maxConstraintWidth < minWidth ? minWidth : maxConstraintWidth;
      }
      if (child.renderStyle.maxWidth.isNotNone) {
        double maxWidth = child.renderStyle.maxWidth.computedValue;
        maxConstraintWidth = maxConstraintWidth > maxWidth ? maxWidth : maxConstraintWidth;
      }
      _overrideChildContentBoxLogicalWidth(child, maxConstraintWidth);
    }
  }

  // Override content box logical width of child when flex-grow/flex-shrink/align-items has changed
  // child's size.
  void _overrideChildContentBoxLogicalWidth(RenderBoxModel child, double maxConstraintWidth) {
    child.renderStyle.contentBoxLogicalWidth = child.renderStyle.deflatePaddingBorderWidth(maxConstraintWidth);
    child.hasOverrideContentLogicalWidth = true;
  }

  // Override content box logical height of child when flex-grow/flex-shrink/align-items has changed
  // child's size.
  void _overrideChildContentBoxLogicalHeight(RenderBoxModel child, double maxConstraintHeight) {
    child.renderStyle.contentBoxLogicalHeight = child.renderStyle.deflatePaddingBorderHeight(maxConstraintHeight);
    child.hasOverrideContentLogicalHeight = true;
  }

  // Set flex container size according to children size.
  void _setContainerSize(
    List<_RunMetrics> _runMetrics,
  ) {
    if (_runMetrics.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }
    double runMaxMainSize = _getRunsMaxMainSize(_runMetrics);
    double runCrossSize = _getRunsCrossSize(_runMetrics);

    // mainAxis gaps are already included in metrics.mainAxisExtent after PASS 3.
    // No need to add them again as this would double-count and cause incorrect sizing.

    double contentWidth = _isHorizontalFlexDirection ? runMaxMainSize : runCrossSize;
    double contentHeight = _isHorizontalFlexDirection ? runCrossSize : runMaxMainSize;

    // Respect specified cross size (height for row, width for column) without growing the container.
    // This allows flex items to overflow when their content is taller/wider than the container.
    if (_isHorizontalFlexDirection) {
      final double? specifiedContentHeight = renderStyle.contentBoxLogicalHeight;
      if (specifiedContentHeight != null) {
        contentHeight = specifiedContentHeight;
      }
    } else {
      final double? specifiedContentWidth = renderStyle.contentBoxLogicalWidth;
      if (specifiedContentWidth != null) {
        contentWidth = specifiedContentWidth;
      }
    }

    // Set flex container size.
    Size layoutContentSize = getContentSize(
      contentWidth: contentWidth,
      contentHeight: contentHeight,
    );

    size = getBoxSize(layoutContentSize);

    // Set auto value of min-width and min-height based on size of flex items.
    if (_isHorizontalFlexDirection) {
      minContentWidth = _getMainAxisAutoSize(_runMetrics);
      minContentHeight = _getCrossAxisAutoSize(_runMetrics);
    } else {
      minContentHeight = _getMainAxisAutoSize(_runMetrics);
      minContentWidth = _getCrossAxisAutoSize(_runMetrics);
    }
  }

  // Set size when layout has no child.
  void _setContainerSizeWithNoChild() {
    Size layoutContentSize = getContentSize(
      contentWidth: 0,
      contentHeight: 0,
    );
    setMaxScrollableSize(layoutContentSize);
    size = scrollableSize = getBoxSize(layoutContentSize);
  }

  // Record the main size of all lines.
  void _recordRunsMainSize(_RunMetrics _runMetrics, List<double> runMainSize) {
    Map<int?, _RunChild> runChildren = _runMetrics.runChildren;
    double runMainExtent = 0;
    void iterateRunChildren(int? hashCode, _RunChild runChild) {
      RenderBox child = runChild.child;
      double runChildMainSize = _isHorizontalFlexDirection ? child.size.width : child.size.height;
      // Should add main axis margin of child to the main axis auto size of parent.
      if (child is RenderBoxModel) {
        double childMarginTop = child.renderStyle.marginTop.computedValue;
        double childMarginBottom = child.renderStyle.marginBottom.computedValue;
        double childMarginLeft = child.renderStyle.marginLeft.computedValue;
        double childMarginRight = child.renderStyle.marginRight.computedValue;
        runChildMainSize +=
            _isHorizontalFlexDirection ? childMarginLeft + childMarginRight : childMarginTop + childMarginBottom;
      }
      runMainExtent += runChildMainSize;
    }

    runChildren.forEach(iterateRunChildren);
    runMainSize.add(runMainExtent);
  }

  // Get auto min size in the main axis which equals the main axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getMainAxisAutoSize(
    List<_RunMetrics> _runMetrics,
  ) {
    double autoMinSize = 0;

    // Main size of each run.
    List<double> runMainSize = [];

    // Calculate the max main size of all runs.
    for (_RunMetrics _runMetrics in _runMetrics) {
      _recordRunsMainSize(_runMetrics, runMainSize);
    }

    autoMinSize = runMainSize.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });
    return autoMinSize;
  }

  // Record the cross size of all lines.
  void _recordRunsCrossSize(_RunMetrics _runMetrics, List<double> runCrossSize) {
    Map<int?, _RunChild> runChildren = _runMetrics.runChildren;
    double runCrossExtent = 0;
    List<double> runChildrenCrossSize = [];
    void iterateRunChildren(int? hashCode, _RunChild runChild) {
      RenderBox child = runChild.child;
      double runChildCrossSize = _isHorizontalFlexDirection ? child.size.height : child.size.width;
      runChildrenCrossSize.add(runChildCrossSize);
    }

    runChildren.forEach(iterateRunChildren);
    runCrossExtent = runChildrenCrossSize.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    runCrossSize.add(runCrossExtent);
  }

  // Get auto min size in the cross axis which equals the cross axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getCrossAxisAutoSize(
    List<_RunMetrics> _runMetrics,
  ) {
    double autoMinSize = 0;

    // Cross size of each run.
    List<double> runCrossSize = [];

    // Calculate the max cross size of all runs.
    for (_RunMetrics _runMetrics in _runMetrics) {
      _recordRunsCrossSize(_runMetrics, runCrossSize);
    }

    // Get the sum of lines
    for (double crossSize in runCrossSize) {
      autoMinSize += crossSize;
    }

    return autoMinSize;
  }

  // Set the size of scrollable overflow area for flex layout.
  // https://drafts.csswg.org/css-overflow-3/#scrollable
  void _setMaxScrollableSize(List<_RunMetrics> _runMetrics) {
    // Scrollable main size collection of each line.
    List<double> scrollableMainSizeOfLines = [];
    // Scrollable cross size collection of each line.
    List<double> scrollableCrossSizeOfLines = [];
    // Total cross size of previous lines.
    double preLinesCrossSize = 0;

    for (_RunMetrics runMetric in _runMetrics) {
      Map<int?, _RunChild> runChildren = runMetric.runChildren;

      List<RenderBox> runChildrenList = [];
      // Scrollable main size collection of each child in the line.
      List<double> scrollableMainSizeOfChildren = [];
      // Scrollable cross size collection of each child in the line.
      List<double> scrollableCrossSizeOfChildren = [];

      void iterateRunChildren(int? hashCode, _RunChild runChild) {
        RenderBox child = runChild.child;
        // Total main size of previous siblings.
        double preSiblingsMainSize = 0;
        for (RenderBox sibling in runChildrenList) {
          preSiblingsMainSize += _isHorizontalFlexDirection ? sibling.size.width : sibling.size.height;
        }

        Size childScrollableSize = child.size;

        double childOffsetX = 0;
        double childOffsetY = 0;

        if (child is RenderBoxModel) {
          RenderStyle childRenderStyle = child.renderStyle;
          CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
          CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;
          // Only non scroll container need to use scrollable size, otherwise use its own size.
          if (overflowX == CSSOverflowType.visible && overflowY == CSSOverflowType.visible) {
            childScrollableSize = child.scrollableSize;
          }

          // Scrollable overflow area is defined in the following spec
          // which includes margin, position and transform offset.
          // https://www.w3.org/TR/css-overflow-3/#scrollable-overflow-region

          // Add offset of margin.
          childOffsetX += childRenderStyle.marginLeft.computedValue + childRenderStyle.marginRight.computedValue;
          childOffsetY += childRenderStyle.marginTop.computedValue + childRenderStyle.marginBottom.computedValue;

          // Add offset of position relative.
          // Offset of position absolute and fixed is added in layout stage of positioned renderBox.
          Offset? relativeOffset = CSSPositionedLayout.getRelativeOffset(childRenderStyle);
          if (relativeOffset != null) {
            childOffsetX += relativeOffset.dx;
            childOffsetY += relativeOffset.dy;
          }

          // Add offset of transform.
          final Offset? transformOffset = child.renderStyle.effectiveTransformOffset;
          if (transformOffset != null) {
            childOffsetX += transformOffset.dx;
            childOffsetY += transformOffset.dy;
          }
        }

        scrollableMainSizeOfChildren.add(preSiblingsMainSize +
            (_isHorizontalFlexDirection
                ? childScrollableSize.width + childOffsetX
                : childScrollableSize.height + childOffsetY));
        scrollableCrossSizeOfChildren.add(_isHorizontalFlexDirection
            ? childScrollableSize.height + childOffsetY
            : childScrollableSize.width + childOffsetX);
        runChildrenList.add(child);
      }

      runChildren.forEach(iterateRunChildren);

      // Max scrollable main size of all the children in the line.
      double maxScrollableMainSizeOfLine = scrollableMainSizeOfChildren.reduce((double curr, double next) {
        return curr > next ? curr : next;
      });

      // Max scrollable cross size of all the children in the line.
      double maxScrollableCrossSizeOfLine = preLinesCrossSize +
          scrollableCrossSizeOfChildren.reduce((double curr, double next) {
            return curr > next ? curr : next;
          });

      scrollableMainSizeOfLines.add(maxScrollableMainSizeOfLine);
      scrollableCrossSizeOfLines.add(maxScrollableCrossSizeOfLine);
      preLinesCrossSize += runMetric.crossAxisExtent;
    }

    // Max scrollable main size of all lines.
    double maxScrollableMainSizeOfLines = scrollableMainSizeOfLines.isEmpty
        ? 0
        : scrollableMainSizeOfLines.reduce((double curr, double next) {
            return curr > next ? curr : next;
          });

    RenderBoxModel container = this;
    bool isScrollContainer = renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    // Padding in the end direction of axis should be included in scroll container.
    double maxScrollableMainSizeOfChildren = maxScrollableMainSizeOfLines +
        _flowAwareMainAxisPadding() +
        (isScrollContainer ? _flowAwareMainAxisPadding(isEnd: true) : 0);

    // Max scrollable cross size of all lines.
    double maxScrollableCrossSizeOfLines = scrollableCrossSizeOfLines.isEmpty
        ? 0
        : scrollableCrossSizeOfLines.reduce((double curr, double next) {
            return curr > next ? curr : next;
          });

    // Padding in the end direction of axis should be included in scroll container.
    double maxScrollableCrossSizeOfChildren = maxScrollableCrossSizeOfLines +
        _flowAwareCrossAxisPadding() +
        (isScrollContainer ? _flowAwareCrossAxisPadding(isEnd: true) : 0);

    double containerContentWidth = size.width -
        container.renderStyle.effectiveBorderLeftWidth.computedValue -
        container.renderStyle.effectiveBorderRightWidth.computedValue;
    double containerContentHeight = size.height -
        container.renderStyle.effectiveBorderTopWidth.computedValue -
        container.renderStyle.effectiveBorderBottomWidth.computedValue;
    double maxScrollableMainSize = math.max(
        _isHorizontalFlexDirection ? containerContentWidth : containerContentHeight, maxScrollableMainSizeOfChildren);
    double maxScrollableCrossSize = math.max(
        _isHorizontalFlexDirection ? containerContentHeight : containerContentWidth, maxScrollableCrossSizeOfChildren);

    scrollableSize = _isHorizontalFlexDirection
        ? Size(maxScrollableMainSize, maxScrollableCrossSize)
        : Size(maxScrollableCrossSize, maxScrollableMainSize);
  }

  // Get the cross size of flex line based on flex-wrap and align-items/align-self properties.
  double _getFlexLineCrossSize(
    RenderBox child,
    double runCrossAxisExtent,
    double runBetweenSpace,
  ) {
    bool isSingleLine = (renderStyle.flexWrap != FlexWrap.wrap && renderStyle.flexWrap != FlexWrap.wrapReverse);


    if (isSingleLine) {
      // Normally the height of flex line in single line equals to flex container's cross size.
      // But it may change in cases of the cross size of replaced flex item tranferred from
      // its flexed main size.
      bool isCrossSizeDefinite = _isHorizontalFlexDirection
          ? (renderStyle.contentBoxLogicalHeight != null || renderStyle.minHeight.isNotAuto)
          : (renderStyle.contentBoxLogicalWidth != null || renderStyle.minWidth.isNotAuto);

      if (_needToStretchChildCrossSize(child) && !isCrossSizeDefinite) {
        return runCrossAxisExtent;
      } else {
        return _getContentCrossSize();
      }
    } else {
      // Flex line of align-content stretch should includes between space.
      bool isMultiLineStretch = renderStyle.alignContent == AlignContent.stretch;
      if (isMultiLineStretch) {
        return runCrossAxisExtent + runBetweenSpace;
      } else {
        return runCrossAxisExtent;
      }
    }
  }

  // Set children offset based on alignment properties.
  void _setChildrenOffset(
    List<_RunMetrics> _runMetrics,
  ) {
    if (_runMetrics.isEmpty) return;

    // Compute spacing before and between each flex line.
    Map<String, double> _runSpacingMap = _computeRunSpacing(_runMetrics);

    double runLeadingSpace = _runSpacingMap['leading']!;
    double runBetweenSpace = _runSpacingMap['between']!;
    // Cross axis offset of each flex line.
    double crossAxisOffset = runLeadingSpace;
    double mainAxisContentSize;
    double crossAxisContentSize;

    if (_isHorizontalFlexDirection) {
      mainAxisContentSize = contentSize.width;
      crossAxisContentSize = contentSize.height;
    } else {
      mainAxisContentSize = contentSize.height;
      crossAxisContentSize = contentSize.width;
    }

    // Set offset of children in each flex line.
    for (int i = 0; i < _runMetrics.length; ++i) {
      final _RunMetrics metrics = _runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final Map<int?, _RunChild> runChildren = metrics.runChildren;
      final List<_RunChild> runChildrenList = runChildren.values.toList();
      final double remainingSpace = mainAxisContentSize - runMainAxisExtent;

      late double leadingSpace;
      late double betweenSpace;

      final int runChildrenCount = runChildren.length;

      // flipMainAxis is used to decide whether to lay out left-to-right/top-to-bottom (false), or
      // right-to-left/bottom-to-top (true). The _startIsTopLeft will return null if there's only
      // one child and the relevant direction is null, in which case we arbitrarily decide not to
      // flip, but that doesn't have any detectable effect.
      final bool flipMainAxis = !(_startIsTopLeft(renderStyle.flexDirection) ?? true);
      switch (renderStyle.justifyContent) {
        case JustifyContent.flexStart:
        case JustifyContent.start:
          leadingSpace = 0.0;
          betweenSpace = 0.0;
          break;
        case JustifyContent.flexEnd:
        case JustifyContent.end:
          leadingSpace = remainingSpace;
          betweenSpace = 0.0;
          break;
        case JustifyContent.center:
          leadingSpace = remainingSpace / 2.0;
          betweenSpace = 0.0;
          break;
        case JustifyContent.spaceBetween:
          leadingSpace = 0.0;
          if (remainingSpace < 0) {
            betweenSpace = 0.0;
          } else {
            betweenSpace = runChildrenCount > 1 ? remainingSpace / (runChildrenCount - 1) : 0.0;
          }
          break;
        case JustifyContent.spaceAround:
          if (remainingSpace < 0) {
            leadingSpace = remainingSpace / 2.0;
            betweenSpace = 0.0;
          } else {
            betweenSpace = runChildrenCount > 0 ? remainingSpace / runChildrenCount : 0.0;
            leadingSpace = betweenSpace / 2.0;
          }
          break;
        case JustifyContent.spaceEvenly:
          if (remainingSpace < 0) {
            leadingSpace = remainingSpace / 2.0;
            betweenSpace = 0.0;
          } else {
            betweenSpace = runChildrenCount > 0 ? remainingSpace / (runChildrenCount + 1) : 0.0;
            leadingSpace = betweenSpace;
          }
          break;
        default:
      }

      // Calculate margin auto children in the main axis.
      double mainAxisMarginAutoChildrenCount = 0;

      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;
        if (_isChildMainAxisMarginAutoExist(child)) {
          mainAxisMarginAutoChildrenCount++;
        }
      }

      // Justify-content has no effect if auto margin of child exists in the main axis.
      if (mainAxisMarginAutoChildrenCount != 0) {
        leadingSpace = 0.0;
        betweenSpace = 0.0;
      }

      double mainAxisStartPadding = _flowAwareMainAxisPadding();
      double crossAxisStartPadding = _flowAwareCrossAxisPadding();

      double mainAxisStartBorder = _flowAwareMainAxisBorder();
      double crossAxisStartBorder = _flowAwareCrossAxisBorder();

      // Main axis position of child on layout.
      double childMainPosition = flipMainAxis
          ? mainAxisStartPadding + mainAxisStartBorder + mainAxisContentSize - leadingSpace
          : leadingSpace + mainAxisStartPadding + mainAxisStartBorder;

      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;
        double childMainAxisMargin = _flowAwareChildMainAxisMargin(child)!;
        // Add start margin of main axis when setting offset.
        childMainPosition += _calculateMainAxisMarginForJustContentType(childMainAxisMargin);
        double? childCrossPosition;
        AlignSelf alignSelf = _getAlignSelf(child);

        String? alignment;

        switch (alignSelf) {
          case AlignSelf.flexStart:
          case AlignSelf.start:
          case AlignSelf.stretch:
            alignment = renderStyle.flexWrap == FlexWrap.wrapReverse ? 'end' : 'start';
            break;
          case AlignSelf.flexEnd:
          case AlignSelf.end:
            alignment = renderStyle.flexWrap == FlexWrap.wrapReverse ? 'start' : 'end';
            break;
          case AlignSelf.center:
            alignment = 'center';
            break;
          case AlignSelf.baseline:
            alignment = 'baseline';
            break;
          case AlignSelf.auto:
            switch (renderStyle.alignItems) {
              case AlignItems.flexStart:
              case AlignItems.start:
              case AlignItems.stretch:
                alignment = renderStyle.flexWrap == FlexWrap.wrapReverse ? 'end' : 'start';
                break;
              case AlignItems.flexEnd:
              case AlignItems.end:
                alignment = renderStyle.flexWrap == FlexWrap.wrapReverse ? 'start' : 'end';
                break;
              case AlignItems.center:
                alignment = 'center';
                break;
              case AlignItems.baseline:
                // FIXME: baseline alignment in wrap-reverse flexWrap may display different from browser in some case
                if (_isHorizontalFlexDirection) {
                  alignment = 'baseline';
                } else if (renderStyle.flexWrap == FlexWrap.wrapReverse) {
                  alignment = 'end';
                } else {
                  alignment = 'start';
                }
                break;
            }
            break;
        }

        // Text-align should only work for text node.
        // @TODO: Need to implement flex formatting context to unify with W3C spec.
        // Each contiguous sequence of child text runs is wrapped in an anonymous block container flex item.
        // Text is aligned in anonymous block container rather than flexbox container.
        // https://www.w3.org/TR/css-flexbox-1/#flex-items

        if (renderStyle.alignItems == AlignItems.stretch && child is RenderTextBox && !_isHorizontalFlexDirection) {
          TextAlign textAlign = renderStyle.textAlign;
          if (textAlign == TextAlign.start) {
            alignment = 'start';
          } else if (textAlign == TextAlign.end) {
            alignment = 'end';
          } else if (textAlign == TextAlign.center) {
            alignment = 'center';
          }
        }

        childCrossPosition = _getChildCrossAxisOffset(
          alignment,
          child,
          childCrossPosition,
          runBaselineExtent,
          runCrossAxisExtent,
          runBetweenSpace,
          crossAxisStartPadding,
          crossAxisStartBorder,
        );

        // Calculate margin auto length according to CSS spec rules
        // https://www.w3.org/TR/css-flexbox-1/#auto-margins
        // margin auto takes up available space in the remaining space
        // between flex items and flex container.
        if (child is RenderBoxModel) {
          RenderStyle childRenderStyle = child.renderStyle;
          CSSLengthValue marginLeft = childRenderStyle.marginLeft;
          CSSLengthValue marginRight = childRenderStyle.marginRight;
          CSSLengthValue marginTop = childRenderStyle.marginTop;
          CSSLengthValue marginBottom = childRenderStyle.marginBottom;

          double horizontalRemainingSpace;
          double verticalRemainingSpace;
          // Margin auto does not work with negative remaining space.
          double mainAxisRemainingSpace = math.max(0, remainingSpace);
          double crossAxisRemainingSpace = math.max(0, crossAxisContentSize - _getCrossAxisExtent(child));

          if (_isHorizontalFlexDirection) {
            horizontalRemainingSpace = mainAxisRemainingSpace;
            verticalRemainingSpace = crossAxisRemainingSpace;
            if (marginLeft.isAuto) {
              if (marginRight.isAuto) {
                childMainPosition += (horizontalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
                betweenSpace = (horizontalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
              } else {
                childMainPosition += horizontalRemainingSpace / mainAxisMarginAutoChildrenCount;
              }
            }

            if (marginTop.isAuto) {
              if (marginBottom.isAuto) {
                childCrossPosition = childCrossPosition! + verticalRemainingSpace / 2;
              } else {
                childCrossPosition = childCrossPosition! + verticalRemainingSpace;
              }
            }
          } else {
            horizontalRemainingSpace = crossAxisRemainingSpace;
            verticalRemainingSpace = mainAxisRemainingSpace;
            if (marginTop.isAuto) {
              if (marginBottom.isAuto) {
                childMainPosition += (verticalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
                betweenSpace = (verticalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
              } else {
                childMainPosition += verticalRemainingSpace / mainAxisMarginAutoChildrenCount;
              }
            }

            if (marginLeft.isAuto) {
              if (marginRight.isAuto) {
                childCrossPosition = childCrossPosition! + horizontalRemainingSpace / 2;
              } else {
                childCrossPosition = childCrossPosition! + horizontalRemainingSpace;
              }
            }
          }
        }

        if (flipMainAxis) childMainPosition -= _getMainAxisExtent(child);

        double crossOffset;
        if (renderStyle.flexWrap == FlexWrap.wrapReverse) {
          crossOffset =
              childCrossPosition! + (crossAxisContentSize - crossAxisOffset - runCrossAxisExtent - runBetweenSpace);
        } else {
          crossOffset = childCrossPosition! + crossAxisOffset;
        }
        Offset relativeOffset = _getOffset(childMainPosition, crossOffset);

        // Apply position relative offset change.
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, child);

        // Need to subtract start margin of main axis when calculating next child's start position.
        double mainAxisGap = _getMainAxisGap();

        // For space-between, space-around, and space-evenly, gap should not be applied
        // because these justify-content values already handle the spacing between items
        bool shouldApplyGap = !(renderStyle.justifyContent == JustifyContent.spaceBetween ||
                                renderStyle.justifyContent == JustifyContent.spaceAround ||
                                renderStyle.justifyContent == JustifyContent.spaceEvenly);
        double effectiveGap = shouldApplyGap ? mainAxisGap : 0;

        if (flipMainAxis) {
          childMainPosition -= betweenSpace + childMainAxisMargin + effectiveGap;
        } else {
          childMainPosition += _getMainAxisExtent(child) - childMainAxisMargin + betweenSpace + effectiveGap;
        }
      }

      // Add cross-axis gap spacing between flex lines
      double crossAxisGap = _getCrossAxisGap();
      crossAxisOffset += runCrossAxisExtent + runBetweenSpace + crossAxisGap;
    }
  }

  // Whether need to stretch child in the cross axis according to alignment property and child cross length.
  bool _needToStretchChildCrossSize(RenderBox child) {
    // Position placeholder and BR element has size of zero, so they can not be stretched.
    // The absolutely-positioned box is considered to be “fixed-size”, a value of stretch
    // is treated the same as flex-start.
    // https://www.w3.org/TR/css-flexbox-1/#abspos-items
    final ParentData? childParentData = child.parentData;
    if (child is! RenderBoxModel || (child.renderStyle.isSelfPositioned())) {
      return false;
    }

    AlignSelf alignSelf = _getAlignSelf(child);
    bool isChildAlignmentStretch =
        alignSelf != AlignSelf.auto ? alignSelf == AlignSelf.stretch : renderStyle.alignItems == AlignItems.stretch;

    bool isChildLengthAuto =
        _isHorizontalFlexDirection ? child.renderStyle.height.isAuto : child.renderStyle.width.isAuto;


    // If the cross size property of the flex item computes to auto, and neither of
    // the cross axis margins are auto, the flex item is stretched.
    // https://www.w3.org/TR/css-flexbox-1/#valdef-align-items-stretch
    if (isChildAlignmentStretch && !_isChildCrossAxisMarginAutoExist(child) && isChildLengthAuto) {
      return true;
    }

    return false;
  }

  // Get child stretched size in the cross axis.
  double _getChildStretchedCrossSize(
    RenderBoxModel child,
    double runCrossAxisExtent,
    double runBetweenSpace,
  ) {
    bool isFlexWrap = renderStyle.flexWrap == FlexWrap.wrap || renderStyle.flexWrap == FlexWrap.wrapReverse;
    double childCrossAxisMargin = _horizontalMarginNegativeSet(0, child, isHorizontal: !_isHorizontalFlexDirection);
    _isHorizontalFlexDirection ? child.renderStyle.margin.vertical : child.renderStyle.margin.horizontal;
    double maxCrossSizeConstraints = _isHorizontalFlexDirection ? constraints.maxHeight : constraints.maxWidth;
    double flexLineCrossSize = _getFlexLineCrossSize(child, runCrossAxisExtent, runBetweenSpace);
    // Should subtract margin when stretch flex item.
    double childStretchedCrossSize = flexLineCrossSize - childCrossAxisMargin;
    // Flex line cross size should not exceed container's cross size if specified when flex-wrap is nowrap.
    if (!isFlexWrap && maxCrossSizeConstraints.isFinite) {
      double crossAxisBorder = _isHorizontalFlexDirection ? renderStyle.border.vertical : renderStyle.border.horizontal;
      double crossAxisPadding =
          _isHorizontalFlexDirection ? renderStyle.padding.vertical : renderStyle.padding.horizontal;
      childStretchedCrossSize =
          math.min(maxCrossSizeConstraints - crossAxisBorder - crossAxisPadding, childStretchedCrossSize);
    }

    // Constrain stretched size by max-width/max-height.
    double? maxCrossSize;
    if (_isHorizontalFlexDirection && child.renderStyle.maxHeight.isNotNone) {
      maxCrossSize = child.renderStyle.maxHeight.computedValue;
    } else if (!_isHorizontalFlexDirection && child.renderStyle.maxWidth.isNotNone) {
      maxCrossSize = child.renderStyle.maxWidth.computedValue;
    }
    if (maxCrossSize != null) {
      childStretchedCrossSize = childStretchedCrossSize > maxCrossSize ? maxCrossSize : childStretchedCrossSize;
    }

    // Constrain stretched size by min-width/min-height.
    double? minCrossSize;
    if (_isHorizontalFlexDirection && child.renderStyle.minHeight.isNotAuto) {
      minCrossSize = child.renderStyle.minHeight.computedValue;
    } else if (!_isHorizontalFlexDirection && child.renderStyle.minWidth.isNotAuto) {
      minCrossSize = child.renderStyle.minWidth.computedValue;
    }
    if (minCrossSize != null) {
      childStretchedCrossSize = childStretchedCrossSize < minCrossSize ? minCrossSize : childStretchedCrossSize;
    }

    return childStretchedCrossSize;
  }

  // Whether margin auto of child is set in the main axis.
  bool _isChildMainAxisMarginAutoExist(RenderBox child) {
    if (child is RenderBoxModel) {
      RenderStyle childRenderStyle = child.renderStyle;
      CSSLengthValue marginLeft = childRenderStyle.marginLeft;
      CSSLengthValue marginRight = childRenderStyle.marginRight;
      CSSLengthValue marginTop = childRenderStyle.marginTop;
      CSSLengthValue marginBottom = childRenderStyle.marginBottom;
      if (_isHorizontalFlexDirection && (marginLeft.isAuto || marginRight.isAuto) ||
          !_isHorizontalFlexDirection && (marginTop.isAuto || marginBottom.isAuto)) {
        return true;
      }
    }
    return false;
  }

  // Whether margin auto of child is set in the cross axis.
  bool _isChildCrossAxisMarginAutoExist(RenderBox child) {
    if (child is RenderBoxModel) {
      RenderStyle childRenderStyle = child.renderStyle;
      CSSLengthValue marginLeft = childRenderStyle.marginLeft;
      CSSLengthValue marginRight = childRenderStyle.marginRight;
      CSSLengthValue marginTop = childRenderStyle.marginTop;
      CSSLengthValue marginBottom = childRenderStyle.marginBottom;
      if (_isHorizontalFlexDirection && (marginTop.isAuto || marginBottom.isAuto) ||
          !_isHorizontalFlexDirection && (marginLeft.isAuto || marginRight.isAuto)) {
        return true;
      }
    }
    return false;
  }

  // Get flex item cross axis offset by align-items/align-self.
  double? _getChildCrossAxisOffset(
    String alignment,
    RenderBox child,
    double? childCrossPosition,
    double runBaselineExtent,
    double runCrossAxisExtent,
    double runBetweenSpace,
    double crossAxisStartPadding,
    double crossAxisStartBorder,
  ) {
    // Leading between height of line box's content area and line height of line box.
    double lineBoxLeading = 0;
    double? lineBoxHeight = _getLineHeight(this);
    if (lineBoxHeight != null) {
      lineBoxLeading = lineBoxHeight - runCrossAxisExtent;
    }

    double flexLineCrossSize = _getFlexLineCrossSize(
      child,
      runCrossAxisExtent,
      runBetweenSpace,
    );
    double childCrossAxisStartMargin = _flowAwareChildCrossAxisMargin(child)!;
    double crossStartAddedOffset = crossAxisStartPadding + crossAxisStartBorder + childCrossAxisStartMargin;

    // Align-items and align-self have no effect if auto margin of child exists in the cross axis.
    if (_isChildCrossAxisMarginAutoExist(child)) {
      return crossStartAddedOffset;
    }

    switch (alignment) {
      case 'start':
        return crossStartAddedOffset;
      case 'end':
        // Length returned by _getCrossAxisExtent includes margin, so end alignment should add start margin.
        return crossAxisStartPadding +
            crossAxisStartBorder +
            flexLineCrossSize -
            _getCrossAxisExtent(child) +
            childCrossAxisStartMargin;
      case 'center':
        return childCrossPosition = crossStartAddedOffset + (flexLineCrossSize - _getCrossAxisExtent(child)) / 2.0;
      case 'baseline':
        // Distance from top to baseline of child.
        double childAscent = _getChildAscent(child);
        final double offset = crossStartAddedOffset + lineBoxLeading / 2 + (runBaselineExtent - childAscent);
        if (debugLogFlexBaselineEnabled) {
          // ignore: avoid_print
          print('[FlexBaseline] offset child=${child.runtimeType}#${child.hashCode} '
              'runBaseline=${runBaselineExtent.toStringAsFixed(2)} '
              'childAscent=${childAscent.toStringAsFixed(2)} '
              'lineLeading=${lineBoxLeading.toStringAsFixed(2)} '
              'crossStart=${crossStartAddedOffset.toStringAsFixed(2)} '
              '=> offset=${offset.toStringAsFixed(2)}');
        }
        return offset;
      default:
        return null;
    }
  }

  // Compute distance to baseline of flex layout.
  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeCssFirstBaseline();
  }

  // Get child size through boxSize to avoid flutter error when parentUsesSize is set to false.
  Size? _getChildSize(RenderBox? child, {bool shouldUseIntrinsicMainSize = false}) {
    Size? childSize;
    if (child is RenderBoxModel) {
      childSize = child.boxSize;
    } else if (child is RenderPositionPlaceholder) {
      childSize = child.boxSize;
    } else if (child != null && child.hasSize) {
      // child is WidgetElement.
      childSize = child.size;
    }

    if (shouldUseIntrinsicMainSize) {
      double? childIntrinsicMainSize = _childrenIntrinsicMainSizes[child.hashCode];
      if (_isHorizontalFlexDirection) {
        childSize = Size(childIntrinsicMainSize!, childSize!.height);
      } else {
        childSize = Size(childSize!.width, childIntrinsicMainSize!);
      }
    }
    return childSize;
  }

  // Get distance from top to baseline of child including margin.
  double _getChildAscent(RenderBox child) {
    // Prefer CSS-cached baseline computed during the child's own layout.
    double? childAscent;
    if (child is RenderBoxModel) {
      // Unwrap baseline from wrapped content if this is an event listener wrapper
      if (child is RenderEventListener) {
        final RenderBox? wrapped = child.child;
        if (wrapped is RenderBoxModel) {
          childAscent = wrapped.computeCssFirstBaseline();
          if (debugLogFlexBaselineEnabled) {
            // ignore: avoid_print
            print('[FlexBaseline] unwrap baseline from child content: '
                '${wrapped.runtimeType}#${wrapped.hashCode} => baseline=${childAscent?.toStringAsFixed(2)}');
          }
        } else {
          childAscent = child.computeCssFirstBaseline();
        }
      } else {
        childAscent = child.computeCssFirstBaseline();
      }
    }
    double? childMarginTop = 0;
    double? childMarginBottom = 0;
    if (child is RenderBoxModel) {
      childMarginTop = child.renderStyle.marginTop.computedValue;
      childMarginBottom = child.renderStyle.marginBottom.computedValue;
    }

    Size? childSize = _getChildSize(child);

    double baseline = parent is RenderFlowLayout
        ? childMarginTop + childSize!.height + childMarginBottom
        : childMarginTop + childSize!.height;
    // When baseline of children not found, use boundary of margin bottom as baseline.
    double extentAboveBaseline = childAscent ?? baseline;
    if (debugLogFlexBaselineEnabled) {
      // ignore: avoid_print
      print('[FlexBaseline] _getChildAscent child='
          '${child.runtimeType}#${child.hashCode} '
          'cssFirstBaseline=${childAscent?.toStringAsFixed(2)} '
          'fallback=${baseline.toStringAsFixed(2)} '
          'extent=${extentAboveBaseline.toStringAsFixed(2)} size='
          '${childSize?.width.toStringAsFixed(2)}x${childSize?.height.toStringAsFixed(2)}');
    }

    return extentAboveBaseline;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    if (!_isHorizontalFlexDirection) {
      return Offset(crossAxisOffset, mainAxisOffset);
    } else {
      return Offset(mainAxisOffset, crossAxisOffset);
    }
  }

  // Get cross size of content size.
  double _getContentCrossSize() {
    // Use contentConstraints if contentSize hasn't been set yet (for early stretch calculations)
    double result;
    if (_isHorizontalFlexDirection) {
      result = contentSize.height != 0 ? contentSize.height :
               (contentConstraints?.maxHeight.isFinite == true ? contentConstraints!.maxHeight : 0);
    } else {
      result = contentSize.width != 0 ? contentSize.width :
               (contentConstraints?.maxWidth.isFinite == true ? contentConstraints!.maxWidth : 0);
    }
    return result;
  }

  double? _getLineHeight(RenderBox child) {
    CSSLengthValue? lineHeight;
    if (child is RenderTextBox) {
      lineHeight = renderStyle.lineHeight;
    } else if (child is RenderBoxModel) {
      lineHeight = child.renderStyle.lineHeight;
    } else if (child is RenderPositionPlaceholder) {
      lineHeight = child.positioned?.renderStyle.lineHeight;
    }

    if (lineHeight != null && lineHeight.type != CSSLengthType.NORMAL) {
      return lineHeight.computedValue;
    }
    return null;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FlexDirection>('flexDirection', renderStyle.flexDirection));
    properties.add(DiagnosticsProperty<JustifyContent>('justifyContent', renderStyle.justifyContent));
    properties.add(DiagnosticsProperty<AlignItems>('alignItems', renderStyle.alignItems));
    properties.add(DiagnosticsProperty<FlexWrap>('flexWrap', renderStyle.flexWrap));
  }

  static bool _isPlaceholderPositioned(RenderObject child) {
    if (child is RenderPositionPlaceholder) {
      RenderBoxModel? realDisplayedBox = child.positioned;
      if (realDisplayedBox?.attached == true) {
        if (realDisplayedBox!.renderStyle.isSelfPositioned()) {
          return true;
        }
      }
    }
    return false;
  }

  static bool? _startIsTopLeft(FlexDirection direction) {
    switch (direction) {
      case FlexDirection.column:
      case FlexDirection.row:
        return true;
      case FlexDirection.rowReverse:
      case FlexDirection.columnReverse:
        return false;
    }
  }
}

// Render flex layout with self repaint boundary.
class RenderRepaintBoundaryFlexLayout extends RenderFlexLayout {
  RenderRepaintBoundaryFlexLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(
          children: children,
          renderStyle: renderStyle,
        );

  @override
  bool get isRepaintBoundary => true;
}
