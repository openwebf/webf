/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
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
import 'package:webf/widget.dart';

// Position and size info of each run (flex line) in flex layout.
// https://www.w3.org/TR/css-flexbox-1/#flex-lines
class _RunMetrics {
  _RunMetrics(this.mainAxisExtent,
      this.crossAxisExtent,
      double totalFlexGrow,
      double totalFlexShrink,
      this.baselineExtent,
      this.runChildren,
      double remainingFreeSpace,)
      : _totalFlexGrow = totalFlexGrow,
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
  final List<_RunChild> runChildren;

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
  _RunChild(RenderBox child,
      double originalMainSize,
      double flexedMainSize,
      bool frozen, {
        required this.effectiveChild,
        required this.alignSelf,
        required this.flexGrow,
        required this.flexShrink,
        required this.usedFlexBasis,
        required this.mainAxisMargin,
        required this.mainAxisStartMargin,
        required this.mainAxisEndMargin,
        required this.crossAxisStartMargin,
        required this.crossAxisEndMargin,
        required this.hasAutoMainAxisMargin,
        required this.hasAutoCrossAxisMargin,
        required this.marginLeftAuto,
        required this.marginRightAuto,
        required this.marginTopAuto,
        required this.marginBottomAuto,
        required this.isReplaced,
        required this.aspectRatio,
      })
      : _child = child,
        _originalMainSize = originalMainSize,
        _flexedMainSize = flexedMainSize,
        _unclampedMainSize = originalMainSize,
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

  // Temporary main size computed from free-space distribution before
  // min/max clamping in the current iteration (§9.7). Used to correctly
  // update remaining free space when freezing violating items.
  double get unclampedMainSize => _unclampedMainSize;
  double _unclampedMainSize;

  set unclampedMainSize(double value) {
    if (_unclampedMainSize != value) {
      _unclampedMainSize = value;
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

  // Cached per-item data for flex layout hot loops.
  // `effectiveChild` is the RenderBoxModel representing this flex item (if any).
  final RenderBoxModel? effectiveChild;
  final AlignSelf alignSelf;
  final double flexGrow;
  final double flexShrink;
  final double? usedFlexBasis;
  // Sum of margins in the main axis for flex sizing (computed values only).
  final double mainAxisMargin;
  // Flow-aware start/end margins used during positioning.
  final double mainAxisStartMargin;
  final double mainAxisEndMargin;
  final double crossAxisStartMargin;
  final double crossAxisEndMargin;
  final bool hasAutoMainAxisMargin;
  final bool hasAutoCrossAxisMargin;
  final bool marginLeftAuto;
  final bool marginRightAuto;
  final bool marginTopAuto;
  final bool marginBottomAuto;
  final bool isReplaced;
  final double? aspectRatio;
}

class _OrderedFlexItem {
  const _OrderedFlexItem(this.child, this.order, this.originalIndex);

  final RenderBox child;
  final int order;
  final int originalIndex;
}

class _RunSpacing {
  const _RunSpacing({required this.leading, required this.between});

  final double leading;
  final double between;
}

class _FlexFactorTotals {
  _FlexFactorTotals({required this.flexGrow, required this.flexShrink});

  double flexGrow;
  double flexShrink;
}

class _FlexContainerInvariants {
  const _FlexContainerInvariants({
    required this.isHorizontalFlexDirection,
    required this.isMainAxisStartAtPhysicalStart,
    required this.isMainAxisReversed,
    required this.isCrossAxisHorizontal,
    required this.isCrossAxisStartAtPhysicalStart,
    required this.mainAxisGap,
    required this.crossAxisGap,
    required this.mainAxisPaddingStart,
    required this.mainAxisPaddingEnd,
    required this.crossAxisPaddingStart,
    required this.crossAxisPaddingEnd,
    required this.mainAxisBorderStart,
    required this.mainAxisBorderEnd,
    required this.crossAxisBorderStart,
    required this.crossAxisBorderEnd,
  });

  factory _FlexContainerInvariants.compute(RenderFlexLayout layout) {
    final bool isHorizontalFlexDirection = layout._isHorizontalFlexDirection;
    final bool isMainAxisStartAtPhysicalStart = layout._isMainAxisStartAtPhysicalStart();
    final bool isMainAxisReversed = layout._isMainAxisReversed();

    // Determine cross axis orientation and where cross-start maps physically.
    final CSSWritingMode wm = layout.renderStyle.writingMode;
    final bool inlineIsHorizontal = (wm == CSSWritingMode.horizontalTb);
    final FlexDirection flexDirection = layout.renderStyle.flexDirection;
    final bool isCrossAxisHorizontal;
    final bool isCrossAxisStartAtPhysicalStart;
    if (flexDirection == FlexDirection.row || flexDirection == FlexDirection.rowReverse) {
      // Cross is block axis.
      isCrossAxisHorizontal = !inlineIsHorizontal;
      if (isCrossAxisHorizontal) {
        // vertical-rl => block-start at right; vertical-lr => left.
        isCrossAxisStartAtPhysicalStart = (wm == CSSWritingMode.verticalLr);
      } else {
        // horizontal-tb => block-start at top.
        isCrossAxisStartAtPhysicalStart = true;
      }
    } else {
      // Cross is inline axis.
      isCrossAxisHorizontal = inlineIsHorizontal;
      if (isCrossAxisHorizontal) {
        // Inline-start follows text direction in horizontal-tb.
        isCrossAxisStartAtPhysicalStart = (layout.renderStyle.direction != TextDirection.rtl);
      } else {
        // Inline-start is physical top in vertical writing modes.
        isCrossAxisStartAtPhysicalStart = true;
      }
    }

    return _FlexContainerInvariants(
      isHorizontalFlexDirection: isHorizontalFlexDirection,
      isMainAxisStartAtPhysicalStart: isMainAxisStartAtPhysicalStart,
      isMainAxisReversed: isMainAxisReversed,
      isCrossAxisHorizontal: isCrossAxisHorizontal,
      isCrossAxisStartAtPhysicalStart: isCrossAxisStartAtPhysicalStart,
      mainAxisGap: layout._getMainAxisGap(),
      crossAxisGap: layout._getCrossAxisGap(),
      mainAxisPaddingStart: layout._flowAwareMainAxisPadding(),
      mainAxisPaddingEnd: layout._flowAwareMainAxisPadding(isEnd: true),
      crossAxisPaddingStart: layout._flowAwareCrossAxisPadding(),
      crossAxisPaddingEnd: layout._flowAwareCrossAxisPadding(isEnd: true),
      mainAxisBorderStart: layout._flowAwareMainAxisBorder(),
      mainAxisBorderEnd: layout._flowAwareMainAxisBorder(isEnd: true),
      crossAxisBorderStart: layout._flowAwareCrossAxisBorder(),
      crossAxisBorderEnd: layout._flowAwareCrossAxisBorder(isEnd: true),
    );
  }

  final bool isHorizontalFlexDirection;
  final bool isMainAxisStartAtPhysicalStart;
  final bool isMainAxisReversed;
  final bool isCrossAxisHorizontal;
  final bool isCrossAxisStartAtPhysicalStart;

  final double mainAxisGap;
  final double crossAxisGap;

  final double mainAxisPaddingStart;
  final double mainAxisPaddingEnd;
  final double crossAxisPaddingStart;
  final double crossAxisPaddingEnd;

  final double mainAxisBorderStart;
  final double mainAxisBorderEnd;
  final double crossAxisBorderStart;
  final double crossAxisBorderEnd;
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
    required super.renderStyle,
  }) {
    addAll(children);
  }

  // Returns the used flex-basis in border-box units, honoring box-sizing semantics.
  // For a definite length basis, the used border-box cannot be smaller than
  // padding+border on the main axis. For auto/content or null, returns null.
  double? _getUsedFlexBasis(RenderBox child) {
    double? basis = _getFlexBasis(child);
    if (basis == null) return null;
    // Unwrap wrappers to read padding/border from the flex item element itself.
    RenderBoxModel? box = child is RenderBoxModel
        ? child
        : (child is RenderEventListener ? child.child as RenderBoxModel? : null);
    if (box == null) return basis;
    final double paddingBorder = _isHorizontalFlexDirection
        ? (box.renderStyle.padding.horizontal + box.renderStyle.border.horizontal)
        : (box.renderStyle.padding.vertical + box.renderStyle.border.vertical);
    return math.max(basis, paddingBorder);
  }

  // Flex line boxes of flex layout.
  // https://www.w3.org/TR/css-flexbox-1/#flex-lines
  List<_RunMetrics> _flexLineBoxMetrics = <_RunMetrics>[];

  // Cache the intrinsic size of children before flex-grow/flex-shrink
  // to avoid relayout when style of flex items changes.
  Expando<double> _childrenIntrinsicMainSizes = Expando<double>('childrenIntrinsicMainSizes');

  // Cache original constraints of children on the first layout.
  Expando<BoxConstraints> _childrenOldConstraints = Expando<BoxConstraints>('childrenOldConstraints');

  _FlexContainerInvariants? _layoutInvariants;

