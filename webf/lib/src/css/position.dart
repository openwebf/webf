/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';

enum CSSPositionType {
  static,
  relative,
  absolute,
  fixed,
  sticky,
}

mixin CSSPositionMixin on RenderStyle {
  static const CSSPositionType DEFAULT_POSITION_TYPE = CSSPositionType.static;

  // https://drafts.csswg.org/css-position/#insets
  // Name: top, right, bottom, left
  // Value: auto | <length-percentage>
  // Initial: auto
  // Applies to: positioned elements
  // Inherited: no
  // Percentages: refer to size of containing block; see prose
  // Computed value: the keyword auto or a computed <length-percentage> value
  // Canonical order: per grammar
  // Animation type: by computed value type
  @override
  CSSLengthValue get top => _top ?? CSSLengthValue.auto;
  CSSLengthValue? _top;
  set top(CSSLengthValue? value) {
    if (_top == value) {
      return;
    }
    _top = value;
    _markContainingBlockNeedsLayout();
  }

  @override
  CSSLengthValue get bottom => _bottom ?? CSSLengthValue.auto;
  CSSLengthValue? _bottom;
  set bottom(CSSLengthValue? value) {
    if (_bottom == value) {
      return;
    }
    _bottom = value;
    _markContainingBlockNeedsLayout();
  }

  @override
  CSSLengthValue get left => _left ?? CSSLengthValue.auto;
  CSSLengthValue? _left;
  set left(CSSLengthValue? value) {
    if (_left == value) {
      return;
    }
    _left = value;
    _markContainingBlockNeedsLayout();
  }

  @override
  CSSLengthValue get right => _right ?? CSSLengthValue.auto;
  CSSLengthValue? _right;
  set right(CSSLengthValue? value) {
    if (_right == value) {
      return;
    }
    _right = value;
    _markContainingBlockNeedsLayout();
  }

  // The z-index property specifies the stack order of an element.
  // Only works on positioned elements(position: absolute/relative/fixed).
  int? _zIndex;

  @override
  int? get zIndex => _zIndex;

  set zIndex(int? value) {
    if (_zIndex == value) return;
    _zIndex = value;
    _markNeedsSort();
    _markParentNeedsPaint();
  }

  @override
  CSSPositionType get position => _position ?? DEFAULT_POSITION_TYPE;
  CSSPositionType? _position;
  set position(CSSPositionType? value) {
    if (_position == value) return;
    _position = value;

    // Position effect the stacking context.
    _markNeedsSort();
    _markContainingBlockNeedsLayout();
    // Position change may affect transformed display
    // https://www.w3.org/TR/css-display-3/#transformations

    // The position changes of the node may affect the whitespace of the nextSibling and previousSibling text node so prev and next node require layout.
    markAdjacentRenderParagraphNeedsLayout();
  }

  void _markNeedsSort() {
    if (isSelfParentDataAreRenderLayoutParentData()) {
      if (isParentRenderLayoutBox()) {
        markParentNeedsSort();
      }
    }
  }

  // Mark parent render object to layout.
  // If force to true, ignoring current position type judgement of static, useful for updating position type.
  void _markContainingBlockNeedsLayout() {
    // Should mark positioned element's containing block needs layout directly
    // cause RelayoutBoundary of positioned element will prevent the needsLayout flag
    // to bubble up in the RenderObject tree.
    Element? containingBlock = target.getContainingBlockElement();
    containingBlock?.renderStyle.markNeedsLayout();
  }

  void _markParentNeedsPaint() {
    // Should mark positioned element's containing block needs layout directly
    // cause RepaintBoundary of positioned element will prevent the needsLayout flag
    // to bubble up in the RenderObject tree.
    if (isSelfParentDataAreRenderLayoutParentData()) {
      RenderStyle renderStyle = this;
      RenderStyle? parentRenderStyle = renderStyle.getParentRenderStyle();
      // The z-index CSS property sets the z-order of a positioned element and its descendants or flex items.
      if (renderStyle.position != DEFAULT_POSITION_TYPE ||
          parentRenderStyle?.effectiveDisplay == CSSDisplay.flex ||
          parentRenderStyle?.effectiveDisplay == CSSDisplay.inlineFlex) {
        markParentNeedsLayout();
      }
    }
  }

  static CSSPositionType resolvePositionType(String? input) {
    switch (input) {
      case RELATIVE:
        return CSSPositionType.relative;
      case ABSOLUTE:
        return CSSPositionType.absolute;
      case FIXED:
        return CSSPositionType.fixed;
      case STICKY:
        return CSSPositionType.sticky;
      default:
        return CSSPositionType.static;
    }
  }
}
