/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
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
    double marginTop;

    if (effectiveDisplay == CSSDisplay.inline) {
      marginTop = 0;
      return marginTop;
    }

    // Margin collapse does not work on following case:
    // 1. Document root element(HTML)
    // 2. Inline level elements
    // 3. Inner renderBox of element with overflow auto/scroll
    if (isDocumentRootBox() || (effectiveDisplay != CSSDisplay.block && effectiveDisplay != CSSDisplay.flex)) {
      marginTop = this.marginTop.computedValue;
      return marginTop;
    }

    // If there is any previous attached render sibling (including placeholders
    // for positioned elements), do not treat this element as the first in-flow
    // child for parent-top collapsing. This matches the engine’s placeholder
    // approach used to anchor static position of positioned siblings, and
    // preserves expected spacing when a positioned sibling precedes.
    final bool hasPrevInFlow = isPreviousSiblingAreRenderObject();
    if (!hasPrevInFlow) {
      // First in-flow child: may collapse with parent top
      marginTop = _collapsedMarginTopWithParent;
    } else {
      // Subsequent in-flow child: do not collapse with previous sibling here.
      // Parent layout combines prev bottom and this top per spec.
      marginTop = _collapsedMarginTopWithFirstChild;
    }

    return marginTop;
  }

  // The top margin of an in-flow block element collapses with its first in-flow block-level child's
  // top margin if the element has no top border, no top padding, and the child has no clearance.
  double get _collapsedMarginTopWithFirstChild {
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle? renderStyle = getSelfRenderStyle();
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
          // Only collapse with the first in-flow block-level child. Ignore positioned children.
          isFirstChildStyleMatch((rs) =>
              (rs.effectiveDisplay == CSSDisplay.block || rs.effectiveDisplay == CSSDisplay.flex) && !rs.isSelfPositioned())) {
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

  // Expose the element’s own collapsed top ignoring parent collapse.
  // This equals the top margin collapsed with its first in-flow block-level
  // child (descendant) when applicable, but does NOT zero out when this box
  // is the first in-flow child of its parent. Useful for formatting-context
  // run-to-run margin collapsing where the previous content may be an
  // anonymous block rather than a DOM sibling.
  double get collapsedMarginTopIgnoringParent => _collapsedMarginTopWithFirstChild;

  // A box's own margins collapse if the 'min-height' property is zero, and it has neither top or bottom
  // borders nor top or bottom padding, and it has a 'height' of either 0 or 'auto', and it does not
  // contain a line box, and all of its in-flow children's margins (if any) collapse.
  // Make collapsed margin-top to the max of its top and bottom and margin-bottom as 0.
  double get _collapsedMarginTopWithSelf {
    bool isOverflowVisible =
        effectiveOverflowX == CSSOverflowType.visible && effectiveOverflowY == CSSOverflowType.visible;
    bool isOverflowClip = effectiveOverflowX == CSSOverflowType.clip && effectiveOverflowY == CSSOverflowType.clip;
    double marginTop = this.marginTop.computedValue;
    double marginBottom = this.marginBottom.computedValue;

    // Margin top and bottom of empty block collapse.
    // Make collapsed margin-top to the max of its top and bottom and margin-bottom as 0.
    if (isBoxModelHaveSize() &&
        isSelfBoxModelMatch((renderBoxModel, _) => renderBoxModel.boxSize!.height == 0) &&
        effectiveDisplay != CSSDisplay.flex &&
        (isOverflowVisible || isOverflowClip)) {
      return math.max(marginTop, marginBottom);
    }

    return marginTop;
  }

  // The top margin of an in-flow block element collapses with its first in-flow block-level child's
  // top margin if the element has no top border, no top padding, and the child has no clearance.
  // Make margin-top as 0 if margin-top with parent collapse.
  double get _collapsedMarginTopWithParent {
    double marginTop = _collapsedMarginTopWithFirstChild;
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle? parentRenderStyle = getAttachedRenderParentRenderStyle();

    if (parentRenderStyle == null) return 0.0;

    // Flex item guard: a flex item establishes an independent formatting context
    // for its contents. Per CSS Flexbox, margins of a flex item's descendants
    // must not collapse with the flex item itself. If our parent is a flex item
    // (i.e., its own parent is a flex container), do not collapse this element's
    // top margin with that parent.
    if (parentRenderStyle.isParentRenderFlexLayout() || parentRenderStyle.isParentRenderGridLayout()) {
      return marginTop;
    }
    // Positioned parent guard: margins of in-flow children do not collapse
    // with absolutely/fixed positioned ancestors. Preserve the element's own
    // top (already collapsed with its first child), and do not collapse with
    // the positioned parent.
    if (parentRenderStyle.isSelfPositioned()) {
      return marginTop;
    }

    bool isParentOverflowVisible = parentRenderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isParentOverflowClip = parentRenderStyle.effectiveOverflowY == CSSOverflowType.clip;
    bool isParentNotRenderWidget = !parentRenderStyle.isSelfRenderWidget();

    // Margin top of first child with parent which is in flow layout collapse with parent
    // which makes the margin top of itself 0.
    // Margin collapse does not work on document root box.
    if (!isParentDocumentRootBox() &&
        parentRenderStyle.effectiveDisplay == CSSDisplay.block &&
        (isParentOverflowVisible || isParentOverflowClip) &&
        parentRenderStyle.paddingTop.computedValue == 0 &&
        isParentNotRenderWidget &&
        parentRenderStyle.effectiveBorderTopWidth.computedValue == 0 &&
        parentRenderStyle.isParentBoxModelMatch((renderBoxModel, _) => renderBoxModel is RenderFlowLayout || renderBoxModel is RenderLayoutBoxWrapper)) {
      return 0;
    }
    return marginTop;
  }

  // The bottom margin of an in-flow block-level element always collapses with the top margin of its next
  // in-flow block-level sibling, unless that sibling has clearance.
  double get _collapsedMarginTopWithPreSibling {
    // Compute the contribution of this element's margin-top given the previous
    // sibling's collapsed margin-bottom. Since the layout adds the previous
    // sibling's collapsed bottom already, the additional top contribution here
    // should be: collapse(prevBottom, selfTop) - prevBottom.
    double selfTop = _collapsedMarginTopWithFirstChild;
    if (isPreviousSiblingAreRenderObject() &&
        (isPreviousSiblingStyleMatch((renderStyle) =>
            (renderStyle.effectiveDisplay == CSSDisplay.block || renderStyle.effectiveDisplay == CSSDisplay.flex) &&
            !renderStyle.isSelfPositioned()))) {
      double prevBottom = getPreviousSiblingRenderStyle<CSSMarginMixin>()!.collapsedMarginBottom;
      double collapsed;
      if (selfTop >= 0 && prevBottom >= 0) {
        collapsed = math.max(selfTop, prevBottom);
      } else if (selfTop <= 0 && prevBottom <= 0) {
        collapsed = math.min(selfTop, prevBottom);
      } else {
        collapsed = selfTop + prevBottom;
      }
      return collapsed - prevBottom;
    }

    return selfTop;
  }

  // Public accessor for sibling-collapsed top contribution.
  // Returns the effective additional top spacing for this element when placed
  // after its previous in-flow block-level sibling. This equals
  // collapse(prevBottom, selfTop) - prevBottom when a previous sibling exists,
  // otherwise it falls back to this element's own self/first-child collapsed top.
  double get collapsedMarginTopForSibling => _collapsedMarginTopWithPreSibling;

  // Margin bottom of in-flow block-level box which has collapsed margin.
  // https://www.w3.org/TR/CSS2/box.html#collapsing-margins
  double get collapsedMarginBottom {
    double marginBottom;

    // Margin is invalid for inline element.
    if (effectiveDisplay == CSSDisplay.inline) {
      marginBottom = 0;
      return marginBottom;
    }

    // Margin collapse does not work on following case:
    // 1. Document root element(HTML)
    // 2. Inline level elements
    // 3. Inner renderBox of element with overflow auto/scroll
    if (isDocumentRootBox() || (effectiveDisplay != CSSDisplay.block && effectiveDisplay != CSSDisplay.flex)) {
      marginBottom = this.marginBottom.computedValue;
      return marginBottom;
    }

    if (!isNextSiblingAreRenderObject()) {
      // Margin bottom collapse with its parent if it is the last child of its parent and its value is 0.
      marginBottom = _collapsedMarginBottomWithParent;
    } else {
      // Margin bottom collapse with its nested last child when meeting following cases at the same time:
      // 1. No padding, border is set.
      // 2. No height, min-height, max-height is set.
      // 3. No block formatting context of itself (eg. overflow scroll and position absolute) is created.
      marginBottom = _collapsedMarginBottomWithLastChild;
    }

    return marginBottom;
  }

  // Collapsed bottom margin to be used when resolving adjacency with the next
  // in-flow sibling. This value collapses with self and the last in-flow child
  // (descendant) when applicable, but it DOES NOT collapse with the parent.
  //
  // Rationale: Whether a box’s bottom margin collapses with its parent depends
  // on the parent’s context (padding/border/height/overflow) and on whether the
  // box is actually the last in-flow fragment for that parent. Layout is the
  // right place to decide parent collapsing. Using this sibling-oriented value
  // prevents prematurely zeroing out the bottom margin in cases where an
  // anonymous block (from inline content) follows this element.
  double get collapsedMarginBottomForSibling {
    // Start with own collapse-with-self result (empty-block handling), then
    // optionally fold in last-child collapse when eligible.
    RenderStyle? renderStyle = getSelfRenderStyle();
    if (renderStyle == null) return 0.0;

    double marginBottom = _collapsedMarginBottomWithSelf;

    double paddingBottom = renderStyle.paddingBottom.computedValue;
    double borderBottom = renderStyle.effectiveBorderBottomWidth.computedValue;
    bool isOverflowVisible = renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isOverflowClip = renderStyle.effectiveOverflowY == CSSOverflowType.clip;

    if (isLayoutBox() &&
        renderStyle.height.isAuto &&
        renderStyle.minHeight.isAuto &&
        renderStyle.maxHeight.isNone &&
        renderStyle.effectiveDisplay == CSSDisplay.block &&
        (isOverflowVisible || isOverflowClip) &&
        paddingBottom == 0 &&
        borderBottom == 0) {
      if (isLastChildAreRenderBoxModel() &&
          // Only collapse with the last in-flow block-level child. Ignore positioned children.
          isLastChildStyleMatch((rs) =>
              (rs.effectiveDisplay == CSSDisplay.block || rs.effectiveDisplay == CSSDisplay.flex) && !rs.isSelfPositioned())) {
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

  // The bottom margin of an in-flow block box with a 'height' of 'auto' and a 'min-height' of zero collapses
  // with its last in-flow block-level child's bottom margin if the box has no bottom padding and no bottom
  // border and the child's bottom margin does not collapse with a top margin that has clearance.
  double get _collapsedMarginBottomWithLastChild {
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle? renderStyle = getSelfRenderStyle();
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
    RenderStyle? parentRenderStyle = getAttachedRenderParentRenderStyle<CSSMarginMixin>();

    if (parentRenderStyle == null) return 0.0;

    // Flex item guard: when the parent is a flex item (its own parent is a
    // flex container), the child's bottom margin must not collapse with the
    // parent. Preserve the child's bottom margin contribution.
    if (parentRenderStyle.isParentRenderFlexLayout() || parentRenderStyle.isParentRenderGridLayout()) {
      return marginBottom;
    }
    // Positioned parent guard: do not collapse the last in-flow child's bottom
    // margin with an absolutely/fixed positioned parent.
    if (parentRenderStyle.isSelfPositioned()) {
      return marginBottom;
    }

    bool isParentOverflowVisible = parentRenderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isParentOverflowClip = parentRenderStyle.effectiveOverflowY == CSSOverflowType.clip;
    bool isParentNotRenderWidget = !parentRenderStyle.isSelfRenderWidget();

    // Margin bottom of first child with parent which is in flow layout collapse with parent
    // which makes the margin top of itself 0.
    // Margin collapse does not work on document root box.
    if (!isParentDocumentRootBox() &&
        parentRenderStyle.effectiveDisplay == CSSDisplay.block &&
        (isParentOverflowVisible || isParentOverflowClip) &&
        isParentNotRenderWidget &&
        parentRenderStyle.paddingBottom.computedValue == 0 &&
        parentRenderStyle.effectiveBorderBottomWidth.computedValue == 0 &&
        parentRenderStyle.isParentBoxModelMatch((renderBoxModel, _) => renderBoxModel is RenderFlowLayout || renderBoxModel is RenderLayoutBoxWrapper)) {
      return 0;
    }
    return marginBottom;
  }

  void debugMarginProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('margin', margin));
  }
}
