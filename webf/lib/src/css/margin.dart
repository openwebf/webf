/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

mixin CSSMarginMixin on RenderStyle {
  /// The amount to margin the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  @override
  EdgeInsets get margin {
    EdgeInsets insets = EdgeInsets.only(
            left: marginLeft.computedValue,
            right: marginRight.computedValue,
            bottom: marginBottom.computedValue,
            top: marginTop.computedValue)
        .resolve(TextDirection.ltr);
    return insets;
  }

  CSSLengthValue? _marginLeft;

  set marginLeft(CSSLengthValue? value) {
    if (_marginLeft == value) return;
    _marginLeft = value;
    markSelfAndParentBoxModelNeedsLayout();
  }

  @override
  CSSLengthValue get marginLeft => _marginLeft ?? CSSLengthValue.zero;

  CSSLengthValue? _marginRight;

  set marginRight(CSSLengthValue? value) {
    if (_marginRight == value) return;
    _marginRight = value;
    markSelfAndParentBoxModelNeedsLayout();
  }

  @override
  CSSLengthValue get marginRight => _marginRight ?? CSSLengthValue.zero;

  CSSLengthValue? _marginBottom;

  set marginBottom(CSSLengthValue? value) {
    if (_marginBottom == value) return;
    _marginBottom = value;
    markSelfAndParentBoxModelNeedsLayout();
  }

  @override
  CSSLengthValue get marginBottom => _marginBottom ?? CSSLengthValue.zero;

  CSSLengthValue? _marginTop;

  set marginTop(CSSLengthValue? value) {
    if (_marginTop == value) return;
    _marginTop = value;
    markSelfAndParentBoxModelNeedsLayout();
  }

  @override
  CSSLengthValue get marginTop => _marginTop ?? CSSLengthValue.zero;

  // Margin top of in-flow block-level box which has collapsed margin.
  // https://www.w3.org/TR/CSS2/box.html#collapsing-margins
  double get collapsedMarginTop {
    String propertyName = 'collapsedMarginTop';

    // Use cached value if exits.
    double? cachedValue = getCachedComputedValue(this, propertyName);
    if (cachedValue != null) {
      return cachedValue;
    }

    double _marginTop;

    if (effectiveDisplay == CSSDisplay.inline) {
      _marginTop = 0;
      // Cache computed value.
      cacheComputedValue(this, propertyName, _marginTop);
      return _marginTop;
    }

    // Margin collapse does not work on following case:
    // 1. Document root element(HTML)
    // 2. Inline level elements
    // 3. Inner renderBox of element with overflow auto/scroll
    if (isDocumentRootBox() || (effectiveDisplay != CSSDisplay.block && effectiveDisplay != CSSDisplay.flex)) {
      _marginTop = marginTop.computedValue;
      // Cache computed value.
      cacheComputedValue(this, propertyName, _marginTop);
      return _marginTop;
    }

    if (!isPreviousSiblingAreRenderBoxModel()) {
      // Margin top collapse with its parent if it is the first child of its parent and its value is 0.
      _marginTop = _collapsedMarginTopWithParent;
    } else {
      // Margin top collapse with margin-bottom of its previous sibling, get the difference between
      // the margin top of itself and the margin bottom of ite previous sibling. Set it to 0 if the
      // difference is negative.
      _marginTop = _collapsedMarginTopWithPreSibling;
    }

    // Cache computed value.
    cacheComputedValue(this, propertyName, _marginTop);
    return _marginTop;
  }

  // The top margin of an in-flow block element collapses with its first in-flow block-level child's
  // top margin if the element has no top border, no top padding, and the child has no clearance.
  double get _collapsedMarginTopWithFirstChild {
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle? renderStyle = isScrollingContentBox() ? getParentRenderStyle() : getSelfRenderStyle();
    if (renderStyle == null) return 0.0;

    double paddingTop = renderStyle.paddingTop.computedValue;
    double borderTop = renderStyle.effectiveBorderTopWidth.computedValue;
    // Use own renderStyle of margin-top cause scrollingContentBox has margin-top of 0
    // which is correct.
    double marginTop = _collapsedMarginTopWithSelf;

    bool isOverflowVisible = renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isOverflowClip = renderStyle.effectiveOverflowY == CSSOverflowType.clip;

    if (renderStyle.isLayoutBox() &&
        renderStyle.effectiveDisplay == CSSDisplay.block &&
        (isOverflowVisible || isOverflowClip) &&
        paddingTop == 0 &&
        borderTop == 0) {
      if (isFirstChildAreRenderBoxModel() &&
          (isFirstChildStyleMatch((renderStyle) =>
              renderStyle.effectiveDisplay == CSSDisplay.block || renderStyle.effectiveDisplay == CSSDisplay.flex))) {
        double childMarginTop = isFirstChildAreRenderFlowLayoutBox()
            ? getFirstChildRenderStyle<CSSMarginMixin>()!._collapsedMarginTopWithFirstChild
            : getFirstChildRenderStyle()!.marginTop.computedValue;
        if (marginTop < 0 && childMarginTop < 0) {
          return math.min(marginTop, childMarginTop);
        } else if (marginTop > 0 && childMarginTop > 0) {
          return math.max(marginTop, childMarginTop);
        } else {
          return marginTop + childMarginTop;
        }
      }
    }
    return marginTop;
  }

  // A box's own margins collapse if the 'min-height' property is zero, and it has neither top or bottom
  // borders nor top or bottom padding, and it has a 'height' of either 0 or 'auto', and it does not
  // contain a line box, and all of its in-flow children's margins (if any) collapse.
  // Make collapsed margin-top to the max of its top and bottom and margin-bottom as 0.
  double get _collapsedMarginTopWithSelf {
    bool isOverflowVisible =
        effectiveOverflowX == CSSOverflowType.visible && effectiveOverflowY == CSSOverflowType.visible;
    bool isOverflowClip = effectiveOverflowX == CSSOverflowType.clip && effectiveOverflowY == CSSOverflowType.clip;
    double _marginTop = marginTop.computedValue;
    double _marginBottom = marginBottom.computedValue;

    // Margin top and bottom of empty block collapse.
    // Make collapsed margin-top to the max of its top and bottom and margin-bottom as 0.
    if (isBoxModelHaveSize() &&
        isSelfBoxModelMatch((renderBoxModel, _) => renderBoxModel.boxSize!.height == 0) &&
        effectiveDisplay != CSSDisplay.flex &&
        (isOverflowVisible || isOverflowClip)) {
      return math.max(_marginTop, _marginBottom);
    }

    return _marginTop;
  }

  // The top margin of an in-flow block element collapses with its first in-flow block-level child's
  // top margin if the element has no top border, no top padding, and the child has no clearance.
  // Make margin-top as 0 if margin-top with parent collapse.
  double get _collapsedMarginTopWithParent {
    double marginTop = _collapsedMarginTopWithFirstChild;
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle? parentRenderStyle = getParentRenderStyle();
    if (parentRenderStyle == null) return 0.0;

    bool isParentOverflowVisible = parentRenderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isParentOverflowClip = parentRenderStyle.effectiveOverflowY == CSSOverflowType.clip;

    // Margin top of first child with parent which is in flow layout collapse with parent
    // which makes the margin top of itself 0.
    // Margin collapse does not work on document root box.
    if (!isParentDocumentRootBox() &&
        parentRenderStyle.effectiveDisplay == CSSDisplay.block &&
        (isParentOverflowVisible || isParentOverflowClip) &&
        parentRenderStyle.paddingTop.computedValue == 0 &&
        parentRenderStyle.effectiveBorderTopWidth.computedValue == 0 &&
        parentRenderStyle.isParentBoxModelMatch((renderBoxModel, _) => renderBoxModel is RenderFlowLayout)) {
      return 0;
    }
    return marginTop;
  }

  // The bottom margin of an in-flow block-level element always collapses with the top margin of its next
  // in-flow block-level sibling, unless that sibling has clearance.
  double get _collapsedMarginTopWithPreSibling {
    double marginTop = _collapsedMarginTopWithFirstChild;
    if (isPreviousSiblingAreRenderBoxModel() &&
        (isPreviousSiblingStyleMatch((renderStyle) =>
            renderStyle.effectiveDisplay == CSSDisplay.block || renderStyle.effectiveDisplay == CSSDisplay.flex))) {
      double preSiblingMarginBottom = getPreviousSiblingRenderStyle<CSSMarginMixin>()!.collapsedMarginBottom;
      if (marginTop > 0 && preSiblingMarginBottom > 0) {
        return math.max(marginTop - preSiblingMarginBottom, 0);
      }
    }

    return marginTop;
  }

  // Margin bottom of in-flow block-level box which has collapsed margin.
  // https://www.w3.org/TR/CSS2/box.html#collapsing-margins
  double get collapsedMarginBottom {
    String propertyName = 'collapsedMarginBottom';

    // Use cached value if exits.
    double? cachedValue = getCachedComputedValue(this, propertyName);
    if (cachedValue != null) {
      return cachedValue;
    }

    double _marginBottom;

    // Margin is invalid for inline element.
    if (effectiveDisplay == CSSDisplay.inline) {
      _marginBottom = 0;
      // Cache computed value.
      cacheComputedValue(this, propertyName, _marginBottom);
      return _marginBottom;
    }

    // Margin collapse does not work on following case:
    // 1. Document root element(HTML)
    // 2. Inline level elements
    // 3. Inner renderBox of element with overflow auto/scroll
    if (isDocumentRootBox() || (effectiveDisplay != CSSDisplay.block && effectiveDisplay != CSSDisplay.flex)) {
      _marginBottom = marginBottom.computedValue;
      // Cache computed value.
      cacheComputedValue(this, propertyName, _marginBottom);
      return _marginBottom;
    }

    bool nextSiblingIsRenderBoxModel = isNextSiblingAreRenderBoxModel();

    if (!nextSiblingIsRenderBoxModel) {
      // Margin bottom collapse with its parent if it is the last child of its parent and its value is 0.
      _marginBottom = _collapsedMarginBottomWithParent;
    } else {
      // Margin bottom collapse with its nested last child when meeting following cases at the same time:
      // 1. No padding, border is set.
      // 2. No height, min-height, max-height is set.
      // 3. No block formatting context of itself (eg. overflow scroll and position absolute) is created.
      _marginBottom = _collapsedMarginBottomWithLastChild;
    }

    // Cache computed value.
    cacheComputedValue(this, propertyName, _marginBottom);
    return _marginBottom;
  }

  // The bottom margin of an in-flow block box with a 'height' of 'auto' and a 'min-height' of zero collapses
  // with its last in-flow block-level child's bottom margin if the box has no bottom padding and no bottom
  // border and the child's bottom margin does not collapse with a top margin that has clearance.
  double get _collapsedMarginBottomWithLastChild {
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle? renderStyle = isScrollingContentBox() ? getParentRenderStyle() : getSelfRenderStyle();
    if (renderStyle == null) return 0.0;
    double paddingBottom = renderStyle.paddingBottom.computedValue;
    double borderBottom = renderStyle.effectiveBorderBottomWidth.computedValue;
    bool isOverflowVisible = renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isOverflowClip = renderStyle.effectiveOverflowY == CSSOverflowType.clip;

    // Use own renderStyle of margin-top cause scrollingContentBox has margin-bottom of 0
    // which is correct.
    double marginBottom = _collapsedMarginBottomWithSelf;

    if (isLayoutBox() &&
        renderStyle.height.isAuto &&
        renderStyle.minHeight.isAuto &&
        renderStyle.maxHeight.isNone &&
        renderStyle.effectiveDisplay == CSSDisplay.block &&
        (isOverflowVisible || isOverflowClip) &&
        paddingBottom == 0 &&
        borderBottom == 0) {
      if (isLastChildAreRenderBoxModel() &&
          isLastChildStyleMatch((renderStyle) =>
              renderStyle.effectiveDisplay == CSSDisplay.block || renderStyle.effectiveDisplay == CSSDisplay.flex)) {
        double childMarginBottom = isLastChildAreRenderLayoutBox()
            ? getLastChildRenderStyle<CSSMarginMixin>()!._collapsedMarginBottomWithLastChild
            : getLastChildRenderStyle<CSSMarginMixin>()!.marginBottom.computedValue;
        if (marginBottom < 0 && childMarginBottom < 0) {
          return math.min(marginBottom, childMarginBottom);
        } else if (marginBottom > 0 && childMarginBottom > 0) {
          return math.max(marginBottom, childMarginBottom);
        } else {
          return marginBottom + childMarginBottom;
        }
      }
    }

    return marginBottom;
  }

  // A box's own margins collapse if the 'min-height' property is zero, and it has neither top or bottom
  // borders nor top or bottom padding, and it has a 'height' of either 0 or 'auto', and it does not
  // contain a line box, and all of its in-flow children's margins (if any) collapse.
  // Make collapsed margin-top to the max of its top and bottom and margin-bottom as 0.
  double get _collapsedMarginBottomWithSelf {
    bool isOverflowVisible =
        effectiveOverflowX == CSSOverflowType.visible && effectiveOverflowY == CSSOverflowType.visible;
    bool isOverflowClip = effectiveOverflowX == CSSOverflowType.clip && effectiveOverflowY == CSSOverflowType.clip;

    // Margin top and bottom of empty block collapse.
    // Make collapsed margin-top to the max of its top and bottom and margin-bottom as 0.
    if (isBoxModelHaveSize() &&
        isSelfBoxModelMatch((renderBoxModel, _) => renderBoxModel.boxSize!.height == 0) &&
        effectiveDisplay != CSSDisplay.flex &&
        (isOverflowVisible || isOverflowClip)) {
      return 0;
    }
    return marginBottom.computedValue;
  }

  // The bottom margin of an in-flow block box with a 'height' of 'auto' and a 'min-height' of zero collapses
  // with its last in-flow block-level child's bottom margin if the box has no bottom padding and no bottom
  // border and the child's bottom margin does not collapse with a top margin that has clearance.
  // Make margin-bottom as 0 if margin-bottom with parent collapse.
  double get _collapsedMarginBottomWithParent {
    double marginBottom = _collapsedMarginBottomWithLastChild;
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle? parentRenderStyle = isParentScrollingContentBox()
        ? getParentRenderStyle<CSSMarginMixin>()?.getParentRenderStyle<CSSMarginMixin>()
        : getParentRenderStyle<CSSMarginMixin>();

    if (parentRenderStyle == null) return 0.0;

    bool isParentOverflowVisible = parentRenderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isParentOverflowClip = parentRenderStyle.effectiveOverflowY == CSSOverflowType.clip;
    // Margin bottom of first child with parent which is in flow layout collapse with parent
    // which makes the margin top of itself 0.
    // Margin collapse does not work on document root box.
    if (!isParentDocumentRootBox() &&
        parentRenderStyle.effectiveDisplay == CSSDisplay.block &&
        (isParentOverflowVisible || isParentOverflowClip) &&
        parentRenderStyle.paddingBottom.computedValue == 0 &&
        parentRenderStyle.effectiveBorderBottomWidth.computedValue == 0 &&
        parentRenderStyle.isParentBoxModelMatch((renderBoxModel, _) => renderBoxModel is RenderFlowLayout)) {
      return 0;
    }
    return marginBottom;
  }

  void debugMarginProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('margin', margin));
  }
}