  @override
  void dispose() {
    super.dispose();

    // Do not forget to clear reference variables, or it will cause memory leaks!
    _flexLineBoxMetrics.clear();
    _childrenIntrinsicMainSizes = Expando<double>('childrenIntrinsicMainSizes');
    _childrenOldConstraints = Expando<BoxConstraints>('childrenOldConstraints');
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  // Whether this flex container lives under a WebFWidgetElementChild wrapper,
  // meaning its outer constraints may come directly from a Flutter widget
  // (e.g., ConstrainedBox) rather than pure CSS layout.
  bool get _hasWidgetConstraintAncestor {
    // return parent is RenderWidgetElementChild;
    return (this as RenderBoxModel).findWidgetElementChild() != null;
  }

  bool get _isHorizontalFlexDirection {
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return inv.isHorizontalFlexDirection;
    // Map flex direction to physical axis considering writing-mode.
    // Row follows the inline axis; column follows the block axis.
    // In horizontal-tb, inline axis is horizontal; in vertical-rl/lr, inline axis is vertical.
    final CSSWritingMode wm = renderStyle.writingMode;
    final bool inlineIsHorizontal = (wm == CSSWritingMode.horizontalTb);
    switch (renderStyle.flexDirection) {
      case FlexDirection.row:
      case FlexDirection.rowReverse:
        return inlineIsHorizontal;
      case FlexDirection.column:
      case FlexDirection.columnReverse:
        return !inlineIsHorizontal; // block axis is perpendicular to inline axis
    }
  }

  // Determine if the main-axis start maps to the physical left (for horizontal)
  // or top (for vertical). This accounts for both flex-direction and text direction.
  bool _isMainAxisStartAtPhysicalStart() {
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return inv.isMainAxisStartAtPhysicalStart;
    final dir = renderStyle.direction;
    final CSSWritingMode wm = renderStyle.writingMode;
    final bool inlineIsHorizontal = (wm == CSSWritingMode.horizontalTb);
    switch (renderStyle.flexDirection) {
      case FlexDirection.row:
        if (inlineIsHorizontal) {
          return dir != TextDirection.rtl; // LTR → left is start; RTL → right is start
        } else {
          return true; // vertical inline: top is start
        }
      case FlexDirection.rowReverse:
        if (inlineIsHorizontal) {
          return dir == TextDirection.rtl; // row-reverse flips inline start/end
        } else {
          return false; // vertical inline: bottom is start
        }
      case FlexDirection.column:
      // Column follows block axis.
      // - horizontal-tb: block is vertical (top is start)
      // - vertical-rl:  block is horizontal (start at physical right)
      // - vertical-lr:  block is horizontal (start at physical left)
        if (inlineIsHorizontal) {
          return true; // top is start
        } else {
          return wm == CSSWritingMode.verticalLr;
        }
      case FlexDirection.columnReverse:
        if (inlineIsHorizontal) {
          return false; // bottom is start
        } else {
          // Reverse the block direction of vertical writing modes
          return wm == CSSWritingMode.verticalRl;
        }
    }
  }

  // Whether the main axis flows in the reverse physical direction
  // (e.g., horizontal RTL row, or column-reverse).
  bool _isMainAxisReversed() {
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return inv.isMainAxisReversed;
    if (_isHorizontalFlexDirection) {
      // Horizontal: reversed when main-start is at the physical right
      return !_isMainAxisStartAtPhysicalStart();
    } else {
      // Vertical: reversed when column-reverse
      return renderStyle.flexDirection == FlexDirection.columnReverse;
    }
  }

  // Get start/end padding in the main axis according to flex direction.
  double _flowAwareMainAxisPadding({bool isEnd = false}) {
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return isEnd ? inv.mainAxisPaddingEnd : inv.mainAxisPaddingStart;
    if (_isHorizontalFlexDirection) {
      final bool startIsLeft = _isMainAxisStartAtPhysicalStart();
      if (!isEnd) {
        return startIsLeft ? renderStyle.paddingLeft.computedValue : renderStyle.paddingRight.computedValue;
      } else {
        return startIsLeft ? renderStyle.paddingRight.computedValue : renderStyle.paddingLeft.computedValue;
      }
    } else {
      final bool startIsTop = _isMainAxisStartAtPhysicalStart();
      if (!isEnd) {
        return startIsTop ? renderStyle.paddingTop.computedValue : renderStyle.paddingBottom.computedValue;
      } else {
        return startIsTop ? renderStyle.paddingBottom.computedValue : renderStyle.paddingTop.computedValue;
      }
    }
  }

  // Get start/end padding in the cross axis according to flex direction.
  double _flowAwareCrossAxisPadding({bool isEnd = false}) {
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return isEnd ? inv.crossAxisPaddingEnd : inv.crossAxisPaddingStart;
    // Cross axis comes from block axis for row, inline axis for column
    final CSSWritingMode wm = renderStyle.writingMode;
    final bool inlineIsHorizontal = (wm == CSSWritingMode.horizontalTb);
    final bool crossIsHorizontal;
    bool crossStartIsPhysicalStart; // left for horizontal, top for vertical
    if (renderStyle.flexDirection == FlexDirection.row || renderStyle.flexDirection == FlexDirection.rowReverse) {
      crossIsHorizontal = !inlineIsHorizontal; // block axis
      if (crossIsHorizontal) {
        crossStartIsPhysicalStart =
        (wm == CSSWritingMode.verticalLr); // start at left for vertical-lr, right for vertical-rl
      } else {
        crossStartIsPhysicalStart = true; // top for horizontal-tb
      }
    } else {
      crossIsHorizontal = inlineIsHorizontal; // inline axis
      if (crossIsHorizontal) {
        crossStartIsPhysicalStart = (renderStyle.direction != TextDirection.rtl); // left if LTR, right if RTL
      } else {
        crossStartIsPhysicalStart = true; // top in vertical writing modes
      }
    }

    if (crossIsHorizontal) {
      if (!isEnd) {
        return crossStartIsPhysicalStart
            ? renderStyle.paddingLeft.computedValue
            : renderStyle.paddingRight.computedValue;
      } else {
        return crossStartIsPhysicalStart
            ? renderStyle.paddingRight.computedValue
            : renderStyle.paddingLeft.computedValue;
      }
    } else {
      return isEnd ? renderStyle.paddingBottom.computedValue : renderStyle.paddingTop.computedValue;
    }
  }

  // Get start/end border in the main axis according to flex direction.
  double _flowAwareMainAxisBorder({bool isEnd = false}) {
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return isEnd ? inv.mainAxisBorderEnd : inv.mainAxisBorderStart;
    if (_isHorizontalFlexDirection) {
      final bool startIsLeft = _isMainAxisStartAtPhysicalStart();
      if (!isEnd) {
        return startIsLeft
            ? renderStyle.effectiveBorderLeftWidth.computedValue
            : renderStyle.effectiveBorderRightWidth.computedValue;
      } else {
        return startIsLeft
            ? renderStyle.effectiveBorderRightWidth.computedValue
            : renderStyle.effectiveBorderLeftWidth.computedValue;
      }
    } else {
      final bool startIsTop = _isMainAxisStartAtPhysicalStart();
      if (!isEnd) {
        return startIsTop
            ? renderStyle.effectiveBorderTopWidth.computedValue
            : renderStyle.effectiveBorderBottomWidth.computedValue;
      } else {
        return startIsTop
            ? renderStyle.effectiveBorderBottomWidth.computedValue
            : renderStyle.effectiveBorderTopWidth.computedValue;
      }
    }
  }

  // Get start/end border in the cross axis according to flex direction.
  double _flowAwareCrossAxisBorder({bool isEnd = false}) {
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return isEnd ? inv.crossAxisBorderEnd : inv.crossAxisBorderStart;
    final CSSWritingMode wm = renderStyle.writingMode;
    final bool crossIsHorizontal = !_isHorizontalFlexDirection;
    if (crossIsHorizontal) {
      final bool usesBlockAxis = renderStyle.flexDirection == FlexDirection.row ||
          renderStyle.flexDirection == FlexDirection.rowReverse;
      final bool crossStartIsPhysicalLeft = usesBlockAxis ? (wm == CSSWritingMode.verticalLr) : true;
      if (!isEnd) {
        return crossStartIsPhysicalLeft
            ? renderStyle.effectiveBorderLeftWidth.computedValue
            : renderStyle.effectiveBorderRightWidth.computedValue;
      } else {
        return crossStartIsPhysicalLeft
            ? renderStyle.effectiveBorderRightWidth.computedValue
            : renderStyle.effectiveBorderLeftWidth.computedValue;
      }
    } else {
      return isEnd
          ? renderStyle.effectiveBorderBottomWidth.computedValue
          : renderStyle.effectiveBorderTopWidth.computedValue;
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
      final bool startIsLeft = _isMainAxisStartAtPhysicalStart();
      if (!isEnd) {
        return startIsLeft
            ? childRenderBoxModel.renderStyle.marginLeft.computedValue
            : childRenderBoxModel.renderStyle.marginRight.computedValue;
      } else {
        return startIsLeft
            ? childRenderBoxModel.renderStyle.marginRight.computedValue
            : childRenderBoxModel.renderStyle.marginLeft.computedValue;
      }
    } else {
      final bool startIsTop = _isMainAxisStartAtPhysicalStart();
      if (!isEnd) {
        return startIsTop
            ? childRenderBoxModel.renderStyle.marginTop.computedValue
            : childRenderBoxModel.renderStyle.marginBottom.computedValue;
      } else {
        return startIsTop
            ? childRenderBoxModel.renderStyle.marginBottom.computedValue
            : childRenderBoxModel.renderStyle.marginTop.computedValue;
      }
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
    final CSSWritingMode wm = renderStyle.writingMode;
    final bool crossIsHorizontal = !_isHorizontalFlexDirection;
    if (crossIsHorizontal) {
      final bool usesBlockAxis = renderStyle.flexDirection == FlexDirection.row ||
          renderStyle.flexDirection == FlexDirection.rowReverse;
      final bool crossStartIsPhysicalLeft = usesBlockAxis ? (wm == CSSWritingMode.verticalLr) : true;
      if (!isEnd) {
        return crossStartIsPhysicalLeft
            ? childRenderBoxModel.renderStyle.marginLeft.computedValue
            : childRenderBoxModel.renderStyle.marginRight.computedValue;
      } else {
        return crossStartIsPhysicalLeft
            ? childRenderBoxModel.renderStyle.marginRight.computedValue
            : childRenderBoxModel.renderStyle.marginLeft.computedValue;
      }
    } else {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginBottom.computedValue
          : childRenderBoxModel.renderStyle.marginTop.computedValue;
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
    RenderBoxModel? box = child is RenderBoxModel
        ? child
        : (child is RenderEventListener ? child.child as RenderBoxModel? : null);
    return box != null ? box.renderStyle.flexGrow : 0.0;
  }

  double _getFlexShrink(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element.
    if (child is RenderPositionPlaceholder) {
      return 0;
    }
    RenderBoxModel? box = child is RenderBoxModel
        ? child
        : (child is RenderEventListener ? child.child as RenderBoxModel? : null);
    return box != null ? box.renderStyle.flexShrink : 0.0;
  }

  double? _getFlexBasis(RenderBox child) {
    RenderBoxModel? box = child is RenderBoxModel
        ? child
        : (child is RenderEventListener ? child.child as RenderBoxModel? : null);
    if (box != null && box.renderStyle.flexBasis != CSSLengthValue.auto) {
      // flex-basis: content → base size is content-based; do not return a numeric value here
      if (box.renderStyle.flexBasis?.type == CSSLengthType.CONTENT) {
        return null;
      }
      double? flexBasis = box.renderStyle.flexBasis?.computedValue;

      ///  https://www.w3.org/TR/2018/CR-css-flexbox-1-20181119/#flex-basis-property
      ///  percentage values of flex-basis are resolved against the flex item’s containing block (i.e. its flex container);
      ///  and if that containing block’s size is indefinite, the used value for flex-basis is content.
      // Note: When flex-basis is 0%, it should remain 0, not be changed to minContentWidth
      // The commented code below was incorrectly setting flexBasis to minContentWidth for 0% values
      if (flexBasis != null && flexBasis == 0 && box.renderStyle.flexBasis?.type == CSSLengthType.PERCENTAGE) {
        // CSS Flexbox: percentage flex-basis is resolved against the flex container’s
        // inner main size. If that size is indefinite, the used value is 'content'.
        // Consider explicit sizing, tight constraints, or bounded constraints as definite.
        final bool hasSpecifiedMain = _isHorizontalFlexDirection
            ? (renderStyle.contentBoxLogicalWidth != null)
            : (renderStyle.contentBoxLogicalHeight != null);
        final bool mainTight = _isHorizontalFlexDirection
            ? ((contentConstraints?.hasTightWidth ?? false) || constraints.hasTightWidth)
            : ((contentConstraints?.hasTightHeight ?? false) || constraints.hasTightHeight);
        final bool mainDefinite = hasSpecifiedMain || mainTight;
        if (!mainDefinite) {
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

  double _getMaxMainAxisSize(RenderBoxModel child) {
    double? resolvePctCap(CSSLengthValue len) {
      if (len.type != CSSLengthType.PERCENTAGE || len.value == null) return null;
      // Determine the container's inner content-box size in the main axis.
      double? containerInner;
      if (_isHorizontalFlexDirection) {
        containerInner = renderStyle.contentBoxLogicalWidth;
        if (containerInner == null) {
          if (contentConstraints != null && contentConstraints!.maxWidth.isFinite) {
            containerInner = contentConstraints!.maxWidth;
          } else if (constraints.hasTightWidth && constraints.maxWidth.isFinite) {
            containerInner = constraints.maxWidth;
          } else {
            // Fallback to ancestor-provided available inline size used for shrink-to-fit.
            final double cmw = (renderStyle).contentMaxConstraintsWidth;
            if (cmw.isFinite) containerInner = cmw;
          }
        }
      } else {
        containerInner = renderStyle.contentBoxLogicalHeight;
        if (containerInner == null) {
          if (contentConstraints != null && contentConstraints!.maxHeight.isFinite) {
            containerInner = contentConstraints!.maxHeight;
          } else if (constraints.hasTightHeight && constraints.maxHeight.isFinite) {
            containerInner = constraints.maxHeight;
          }
        }
      }
      if (containerInner != null && containerInner.isFinite) {
        // Min/max in WebF are applied to the border-box. Percentage is relative to
        // the flex container's content box in the main axis, so the cap is:
        // border-box cap = percent * container content size.
        final double pct = len.value!.clamp(0.0, double.infinity);
        return containerInner * pct;
      }
      return null;
    }

    if (_isHorizontalFlexDirection) {
      final CSSLengthValue mw = child.renderStyle.maxWidth;
      if (mw.isNone) return double.infinity;
      // Prefer resolving percentage against the flex container when possible.
      final double? pctCap = resolvePctCap(mw);
      return pctCap ?? mw.computedValue;
    } else {
      final CSSLengthValue mh = child.renderStyle.maxHeight;
      if (mh.isNone) return double.infinity;
      final double? pctCap = resolvePctCap(mh);
      return pctCap ?? mh.computedValue;
    }
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
    if (textParentBoxModel.renderStyle.display == CSSDisplay.flex &&
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
    // Use content-box for specified size suggestion, per spec language.
    // The automatic minimum size compares content-box suggestions and only
    // converts to border-box at the end by adding padding/border.
    double? childLogicalWidth = child.renderStyle.contentBoxLogicalWidth;
    double? childLogicalHeight = child.renderStyle.contentBoxLogicalHeight;

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
    // Prefer IFC-driven min-intrinsic width/height for flow content to avoid
    // overestimating the automatic minimum size (which can cause unintended
    // overflow). Fall back to cached minContentWidth/Height when IFC is not
    // established or values are unavailable.
    double contentSize;
    if (_isHorizontalFlexDirection) {
      if (child is RenderFlowLayout && child.inlineFormattingContext != null) {
        final double ifcMin = child.inlineFormattingContext!.paragraphMinIntrinsicWidth;
        contentSize = (ifcMin.isFinite && ifcMin > 0) ? ifcMin : child.minContentWidth;
      } else {
        contentSize = child.minContentWidth;
      }
    } else {
      if (child is RenderFlowLayout && child.inlineFormattingContext != null) {
        // For column direction, use IFC height only when that context exists; otherwise use cached minContentHeight.
        // Note: Paragraph min-intrinsic height is effectively the single-line height.
        // Our cached minContentHeight is produced by flow layout and is already suitable here.
        contentSize = child.minContentHeight;
      } else {
        contentSize = child.minContentHeight;
      }
    }

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
    double autoMinSizeContent;

    if (specifiedSize != null) {
      // Per CSS Flexbox automatic minimum size rules used by browsers in practice,
      // flex items are allowed to shrink below a specified width unless an explicit
      // min-width is set. Treat the content-based minimum as the smaller of the
      // content size suggestion and the specified size suggestion, so a definite
      // width does not implicitly become a min-width.
      autoMinSizeContent = math.min(contentSize, specifiedSize);
    } else {
      if (childAspectRatio != null) {
        // With an aspect ratio and no specified size, use the smaller of content size suggestion
        // and transferred size suggestion (still a content-box size at this point).
        autoMinSizeContent = math.min(contentSize, transferredSize!);
      } else {
        // Otherwise the content size suggestion (content-box).
        autoMinSizeContent = contentSize;
      }
    }

    // Convert the content-box minimum to a border-box minimum by adding padding and border
    // on the flex container's main axis, per CSS sizing.
    final double paddingBorderMain = _isHorizontalFlexDirection
        ? (childRenderStyle.padding.horizontal + childRenderStyle.border.horizontal)
        : (childRenderStyle.padding.vertical + childRenderStyle.border.vertical);

    // If overflow in the flex main axis is not visible, browsers allow the flex item
    // to shrink below the content-based minimum. Model this by treating the automatic
    // minimum as zero (border-box becomes just padding+border).
    if ((_isHorizontalFlexDirection && childRenderStyle.overflowX != CSSOverflowType.visible) ||
        (!_isHorizontalFlexDirection && childRenderStyle.overflowY != CSSOverflowType.visible)) {
      double autoMinBorderBox = paddingBorderMain;
      if (maxMainLength.isNotNone) {
        autoMinBorderBox = math.min(autoMinBorderBox, maxMainLength.computedValue);
      }
      return autoMinBorderBox;
    }

    double autoMinBorderBox = autoMinSizeContent + paddingBorderMain;

    // Finally, clamp by the definite max main size (which is border-box) if present.
    if (maxMainLength.isNotNone) {
      autoMinBorderBox = math.min(autoMinBorderBox, maxMainLength.computedValue);
    }

    return autoMinBorderBox;
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
    // Unwrap event listener wrappers so intrinsic sizing uses the actual flex item
    if (child is RenderEventListener && child.child is RenderBoxModel) {
      child = child.child as RenderBoxModel;
    }
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
        // Row direction: main axis is width. For intrinsic measurement, avoid
        // inheriting the container's main-axis cap when width is auto or
        // flex-basis:content so content can determine its natural size.
        if (!isReplaced && (s.width.isAuto || isFlexBasisContent)) {
          c = BoxConstraints(
            minWidth: c.minWidth,
            maxWidth: double.infinity,
            minHeight: c.minHeight,
            maxHeight: c.maxHeight,
          );
        }
      } else {
        // Column direction: main axis is height. Similarly, for intrinsic
        // measurement avoid inheriting a tight/zero maxHeight from the container
        // when the item has auto height or flex-basis:content. This lets the
        // item size to its content instead of being prematurely clamped to 0.
        if (!isReplaced && (s.height.isAuto || isFlexBasisContent)) {
          c = BoxConstraints(
            minWidth: c.minWidth,
            maxWidth: c.maxWidth,
            minHeight: c.minHeight,
            maxHeight: double.infinity,
          );
        }
        // Column direction: main axis vertical, cross axis is width.
        // For intrinsic measurement of auto-width flex items, use the container's available
        // width only when the item would actually be stretched in the cross axis. Otherwise,
        // for align-self not stretching, let the item shrink-to-fit its contents so that
        // percentage paddings and similar effects resolve against the item's own width.
        if (!isReplaced && (s.width.isAuto || isFlexBasisContent)) {
          // Determine if child should be stretched in cross axis.
          final AlignSelf self = s.alignSelf;
          final bool parentStretch = renderStyle.alignItems == AlignItems.stretch;
          final bool shouldStretch = self == AlignSelf.auto ? parentStretch : self == AlignSelf.stretch;

          // Determine if the container has a definite cross size (width).
          // Determine whether the flex container's cross size (width in column direction)
          // is definite at this point. A width is definite if:
          // - The container has a specified content-box width (CSS width), or
          // - The container's contentConstraints report a tight width, or
          // - The outer constraints are tight in width (e.g., fixed-size slot), AND the
          //   container is not inline-flex with auto width (inline-flex shrink-to-fit should
          //   be treated as indefinite during intrinsic measurement).
          final bool isInlineFlexAuto =
              renderStyle.effectiveDisplay == CSSDisplay.inlineFlex && renderStyle.width.isAuto;
          final bool containerCrossDefinite =
              (renderStyle.contentBoxLogicalWidth != null) ||
                  (contentConstraints?.hasTightWidth ?? false) ||
                  (constraints.hasTightWidth && !isInlineFlexAuto) ||
                  (((contentConstraints?.hasBoundedWidth ?? false) || constraints.hasBoundedWidth) &&
                      !isInlineFlexAuto);

          double newMaxW;
          if (containerCrossDefinite && shouldStretch) {
            // Clamp to the container's available width. Prefer tight widths;
            // otherwise, for non-inline-flex, a bounded width is acceptable for wrapping.
            double boundedContainerW = double.infinity;
            if (constraints.hasTightWidth && constraints.maxWidth.isFinite) {
              boundedContainerW = constraints.maxWidth;
            } else if ((contentConstraints?.hasTightWidth ?? false) && contentConstraints!.maxWidth.isFinite) {
              boundedContainerW = contentConstraints!.maxWidth;
            } else if (!isInlineFlexAuto) {
              // Fall back to bounded (non-tight) width for block-level flex containers.
              if ((contentConstraints?.hasBoundedWidth ?? false) && contentConstraints!.maxWidth.isFinite) {
                boundedContainerW = contentConstraints!.maxWidth;
              }
            }
            newMaxW = boundedContainerW;
          } else if (containerCrossDefinite && !shouldStretch) {
            // Not stretching: during intrinsic measurement, do not clamp the cross-axis
            // width to the container. Let content determine its natural (max-content)
            // contribution so that subsequent shrink-to-fit in _getChildAdjustedConstraints
            // can correctly choose between min-/max-content. This avoids measuring the
            // item at full container width (e.g., 398px) which breaks centering tests.
            newMaxW = double.infinity;
          } else {
            // No definite container width: let content determine size.
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
            maxHeight: c.maxHeight,
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
        // Do not clamp intrinsic constraints to a zero percentage flex-basis. Per spec,
        // percentage flex-basis resolves against the flex container’s inner main size;
        // when that size is effectively indefinite for intrinsic measurement, using 0
        // would prematurely collapse the child. Let content sizing drive the measure.
        final RenderBoxModel childBox = child;
        final bool isZeroPctBasis = childBox.renderStyle.flexBasis?.type == CSSLengthType.PERCENTAGE && basis == 0;
        // Only skip clamping to 0 for percentage flex-basis during intrinsic sizing
        // in column direction (vertical main axis). In row direction, a 0% flex-basis
        // should remain 0 for intrinsic measurement so width-based distribution matches CSS.
        if (isZeroPctBasis && !_isHorizontalFlexDirection) {
          // Skip applying basis=0 as a tight constraint; keep prior relaxed constraints.
        } else {
          // Flex-basis is a definite length. Honor box-sizing:border-box semantics:
          // the used border-box size cannot be smaller than padding+border.
          if (_isHorizontalFlexDirection) {
            final double minBorderBoxW =
                child.renderStyle.padding.horizontal + child.renderStyle.border.horizontal;
            final double used = math.max(basis, minBorderBoxW);
            c = BoxConstraints(
              minWidth: used,
              maxWidth: used,
              minHeight: c.minHeight,
              maxHeight: c.maxHeight,
            );
          } else {
            final double minBorderBoxH =
                child.renderStyle.padding.vertical + child.renderStyle.border.vertical;
            final double used = math.max(basis, minBorderBoxH);
            c = BoxConstraints(
              minWidth: c.minWidth,
              maxWidth: c.maxWidth,
              minHeight: used,
              maxHeight: used,
            );
          }
        }
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
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return inv.mainAxisGap;
    CSSLengthValue gap = _isHorizontalFlexDirection
        ? renderStyle.columnGap
        : renderStyle.rowGap;
    if (gap.type == CSSLengthType.NORMAL) return 0;
    return gap.computedValue;
  }

  // Get gap spacing for cross axis (between flex lines)
  double _getCrossAxisGap() {
    final _FlexContainerInvariants? inv = _layoutInvariants;
    if (inv != null) return inv.crossAxisGap;
    CSSLengthValue gap = _isHorizontalFlexDirection
        ? renderStyle.rowGap
        : renderStyle.columnGap;
    if (gap.type == CSSLengthType.NORMAL) return 0;
    return gap.computedValue;
  }

  // Sort flex items by their order property (default order is 0), stably.
  // When multiple items have the same order, preserve their original DOM order.
  List<RenderBox> _getSortedFlexItems(List<RenderBox> children) {
    if (children.length < 2) return children;

    int getOrder(RenderBox box) {
      if (box is RenderBoxModel) return box.renderStyle.order;
      if (box is RenderEventListener) {
        final RenderBox? inner = box.child;
        if (inner is RenderBoxModel) return inner.renderStyle.order;
      }
      return 0;
    }

    // Fast path: avoid sorting/allocation when all orders are 0, or already sorted.
    bool anyNonZero = false;
    bool alreadySorted = true;
    int prevOrder = getOrder(children[0]);
    anyNonZero = prevOrder != 0;
    for (int i = 1; i < children.length; i++) {
      final int order = getOrder(children[i]);
      anyNonZero = anyNonZero || order != 0;
      if (order < prevOrder) alreadySorted = false;
      prevOrder = order;
    }
    if (!anyNonZero || alreadySorted) return children;

    // Stable sort by (order, originalIndex).
    final List<_OrderedFlexItem> items = List<_OrderedFlexItem>.generate(
      children.length,
      (int i) => _OrderedFlexItem(children[i], getOrder(children[i]), i),
      growable: false,
    );
    items.sort((_OrderedFlexItem a, _OrderedFlexItem b) {
      final int byOrder = a.order.compareTo(b.order);
      return byOrder != 0 ? byOrder : a.originalIndex.compareTo(b.originalIndex);
    });
    return List<RenderBox>.generate(items.length, (int i) => items[i].child, growable: false);
  }

  @override
  void performLayout() {
    try {
      _doPerformLayout();

      if (needsRelayout) {
        _doPerformLayout();
        needsRelayout = false;
      }
    } catch (e, stack) {
      if (!kReleaseMode) {
        layoutExceptions = '$e\n$stack';
        reportException('performLayout', e, stack);
      }
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

    _layoutInvariants = _FlexContainerInvariants.compute(this);
    try {
      List<RenderBoxModel> positionedChildren = [];
      List<RenderPositionPlaceholder> positionPlaceholderChildren = [];
      List<RenderBox> flexItemChildren = [];

      // Prepare children of different type for layout.
      RenderBox? child = firstChild;
      while (child != null) {
        final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
        if (child is RenderBoxModel &&
            (child.renderStyle.isSelfPositioned() || child.renderStyle.isSelfStickyPosition())) {
          positionedChildren.add(child);
        } else if (child is RenderPositionPlaceholder && _isPlaceholderPositioned(child)) {
          positionPlaceholderChildren.add(child);
        } else {
          flexItemChildren.add(child);
        }
        child = childParentData.nextSibling;
      }

      if (!kReleaseMode) {
        developer.Timeline.startSync('RenderFlex.layoutPositionedChild');
      }

      // Need to layout out of flow positioned element before normal flow element
      // cause the size of RenderPositionPlaceholder in flex layout needs to use
      // the size of its original RenderBoxModel.
      for (RenderBoxModel child in positionedChildren) {
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
      List<RenderBox> orderedChildren = _getSortedFlexItems(flexItemChildren);
      _layoutFlexItems(orderedChildren);

      if (!kReleaseMode) {
        developer.Timeline.finishSync();
      }

      // After flex container size is resolved, relayout absolute/fixed positioned
      // children whose auto-height depends on top/bottom insets and the containing
      // block height. The initial layout before flex items ensures placeholders
      // get the correct intrinsic size; this second pass adjusts the actual
      // positioned box to stretch vertically without affecting flex metrics.
      for (RenderBoxModel child in positionedChildren) {
        final CSSRenderStyle rs = child.renderStyle;
        final CSSPositionType pos = rs.position;
        final bool isAbsOrFixed = pos == CSSPositionType.absolute || pos == CSSPositionType.fixed;
        final bool hasExplicitMaxHeight = !rs.maxHeight.isNone;
        final bool hasExplicitMinHeight = !rs.minHeight.isAuto;
        if (isAbsOrFixed &&
            !rs.isSelfRenderReplaced() &&
            rs.height.isAuto &&
            rs.top.isNotAuto &&
            rs.bottom.isNotAuto &&
            !hasExplicitMaxHeight &&
            !hasExplicitMinHeight) {
          CSSPositionedLayout.layoutPositionedChild(this, child, needsRelayout: true);
        }
      }

      if (!kReleaseMode) {
        developer.Timeline.startSync('RenderFlex.adjustPositionChildren');
      }

      // init overflowLayout size
      initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height), Rect.fromLTRB(0, 0, size.width, size.height));

      // calculate all flexItem child overflow size
      addOverflowLayoutFromChildren(orderedChildren);

      // Every placeholder of positioned element should be layouted in a separated layer in flex layout
      // which is different from the placeholder in flow layout which layout in the same flow as
      // other elements in normal flow.
      for (RenderPositionPlaceholder child in positionPlaceholderChildren) {
        _layoutPositionPlaceholder(child);
      }

      // Apply offset for positioned elements that are direct children (containing block = this).
      for (RenderBoxModel child in positionedChildren) {
        CSSPositionedLayout.applyPositionedChildOffset(this, child);
        // Apply sticky paint-time offset (no-op for non-sticky).
        CSSPositionedLayout.applyStickyChildOffset(this, child);
        // Do not expand scroll range for sticky; its placeholder accounts for flow size.
        if (child.renderStyle.position != CSSPositionType.sticky) {
          extendMaxScrollableSize(child);
          addOverflowLayoutFromChild(child);
        }
      }

      if (!kReleaseMode) {
        developer.Timeline.finishSync();
      }

      didLayout();
    } finally {
      _layoutInvariants = null;
    }
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

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutFlexItems.computeRunMetrics',
          arguments: {'renderObject': describeIdentity(this)});
    }

    // Layout children to compute metrics of flex lines.
    List<_RunMetrics> runMetrics = _computeRunMetrics(children);

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    // Set flex container size.
    _setContainerSize(runMetrics);

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutFlexItems.adjustChildrenSize');
    }

    // Adjust children size based on flex properties which may affect children size.
    _adjustChildrenSize(runMetrics);

    // _runMetrics maybe update after adjust, set flex containerSize again
    _setContainerSize(runMetrics);

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutFlexItems.setChildrenOffset');
    }

    // Set children offset based on flex alignment properties.
    _setChildrenOffset(runMetrics);

    if (!kReleaseMode) {
      developer.Timeline.finishSync();
    }

    if (!kReleaseMode) {
      developer.Timeline.startSync('RenderFlex.layoutFlexItems.setMaxScrollableSize');
    }

    // Set the size of scrollable overflow area for flex layout.
    _setMaxScrollableSize(runMetrics);

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
        // Inline flex container with no flex items: synthesize baseline from the
        // bottom margin edge (consistent with atomic inline-level boxes per CSS2.1).
        final double borderBoxHeight = boxSize?.height ?? size.height;
        final double marginBottom = renderStyle.marginBottom.computedValue;
        containerBaseline = borderBoxHeight + marginBottom;
      }
    } else {
      // If the flex container's main axis differs from the inline axis (e.g. column/column-reverse),
      // it participates in baseline alignment as a block container per
      // https://www.w3.org/TR/css-flexbox-1/#flex-baselines. Block containers without
      // inline content synthesize the baseline from the bottom border edge.
      if (!_isHorizontalFlexDirection) {
        // Establish baseline from the first flex item on the first line that
        // participates in baseline alignment (align-self/align-items: baseline).
        final _RunMetrics firstLineMetrics = _flexLineBoxMetrics[0];
        final List<_RunChild> firstRunChildren = firstLineMetrics.runChildren;
        RenderBox? baselineChild;
        double? baselineDistance;
        RenderBox? fallbackChild;
        double? fallbackBaseline;

        bool participatesInBaseline(RenderBox candidate) {
          // Items with auto margins on the cross axis absorb free space and should not
          // be considered for establishing the container's external baseline.
          // This mirrors browser behavior in cases like margin-top:auto, where the
          // baseline-aligned item no longer anchors the container baseline in IFC.
          if (_isChildCrossAxisMarginAutoExist(candidate)) return false;
          final AlignSelf self = _getAlignSelf(candidate);
          if (self == AlignSelf.baseline || self == AlignSelf.lastBaseline) return true;
          if (self == AlignSelf.auto &&
              (renderStyle.alignItems == AlignItems.baseline || renderStyle.alignItems == AlignItems.lastBaseline)) {
            return true;
          }
          return false;
        }

        for (final _RunChild runChild in firstRunChildren) {
          final RenderBox child = runChild.child;
          final double? childBaseline = child.getDistanceToBaseline(TextBaseline.alphabetic);
          final bool participates = participatesInBaseline(child);

          if (participates && baselineChild == null) {
            baselineChild = child;
            baselineDistance = childBaseline;
            if (childBaseline != null) {
              break;
            }
          }

          if (childBaseline != null && fallbackChild == null) {
            fallbackChild = child;
            fallbackBaseline = childBaseline;
          }

          fallbackChild ??= child;
        }

        baselineChild ??= fallbackChild;
        baselineDistance ??= fallbackBaseline;

        if (baselineChild != null) {
          if (baselineDistance != null) {
            containerBaseline = baselineDistance;
            setCssBaselines(first: containerBaseline, last: containerBaseline);
            return;
          }
          // No child provided a baseline; fall back to block container behavior
          // (distance from border-box top to the bottom border edge).
        }

        final double borderBoxHeight = boxSize?.height ?? size.height;
        // For inline flex containers, include bottom margin to synthesize an
        // external baseline from the bottom margin edge.
        if (isDisplayInline) {
          containerBaseline = borderBoxHeight + renderStyle.marginBottom.computedValue;
        } else {
          containerBaseline = borderBoxHeight;
        }
        setCssBaselines(first: containerBaseline, last: containerBaseline);
        return;
      }

      // Row-direction (horizontal main axis): per CSS Flexbox §10.8 and
      // Baseline Alignment in Flexbox, the container’s baseline is taken from
      // the first flex item on the first line that participates in baseline
      // alignment (align-self: baseline or align-items: baseline). If none
      // participate, fall back to the first item with a baseline; if no item
      // exposes a baseline, synthesize from the bottom border edge.
      final _RunMetrics firstLineMetrics = _flexLineBoxMetrics[0];
      final List<_RunChild> firstRunChildren = firstLineMetrics.runChildren;
      if (firstRunChildren.isNotEmpty) {
        RenderBox? baselineChild;
        double? baselineDistance; // distance from child's border-top to its baseline
        RenderBox? fallbackChild;
        double? fallbackBaseline;

        bool participatesInBaseline(RenderBox candidate) {
          final AlignSelf self = _getAlignSelf(candidate);
          if (self == AlignSelf.baseline || self == AlignSelf.lastBaseline) return true;
          if (self == AlignSelf.auto &&
              (renderStyle.alignItems == AlignItems.baseline || renderStyle.alignItems == AlignItems.lastBaseline)) {
            return true;
          }
          return false;
        }

        for (final _RunChild runChild in firstRunChildren) {
          final RenderBox child = runChild.child;
          final double? childBaseline = child.getDistanceToBaseline(TextBaseline.alphabetic);

          // Compute baseline participation (inline here for robust wrapper handling)
          RenderBoxModel? styleBox;
          if (child is RenderBoxModel) {
            styleBox = child;
          } else if (child is RenderEventListener) {
            styleBox = child.child as RenderBoxModel?;
          } else if (child is RenderPositionPlaceholder) {
            styleBox = child.positioned;
          }
          bool hasCrossAuto = false;
          bool mtAuto = false, mbAuto = false;
          if (styleBox != null) {
            final s = styleBox.renderStyle;
            mtAuto = s.marginTop.isAuto;
            mbAuto = s.marginBottom.isAuto;
            hasCrossAuto = _isHorizontalFlexDirection
                ? (mtAuto || mbAuto)
                : (s.marginLeft.isAuto || s.marginRight.isAuto);
          }
          AlignSelf self = _getAlignSelf(child);
          final bool participates = (!hasCrossAuto) &&
              (self == AlignSelf.baseline ||
                  self == AlignSelf.lastBaseline ||
                  (self == AlignSelf.auto &&
                      (renderStyle.alignItems == AlignItems.baseline || renderStyle.alignItems == AlignItems.lastBaseline)));
          double dy = 0;
          if (child.parentData is RenderLayoutParentData) {
            dy = (child.parentData as RenderLayoutParentData).offset.dy;
          }

          if (participates && baselineChild == null) {
            baselineChild = child;
            baselineDistance = childBaseline;
            if (childBaseline != null) {
              break;
            }
          }

          if (childBaseline != null && fallbackChild == null) {
            fallbackChild = child;
            fallbackBaseline = childBaseline;
          }

          fallbackChild ??= child;
        }

        // Prefer the first baseline-participating child (excluding cross-axis auto margins);
        // otherwise fall back to the first child that exposes a baseline; otherwise the first item.
        final RenderBox? chosen = baselineChild ?? fallbackChild;
        final double? chosenBaseline = baselineChild != null ? baselineDistance : fallbackBaseline;

        if (chosen != null) {
          if (chosenBaseline != null) {
            final RenderLayoutParentData pd = chosen.parentData as RenderLayoutParentData;
            double dy = pd.offset.dy;
            if (chosen is RenderBoxModel) {
              final Offset? rel = CSSPositionedLayout.getRelativeOffset(chosen.renderStyle);
              if (rel != null) dy -= rel.dy;
            }
            containerBaseline = chosenBaseline + dy;
          } else {
            // Chosen item has no baseline; synthesize from container bottom edge.
            final double borderBoxHeight = boxSize?.height ?? size.height;
            // If inline-level (inline-flex), synthesize from bottom margin edge.
            if (isDisplayInline) {
              containerBaseline = borderBoxHeight + renderStyle.marginBottom.computedValue;
            } else {
              containerBaseline = borderBoxHeight;
            }
          }
        }
      }
    }
    setCssBaselines(first: containerBaseline, last: containerBaseline);
  }

  // Layout position placeholder.
  void _layoutPositionPlaceholder(RenderPositionPlaceholder child) {
    List<RenderBox> positionPlaceholderChildren = [child];

    // Layout children to compute metrics of flex lines.
    List<_RunMetrics> runMetrics = _computeRunMetrics(positionPlaceholderChildren);

    // Set children offset based on flex alignment properties.
    _setChildrenOffset(runMetrics);
  }

  // Layout children in normal flow order to calculate metrics of flex lines according to its constraints
  // and flex-wrap property.
  List<_RunMetrics> _computeRunMetrics(List<RenderBox> children,) {
    List<_RunMetrics> runMetrics = <_RunMetrics>[];
    if (children.isEmpty) return runMetrics;

    final bool isHorizontal = _isHorizontalFlexDirection;
    final bool isWrap = renderStyle.flexWrap == FlexWrap.wrap || renderStyle.flexWrap == FlexWrap.wrapReverse;
    final double mainAxisGap = _getMainAxisGap();

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
    if (isHorizontal) {
      flexLineLimit = renderStyle.contentMaxConstraintsWidth;
    } else {
      flexLineLimit = containerBox.contentConstraints!.maxHeight;
    }

    // Info about each flex item in each flex line
    List<_RunChild> runChildren = <_RunChild>[];

    // PASS 1+2: Intrinsic layout + compute run metrics in one pass.
    for (RenderBox child in children) {
      final BoxConstraints childConstraints = _getIntrinsicConstraints(child);
      child.layout(childConstraints, parentUsesSize: true);

      if (child is RenderBoxModel) {
        child.clearOverrideContentSize();
      }

      final RenderLayoutParentData? childParentData = child.parentData as RenderLayoutParentData?;

      // Use intrinsic size for run calculations
      final Size childSize = child.size;
      double intrinsicMain = isHorizontal ? childSize.width : childSize.height;

      // CSS Flexbox §9.2: For flex-basis:auto with an auto main-size, the flex base size
      // should come from the item's max-content contribution in the main axis, not from
      // the block formatting context's "fill-available" used size. Our intrinsic pass can
      // mistakenly inherit a container-bounded width for block-level items that establish
      // an inline formatting context (IFC), causing the base size to equal the container
      // width. Detect that case and prefer the IFC's max-intrinsic width instead.
      if (isHorizontal && child is RenderFlowLayout) {
        final RenderFlowLayout flowChild = child;
        final CSSRenderStyle cs = flowChild.renderStyle;
        final bool autoMain = cs.width.isAuto;
        final bool hasDefiniteBasis = _getFlexBasis(flowChild) != null;
        if (autoMain && !hasDefiniteBasis && flowChild.inlineFormattingContext != null) {
          // Paragraph max-intrinsic width approximates the max-content contribution.
          final double paraMax = flowChild.inlineFormattingContext!.paragraphMaxIntrinsicWidth;
          // Convert content-width to border-box width by adding horizontal padding + borders.
          final double paddingBorderH =
              cs.paddingLeft.computedValue +
                  cs.paddingRight.computedValue +
                  cs.effectiveBorderLeftWidth.computedValue +
                  cs.effectiveBorderRightWidth.computedValue;
          final double candidate = (paraMax.isFinite ? paraMax : 0) + paddingBorderH;
          // If the currently measured intrinsic width is larger (e.g., filled to container),
          // prefer the content-based candidate to avoid unintended expansion.
          if (candidate > 0 && candidate < intrinsicMain) {
            intrinsicMain = candidate;
          }
        }
      }

      // Clamp intrinsic main size by child's min/max constraints before flexing,
      // so percentage max-width/height act as caps on the base size per spec.
      if (child is RenderBoxModel) {
        final CSSRenderStyle cs = child.renderStyle;
        // Determine min/max along the main axis
        double? minMain;
        double? maxMain;
        if (isHorizontal) {
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
        bool hasPctMaxMain = isHorizontal
            ? child.renderStyle.maxWidth.type == CSSLengthType.PERCENTAGE
            : child.renderStyle.maxHeight.type == CSSLengthType.PERCENTAGE;
        bool hasAutoMain = isHorizontal ? child.renderStyle.width.isAuto : child.renderStyle.height
            .isAuto;
        if (hasPctMaxMain && hasAutoMain) {
          double paddingBorderMain = isHorizontal
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
          Element domElement = child.renderStyle.target;
          isEmptyElement = !domElement.hasChildren();

          // For empty elements, force intrinsic size to padding+border
          if (isEmptyElement) {
            intrinsicMain = paddingBorderMain;
          }
        }
      }

      // Enforce automatic minimum main size (min-size:auto) so preserved sizes
      // never fall below min-content contributions in the main axis.
      if (child is RenderBoxModel) {
        final double autoMinMain = _getMinMainAxisSize(child);
        if (intrinsicMain < autoMinMain) {
          intrinsicMain = autoMinMain;
        }
      }

      _childrenIntrinsicMainSizes[child] = intrinsicMain;

      Size? intrinsicChildSize = _getChildSize(child, shouldUseIntrinsicMainSize: true);

      double childMainAxisExtent = _getMainAxisExtent(child, shouldUseIntrinsicMainSize: true);
      double childCrossAxisExtent = _getCrossAxisExtent(child);
      // Include gap spacing in flex line limit check
      double gapSpacing = runChildren.isNotEmpty ? mainAxisGap : 0;
      bool isExceedFlexLineLimit = runMainAxisExtent + gapSpacing + childMainAxisExtent > flexLineLimit;
      // calculate flex line
      if (isWrap &&
          runChildren.isNotEmpty &&
          isExceedFlexLineLimit) {
        runMetrics.add(_RunMetrics(
            runMainAxisExtent,
            runCrossAxisExtent,
            totalFlexGrow,
            totalFlexShrink,
            maxSizeAboveBaseline,
            runChildren,
            0));
        runChildren = <_RunChild>[];
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        maxSizeAboveBaseline = 0.0;
        maxSizeBelowBaseline = 0.0;

        totalFlexGrow = 0;
        totalFlexShrink = 0;
      }
      // Add gap spacing between items (not before the first item)
      if (runChildren.isNotEmpty) {
        runMainAxisExtent += mainAxisGap;
      }
      runMainAxisExtent += childMainAxisExtent;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);

      // Vertical align is only valid for inline box.
      // Baseline alignment in column direction behave the same as flex-start.
      AlignSelf alignSelf = _getAlignSelf(child);
      bool isBaselineAlign =
          alignSelf == AlignSelf.baseline ||
          alignSelf == AlignSelf.lastBaseline ||
          renderStyle.alignItems == AlignItems.baseline ||
          renderStyle.alignItems == AlignItems.lastBaseline;
      if (isHorizontal && isBaselineAlign) {
        // Distance from top to baseline of child
        double childAscent = _getChildAscent(child);
        double childMarginTop = 0;
        double childMarginBottom = 0;
        if (child is RenderBoxModel) {
          childMarginTop = child.renderStyle.marginTop.computedValue;
          childMarginBottom = child.renderStyle.marginBottom.computedValue;
        }
        if (DebugFlags.debugLogFlexBaselineEnabled) {
          final Size? ic = intrinsicChildSize;
          renderingLogger.finer('[FlexBaseline] PASS2 child='
              '${child.runtimeType}#${child.hashCode} '
              'intrinsicSize=${ic?.width.toStringAsFixed(2)}x${ic?.height.toStringAsFixed(2)} '
              'ascent=${childAscent.toStringAsFixed(2)} '
              'mT=${childMarginTop.toStringAsFixed(2)} mB=${childMarginBottom.toStringAsFixed(2)}');
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
        if (DebugFlags.debugLogFlexBaselineEnabled) {
          renderingLogger.finer('[FlexBaseline] RUN update: maxAbove='
              '${maxSizeAboveBaseline.toStringAsFixed(2)} '
              'maxBelow=${maxSizeBelowBaseline.toStringAsFixed(2)} '
              'runCross=${runCrossAxisExtent.toStringAsFixed(2)}');
        }
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }

      // Per CSS Flexbox §9.7, keep two sizes:
      // - flex base size: from flex-basis if definite, otherwise the intrinsic
      //   content-based size BEFORE min/max clamping.
      // - hypothetical main size: the base size clamped by min/max.
      // We store the base size in runChild.originalMainSize so remaining free
      // space and shrink/grow weighting use the correct base, and keep the
      // clamped value in _childrenIntrinsicMainSizes for line metrics.
      final RenderBoxModel? effectiveChild = child is RenderBoxModel ? child : null;
      final double? usedFlexBasis = effectiveChild != null ? _getUsedFlexBasis(child) : null;

      double baseMainSize;
      if (usedFlexBasis != null) {
        // Used basis is already border-box (>= padding+border) for non-zero bases.
        // For flex-basis: 0% in the main axis, use a flex base size of 0 so equal-flex
        // items share free space evenly regardless of padding/border, while the
        // non-flex portion (padding/border) is accounted for separately in totalSpace.
        final CSSLengthValue? fb = effectiveChild?.renderStyle.flexBasis;
        if (fb != null && fb.type == CSSLengthType.PERCENTAGE && fb.computedValue == 0) {
          baseMainSize = 0;
        } else {
          baseMainSize = usedFlexBasis;
        }
      } else {
        // childSize is the intrinsic measurement from PASS 1 (pre-clamp).
        baseMainSize = isHorizontal ? childSize.width : childSize.height;
      }

      // Use clamped intrinsic main size as the hypothetical size for line metrics.
      double originalMainSize = baseMainSize;
      double mainAxisMargin = 0.0;
      if (effectiveChild != null) {
        final RenderStyle s = effectiveChild.renderStyle;
        final double marginHorizontal = s.marginLeft.computedValue + s.marginRight.computedValue;
        final double marginVertical = s.marginTop.computedValue + s.marginBottom.computedValue;
        mainAxisMargin = isHorizontal ? marginHorizontal : marginVertical;
      }

      final RenderBoxModel? marginBoxModel =
          child is RenderBoxModel ? child : (child is RenderPositionPlaceholder ? child.positioned : null);
      final RenderStyle? marginStyle = marginBoxModel?.renderStyle;
      final bool marginLeftAuto = marginStyle?.marginLeft.isAuto ?? false;
      final bool marginRightAuto = marginStyle?.marginRight.isAuto ?? false;
      final bool marginTopAuto = marginStyle?.marginTop.isAuto ?? false;
      final bool marginBottomAuto = marginStyle?.marginBottom.isAuto ?? false;
      final bool hasAutoMainAxisMargin = isHorizontal
          ? (marginLeftAuto || marginRightAuto)
          : (marginTopAuto || marginBottomAuto);
      final bool hasAutoCrossAxisMargin = isHorizontal
          ? (marginTopAuto || marginBottomAuto)
          : (marginLeftAuto || marginRightAuto);

      final double flexGrow = _getFlexGrow(child);
      final double flexShrink = _getFlexShrink(child);

      runChildren.add(_RunChild(
        child,
        originalMainSize,
        0,
        false,
        effectiveChild: effectiveChild,
        alignSelf: alignSelf,
        flexGrow: flexGrow,
        flexShrink: flexShrink,
        usedFlexBasis: usedFlexBasis,
        mainAxisMargin: mainAxisMargin,
        mainAxisStartMargin: _flowAwareChildMainAxisMargin(child) ?? 0.0,
        mainAxisEndMargin: _flowAwareChildMainAxisMargin(child, isEnd: true) ?? 0.0,
        crossAxisStartMargin: _flowAwareChildCrossAxisMargin(child) ?? 0.0,
        crossAxisEndMargin: _flowAwareChildCrossAxisMargin(child, isEnd: true) ?? 0.0,
        hasAutoMainAxisMargin: hasAutoMainAxisMargin,
        hasAutoCrossAxisMargin: hasAutoCrossAxisMargin,
        marginLeftAuto: marginLeftAuto,
        marginRightAuto: marginRightAuto,
        marginTopAuto: marginTopAuto,
        marginBottomAuto: marginBottomAuto,
        isReplaced: effectiveChild?.renderStyle.isSelfRenderReplaced() ?? false,
        aspectRatio: effectiveChild?.renderStyle.aspectRatio,
      ));

      childParentData!.runIndex = runMetrics.length;

      assert(child.parentData == childParentData);

      if (flexGrow > 0) {
        totalFlexGrow += flexGrow;
      }
      if (flexShrink > 0) {
        totalFlexShrink += flexShrink;
      }
    }

    if (runChildren.isNotEmpty) {
      // Do not pre-shrink overflow:hidden items outside of the standard flex
      // algorithm. Browsers resolve flexible lengths per §9.7, then clamp to
      // min/max and iterate. Pre-distribution here deviates from CSS and caused
      // incorrect widths for cases like text truncation within flex rows.
      runMetrics.add(_RunMetrics(
          runMainAxisExtent,
          runCrossAxisExtent,
          totalFlexGrow,
          totalFlexShrink,
          maxSizeAboveBaseline,
          runChildren,
          0));
    }

    _flexLineBoxMetrics = runMetrics;

    // PASS 3: Store percentage constraints for later use in _adjustChildrenSize
    // This ensures they are calculated with the final parent dimensions
    for (RenderBox child in children) {
      RenderBoxModel? box = child is RenderBoxModel
          ? child
          : (child is RenderEventListener ? child.child as RenderBoxModel? : null);
      if (box != null) {
        bool hasPercentageMaxWidth = box.renderStyle.maxWidth.type == CSSLengthType.PERCENTAGE;
        bool hasPercentageMaxHeight = box.renderStyle.maxHeight.type == CSSLengthType.PERCENTAGE;

        if (hasPercentageMaxWidth || hasPercentageMaxHeight) {
          // Store the final constraints for use in _adjustChildrenSize
          BoxConstraints finalConstraints = box.getConstraints();
          _childrenOldConstraints[box] = finalConstraints;
        }
      }
    }

    return runMetrics;
  }

  // Compute the leading and between spacing of each flex line.
  _RunSpacing _computeRunSpacing(List<_RunMetrics> runMetrics,) {
    double? contentBoxLogicalWidth = renderStyle.contentBoxLogicalWidth;
    double? contentBoxLogicalHeight = renderStyle.contentBoxLogicalHeight;
    double containerCrossAxisExtent = 0.0;

    if (!_isHorizontalFlexDirection) {
      containerCrossAxisExtent = contentBoxLogicalWidth ?? 0;
    } else {
      containerCrossAxisExtent = contentBoxLogicalHeight ?? 0;
    }

    double runCrossSize = _getRunsCrossSize(runMetrics);

    // Calculate leading and between space between flex lines.
    final double crossAxisFreeSpace = containerCrossAxisExtent - runCrossSize;
    final int runCount = runMetrics.length;
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
    // If lines overflow the container cross axis (negative free space), clamp alignment to start
    // only when the cross axis is horizontal (i.e., flex-direction: column where cross is width).
    // This avoids negative X offsets (e.g., wrap-004). For vertical cross axes (row direction),
    // preserve negative leading space so align-content:center truly centers the overflowing lines.
    if (crossAxisFreeSpace < 0 && !_isHorizontalFlexDirection) {
      runLeadingSpace = 0.0;
      runBetweenSpace = 0.0;
    }
    return _RunSpacing(leading: runLeadingSpace, between: runBetweenSpace);
  }

  // Find the size in the cross axis of flex lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsCrossSize(List<_RunMetrics> runMetrics,) {
    double crossSize = 0;
    double crossAxisGap = _getCrossAxisGap();
    for (int i = 0; i < runMetrics.length; i++) {
      crossSize += runMetrics[i].crossAxisExtent;
      // Add gap spacing between lines (not after the last line)
      if (i < runMetrics.length - 1) {
        crossSize += crossAxisGap;
      }
    }
    return crossSize;
  }

  // Find the max size in the main axis of flex lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsMaxMainSize(List<_RunMetrics> runMetrics,) {
    // Find the max size of flex lines.
    _RunMetrics maxMainSizeMetrics = runMetrics.reduce((_RunMetrics curr, _RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    return maxMainSizeMetrics.mainAxisExtent;
  }

  // Resolve flex item length if flex-grow or flex-shrink exists.
  // https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  bool _resolveFlexibleLengths(_RunMetrics runMetric, _FlexFactorTotals totalFlexFactor, double initialFreeSpace,) {
    final List<_RunChild> runChildren = runMetric.runChildren;
    final double totalFlexGrow = totalFlexFactor.flexGrow;
    final double totalFlexShrink = totalFlexFactor.flexShrink;
    // Determine distribution mode using the current remaining free space, not just the initial value,
    // because freezing items at min/max can flip the sign mid-iteration.
    bool isFlexGrow = initialFreeSpace > 0 && totalFlexGrow > 0;
    bool isFlexShrink = initialFreeSpace < 0 && totalFlexShrink > 0;

    double sumFlexFactors = isFlexGrow ? totalFlexGrow : (isFlexShrink ? totalFlexShrink : 0);

    // Per CSS Flexbox §9.7, if the sum of the unfrozen flex items’ flex
    // factors is less than 1, multiply the free space by this sum.
    // Applies to both grow and shrink phases (for shrink, the factors are
    // the flex-shrink factors of unfrozen items).
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

    final double remainingFreeSpace = runMetric.remainingFreeSpace;
    final double? spacePerFlex = (remainingFreeSpace > 0 && totalFlexGrow > 0)
        ? (remainingFreeSpace / totalFlexGrow)
        : null;

    // For flex-shrink, compute the total weighted flex-shrink factor once per
    // iteration: sum(baseSize * flexShrink) for all unfrozen items.
    double totalWeightedFlexShrink = 0.0;
    if (remainingFreeSpace < 0 && totalFlexShrink > 0) {
      for (final _RunChild runChild in runChildren) {
        if (runChild.frozen) continue;
        final double childFlexShrink = runChild.flexShrink;
        if (childFlexShrink == 0) continue;

        final double baseSize = (runChild.usedFlexBasis ?? runChild.originalMainSize);
        totalWeightedFlexShrink += baseSize * childFlexShrink;
      }
    }

    // Loop flex item to find min/max violations.
    for (final _RunChild runChild in runChildren) {
      if (runChild.frozen) continue;

      // Use used flex-basis (border-box) for originalMainSize when definite.
      final double originalMainSize = runChild.usedFlexBasis ?? runChild.originalMainSize;

      double computedSize = originalMainSize;
      double flexedMainSize = originalMainSize;

      final double flexGrow = runChild.flexGrow;
      final double flexShrink = runChild.flexShrink;

      // Re-evaluate grow/shrink based on current remaining free space sign.
      final bool doGrow = spacePerFlex != null && flexGrow > 0;
      final bool doShrink = remainingFreeSpace < 0 && totalFlexShrink > 0 && flexShrink > 0;

      if (doGrow) {
        computedSize = originalMainSize + spacePerFlex * flexGrow;
      } else if (doShrink) {
        // Distribute negative free space proportionally per §9.7. Items with
        // overflow clipping still participate normally; their automatic
        // minimum size may be zero, but that affects clamping, not the
        // distribution itself.
        if (totalWeightedFlexShrink != 0) {
          final double scaledShrink = originalMainSize * flexShrink;
          computedSize = originalMainSize + (scaledShrink / totalWeightedFlexShrink) * remainingFreeSpace;
        }
      }

      // Save the pre-clamp size to adjust remaining free space correctly
      // when freezing items that violate min/max.
      runChild.unclampedMainSize = computedSize;
      flexedMainSize = computedSize;

      double minFlexPrecision = 0.5;
      // Find all the violations by comparing min and max size of flex items.
      // Always enforce min/max constraints on the flex item, regardless of overflow clipping.
      // Overflow does not disable max-width/height.
      {
        // Apply min/max against the flex item itself (the element). RenderEventListener
        // is a RenderBoxModel; do not unwrap to its child.
        RenderBoxModel? clampTarget = runChild.effectiveChild;
        if (clampTarget != null) {
          double minMainAxisSize = _getMinMainAxisSize(clampTarget);
          double maxMainAxisSize = _getMaxMainAxisSize(clampTarget);
          if (computedSize < minMainAxisSize && (computedSize - minMainAxisSize).abs() >= minFlexPrecision) {
            flexedMainSize = minMainAxisSize;
          } else if (computedSize > maxMainAxisSize && (computedSize - maxMainAxisSize).abs() >= minFlexPrecision) {
            flexedMainSize = maxMainAxisSize;
          }
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
    }

    // Freeze over-flexed items.
    if (totalViolation == 0) {
      // If total violation is zero, freeze all the flex items and exit loop.
      for (final _RunChild runChild in runChildren) {
        runChild.frozen = true;
      }
    } else {
      List<_RunChild> violations = totalViolation < 0 ? maxViolations : minViolations;

      // Find all the violations, set main size and freeze all the flex items.
      for (int i = 0; i < violations.length; i++) {
        _RunChild runChild = violations[i];
        runChild.frozen = true;
        // Update remaining free space by the actual amount assigned to this
        // item in this iteration (relative to its original size). If the
        // item was clamped to its min/max, flexedMainSize equals the clamp
        // result; its delta reflects how much free space it actually took.
        runMetric.remainingFreeSpace -= runChild.flexedMainSize - runChild.originalMainSize;

        double flexGrow = runChild.flexGrow;
        double flexShrink = runChild.flexShrink;

        // If total violation is positive, freeze all the items with min violations.
        if (flexGrow > 0) {
          totalFlexFactor.flexGrow -= flexGrow;

          // If total violation is negative, freeze all the items with max violations.
        } else if (flexShrink > 0) {
          totalFlexFactor.flexShrink -= flexShrink;
        }
      }
    }

    return totalViolation != 0;
  }

  bool _hasBaselineAlignedChildren(List<_RunMetrics> runMetrics) {
    if (!_isHorizontalFlexDirection) return false;
    if (renderStyle.alignItems == AlignItems.baseline) return true;
    for (final _RunMetrics metrics in runMetrics) {
      for (final _RunChild runChild in metrics.runChildren) {
        if (runChild.alignSelf == AlignSelf.baseline) return true;
      }
    }
    return false;
  }

  bool _hasStretchedChildrenInCrossAxis(List<_RunMetrics> runMetrics) {
    for (final _RunMetrics metrics in runMetrics) {
      for (final _RunChild runChild in metrics.runChildren) {
        final RenderBoxModel? effectiveChild = runChild.effectiveChild;
        if (effectiveChild != null) {
          if (_needToStretchChildCrossSize(effectiveChild)) return true;
        } else {
          if (_needToStretchChildCrossSize(runChild.child)) return true;
        }
      }
    }
    return false;
  }

  bool _tryNoFlexNoStretchNoBaselineFastPath(
    List<_RunMetrics> runMetrics, {
    required double? maxMainSize,
    required bool isMainSizeDefinite,
    required double? contentBoxLogicalWidth,
    required double? contentBoxLogicalHeight,
  }) {
    final bool isHorizontal = _isHorizontalFlexDirection;
    final double mainAxisGap = _getMainAxisGap();
    final double containerStyleMin = isHorizontal
        ? (renderStyle.minWidth.isNotAuto ? renderStyle.minWidth.computedValue : 0.0)
        : (renderStyle.minHeight.isNotAuto ? renderStyle.minHeight.computedValue : 0.0);

    // First, verify no run will actually enter flexible length resolution.
    for (final _RunMetrics metrics in runMetrics) {
      final List<_RunChild> runChildrenList = metrics.runChildren;

      double totalSpace = 0;
      for (final _RunChild runChild in runChildrenList) {
        final double childSpace = runChild.usedFlexBasis ?? runChild.originalMainSize;
        totalSpace += childSpace + runChild.mainAxisMargin;
      }

      final int itemCount = runChildrenList.length;
      if (itemCount > 1) {
        totalSpace += (itemCount - 1) * mainAxisGap;
      }

      final double freeSpace = maxMainSize != null ? (maxMainSize - totalSpace) : 0.0;

      final bool boundedOnly = maxMainSize != null &&
          !(isHorizontal
              ? (contentBoxLogicalWidth != null ||
                  (contentConstraints?.hasTightWidth ?? false) ||
                  constraints.hasTightWidth)
              : (contentBoxLogicalHeight != null ||
                  (contentConstraints?.hasTightHeight ?? false) ||
                  constraints.hasTightHeight));

      final bool willShrink = maxMainSize != null && freeSpace < 0 && metrics.totalFlexShrink > 0;

      bool willGrow = false;
      if (metrics.totalFlexGrow > 0 && !boundedOnly) {
        if (isMainSizeDefinite) {
          willGrow = maxMainSize != null && freeSpace > 0;
        } else {
          // Auto main size: positive free space is only distributable to satisfy an
          // author-specified min-main-size.
          willGrow = containerStyleMin > totalSpace;
        }
      }

      if (willGrow || willShrink) return false;
    }

    // No flexing/no stretching/no baseline alignment: relayout only items that actually need it.
    final double availCross = contentConstraints?.maxWidth ?? double.infinity;
    for (final _RunMetrics metrics in runMetrics) {
      final List<_RunChild> runChildrenList = metrics.runChildren;
      final int runChildrenCount = runChildrenList.length;

      bool didRelayout = false;
      for (final _RunChild runChild in runChildrenList) {
        final RenderBox child = runChild.child;
        final RenderBoxModel? effectiveChild = runChild.effectiveChild;
        if (effectiveChild == null) continue;

        final double childOldMainSize = isHorizontal ? child.size.width : child.size.height;
        final double? desiredPreservedMain = _childrenIntrinsicMainSizes[child];

        bool needsLayout = effectiveChild.needsRelayout;
        if (!needsLayout && desiredPreservedMain != null && desiredPreservedMain != childOldMainSize) {
          needsLayout = true;
        }
        if (!needsLayout && desiredPreservedMain != null) {
          final BoxConstraints applied = child.constraints;
          final bool autoMain = isHorizontal
              ? effectiveChild.renderStyle.width.isAuto
              : effectiveChild.renderStyle.height.isAuto;
          final bool wasNonTightMain = isHorizontal ? !applied.hasTightWidth : !applied.hasTightHeight;
          if (autoMain && wasNonTightMain) {
            needsLayout = true;
          }
        }

        // Column-direction: apply shrink-to-fit cross sizing only when a definite available width exists.
        if (!needsLayout && !isHorizontal) {
          final bool childCrossAuto = effectiveChild.renderStyle.width.isAuto;
          if (childCrossAuto && availCross.isFinite) {
            final double measuredBorderW = effectiveChild.size.width;
            if (measuredBorderW > availCross + 0.5) {
              needsLayout = true;
            }
          }
        }

        if (!needsLayout) continue;

        _markFlexRelayoutForTextOnly(effectiveChild);

        final BoxConstraints childConstraints = _getChildAdjustedConstraints(
          effectiveChild,
          null, // no main-axis flexing
          null, // no cross-axis stretching
          runChildrenCount,
          preserveMainAxisSize: desiredPreservedMain,
        );
        child.layout(childConstraints, parentUsesSize: true);
        didRelayout = true;
      }

      if (!didRelayout) continue;

      // Recompute run extents from the final child sizes.
      double mainAxisExtent = 0;
      double crossAxisExtent = 0;
      for (int i = 0; i < runChildrenList.length; i++) {
        if (i > 0) mainAxisExtent += mainAxisGap;
        final RenderBox child = runChildrenList[i].child;
        mainAxisExtent += _getMainAxisExtent(child);
        crossAxisExtent = math.max(crossAxisExtent, _getCrossAxisExtent(child));
      }
      metrics.mainAxisExtent = mainAxisExtent;
      metrics.crossAxisExtent = crossAxisExtent;
    }

    return true;
  }

  // Adjust children size (not include position placeholder) based on
  // flex factors (flex-grow/flex-shrink) and alignment in cross axis (align-items).
  //  https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  void _adjustChildrenSize(List<_RunMetrics> runMetrics,) {
    if (runMetrics.isEmpty) return;
    final bool isHorizontal = _isHorizontalFlexDirection;
    final double mainAxisGap = _getMainAxisGap();
    final bool hasBaselineAlignment = _hasBaselineAlignedChildren(runMetrics);
    final bool canAttemptFastPath = isHorizontal && !hasBaselineAlignment;
    final bool hasStretchedChildren =
        canAttemptFastPath ? _hasStretchedChildrenInCrossAxis(runMetrics) : true;
    double? contentBoxLogicalWidth = renderStyle.contentBoxLogicalWidth;
    double? contentBoxLogicalHeight = renderStyle.contentBoxLogicalHeight;

    // Container's width specified by style or inherited from parent.
    // Use null to indicate an indefinite size; do not default to 0,
    // which would incorrectly create free space for flex resolution.
    double? containerWidth;
    if (contentBoxLogicalWidth != null) {
      containerWidth = contentBoxLogicalWidth;
    } else if (contentConstraints!.hasTightWidth) {
      containerWidth = contentConstraints!.maxWidth;
    }

    // Container's height specified by style or inherited from parent.
    // Use null to indicate an indefinite size; do not default to 0,
    // which would incorrectly create free space for flex resolution.
    double? containerHeight;

    // If not tight or explicit, consider bounded max size as a definite available size
    // for resolving flexible lengths. This allows flex-shrink to operate when the
    // container has a finite max-height/width (e.g., max-height: 17px in column).
    if (containerWidth == null) {
      if ((contentConstraints?.hasBoundedWidth ?? false) && (contentConstraints?.maxWidth.isFinite ?? false)) {
        containerWidth = contentConstraints!.maxWidth;
      } else if (constraints.hasBoundedWidth && constraints.maxWidth.isFinite) {
        containerWidth = constraints.maxWidth;
      }
    }
    // Prefer the actually imposed outer constraints when they are tighter than
    // the content constraints (e.g., a flex item whose max inline-size is 172px
    // but whose internal contentMaxConstraintsWidth is larger). This ensures
    // the flex algorithm sees the correct available main size and will shrink
    // items when content overflows.
    if (constraints.hasBoundedWidth && constraints.maxWidth.isFinite) {
      containerWidth =
          (containerWidth == null) ? constraints.maxWidth : math.min(containerWidth, constraints.maxWidth);
    }
    if ((contentConstraints?.hasBoundedHeight ?? false) && (contentConstraints?.maxHeight.isFinite ?? false)) {
      containerHeight = contentConstraints!.maxHeight;
    } else if (constraints.hasBoundedHeight && constraints.maxHeight.isFinite) {
      containerHeight = constraints.maxHeight;
    }
    if (constraints.hasBoundedHeight && constraints.maxHeight.isFinite) {
      containerHeight =
          (containerHeight == null) ? constraints.maxHeight : math.min(containerHeight, constraints.maxHeight);
    }
    if (contentBoxLogicalHeight != null) {
      containerHeight = contentBoxLogicalHeight;
    } else if (contentConstraints!.hasTightHeight) {
      containerHeight = contentConstraints!.maxHeight;
    }

    double? maxMainSize = isHorizontal ? containerWidth : containerHeight;

    // Flexbox has several additional cases where a length can be considered definite.
    // https://www.w3.org/TR/css-flexbox-1/#definite-sizes
    // Treat the main size as definite if either:
    // - The flex container has a specified content-box size in the main axis, or
    // - The layout constraints on the main axis are tight (e.g., fixed by parent).
    bool isMainSizeDefinite = isHorizontal
        ? (contentBoxLogicalWidth != null || (contentConstraints?.hasTightWidth ?? false) ||
        constraints.hasTightWidth ||
        ((contentConstraints?.hasBoundedWidth ?? false) && (contentConstraints?.maxWidth.isFinite ?? false)) ||
        (constraints.hasBoundedWidth && constraints.maxWidth.isFinite))
        : (contentBoxLogicalHeight != null || (contentConstraints?.hasTightHeight ?? false) ||
        constraints.hasTightHeight ||
        ((contentConstraints?.hasBoundedHeight ?? false) && (contentConstraints?.maxHeight.isFinite ?? false)) ||
        (constraints.hasBoundedHeight && constraints.maxHeight.isFinite));

    if (canAttemptFastPath && !hasStretchedChildren) {
      if (_tryNoFlexNoStretchNoBaselineFastPath(
        runMetrics,
        maxMainSize: maxMainSize,
        isMainSizeDefinite: isMainSizeDefinite,
        contentBoxLogicalWidth: contentBoxLogicalWidth,
        contentBoxLogicalHeight: contentBoxLogicalHeight,
      )) {
        return;
      }
    }

    // Compute spacing before and between each flex line.
    final _RunSpacing runSpacing = _computeRunSpacing(runMetrics);
    final double runBetweenSpace = runSpacing.between;

    for (int i = 0; i < runMetrics.length; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double totalFlexGrow = metrics.totalFlexGrow;
      final double totalFlexShrink = metrics.totalFlexShrink;
      final List<_RunChild> runChildrenList = metrics.runChildren;

      double totalSpace = 0;
      // Flex factor calculation depends on flex-basis if exists.
      for (final _RunChild runChild in runChildrenList) {
        final double childSpace = runChild.usedFlexBasis ?? runChild.originalMainSize;
        totalSpace += childSpace + runChild.mainAxisMargin;
      }

      // Add gap spacing to total space calculation for flex-grow available space
      int itemCount = runChildrenList.length;
      if (itemCount > 1) {
        double totalGapSpacing = (itemCount - 1) * mainAxisGap;
        totalSpace += totalGapSpacing;
      }

      // Flexbox free space distribution:
      // For definite main sizes (tight or specified) or auto main size bounded by a max constraint,
      // distribute free space per spec. Positive free space allows grow when flex-basis is 0 (e.g., flex: 1),
      // negative free space triggers shrink when items overflow.
      final bool boundedOnly = maxMainSize != null && !(isHorizontal
          ? (contentBoxLogicalWidth != null || (contentConstraints?.hasTightWidth ?? false) || constraints.hasTightWidth)
          : (contentBoxLogicalHeight != null || (contentConstraints?.hasTightHeight ?? false) || constraints.hasTightHeight));
      double initialFreeSpace = 0;
      if (maxMainSize != null) {
        initialFreeSpace = maxMainSize - totalSpace;
      } else {
        // Indefinite main-size (e.g., width:auto in row, height:auto in column).
        // Do NOT synthesize positive free space from the flex container's
        // automatic minimum size (which includes its own padding/border).
        // Per CSS Flexbox, when the available main size is indefinite, treat
        // the initial free space as 0 unless the container has a definite
        // CSS min-main-size. This prevents erroneously adding the container's
        // padding/border to the distributable space (e.g., +42px in the sample).
        final double layoutContentMainSize =
            isHorizontal ? contentSize.width : contentSize.height;

        // Only honor a definite author-specified min-main-size on the container.
        double containerStyleMin = 0.0;
        if (isHorizontal) {
          if (renderStyle.minWidth.isNotAuto) containerStyleMin = renderStyle.minWidth.computedValue;
        } else {
          if (renderStyle.minHeight.isNotAuto) containerStyleMin = renderStyle.minHeight.computedValue;
        }

        // If a definite min is set, treat that as the available main size headroom.
        // Otherwise, keep the container's main size content-driven with zero
        // distributable positive free space.
        if (containerStyleMin > 0) {
          final double inferredMain = math.max(containerStyleMin, layoutContentMainSize);
          maxMainSize = inferredMain;
          initialFreeSpace = inferredMain - totalSpace;
        } else {
          // No definite min → do not create positive free space.
          maxMainSize = layoutContentMainSize;
          initialFreeSpace = 0;
        }
      }

      double layoutContentMainSize = isHorizontal ? contentSize.width : contentSize.height;
      // Only consider an author-specified (definite) min-main-size on the flex container here.
      // Do not use the automatic min size, which includes padding/border, to synthesize
      // positive free space; that incorrectly inflates the container (e.g., to 360).
      double containerStyleMin = 0.0;
      if (isHorizontal) {
        if (renderStyle.minWidth.isNotAuto) containerStyleMin = renderStyle.minWidth.computedValue;
      } else {
        if (renderStyle.minHeight.isNotAuto) containerStyleMin = renderStyle.minHeight.computedValue;
      }
      // Adapt free space only when the container has a definite CSS min-main-size.
      if (initialFreeSpace == 0) {
        final double minTarget = containerStyleMin > 0
            ? math.max(layoutContentMainSize, containerStyleMin)
            : layoutContentMainSize;
        if (maxMainSize < minTarget) {
          maxMainSize = minTarget;

          double maxMainConstraints =
              _isHorizontalFlexDirection ? contentConstraints!.maxWidth : contentConstraints!.maxHeight;
          // determining isScrollingContentBox is to reduce the scope of influence
          if (renderStyle.isSelfScrollingContainer() && maxMainConstraints.isFinite) {
            maxMainSize = totalFlexShrink > 0 ? math.min(maxMainSize, maxMainConstraints) : maxMainSize;
            maxMainSize = totalFlexGrow > 0 ? math.max(maxMainSize, maxMainConstraints) : maxMainSize;
          }

          initialFreeSpace = maxMainSize - totalSpace;
        }
      }

      // For auto main-size bounded only by a max constraint, browsers do not treat
      // the headroom up to that max as positive free space. Suppress flex-grow in this case.
      double usedFreeSpace = initialFreeSpace;
      if (boundedOnly && usedFreeSpace > 0) {
        usedFreeSpace = 0;
      }
      // If the flex container's main size is not definite (height:auto for
      // column, width:auto for row), browsers do not treat any positive headroom
      // as distributable free space. Only a definite min-main-size can create
      // positive free space for growth. Clamp positive free space to 0 in the
      // auto main-size case unless the container's min-main-size requires growth.
      if (!isMainSizeDefinite) {
        // For auto main-size, suppress positive free space distribution unless
        // a definite CSS min-main-size exists on the flex container itself.
        double containerStyleMin = 0.0;
        if (isHorizontal) {
          if (renderStyle.minWidth.isNotAuto) containerStyleMin = renderStyle.minWidth.computedValue;
        } else {
          if (renderStyle.minHeight.isNotAuto) containerStyleMin = renderStyle.minHeight.computedValue;
        }

        if (containerStyleMin <= 0 || containerStyleMin <= totalSpace) {
          usedFreeSpace = math.min(usedFreeSpace, 0);
        } else {
          // Ensure at least enough free space to satisfy container's CSS min-main-size.
          final double required = containerStyleMin - totalSpace;
          if (required > usedFreeSpace) usedFreeSpace = required;
        }
      }

      bool isFlexGrow = usedFreeSpace > 0 && totalFlexGrow > 0;
      bool isFlexShrink = usedFreeSpace < 0 && totalFlexShrink > 0;

      // Follow CSS Flexbox spec strictly: if free space is negative and totalShrink > 0,
      // we shrink items proportionally to their scaled flex-shrink factors. Do not suppress
      // shrinking for “overflow preservation” scenarios — authors can opt out via
      // min-width/height or flex: none.

      if (isFlexGrow || isFlexShrink) {
        // remainingFreeSpace starts out at the same value as initialFreeSpace
        // but as we place and lay out flex items we subtract from it.
        metrics.remainingFreeSpace = usedFreeSpace;

        final _FlexFactorTotals totalFlexFactor = _FlexFactorTotals(
          flexGrow: metrics.totalFlexGrow,
          flexShrink: metrics.totalFlexShrink,
        );
        // Loop flex items to resolve flexible length of flex items with flex factor.
        while (_resolveFlexibleLengths(metrics, totalFlexFactor, usedFreeSpace)) {}
      }

      // Phase 1 — Relayout each item with its resolved main size only.
      // Do not apply align-items: stretch yet, so text/content can expand to
      // its natural height based on the final line width.
      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;
        // Unwrap wrappers to operate on the actual flex item while still laying out the wrapper.
        RenderBoxModel? effectiveChild = runChild.effectiveChild;
        if (effectiveChild == null) {
          // Non-RenderBoxModel child: nothing to tighten in phase 1.
          continue;
        }
        double childOldMainSize = _isHorizontalFlexDirection ? child.size.width : child.size.height;

        // Determine used main size from the flexible lengths result, if any.
        double? childFlexedMainSize;
        if ((isFlexGrow && runChild.flexGrow > 0) || (isFlexShrink && runChild.flexShrink > 0)) {
          childFlexedMainSize = runChild.flexedMainSize;
        }

        double? desiredPreservedMain;
        if (childFlexedMainSize == null) {
          desiredPreservedMain = _childrenIntrinsicMainSizes[child];
        }

        bool needsLayout = (childFlexedMainSize != null) ||
            (effectiveChild.needsRelayout);
        if (!needsLayout && desiredPreservedMain != null && (desiredPreservedMain != childOldMainSize)) {
          needsLayout = true;
        }
        if (!needsLayout && desiredPreservedMain != null) {
          final BoxConstraints applied = child.constraints;
          final bool autoMain = _isHorizontalFlexDirection
              ? effectiveChild.renderStyle.width.isAuto
              : effectiveChild.renderStyle.height.isAuto;
          final bool wasNonTightMain = _isHorizontalFlexDirection
              ? !applied.hasTightWidth
              : !applied.hasTightHeight;
          if (autoMain && wasNonTightMain) {
            needsLayout = true;
          }
        }

        // For column-direction containers, if the flex item has auto cross size (width)
        // and is not stretched, and the container has a definite available cross size,
        // force a secondary layout when the intrinsic pass measured the item wider than
        // the available width. This enables shrink-to-fit logic in
        // _getChildAdjustedConstraints to produce the expected width.
        if (!needsLayout && !_isHorizontalFlexDirection) {
          final bool childCrossAuto = effectiveChild.renderStyle.width.isAuto;
          final bool noStretch = !_needToStretchChildCrossSize(effectiveChild);
          final double availCross = contentConstraints?.maxWidth ?? double.infinity;
          if (childCrossAuto && noStretch && availCross.isFinite) {
            // Compare against the border-box width measured during intrinsic pass.
            final double measuredBorderW = effectiveChild.size.width;
            if (measuredBorderW > availCross + 0.5) {
              needsLayout = true;
            }
          }
        }

        if (!needsLayout) continue;

        // Mark text-only parents for flex relayout optimization.
        _markFlexRelayoutForTextOnly(effectiveChild);

        final BoxConstraints childConstraints = _getChildAdjustedConstraints(
          effectiveChild,
          childFlexedMainSize,
          null, // defer stretching
          runChildrenList.length,
          preserveMainAxisSize: desiredPreservedMain,
        );
        child.layout(childConstraints, parentUsesSize: true);
      }

      // After Phase 1, recompute the run cross extent based on the items’ natural
      // cross sizes with final main sizes.
      metrics.crossAxisExtent = _recomputeRunCrossExtent(metrics);

      // Phase 2 — Apply align-items/align-self: stretch using the computed line cross size.
      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;
        RenderBoxModel? effectiveChild = runChild.effectiveChild;
        if (effectiveChild == null) continue;

        double? childStretchedCrossSize;
        if (_needToStretchChildCrossSize(effectiveChild)) {
          childStretchedCrossSize =
              _getChildStretchedCrossSize(effectiveChild, metrics.crossAxisExtent, runBetweenSpace);
          if (effectiveChild is RenderLayoutBox && effectiveChild.isNegativeMarginChangeHSize) {
            double childCrossAxisMargin = _isHorizontalFlexDirection
                ? effectiveChild.renderStyle.margin.vertical
                : effectiveChild.renderStyle.margin.horizontal;
            childStretchedCrossSize += childCrossAxisMargin.abs();
          }
        }

        // Skip if no stretching is needed.
        if (childStretchedCrossSize == null) continue;

        // If the current cross size already matches the stretched result, skip.
        final double currentCross = _isHorizontalFlexDirection ? child.size.height : child.size.width;
        if ((childStretchedCrossSize - currentCross).abs() < 0.5) continue;

        // Apply stretch by relayout with tightened cross-axis constraint.
        final BoxConstraints childConstraints = _getChildAdjustedConstraints(
          effectiveChild,
          null, // main already resolved
          childStretchedCrossSize,
          runChildrenList.length,
        );
        child.layout(childConstraints, parentUsesSize: true);
      }

      // Finally, recompute run main & cross extents using the final sizes.
      double mainAxisExtent = 0;
      for (int i = 0; i < runChildrenList.length; i++) {
        if (i > 0) mainAxisExtent += mainAxisGap;
        mainAxisExtent += _getMainAxisExtent(runChildrenList[i].child);
      }
      metrics.mainAxisExtent = mainAxisExtent;
      metrics.crossAxisExtent = _recomputeRunCrossExtent(metrics);
    }
  }

  // Adjust flex line cross extent caused by flex item stretch due to alignment properties
  // in the cross axis (align-items/align-self).
  double _recomputeRunCrossExtent(_RunMetrics metrics) {
    final List<_RunChild> runChildren = metrics.runChildren;
    final bool isHorizontal = _isHorizontalFlexDirection;

    double runCrossAxisExtent = 0;

    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;

    for (final _RunChild runChild in runChildren) {
      RenderBox child = runChild.child;
      double childMainSize = isHorizontal ? child.size.width : child.size.height;
      double childCrossSize = isHorizontal ? child.size.height : child.size.width;
      double childCrossMargin = 0;
      if (child is RenderBoxModel) {
        childCrossMargin = isHorizontal
            ? child.renderStyle.marginTop.computedValue + child.renderStyle.marginBottom.computedValue
            : child.renderStyle.marginLeft.computedValue + child.renderStyle.marginRight.computedValue;
      }
      double childCrossExtent = childCrossSize + childCrossMargin;

      if (runChild.flexedMainSize != childMainSize &&
          child is RenderBoxModel &&
          runChild.isReplaced &&
          runChild.aspectRatio != null) {
        double childAspectRatio = runChild.aspectRatio!;
        if (isHorizontal && child.renderStyle.height.isAuto) {
          childCrossSize = runChild.flexedMainSize / childAspectRatio;
        } else if (!isHorizontal && child.renderStyle.width.isAuto) {
          childCrossSize = runChild.flexedMainSize * childAspectRatio;
        }
        childCrossExtent = childCrossSize + childCrossMargin;
      }

      // Vertical align is only valid for inline box.
      // Baseline alignment in column direction behave the same as flex-start.
      AlignSelf alignSelf = _getAlignSelf(child);
      bool isBaselineAlign =
          alignSelf == AlignSelf.baseline ||
          alignSelf == AlignSelf.lastBaseline ||
          renderStyle.alignItems == AlignItems.baseline ||
          renderStyle.alignItems == AlignItems.lastBaseline;

      if (isHorizontal && isBaselineAlign) {
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
  BoxConstraints _getChildAdjustedConstraints(RenderBoxModel child,
      double? childFlexedMainSize,
      double? childStretchedCrossSize,
      int lineChildrenCount,
      {double? preserveMainAxisSize}) {
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
    BoxConstraints oldConstraints = _childrenOldConstraints[child] ?? child.constraints;

    // Row flex container + pure cross-axis stretch:
    // Preserve the flex-resolved main size (oldConstraints.min/maxWidth) and
    // only tighten the cross size to the stretched line height. This prevents
    // align-items:stretch from inflating the main-axis size again.
    if (_isHorizontalFlexDirection &&
        childStretchedCrossSize != null &&
        childFlexedMainSize == null &&
        !child.renderStyle.isSelfRenderReplaced()) {
      // Use the current constraints on the child, which already encode
      // the flex-resolved main size from the previous pass (e.g., 172px),
      // rather than the original percentage/min-width based constraints.
      final BoxConstraints prev = child.constraints;
      final double minW = prev.minWidth;
      final double maxW = prev.maxWidth;
      final double h = childStretchedCrossSize;
      final BoxConstraints res = BoxConstraints(
        minWidth: minW,
        maxWidth: maxW,
        minHeight: h,
        maxHeight: h,
      );
      return res;
    }

    // Compute safe used border-box sizes when overrides are present. In certain
    // multi-pass layouts (e.g., wrappers like RenderEventListener or when text
    // reflows), borderBoxLogicalWidth/Height may not yet be populated even if
    // hasOverrideContentLogicalWidth/Height is true. Avoid null-unwrap and fall
    // back to deriving from contentBox + padding + border or the previous
    // constraints.
    double safeUsedBorderBoxWidth() {
      final double? logicalW = child.renderStyle.borderBoxLogicalWidth;
      if (logicalW != null && logicalW.isFinite) return math.max(0, logicalW);
      final double? contentW = child.renderStyle.contentBoxLogicalWidth;
      if (contentW != null && contentW.isFinite) {
        final double pad = child.renderStyle.paddingLeft.computedValue +
            child.renderStyle.paddingRight.computedValue;
        final double border = child.renderStyle.effectiveBorderLeftWidth.computedValue +
            child.renderStyle.effectiveBorderRightWidth.computedValue;
        return math.max(0, contentW + pad + border);
      }
      return math.max(0, oldConstraints.maxWidth);
    }

    double safeUsedBorderBoxHeight() {
      final double? logicalH = child.renderStyle.borderBoxLogicalHeight;
      if (logicalH != null && logicalH.isFinite) return math.max(0, logicalH);
      final double? contentH = child.renderStyle.contentBoxLogicalHeight;
      if (contentH != null && contentH.isFinite) {
        final double pad = child.renderStyle.paddingTop.computedValue +
            child.renderStyle.paddingBottom.computedValue;
        final double border = child.renderStyle.effectiveBorderTopWidth.computedValue +
            child.renderStyle.effectiveBorderBottomWidth.computedValue;
        return math.max(0, contentH + pad + border);
      }
      return math.max(0, oldConstraints.maxHeight);
    }

    double maxConstraintWidth = child.hasOverrideContentLogicalWidth
        ? safeUsedBorderBoxWidth()
        : oldConstraints.maxWidth;
    double maxConstraintHeight = child.hasOverrideContentLogicalHeight
        ? safeUsedBorderBoxHeight()
        : oldConstraints.maxHeight;

    double minConstraintWidth = child.hasOverrideContentLogicalWidth
        ? safeUsedBorderBoxWidth()
        : (oldConstraints.minWidth > maxConstraintWidth ? maxConstraintWidth : oldConstraints.minWidth);
    double minConstraintHeight = child.hasOverrideContentLogicalHeight
        ? safeUsedBorderBoxHeight()
        : (oldConstraints.minHeight > maxConstraintHeight ? maxConstraintHeight : oldConstraints.minHeight);

    // If the flex item has a definite height in a row-direction container,
    // lock the child's height to the used border-box height. This prevents
    // later passes (e.g., text reflow) from clearing the specified height
    // and expanding to content height (which would incorrectly grow the
    // flex item above its specified height). Matches CSS: a definite
    // cross-size is not affected by align-items: stretch or content.
    if (_isHorizontalFlexDirection && !child.renderStyle.height.isAuto) {
      final double? usedBorderBoxH = child.renderStyle.borderBoxLogicalHeight;
      if (usedBorderBoxH != null && usedBorderBoxH.isFinite) {
        minConstraintHeight = usedBorderBoxH;
        maxConstraintHeight = usedBorderBoxH;
      }
    }

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

    // Enforce the automatic minimum size on the main axis when flex-direction is column
    // and the item did not flex in the main axis. This prevents a definite flex-basis: 0
    // from collapsing the item’s height below its content-based minimum (min-height: auto).
    // Spec reference: https://www.w3.org/TR/css-flexbox-1/#min-size-auto
    if (!_isHorizontalFlexDirection && childFlexedMainSize == null) {
      // Compute the effective minimum main size (resolves auto to content-based minimum).
      final double autoMinMain = _getMinMainAxisSize(child);
      if (autoMinMain > 0) {
        // Raise the min height to at least the automatic minimum.
        if (minConstraintHeight < autoMinMain) {
          minConstraintHeight = autoMinMain;
        }
        // Ensure max height is not lower than min height.
        if (maxConstraintHeight < minConstraintHeight) {
          maxConstraintHeight = minConstraintHeight;
        }
      }
    }

    // Column flex: when the container has a bounded max-height (definite cap) but an
    // indefinite main-size (height:auto), browsers do not distribute positive free space.
    // However, widget-based flex items (RenderWidget) commonly require a tight viewport
    // height to behave correctly (e.g., list views). When the preserved (intrinsic) main
    // size exceeds the container’s available cap, clamp the child’s main-axis constraints
    // tightly to the container cap so the widget sizes to the visible viewport instead of
    // overflowing. This mirrors practical browser behavior for scrollable widgets when
    // author intent is flex: 1; min-height: 0 under a max-height container.
    if (!_isHorizontalFlexDirection) {
      final bool containerBounded = (contentConstraints?.hasBoundedHeight ?? false) &&
          (contentConstraints?.maxHeight.isFinite ?? false);
      if (containerBounded) {
        final double cap = contentConstraints!.maxHeight;
        final bool childIsWidget = child is RenderWidget || child.renderStyle.target is WidgetElement;
        if (childIsWidget && preserveMainAxisSize != null && preserveMainAxisSize > cap) {
          minConstraintHeight = cap;
          maxConstraintHeight = cap;
        }
      }
    }

    // Column flex: when not stretching in the cross axis, lock the item's used cross size
    // (width) during the relayout pass so its descendants see a definite containing block width.
    // This ensures percentage paddings/margins inside the item resolve against the item's
    // actual width (e.g., padding-bottom:50% → height=width/2), matching browsers.
    // Do not apply this optimization to replaced elements; their aspect-ratio handling
    // and intrinsic sizing already provide stable behavior, and locking can produce
    // intermediate widths that conflict with later stretch.
    if (!_isHorizontalFlexDirection && childStretchedCrossSize == null && !child.renderStyle.isSelfRenderReplaced()) {
      final bool childCrossAuto = child.renderStyle.width.isAuto;
      final bool childCrossPercent = child.renderStyle.width.type == CSSLengthType.PERCENTAGE;

      // Determine the effective cross-axis alignment for this child.
      final AlignSelf selfAlign = _getAlignSelf(child);
      final bool isStretchAlignment = selfAlign != AlignSelf.auto
          ? (selfAlign == AlignSelf.stretch)
          : (renderStyle.alignItems == AlignItems.stretch);

      // If the child will not be stretched in the cross axis (e.g., align-self: center),
      // prefer a shrink-to-fit width based on the child’s content contribution so items
      // don’t expand to the full column width. This matches browser behavior for
      // column-direction flex items with non-stretch alignment.
      if (childCrossAuto && !isStretchAlignment) {
        // Compute shrink-to-fit width in the cross axis for column flex items:
        // used = min(max(min-content, available), max-content).
        // Work in content-box, then convert to border-box by adding padding+border.
        final double paddingBorderH = child.renderStyle.padding.horizontal + child.renderStyle.border.horizontal;

        // Min-content contribution (content-box).
        final double minContentCB = child.minContentWidth;

        // Max-content contribution (content-box). Prefer IFC paragraph max-intrinsic width for flow content.
        double maxContentCB = minContentCB; // fallback
        if (child is RenderFlowLayout && child.inlineFormattingContext != null) {
          final double paraMax = child.inlineFormattingContext!.paragraphMaxIntrinsicWidth;
          if (paraMax.isFinite && paraMax > 0) maxContentCB = paraMax;
        }

        // Available cross size (content-box width of the container) if definite.
        // Per CSS Flexbox, the available cross space for a flex item is the
        // flex container’s inner cross size minus the item’s margins in the
        // cross axis. Subtract positive start/end margins to get the space
        // available to the item’s border-box for shrink-to-fit width.
        double availableCross = double.infinity;
        if (contentConstraints != null && contentConstraints!.maxWidth.isFinite) {
          availableCross = contentConstraints!.maxWidth;
        } else {
          // Fallback to current laid-out content width when known.
          final double borderH = renderStyle.effectiveBorderLeftWidth.computedValue +
              renderStyle.effectiveBorderRightWidth.computedValue;
          final double fallback = math.max(0.0, size.width - borderH);
          if (fallback.isFinite && fallback > 0) availableCross = fallback;
        }
        // Subtract cross-axis margins (positive values only) from available width.
        if (availableCross.isFinite) {
          final double startMargin = _flowAwareChildCrossAxisMargin(child) ?? 0;
          final double endMargin = _flowAwareChildCrossAxisMargin(child, isEnd: true) ?? 0;
          final double marginDeduction = math.max(0.0, startMargin) + math.max(0.0, endMargin);
          availableCross = math.max(0.0, availableCross - marginDeduction);
        }

        // If IFC not available yet and max-content collapsed to min-content, try using
        // the child width from the intrinsic pass as a better approximation of max-content,
        // but only when it is less than the container's available cross size to avoid
        // regressing centering cases (e.g., column-wrap with align-self:center).
        if (maxContentCB <= minContentCB + 0.5) {
          final double priorBorderW = child.size.width;
          final double priorContentW = math.max(0.0, priorBorderW - (child.renderStyle.padding.horizontal + child.renderStyle.border.horizontal));
          if (priorContentW.isFinite && priorContentW > minContentCB) {
            maxContentCB = priorContentW;
          }
        }

        // Convert to border-box for comparison with constraints we apply to the child.
        final double minBorder = math.max(0.0, minContentCB + paddingBorderH);
        final double maxBorder = math.max(minBorder, maxContentCB + paddingBorderH);
        final double availBorder = availableCross.isFinite ? availableCross : double.infinity;

        double shrinkBorderW = maxBorder;
        if (availBorder.isFinite) {
          shrinkBorderW = math.min(math.max(minBorder, availBorder), maxBorder);
        }

        // Respect the child’s own min/max-width caps.
        // For percentages, clamp against the flex container's definite cross size
        // (its content-box width) when available; otherwise, defer clamping.
        if (child.renderStyle.minWidth.isNotAuto) {
          if (child.renderStyle.minWidth.type == CSSLengthType.PERCENTAGE) {
            if (availableCross.isFinite) {
              final double usedMin = (child.renderStyle.minWidth.value ?? 0) * availableCross;
              shrinkBorderW = math.max(shrinkBorderW, usedMin);
            }
          } else {
            shrinkBorderW = math.max(shrinkBorderW, child.renderStyle.minWidth.computedValue);
          }
        }
        if (child.renderStyle.maxWidth.isNotNone) {
          if (child.renderStyle.maxWidth.type == CSSLengthType.PERCENTAGE) {
            if (availableCross.isFinite) {
              final double usedMax = (child.renderStyle.maxWidth.value ?? 0) * availableCross;
              shrinkBorderW = math.min(shrinkBorderW, usedMax);
            }
          } else {
            shrinkBorderW = math.min(shrinkBorderW, child.renderStyle.maxWidth.computedValue);
          }
        }

        if (shrinkBorderW.isFinite && shrinkBorderW >= 0) {
          minConstraintWidth = shrinkBorderW;
          maxConstraintWidth = shrinkBorderW;
          _overrideChildContentBoxLogicalWidth(child, shrinkBorderW);
        }
      } else if (childCrossAuto) {
        // Existing behavior: cross-lock width to the available cross size when stretching
        // (or when alignment falls back to stretch). This preserves previous layout for
        // stretch cases and avoids regressions.
        double fixedW;
        if (child.renderStyle.isSelfRenderReplaced() && child.renderStyle.aspectRatio != null) {
          final double usedBorderBoxH = child.renderStyle.borderBoxLogicalHeight ?? child.size.height;
          fixedW = usedBorderBoxH * child.renderStyle.aspectRatio!;
        } else {
          fixedW = child.size.width;
        }
        final double containerCrossMax = contentConstraints?.maxWidth ?? double.infinity;
        final double containerContentW = containerCrossMax.isFinite
            ? containerCrossMax
            : math.max(0.0, size.width - (renderStyle.effectiveBorderLeftWidth.computedValue +
                renderStyle.effectiveBorderRightWidth.computedValue));

        double styleMinW = 0.0;
        final CSSLengthValue minWLen = child.renderStyle.minWidth;
        if (minWLen.isNotAuto) {
          styleMinW = (minWLen.type == CSSLengthType.PERCENTAGE)
              ? (minWLen.value ?? 0) * containerContentW
              : minWLen.computedValue;
        }
        double styleMaxW = double.infinity;
        final CSSLengthValue maxWLen = child.renderStyle.maxWidth;
        if (maxWLen.isNotNone) {
          styleMaxW = (maxWLen.type == CSSLengthType.PERCENTAGE)
              ? (maxWLen.value ?? 0) * containerContentW
              : maxWLen.computedValue;
        }

        fixedW = fixedW.clamp(styleMinW, styleMaxW);
        if (containerContentW.isFinite) fixedW = math.min(fixedW, containerContentW);

        if (fixedW.isFinite && fixedW > 0) {
          minConstraintWidth = fixedW;
          maxConstraintWidth = fixedW;
          _overrideChildContentBoxLogicalWidth(child, fixedW);
        }
      } else if (childCrossPercent) {
        // Resolve percentage width against the flex container's definite cross size (content box width)
        // once it becomes known (second layout pass). This matches CSS flex item percentage resolution
        // in column-direction containers.
        double containerContentW;
        if (contentConstraints != null && contentConstraints!.maxWidth.isFinite) {
          containerContentW = contentConstraints!.maxWidth;
        } else {
          final double borderH = renderStyle.effectiveBorderLeftWidth.computedValue +
              renderStyle.effectiveBorderRightWidth.computedValue;
          containerContentW = math.max(0, size.width - borderH);
        }
        final double percent = child.renderStyle.width.value ?? 0;
        double childBorderBoxW = containerContentW.isFinite ? (containerContentW * percent) : 0;
        if (!childBorderBoxW.isFinite || childBorderBoxW < 0) childBorderBoxW = 0;

        if (child.renderStyle.maxWidth.isNotNone && child.renderStyle.maxWidth.type != CSSLengthType.PERCENTAGE) {
          childBorderBoxW = math.min(childBorderBoxW, child.renderStyle.maxWidth.computedValue);
        }
        if (child.renderStyle.minWidth.isNotAuto) {
          childBorderBoxW = math.max(childBorderBoxW, child.renderStyle.minWidth.computedValue);
        }

        minConstraintWidth = childBorderBoxW;
        maxConstraintWidth = childBorderBoxW;
        _overrideChildContentBoxLogicalWidth(child, childBorderBoxW);
      }
    }

    // For replaced elements in a column flex container during phase 1 (no cross stretch yet),
    // cap the available cross size by the container’s content-box width so the intrinsic sizing
    // does not expand to unconstrained widths (e.g., viewport width) before the stretch phase.
    if (!_isHorizontalFlexDirection && child.renderStyle.isSelfRenderReplaced() && childStretchedCrossSize == null) {
      final double containerCrossMax = contentConstraints?.maxWidth ?? double.infinity;
      if (containerCrossMax.isFinite) {
        if (maxConstraintWidth.isInfinite || maxConstraintWidth > containerCrossMax) {
          maxConstraintWidth = containerCrossMax;
        }
        if (minConstraintWidth > maxConstraintWidth) {
          minConstraintWidth = maxConstraintWidth;
        }
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
    // Block-level flex items whose contents form an inline formatting context (e.g., a <div> with only text)
    // also need height to be unconstrained on the secondary pass so text can wrap after flex-shrink.
    // This mirrors browser behavior: first resolve the used main size, then measure cross size with auto height.
    bool establishesIFC = child.renderStyle.shouldEstablishInlineFormattingContext();
    bool isSecondaryLayoutPass = child.hasSize;

    // Allow dynamic height adjustment during secondary layout when width has changed and height is auto
    bool allowDynamicHeight = _isHorizontalFlexDirection &&
        isSecondaryLayoutPass &&
        (isTextElement || isInlineElementWithText || establishesIFC) &&
        // For non-flexed items, only allow when this is the only item on the line
        // so the line cross-size is content-driven.
        (childFlexedMainSize != null || (preserveMainAxisSize != null && lineChildrenCount == 1)) &&
        // Do not override stretch to a sibling's definite height when multiple items exist.
        (childStretchedCrossSize == null || lineChildrenCount == 1) &&
        child.renderStyle.height.isAuto;

    if (allowDynamicHeight) {
      // Remove tight height constraints to allow text to reflow properly. When the
      // flex item is stretched in the cross axis, maintain its minimum height so
      // margins and padding are preserved while still allowing it to expand beyond
      // the stretched size if its contents require it.
      if (childStretchedCrossSize != null && childStretchedCrossSize > 0) {
        minConstraintHeight = math.max(minConstraintHeight, childStretchedCrossSize);
      } else {
        minConstraintHeight = 0;
      }
      maxConstraintHeight = double.infinity;
      // Clear any previously overridden content logical height so getContentSize
      // uses the measured IFC height rather than a stale fixed value.
      child.hasOverrideContentLogicalHeight = false;
      child.renderStyle.contentBoxLogicalHeight = null;
    }
    // Calculate minimum height needed for child's content (padding + border + content)
    double adjustedMaxHeight = maxConstraintHeight;
    if (childStretchedCrossSize == null) {
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
      if (contentMinHeight > adjustedMaxHeight) {
        adjustedMaxHeight = contentMinHeight;
      }
    }
    // If not stretching in a row-direction container (vertical cross-axis), ensure the
    // child's border-box height is at least its padding+border so tall paddings are preserved.
    if (_isHorizontalFlexDirection && childStretchedCrossSize == null) {
      final double paddingBorderV =
          child.renderStyle.effectiveBorderTopWidth.computedValue +
              child.renderStyle.effectiveBorderBottomWidth.computedValue +
              child.renderStyle.paddingTop.computedValue +
              child.renderStyle.paddingBottom.computedValue;
      if (paddingBorderV > minConstraintHeight) {
        minConstraintHeight = paddingBorderV;
      }
    }
    // Normalize: maxHeight must be >= minHeight.
    if (adjustedMaxHeight < minConstraintHeight) {
      adjustedMaxHeight = minConstraintHeight;
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
      // Preserve the hypothetical main size when no flexing occurs (free space = 0).
      // Spec: the used main size equals the hypothetical main size in this case.
      if (_isHorizontalFlexDirection) {
        // Row direction: preserve width, but cap by the container's available content width
        // so inline content (IFC) can wrap instead of overflowing when the container has
        // a definite or bounded width (e.g., inline-flex with max-width).
        final bool hasDefiniteFlexBasis = _getFlexBasis(child) != null;
        final bool isReplaced = child.renderStyle.isSelfRenderReplaced();
        final double childFlexGrow = _getFlexGrow(child);
        final double childFlexShrink = _getFlexShrink(child);
        final bool isFlexNone = childFlexGrow == 0 && childFlexShrink == 0; // flex: none
        if (hasDefiniteFlexBasis || (child.renderStyle.width.isAuto && !isReplaced)) {
          if (isFlexNone) {
            // For flex: none items, do not constrain to the container width.
            // Let the item keep its preserved (intrinsic) width and overflow if necessary.
            minConstraintWidth = preserveMainAxisSize;
            maxConstraintWidth = preserveMainAxisSize;
          } else {
            final double containerAvail = contentConstraints?.maxWidth ?? double.infinity;
            if (containerAvail.isFinite) {
              double cap = preserveMainAxisSize;
              // Also honor the child’s own definite (non-percentage) max-width if any.
              if (child.renderStyle.maxWidth.isNotNone && child.renderStyle.maxWidth.type != CSSLengthType.PERCENTAGE) {
                cap = math.min(cap, child.renderStyle.maxWidth.computedValue);
              }
              cap = math.min(cap, containerAvail);
              // Shrink-to-fit: choose a definite width within [min-content, max-content]
              // bounded by container available width and max-width. Provide a tight
              // width equal to the cap so inline content wraps to that measure.
              minConstraintWidth = cap;
              maxConstraintWidth = cap;
            } else {
              // No definite container width: preserve tightly.
              minConstraintWidth = preserveMainAxisSize;
              maxConstraintWidth = preserveMainAxisSize;
            }
          }
        }
      } else {
        // Column direction: preserve height.
        // Do not preserve when the flex container's main size is auto and only
        // bounded by a max constraint (e.g., max-height). In that scenario, the
        // container must not force a tight height on the item; allow the child to
        // reflow under the container's bounded height instead of freezing to the
        // intrinsic height from PASS 2.
        final bool containerBoundedOnly = (contentConstraints?.hasBoundedHeight ?? false) &&
            !(contentConstraints?.hasTightHeight ?? false) &&
            renderStyle.contentBoxLogicalHeight == null;

        // Avoid over-constraining text reflow cases by applying only when the
        // intrinsic pass forced a tight zero height or when the basis is definite
        // (including 0) and height is auto.
        final bool hasDefiniteFlexBasis = _getFlexBasis(child) != null;
        final bool heightAuto = child.renderStyle.height.isAuto;
        final bool intrinsicForcedZero = oldConstraints.maxHeight == 0;
        if (!containerBoundedOnly &&
            preserveMainAxisSize > 0 &&
            (intrinsicForcedZero || (hasDefiniteFlexBasis && heightAuto))) {
          minConstraintHeight = preserveMainAxisSize;
          maxConstraintHeight = preserveMainAxisSize;
        }
      }
    }

    // Ensure normalization after any adjustments above (preserveMainAxisSize may raise min).
    if (adjustedMaxHeight < minConstraintHeight) {
      adjustedMaxHeight = minConstraintHeight;
    }

    BoxConstraints childConstraints = BoxConstraints(
      minWidth: minConstraintWidth,
      maxWidth: maxConstraintWidth,
      minHeight: minConstraintHeight,
      maxHeight: adjustedMaxHeight,
    );

    return childConstraints;
  }

  // When replaced element is stretched or shrinked only on one axis and
  // length is not specified on the other axis, the length needs to be
  // overrided in the other axis.
  void _overrideReplacedChildLength(RenderBoxModel child,
      double? childFlexedMainSize,
      double? childStretchedCrossSize,) {
    assert(child.renderStyle.isSelfRenderReplaced());
    if (childFlexedMainSize != null && childStretchedCrossSize == null) {
      if (_isHorizontalFlexDirection) {
        _overrideReplacedChildHeight(child);
      } else {
        _overrideReplacedChildWidth(child);
      }
    }

    // Do not override the flex item’s resolved main size based on a cross-axis
    // stretch. In flex layout, the used main size is established by the flex
    // algorithm (including min/max clamping). Adjusting the opposite axis to
    // preserve the intrinsic aspect ratio is only valid when the main axis was
    // changed directly (flexing). For a pure cross-axis stretch, the cross size
    // is tightened separately via constraints and the main size remains intact.
    // Therefore, intentionally no-op when only childStretchedCrossSize is provided.
  }

  // Override replaced child height when its height is auto.
  void _overrideReplacedChildHeight(RenderBoxModel child,) {
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
  void _overrideReplacedChildWidth(RenderBoxModel child,) {
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
    // Deflating padding/border can yield a negative content-box when the
    // assigned border-box is smaller than padding+border. CSS forbids
    // negative content sizes; clamp to zero so downstream layout (e.g.,
    // intrinsic measurement and alignment) receives a sane, non-negative
    // logical size.
    double deflated = child.renderStyle.deflatePaddingBorderWidth(maxConstraintWidth);
    if (deflated.isFinite && deflated < 0) deflated = 0;
    child.renderStyle.contentBoxLogicalWidth = deflated;
    child.hasOverrideContentLogicalWidth = true;
  }

  // Override content box logical height of child when flex-grow/flex-shrink/align-items has changed
  // child's size.
  void _overrideChildContentBoxLogicalHeight(RenderBoxModel child, double maxConstraintHeight) {
    // See width counterpart: guard against negative content-box heights
    // when padding/border exceed the assigned border-box. Use zero to
    // represent the collapsed content box per spec.
    double deflated = child.renderStyle.deflatePaddingBorderHeight(maxConstraintHeight);
    if (deflated.isFinite && deflated < 0) deflated = 0;
    child.renderStyle.contentBoxLogicalHeight = deflated;
    child.hasOverrideContentLogicalHeight = true;
  }

  // Set flex container size according to children size.
  void _setContainerSize(List<_RunMetrics> runMetrics,) {
    if (runMetrics.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }
    double runMaxMainSize = _getRunsMaxMainSize(runMetrics);
    double runCrossSize = _getRunsCrossSize(runMetrics);

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
    final Size boxSize = getBoxSize(layoutContentSize);

    size = boxSize;

    // Set auto value of min-width and min-height based on size of flex items.
    if (_isHorizontalFlexDirection) {
      minContentWidth = _getMainAxisAutoSize(runMetrics);
      minContentHeight = _getCrossAxisAutoSize(runMetrics);
    } else {
      minContentHeight = _getMainAxisAutoSize(runMetrics);
      minContentWidth = _getCrossAxisAutoSize(runMetrics);
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
  void _recordRunsMainSize(_RunMetrics runMetrics, List<double> runMainSize) {
    final List<_RunChild> runChildren = runMetrics.runChildren;
    double runMainExtent = 0;
    for (final _RunChild runChild in runChildren) {
      final RenderBox child = runChild.child;
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
    runMainSize.add(runMainExtent);
  }

  // Get auto min size in the main axis which equals the main axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getMainAxisAutoSize(List<_RunMetrics> runMetrics,) {
    double autoMinSize = 0;

    // Main size of each run.
    List<double> runMainSize = [];

    // Calculate the max main size of all runs.
    for (final runMetric in runMetrics) {
      _recordRunsMainSize(runMetric, runMainSize);
    }

    autoMinSize = runMainSize.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });
    return autoMinSize;
  }

  // Record the cross size of all lines.
  void _recordRunsCrossSize(_RunMetrics runMetrics, List<double> runCrossSize) {
    final List<_RunChild> runChildren = runMetrics.runChildren;
    double runCrossExtent = 0;
    for (final _RunChild runChild in runChildren) {
      final RenderBox child = runChild.child;
      final double runChildCrossSize = _isHorizontalFlexDirection ? child.size.height : child.size.width;
      runCrossExtent = math.max(runCrossExtent, runChildCrossSize);
    }
    runCrossSize.add(runCrossExtent);
  }

  // Get auto min size in the cross axis which equals the cross axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getCrossAxisAutoSize(List<_RunMetrics> runMetrics,) {
    double autoMinSize = 0;

    // Cross size of each run.
    List<double> runCrossSize = [];

    // Calculate the max cross size of all runs.
    for (final runMetric in runMetrics) {
      _recordRunsCrossSize(runMetric, runCrossSize);
    }

    // Get the sum of lines
    for (double crossSize in runCrossSize) {
      autoMinSize += crossSize;
    }

    return autoMinSize;
  }

  // Set the size of scrollable overflow area for flex layout.
  // https://drafts.csswg.org/css-overflow-3/#scrollable
  void _setMaxScrollableSize(List<_RunMetrics> runMetrics) {
    // Scrollable main size collection of each line.
    List<double> scrollableMainSizeOfLines = [];
    // Scrollable cross size collection of each line.
    List<double> scrollableCrossSizeOfLines = [];
    // Total cross size of previous lines.
    double preLinesCrossSize = 0;

    for (_RunMetrics runMetric in runMetrics) {
      final List<_RunChild> runChildren = runMetric.runChildren;
      // Avoid O(n^2) summation of previous siblings by keeping a running total.
      double preSiblingsMainSize = 0;
      double maxScrollableMainSizeOfLine = 0;
      double maxScrollableCrossSizeInLine = 0;

      for (final _RunChild runChild in runChildren) {
        final RenderBox child = runChild.child;

        Size childScrollableSize = child.size;
        double childOffsetX = 0;
        double childOffsetY = 0;

        if (child is RenderBoxModel) {
          final RenderStyle childRenderStyle = child.renderStyle;
          final CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
          final CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;
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
          final Offset? relativeOffset = CSSPositionedLayout.getRelativeOffset(childRenderStyle);
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

        final double childScrollableMain = preSiblingsMainSize +
            (_isHorizontalFlexDirection
                ? childScrollableSize.width + childOffsetX
                : childScrollableSize.height + childOffsetY);
        final double childScrollableCross = _isHorizontalFlexDirection
            ? childScrollableSize.height + childOffsetY
            : childScrollableSize.width + childOffsetX;

        maxScrollableMainSizeOfLine = math.max(maxScrollableMainSizeOfLine, childScrollableMain);
        maxScrollableCrossSizeInLine = math.max(maxScrollableCrossSizeInLine, childScrollableCross);

        // Update running main size for subsequent siblings (border-box size + main-axis margins).
        double childMainSize = _isHorizontalFlexDirection ? child.size.width : child.size.height;
        if (child is RenderBoxModel) {
          if (_isHorizontalFlexDirection) {
            childMainSize += child.renderStyle.marginLeft.computedValue + child.renderStyle.marginRight.computedValue;
          } else {
            childMainSize += child.renderStyle.marginTop.computedValue + child.renderStyle.marginBottom.computedValue;
          }
        }
        preSiblingsMainSize += childMainSize;
      }

      // Max scrollable cross size of all the children in the line.
      final double maxScrollableCrossSizeOfLine = preLinesCrossSize + maxScrollableCrossSizeInLine;

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
  double _getFlexLineCrossSize(RenderBox child,
      double runCrossAxisExtent,
      double runBetweenSpace,) {
    bool isSingleLine = (renderStyle.flexWrap != FlexWrap.wrap && renderStyle.flexWrap != FlexWrap.wrapReverse);

    if (isSingleLine) {
      final bool hasDefiniteContainerCross = _hasDefiniteContainerCrossSize();
      // For single-line flex containers, prefer the container’s definite inner cross size
      // (content-box) when available. This includes cases where the container’s cross size
      // is established by its parent (e.g., align-items:stretch on the parent), even if the
      // container’s own cross-size property is auto. Per CSS Flexbox §9.4, for single-line
      // flex containers the flex line’s cross size equals the flex container’s inner cross size
      // when that size is definite.
      // https://www.w3.org/TR/css-flexbox-1/#algo-cross-line
      double? explicitContainerCross;   // from explicit non-auto width/height
      double? resolvedContainerCross;   // resolved cross size for block-level flex when auto
      double? minCrossFromConstraints;  // content-box min cross size
      double? minCrossFromStyle;        // content-box min cross size derived from min-width/min-height
      double? containerInnerCross;      // measured inner cross size from this layout pass
      final CSSDisplay effectiveDisplay = renderStyle.effectiveDisplay;
      final bool isInlineFlex = effectiveDisplay == CSSDisplay.inlineFlex;
      final CSSWritingMode wm = renderStyle.writingMode;
      // Cross axis is horizontal when main is vertical, meaning cross property is physical width.
      final bool crossIsWidth = !_isHorizontalFlexDirection;
      // Available inner cross size after applying outer constraints. Only used
      // when this flex container is hosted under a WebFWidgetElementChild, so
      // that line cross size is clamped to the visible inner box from Flutter
      // constraints (e.g., a 40px-tall flex container clamped to 28px).
      double? availableInnerCross;
      if (_hasWidgetConstraintAncestor) {
        if (_isHorizontalFlexDirection) {
          // Row: cross axis is height.
          final double maxH = constraints.maxHeight;
          if (maxH.isFinite) {
            final double borderV = renderStyle.effectiveBorderTopWidth.computedValue +
                renderStyle.effectiveBorderBottomWidth.computedValue;
            final double paddingV = renderStyle.paddingTop.computedValue + renderStyle.paddingBottom.computedValue;
            availableInnerCross = math.max(0, maxH - borderV - paddingV);
          }
        } else {
          // Column: cross axis is width.
          final double maxW = constraints.maxWidth;
          if (maxW.isFinite) {
            final double borderH = renderStyle.effectiveBorderLeftWidth.computedValue +
                renderStyle.effectiveBorderRightWidth.computedValue;
            final double paddingH = renderStyle.paddingLeft.computedValue + renderStyle.paddingRight.computedValue;
            availableInnerCross = math.max(0, maxW - borderH - paddingH);
          }
        }
      }

      double clampToAvailable(double value) {
        if (availableInnerCross == null || !availableInnerCross.isFinite) return value;
        return value > availableInnerCross ? availableInnerCross : value;
      }
      if (_isHorizontalFlexDirection) {
        // Row: cross is height
        // Only treat as definite if height is explicitly specified (not auto)
        if (hasDefiniteContainerCross && renderStyle.height.isNotAuto) {
          explicitContainerCross = renderStyle.contentBoxLogicalHeight;
        }
        // Also consider the actually measured inner cross size from this layout pass.
        if (hasDefiniteContainerCross && contentSize.height.isFinite && contentSize.height > 0) {
          containerInnerCross = contentSize.height;
        }
        // min-height should also participate in establishing the line cross size
        // for single-line flex containers, even when the container's cross size
        // is otherwise indefinite (e.g. height:auto under grid layout constraints).
        if (renderStyle.minHeight.isNotAuto) {
          final double minBorderBox = renderStyle.minHeight.computedValue;
          double minContentBox = renderStyle.deflatePaddingBorderHeight(minBorderBox);
          if (minContentBox.isFinite && minContentBox < 0) minContentBox = 0;
          if (minContentBox.isFinite && minContentBox > 0) {
            minCrossFromStyle = minContentBox;
          }
        }
        // Height:auto is generally not definite prior to layout; still capture a min-cross constraint if present.
        if (contentConstraints != null && contentConstraints!.minHeight.isFinite && contentConstraints!.minHeight > 0) {
          minCrossFromConstraints = contentConstraints!.minHeight;
        }
      } else {
        // Column: cross is width
        // Only treat as definite if width is explicitly specified (not auto)
        if (hasDefiniteContainerCross && renderStyle.width.isNotAuto) {
          explicitContainerCross = renderStyle.contentBoxLogicalWidth;
        }
        // For block-level flex with width:auto in horizontal writing mode, the used width
        // is fill-available and thus definite; only then may we resolve from constraints.
        if (hasDefiniteContainerCross && !isInlineFlex && (explicitContainerCross == null) && crossIsWidth &&
            wm == CSSWritingMode.horizontalTb) {
          if (contentConstraints != null && contentConstraints!.hasBoundedWidth &&
              contentConstraints!.maxWidth.isFinite) {
            resolvedContainerCross = contentConstraints!.maxWidth;
          }
        }
        // For column-direction containers with width:auto, do not treat the measured
        // content width as a definite line cross size; width:auto should shrink-to-fit
        // in vertical writing modes. Only consider the measured inner width when the
        // container has an explicit (non-auto) width.
        if (hasDefiniteContainerCross && renderStyle.width.isNotAuto && contentSize.width.isFinite && contentSize.width > 0) {
          containerInnerCross = contentSize.width;
        }
        if (renderStyle.minWidth.isNotAuto) {
          final double minBorderBox = renderStyle.minWidth.computedValue;
          double minContentBox = renderStyle.deflatePaddingBorderWidth(minBorderBox);
          if (minContentBox.isFinite && minContentBox < 0) minContentBox = 0;
          if (minContentBox.isFinite && minContentBox > 0) {
            minCrossFromStyle = minContentBox;
          }
        }
        if (contentConstraints != null && contentConstraints!.minWidth.isFinite && contentConstraints!.minWidth > 0) {
          minCrossFromConstraints = contentConstraints!.minWidth;
        }
      }

      // Prefer the larger of the style-derived and constraints-derived minimum cross sizes.
      if (minCrossFromStyle != null && minCrossFromStyle!.isFinite) {
        if (minCrossFromConstraints != null && minCrossFromConstraints!.isFinite) {
          minCrossFromConstraints = math.max(minCrossFromConstraints!, minCrossFromStyle!);
        } else {
          minCrossFromConstraints = minCrossFromStyle;
        }
      }

      if (explicitContainerCross != null && explicitContainerCross.isFinite) {
        explicitContainerCross = clampToAvailable(explicitContainerCross);
      }
      if (containerInnerCross != null && containerInnerCross.isFinite) {
        containerInnerCross = clampToAvailable(containerInnerCross);
      }
      if (resolvedContainerCross != null && resolvedContainerCross.isFinite) {
        resolvedContainerCross = clampToAvailable(resolvedContainerCross);
      }
      // If the container specified an explicit cross size, use it.
      if (explicitContainerCross != null && explicitContainerCross.isFinite) {
        return explicitContainerCross;
      }
      // For single-line containers with a definite cross size, the line cross size equals
      // the container’s inner cross size.
      if (hasDefiniteContainerCross) {
        if (containerInnerCross != null && containerInnerCross.isFinite) {
          return containerInnerCross;
        }
        if (!isInlineFlex && resolvedContainerCross != null && resolvedContainerCross.isFinite) {
          return resolvedContainerCross;
        }
      }
      // Otherwise clamp to min-cross if present.
      if (minCrossFromConstraints != null && minCrossFromConstraints.isFinite) {
        return math.max(runCrossAxisExtent, minCrossFromConstraints);
      }
      return runCrossAxisExtent;
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
  void _setChildrenOffset(List<_RunMetrics> runMetrics,) {
    if (runMetrics.isEmpty) return;

    final bool isHorizontal = _isHorizontalFlexDirection;
    // flipMainAxis decides whether the main axis increases toward the physical end
    // (false: LTR row or column; true: RTL row or column-reverse). This incorporates
    // both flex-direction and text direction for horizontal axes.
    final bool flipMainAxis = _isMainAxisReversed();
    final double mainAxisGap = _getMainAxisGap();
    final double crossAxisGap = _getCrossAxisGap();
    final double mainAxisStartPadding = _flowAwareMainAxisPadding();
    final double crossAxisStartPadding = _flowAwareCrossAxisPadding();
    final double mainAxisStartBorder = _flowAwareMainAxisBorder();
    final double crossAxisStartBorder = _flowAwareCrossAxisBorder();

    // Compute spacing before and between each flex line.
    final _RunSpacing runSpacing = _computeRunSpacing(runMetrics);
    final double runLeadingSpace = runSpacing.leading;
    final double runBetweenSpace = runSpacing.between;
    // Cross axis offset of each flex line.
    double crossAxisOffset = runLeadingSpace;

    double mainAxisContentSize;
    double crossAxisContentSize;

    if (_hasWidgetConstraintAncestor) {
      // For flex containers hosted under a WebFWidgetElementChild, clamp the
      // intrinsic contentSize to the actual inner box size from Flutter
      // constraints so that alignment (justify-content/align-items) operates
      // within the visible box instead of an unconstrained CSS height/width.
      final double borderLeft = renderStyle.effectiveBorderLeftWidth.computedValue;
      final double borderRight = renderStyle.effectiveBorderRightWidth.computedValue;
      final double borderTop = renderStyle.effectiveBorderTopWidth.computedValue;
      final double borderBottom = renderStyle.effectiveBorderBottomWidth.computedValue;
      final double paddingLeft = renderStyle.paddingLeft.computedValue;
      final double paddingRight = renderStyle.paddingRight.computedValue;
      final double paddingTop = renderStyle.paddingTop.computedValue;
      final double paddingBottom = renderStyle.paddingBottom.computedValue;

      final double innerWidthFromSize =
          math.max(0.0, size.width - borderLeft - borderRight - paddingLeft - paddingRight);
      final double innerHeightFromSize =
          math.max(0.0, size.height - borderTop - borderBottom - paddingTop - paddingBottom);

      double contentMainExtent;
      double contentCrossExtent;
      double innerMainFromSize;
      double innerCrossFromSize;

      if (isHorizontal) {
        // Row: main axis is width, cross axis is height.
        contentMainExtent = contentSize.width;
        contentCrossExtent = contentSize.height;
        innerMainFromSize = innerWidthFromSize;
        innerCrossFromSize = innerHeightFromSize;
      } else {
        // Column: main axis is height, cross axis is width.
        contentMainExtent = contentSize.height;
        contentCrossExtent = contentSize.width;
        innerMainFromSize = innerHeightFromSize;
        innerCrossFromSize = innerWidthFromSize;
      }

      mainAxisContentSize = contentMainExtent;
      if (innerMainFromSize.isFinite && innerMainFromSize > 0) {
        if (!mainAxisContentSize.isFinite || mainAxisContentSize <= 0) {
          mainAxisContentSize = innerMainFromSize;
        } else {
          mainAxisContentSize = math.min(mainAxisContentSize, innerMainFromSize);
        }
      }
      crossAxisContentSize = contentCrossExtent;
      if (innerCrossFromSize.isFinite && innerCrossFromSize > 0) {
        if (!crossAxisContentSize.isFinite || crossAxisContentSize <= 0) {
          crossAxisContentSize = innerCrossFromSize;
        } else {
          crossAxisContentSize = math.min(crossAxisContentSize, innerCrossFromSize);
        }
      }
    } else {
      // Pure DOM flex: use the intrinsic contentSize for alignment, which
      // matches browser flexbox behavior and is relied upon by existing
      // layout tests (e.g., chat layout and flex algorithm tests).
      if (isHorizontal) {
        mainAxisContentSize = contentSize.width;
        crossAxisContentSize = contentSize.height;
      } else {
        mainAxisContentSize = contentSize.height;
        crossAxisContentSize = contentSize.width;
      }
    }

    // Set offset of children in each flex line.
    for (int i = 0; i < runMetrics.length; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final List<_RunChild> runChildrenList = metrics.runChildren;
      final double remainingSpace = mainAxisContentSize - runMainAxisExtent;

      late double leadingSpace;
      late double betweenSpace;

      final int runChildrenCount = runChildrenList.length;

      switch (renderStyle.justifyContent) {
        case JustifyContent.flexStart:
        case JustifyContent.start:
        case JustifyContent.stretch:
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
      }

      // Calculate margin auto children in the main axis.
      double mainAxisMarginAutoChildrenCount = 0;

      for (_RunChild runChild in runChildrenList) {
        if (runChild.hasAutoMainAxisMargin) {
          mainAxisMarginAutoChildrenCount++;
        }
      }

      // Justify-content has no effect if auto margin of child exists in the main axis.
      if (mainAxisMarginAutoChildrenCount != 0) {
        leadingSpace = 0.0;
        betweenSpace = 0.0;
      }

      // Main axis position of child on layout.
      double childMainPosition = flipMainAxis
          ? mainAxisStartPadding + mainAxisStartBorder + mainAxisContentSize - leadingSpace
          : leadingSpace + mainAxisStartPadding + mainAxisStartBorder;

      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;
        // Flow-aware margins in the main axis.
        final double childStartMargin = runChild.mainAxisStartMargin;
        final double childEndMargin = runChild.mainAxisEndMargin;
        // Border-box main-size of the child (no margins).
        final double childMainSizeOnly = _getMainSize(child);

        // Position the child along the main axis respecting direction.
        if (flipMainAxis) {
          // In reversed main axis (e.g., column-reverse or RTL row), advance from the
          // far edge by the start margin and the child's own size. Do not subtract the
          // trailing (end) margin here — it separates this item from the next.
          final double adjStartMargin = _calculateMainAxisMarginForJustContentType(childStartMargin);
          childMainPosition -= (adjStartMargin + childMainSizeOnly);
        } else {
          // In normal flow, advance by the start margin before placing.
          childMainPosition += _calculateMainAxisMarginForJustContentType(childStartMargin);
        }
        double? childCrossPosition;
        AlignSelf alignSelf = runChild.alignSelf;

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
          case AlignSelf.lastBaseline:
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
              case AlignItems.lastBaseline:
              // FIXME: baseline alignment in wrap-reverse flexWrap may display different from browser in some case
                if (isHorizontal) {
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

        if (renderStyle.alignItems == AlignItems.stretch && child is RenderTextBox && !isHorizontal) {
          TextAlign textAlign = renderStyle.textAlign;
          if (textAlign == TextAlign.start) {
            alignment = 'start';
          } else if (textAlign == TextAlign.end) {
            alignment = 'end';
          } else if (textAlign == TextAlign.center) {
            alignment = 'center';
          }
        }

        final double childCrossAxisExtent = _getCrossAxisExtent(child);
        childCrossPosition = _getChildCrossAxisOffset(
          alignment,
          child,
          childCrossPosition,
          runBaselineExtent,
          runCrossAxisExtent,
          runBetweenSpace,
          crossAxisStartPadding,
          crossAxisStartBorder,
          childCrossAxisExtent: childCrossAxisExtent,
          childCrossAxisStartMargin: runChild.crossAxisStartMargin,
          childCrossAxisEndMargin: runChild.crossAxisEndMargin,
          hasAutoCrossAxisMargin: runChild.hasAutoCrossAxisMargin,
        );

        // Calculate margin auto length according to CSS spec rules
        // https://www.w3.org/TR/css-flexbox-1/#auto-margins
        // margin auto takes up available space in the remaining space
        // between flex items and flex container.
        if (child is RenderBoxModel) {
          double horizontalRemainingSpace;
          double verticalRemainingSpace;
          // Margin auto does not work with negative remaining space.
          double mainAxisRemainingSpace = math.max(0, remainingSpace);
          double crossAxisRemainingSpace = math.max(0, crossAxisContentSize - childCrossAxisExtent);

          if (isHorizontal) {
            horizontalRemainingSpace = mainAxisRemainingSpace;
            verticalRemainingSpace = crossAxisRemainingSpace;
            if (runChild.marginLeftAuto) {
              if (runChild.marginRightAuto) {
                childMainPosition += (horizontalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
                betweenSpace = (horizontalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
              } else {
                childMainPosition += horizontalRemainingSpace / mainAxisMarginAutoChildrenCount;
              }
            }

            if (runChild.marginTopAuto) {
              if (runChild.marginBottomAuto) {
                childCrossPosition = childCrossPosition! + verticalRemainingSpace / 2;
              } else {
                childCrossPosition = childCrossPosition! + verticalRemainingSpace;
              }
            }
          } else {
            horizontalRemainingSpace = crossAxisRemainingSpace;
            verticalRemainingSpace = mainAxisRemainingSpace;
            if (runChild.marginTopAuto) {
              if (runChild.marginBottomAuto) {
                childMainPosition += (verticalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
                betweenSpace = (verticalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
              } else {
                childMainPosition += verticalRemainingSpace / mainAxisMarginAutoChildrenCount;
              }
            }

            if (runChild.marginLeftAuto) {
              if (runChild.marginRightAuto) {
                childCrossPosition = childCrossPosition! + horizontalRemainingSpace / 2;
              } else {
                childCrossPosition = childCrossPosition! + horizontalRemainingSpace;
              }
            }
          }
        }

        // childMainPosition already accounts for size in reversed flow.

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

        // Prepare for next child.
        // Apply the author-specified gap in addition to any justify-content spacing.
        // Spec: the free space for justify-content is computed after subtracting gaps
        // from the available inline-size, but the physical gap remains between items.
        final double effectiveGap = mainAxisGap;

        if (flipMainAxis) {
          // After placing in reversed flow, move past the trailing (end) margin,
          // then account for between-space and gaps.
          childMainPosition -= (childEndMargin + betweenSpace + effectiveGap);
        } else {
          // Normal flow: advance by the child size, trailing margin, between-space and gaps.
          childMainPosition += (childMainSizeOnly + childEndMargin + betweenSpace + effectiveGap);
        }
      }

      // Add cross-axis gap spacing between flex lines
      crossAxisOffset += runCrossAxisExtent + runBetweenSpace + crossAxisGap;
    }
  }

  // Whether need to stretch child in the cross axis according to alignment property and child cross length.
  bool _needToStretchChildCrossSize(RenderBox child) {
    // Position placeholder and BR element has size of zero, so they can not be stretched.
    // The absolutely-positioned box is considered to be “fixed-size”, a value of stretch
    // is treated the same as flex-start.
    // https://www.w3.org/TR/css-flexbox-1/#abspos-items
    RenderBoxModel? childBoxModel;
    if (child is RenderBoxModel) {
      childBoxModel = child;
    } else if (child is RenderEventListener) {
      final RenderBox? listenerChild = child.child;
      if (listenerChild is RenderBoxModel) {
        childBoxModel = listenerChild;
      }
    } else if (child is RenderPositionPlaceholder) {
      childBoxModel = child.positioned;
    }

    if (childBoxModel == null || childBoxModel.renderStyle.isSelfPositioned()) {
      return false;
    }

    final RenderStyle childStyle = childBoxModel.renderStyle;

    final bool hasDefiniteCrossSize = _hasDefiniteContainerCrossSize();

    if (childStyle.isSelfRenderReplaced() && !hasDefiniteCrossSize) {
      return false;
    }

    AlignSelf alignSelf = _getAlignSelf(child);
    bool isChildAlignmentStretch = alignSelf != AlignSelf.auto
        ? alignSelf == AlignSelf.stretch
        : renderStyle.alignItems == AlignItems.stretch;

    if (!isChildAlignmentStretch) {
      return false;
    }

    if (_isChildCrossAxisMarginAutoExist(child)) {
      return false;
    }

    final bool isChildLengthAuto = _isHorizontalFlexDirection
        ? childBoxModel.renderStyle.height.isAuto
        : childBoxModel.renderStyle.width.isAuto;

    if (!isChildLengthAuto) {
      return false;
    }

    // Replaced elements (e.g., <img>) with an intrinsic aspect ratio should not be
    // stretched in the cross axis; browsers keep their border-box proportional even
    // under align-items: stretch. This matches CSS Flexbox §9.4.
    if (_shouldPreserveIntrinsicRatio(childBoxModel, hasDefiniteContainerCross: hasDefiniteCrossSize)) {
      return false;
    }

    return true;
  }

  bool _shouldPreserveIntrinsicRatio(RenderBoxModel child, {required bool hasDefiniteContainerCross}) {
    if (child is! RenderReplaced) {
      return false;
    }
    if (hasDefiniteContainerCross) {
      return false;
    }
    final RenderStyle style = child.renderStyle;
    if (style.aspectRatio != null && style.aspectRatio! > 0) {
      return true;
    }
    final double intrinsicWidth = style.intrinsicWidth;
    final double intrinsicHeight = style.intrinsicHeight;
    return intrinsicWidth > 0 && intrinsicHeight > 0;
  }

  bool _hasDefiniteContainerCrossSize() {
    if (_isHorizontalFlexDirection) {
      if (renderStyle.contentBoxLogicalHeight != null) return true;
      if (contentConstraints != null && contentConstraints!.hasTightHeight) return true;
      if (constraints.hasTightHeight) return true;
      return false;
    } else {
      if (renderStyle.contentBoxLogicalWidth != null) return true;
      if (contentConstraints != null && contentConstraints!.hasTightWidth) return true;
      if (constraints.hasTightWidth) return true;
      return false;
    }
  }

  // Get child stretched size in the cross axis.
  double _getChildStretchedCrossSize(RenderBoxModel child,
      double runCrossAxisExtent,
      double runBetweenSpace,) {
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

    // Ensure stretched height in row-direction is not smaller than the
    // child's vertical padding + border. This preserves expected visuals
    // where large paddings create a 66px-tall box even when the line
    // cross-size is smaller (e.g., 32px). The content box may become
    // negative; we clamp the border-box height to padding+border.
    if (_isHorizontalFlexDirection) {
      final double paddingBorderV =
          child.renderStyle.effectiveBorderTopWidth.computedValue +
              child.renderStyle.effectiveBorderBottomWidth.computedValue +
              child.renderStyle.paddingTop.computedValue +
              child.renderStyle.paddingBottom.computedValue;
      if (childStretchedCrossSize < paddingBorderV) {
        childStretchedCrossSize = paddingBorderV;
      }
    }

    return childStretchedCrossSize;
  }

  // Whether margin auto of child is set in the cross axis.
  bool _isChildCrossAxisMarginAutoExist(RenderBox child) {
    RenderBoxModel? box;
    if (child is RenderBoxModel) {
      box = child;
    } else if (child is RenderEventListener) {
      box = child.child as RenderBoxModel?;
    } else if (child is RenderPositionPlaceholder) {
      box = child.positioned;
    }
    if (box != null) {
      final RenderStyle s = box.renderStyle;
      final CSSLengthValue marginLeft = s.marginLeft;
      final CSSLengthValue marginRight = s.marginRight;
      final CSSLengthValue marginTop = s.marginTop;
      final CSSLengthValue marginBottom = s.marginBottom;
      if (_isHorizontalFlexDirection && (marginTop.isAuto || marginBottom.isAuto)) return true;
      if (!_isHorizontalFlexDirection && (marginLeft.isAuto || marginRight.isAuto)) return true;
    }
    return false;
  }

  // Get flex item cross axis offset by align-items/align-self.
  double? _getChildCrossAxisOffset(String alignment,
      RenderBox child,
      double? childCrossPosition,
      double runBaselineExtent,
      double runCrossAxisExtent,
      double runBetweenSpace,
      double crossAxisStartPadding,
      double crossAxisStartBorder, {
        required double childCrossAxisExtent,
        required double childCrossAxisStartMargin,
        required double childCrossAxisEndMargin,
        required bool hasAutoCrossAxisMargin,
      }) {
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
    // start offset including margin (used by start/end alignment)
    double crossStartAddedOffset = crossAxisStartPadding + crossAxisStartBorder + childCrossAxisStartMargin;
    // start offset without margin (used by center alignment where we center the margin-box itself)
    double crossStartNoMargin = crossAxisStartPadding + crossAxisStartBorder;

    final _FlexContainerInvariants? inv = _layoutInvariants;
    final bool crossIsHorizontal;
    final bool crossStartIsPhysicalStart; // left for horizontal, top for vertical
    if (inv != null) {
      crossIsHorizontal = inv.isCrossAxisHorizontal;
      crossStartIsPhysicalStart = inv.isCrossAxisStartAtPhysicalStart;
    } else {
      // Determine cross axis orientation and where cross-start maps physically.
      final CSSWritingMode wm = renderStyle.writingMode;
      final bool inlineIsHorizontal = (wm == CSSWritingMode.horizontalTb);
      if (renderStyle.flexDirection == FlexDirection.row || renderStyle.flexDirection == FlexDirection.rowReverse) {
        // Cross is block axis.
        crossIsHorizontal = !inlineIsHorizontal;
        if (crossIsHorizontal) {
          // vertical-rl => block-start at right; vertical-lr => left.
          crossStartIsPhysicalStart = (wm == CSSWritingMode.verticalLr);
        } else {
          // horizontal-tb => block-start at top.
          crossStartIsPhysicalStart = true;
        }
      } else {
        // Cross is inline axis.
        crossIsHorizontal = inlineIsHorizontal;
        if (crossIsHorizontal) {
          // Inline-start follows text direction in horizontal-tb.
          crossStartIsPhysicalStart = (renderStyle.direction != TextDirection.rtl);
        } else {
          // Inline-start is physical top in vertical writing modes.
          crossStartIsPhysicalStart = true;
        }
      }
    }

    // Align-items and align-self have no effect if auto margin of child exists in the cross axis.
    if (hasAutoCrossAxisMargin) {
      return crossStartAddedOffset;
    }

    switch (alignment) {
      case 'start':
        if (crossStartIsPhysicalStart) {
          return crossStartAddedOffset;
        } else {
          // Cross-start at right (or bottom): place item flush to that side.
          return crossAxisStartPadding +
              crossAxisStartBorder +
              flexLineCrossSize -
              childCrossAxisExtent +
              childCrossAxisStartMargin;
        }
      case 'end':
        if (crossStartIsPhysicalStart) {
          // Place at cross-end (right or bottom for normal cases)
          return crossAxisStartPadding +
              crossAxisStartBorder +
              flexLineCrossSize -
              childCrossAxisExtent +
              childCrossAxisStartMargin;
        } else {
          // Cross-start at right: cross-end is left
          return crossStartAddedOffset;
        }
      case 'center':
        // Center the child's MARGIN-BOX within the flex line's content box (spec behavior).
        // We first get the child's cross-extent including margins, then derive the
        // border-box extent for overflow heuristics and logging.
        final double childExtentWithMargin = childCrossAxisExtent; // includes margins
        final double startMargin = childCrossAxisStartMargin;
        final double endMargin = childCrossAxisEndMargin;
        final double borderBoxExtent = math.max(0.0, childExtentWithMargin - (startMargin + endMargin));
        // Center within the content box by default (spec-aligned).
        // Additionally, for vertical cross-axes (row direction), if the child overflows
        // the content box (free space < 0) and the container has cross-axis padding,
        // center within the container border-box for better visual centering of padded
        // controls, without affecting non-overflow cases (e.g., footers).
        if (!crossIsHorizontal) {
          // For vertical cross-axes (row direction), when the container has non-zero
          // cross-axis padding or borders and the item overflows the content box,
          // center the item within the container's BORDER-BOX for better visual
          // centering of padded controls. This preserves expected behavior for
          // headers/toolbars where padding defines visual bounds.
          final double padStart = crossAxisStartPadding;
          final double padEnd = inv?.crossAxisPaddingEnd ?? _flowAwareCrossAxisPadding(isEnd: true);
          final double borderStart = crossAxisStartBorder;
          final double borderEnd = inv?.crossAxisBorderEnd ?? renderStyle.effectiveBorderBottomWidth.computedValue;
          final double padBorderSum = padStart + padEnd + borderStart + borderEnd;
          final double freeSpace = flexLineCrossSize - borderBoxExtent;
          if (padBorderSum > 0 && freeSpace <= 0) {
            // Determine container content cross size (definite if set on style),
            // fall back to the current line cross size.
            final double containerContentCross = renderStyle.contentBoxLogicalHeight ?? flexLineCrossSize;
            final double containerBorderCross = containerContentCross + padStart + padEnd + borderStart + borderEnd;
            final double posFromBorder = (containerBorderCross - borderBoxExtent) / 2.0;
            final double pos = posFromBorder; // since offsets are measured from border-start
            return pos.isFinite ? pos : crossStartNoMargin;
          }
        }
        // If the margin-box is equal to or wider than the line cross size, pin to start
        // to avoid introducing cross-axis offset that would create horizontal scroll.
        final double marginBoxExtent = borderBoxExtent + startMargin + endMargin;
        // Only clamp for horizontal cross-axis (i.e., when cross is width), and only when
        // overflow is caused by margins (border-box fits, margin-box overflows). If the
        // border-box itself is wider than the line, we still center (allow negative offset)
        // per Box Alignment overflow handling.
        // Only treat as overflow when the margin-box actually exceeds the line cross size.
        // If it exactly equals, there is no overflow and centering should place the
        // border-box at startMargin (i.e., symmetric gaps), matching browser behavior.
        final bool marginOnlyOverflow = borderBoxExtent <= flexLineCrossSize && marginBoxExtent > flexLineCrossSize;
        if (crossIsHorizontal && marginOnlyOverflow) {
          return crossStartNoMargin;
        }
        // Center the margin-box in the line's content box, then add the start margin
        // to obtain the border-box offset.
        final double freeInContent = flexLineCrossSize - marginBoxExtent;
        final double pos = crossStartNoMargin + freeInContent / 2.0 + startMargin;
        return pos;
      case 'baseline':
      // In column flex-direction (vertical main axis), baseline alignment behaves
      // like flex-start per our layout model. Avoid using runBaselineExtent which
      // is not computed for vertical-main containers.
        if (!_isHorizontalFlexDirection) {
          return crossStartAddedOffset;
        }
        // Distance from top to baseline of child.
        double childAscent = _getChildAscent(child);
        final double offset = crossStartAddedOffset + lineBoxLeading / 2 + (runBaselineExtent - childAscent);
        if (DebugFlags.debugLogFlexBaselineEnabled) {
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
      assert(child != null);
      double? childIntrinsicMainSize = _childrenIntrinsicMainSizes[child!];
      if (_isHorizontalFlexDirection) {
        childSize = Size(childIntrinsicMainSize!, childSize!.height);
      } else {
        childSize = Size(childSize!.width, childIntrinsicMainSize!);
      }
    }
    return childSize;
  }

  // Get distance from the item's cross-start margin edge to its first baseline.
  // For row-direction flex containers (horizontal main axis), this is
  // margin-top + (distance from border-box top to the baseline).
  // If the child provides no baseline, synthesize it from the bottom margin edge.
  double _getChildAscent(RenderBox child) {
    // Prefer CSS-cached baseline computed during the child's own layout.
    double? cssBaselineFromBorderTop;
    if (child is RenderBoxModel) {
      // Unwrap baseline from wrapped content if this is an event listener wrapper.
      if (child is RenderEventListener) {
        final RenderBox? wrapped = child.child;
        if (wrapped is RenderBoxModel) {
          cssBaselineFromBorderTop = wrapped.computeCssFirstBaseline();
          if (DebugFlags.debugLogFlexBaselineEnabled) {
            // ignore: avoid_print
            print('[FlexBaseline] unwrap baseline from child content: '
                '${wrapped.runtimeType}#${wrapped.hashCode} => baseline=${cssBaselineFromBorderTop?.toStringAsFixed(2)}');
          }
        } else {
          cssBaselineFromBorderTop = child.computeCssFirstBaseline();
        }
      } else {
        cssBaselineFromBorderTop = child.computeCssFirstBaseline();
      }
    }

    // Cross-start margins in the flex item's own axis.
    double marginTop = 0;
    double marginBottom = 0;
    if (child is RenderBoxModel) {
      marginTop = child.renderStyle.marginTop.computedValue;
      marginBottom = child.renderStyle.marginBottom.computedValue;
    }

    final Size? childSize = _getChildSize(child);

    // Fallback baseline for boxes without an intrinsic baseline.
    // Bottom margin edge: top-margin + border-box height (+ bottom-margin when used by flow layout baseline).
    final double fallbackFromMarginTop = marginTop + (childSize?.height ?? 0);
    // Compose the final distance from the margin-top edge to the baseline.
    final double extentAboveBaseline = (cssBaselineFromBorderTop != null)
        // Spec: distance from cross-start margin edge to the baseline includes margin-top.
        ? marginTop + cssBaselineFromBorderTop
        // If no baseline, synthesize from bottom margin edge.
        : (parent is RenderFlowLayout
            ? (fallbackFromMarginTop + marginBottom)
            : fallbackFromMarginTop);

    if (DebugFlags.debugLogFlexBaselineEnabled) {
      // ignore: avoid_print
      print('[FlexBaseline] _getChildAscent child='
          '${child.runtimeType}#${child.hashCode} '
          'cssFirstBaseline=${cssBaselineFromBorderTop?.toStringAsFixed(2)} '
          'marginTop=${marginTop.toStringAsFixed(2)} marginBottom=${marginBottom.toStringAsFixed(2)} '
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
}

// Render flex layout with self repaint boundary.
class RenderRepaintBoundaryFlexLayout extends RenderFlexLayout {
  RenderRepaintBoundaryFlexLayout({
    super.children,
    required super.renderStyle,
  });

  @override
  bool get isRepaintBoundary => true;
}
