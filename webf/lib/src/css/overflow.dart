/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';

// CSS Overflow: https://drafts.csswg.org/css-overflow-3/

enum CSSOverflowType { auto, visible, hidden, scroll, clip }

// Styles which need to copy from outer scrolling box to inner scrolling content box.
// ignore: unused_element
List<String> _scrollingContentBoxCopyStyles = [
  DISPLAY,
  LINE_HEIGHT,
  TEXT_ALIGN,
  WHITE_SPACE,
  FLEX_DIRECTION,
  FLEX_WRAP,
  ALIGN_CONTENT,
  ALIGN_ITEMS,
  ALIGN_SELF,
  JUSTIFY_CONTENT,
  COLOR,
  TEXT_DECORATION_LINE,
  TEXT_DECORATION_COLOR,
  TEXT_DECORATION_STYLE,
  FONT_WEIGHT,
  FONT_STYLE,
  FONT_FAMILY,
  FONT_SIZE,
  LETTER_SPACING,
  WORD_SPACING,
  TEXT_SHADOW,
  TEXT_OVERFLOW,
  LINE_CLAMP,
];

mixin CSSOverflowMixin on RenderStyle {
  @override
  CSSOverflowType get overflowX => _overflowX ?? CSSOverflowType.visible;
  CSSOverflowType? _overflowX;

  set overflowX(CSSOverflowType? value) {
    if (_overflowX == value) return;
    _overflowX = value;
  }

  @override
  CSSOverflowType get overflowY => _overflowY ?? CSSOverflowType.visible;
  CSSOverflowType? _overflowY;

  set overflowY(CSSOverflowType? value) {
    if (_overflowY == value) return;
    _overflowY = value;
  }

  // As specified, except with visible/clip computing to auto/hidden (respectively)
  // if one of overflow-x or overflow-y is neither visible nor clip.
  // https://www.w3.org/TR/css-overflow-3/#propdef-overflow-x
  @override
  CSSOverflowType get effectiveOverflowX {
    if (overflowX == CSSOverflowType.visible && overflowY != CSSOverflowType.visible) {
      return CSSOverflowType.auto;
    }
    if (overflowX == CSSOverflowType.clip && overflowY != CSSOverflowType.clip) {
      return CSSOverflowType.hidden;
    }
    return overflowX;
  }

  // As specified, except with visible/clip computing to auto/hidden (respectively)
  // if one of overflow-x or overflow-y is neither visible nor clip.
  // https://www.w3.org/TR/css-overflow-3/#propdef-overflow-y
  @override
  CSSOverflowType get effectiveOverflowY {
    if (overflowY == CSSOverflowType.visible && overflowX != CSSOverflowType.visible) {
      return CSSOverflowType.auto;
    }
    if (overflowY == CSSOverflowType.clip && overflowX != CSSOverflowType.clip) {
      return CSSOverflowType.hidden;
    }
    return overflowY;
  }

  static CSSOverflowType resolveOverflowType(String definition) {
    switch (definition) {
      case HIDDEN:
        return CSSOverflowType.hidden;
      case SCROLL:
        return CSSOverflowType.scroll;
      case AUTO:
        return CSSOverflowType.auto;
      case CLIP:
        return CSSOverflowType.clip;
      case VISIBLE:
      default:
        return CSSOverflowType.visible;
    }
  }
}

mixin ElementOverflowMixin on ElementBase {
  // The duration time for element scrolling to a significant place.
  static const SCROLL_DURATION = Duration(milliseconds: 250);

  flutter.ScrollController? scrollControllerX;
  flutter.ScrollController? scrollControllerY;

  double get scrollTop {
    ownerDocument.forceRebuild();
    if (scrollControllerY != null) {
      return scrollControllerY?.position.pixels ?? 0;
    }

    return 0.0;
  }

  set scrollTop(double value) {
    _scrollTo(y: value);
  }

  void scroll(double x, double y, [bool withAnimation = false]) {
    ownerDocument.forceRebuild();
    _scrollTo(x: x, y: y, withAnimation: withAnimation);
  }

  void scrollBy(double x, double y, [bool withAnimation = false]) {
    ownerDocument.forceRebuild();
    _scrollBy(dx: x, dy: y, withAnimation: withAnimation);
  }

  void scrollTo(double x, double y, [bool withAnimation = false]) {
    ownerDocument.forceRebuild();
    _scrollTo(x: x, y: y, withAnimation: withAnimation);
  }

  void _ensureRenderObjectHasLayout() {
    if (renderStyle.getSelfRenderBoxValue((renderBoxModel, _) => renderBoxModel.needsLayout) == true) {
      RendererBinding.instance.rootPipelineOwner.flushLayout();
    }
  }

  double get scrollLeft {
    ownerDocument.forceRebuild();

    return scrollControllerX?.position.pixels ?? 0;
  }

  set scrollLeft(double value) {
    _scrollTo(x: value);
  }

  double get scrollHeight {
    ownerDocument.forceRebuild();
    if (!isRendererAttached) {
      return 0.0;
    }
    _ensureRenderObjectHasLayout();

    flutter.ScrollController? scrollController = scrollControllerY;

    if (scrollController != null) {
      // Viewport height + maxScrollExtent
      return renderStyle.clientHeight()! + scrollController.position.maxScrollExtent;
    }

    Size scrollContainerSize = renderStyle.scrollableSize()!;
    return scrollContainerSize.height;
  }

  double get scrollWidth {
    ownerDocument.forceRebuild();
    if (!isRendererAttached) {
      return 0.0;
    }
    _ensureRenderObjectHasLayout();
    flutter.ScrollController? scrollController = scrollControllerX;

    if (scrollController != null) {
      return renderStyle.clientWidth()! + scrollController.position.maxScrollExtent;
    }
    Size scrollContainerSize = renderStyle.scrollableSize()!;
    return scrollContainerSize.width;
  }

  String get dir {
    return 'ltr';
  }

  double get clientTop {
    ownerDocument.forceRebuild();
    _ensureRenderObjectHasLayout();
    return renderStyle.effectiveBorderTopWidth.computedValue;
  }

  double get clientLeft {
    ownerDocument.forceRebuild();
    _ensureRenderObjectHasLayout();
    return renderStyle.effectiveBorderLeftWidth.computedValue;
  }

  double get clientWidth {
    ownerDocument.forceRebuild();
    _ensureRenderObjectHasLayout();
    return renderStyle.clientWidth() ?? 0.0;
  }

  double get clientHeight {
    ownerDocument.forceRebuild();
    _ensureRenderObjectHasLayout();
    return renderStyle.clientHeight() ?? 0.0;
  }

  double get offsetWidth {
    ownerDocument.forceRebuild();
    _ensureRenderObjectHasLayout();
    if (!renderStyle.hasRenderBox()) return 0;
    return renderStyle.getSelfRenderBoxValue((renderBox, _) => renderBox.hasSize ? renderBox.size.width : 0.0);
  }

  double get offsetHeight {
    ownerDocument.forceRebuild();
    _ensureRenderObjectHasLayout();
    if (!renderStyle.hasRenderBox()) return 0;
    return renderStyle.getSelfRenderBoxValue((renderBox, _) => renderBox.hasSize ? renderBox.size.height : 0.0);
  }

  void _scrollBy({double dx = 0.0, double dy = 0.0, bool? withAnimation}) {
    if (dx != 0) {
      _scroll(scrollLeft + dx, Axis.horizontal, withAnimation: withAnimation);
    }
    if (dy != 0) {
      _scroll(scrollTop + dy, Axis.vertical, withAnimation: withAnimation);
    }
  }

  void _scrollTo({double? x, double? y, bool? withAnimation}) {
    if (x != null) {
      _scroll(x, Axis.horizontal, withAnimation: withAnimation);
    }

    if (y != null) {
      _scroll(y, Axis.vertical, withAnimation: withAnimation);
    }
  }

  void _scroll(num aim, Axis direction, {bool? withAnimation = false}) {
    if (attachedRenderer == null) return;

    flutter.ScrollController? scrollController = direction == Axis.horizontal ? scrollControllerX : scrollControllerY;

    if (scrollController == null) return;

    double distance = aim.toDouble();

    // Apply scroll effect after layout.
    assert(isRendererAttached, 'Overflow can only be added to a RenderBox.');
    RendererBinding.instance.rootPipelineOwner.flushLayout();

    scrollController.position.moveTo(
      distance,
      duration: withAnimation == true ? SCROLL_DURATION : null,
      curve: withAnimation == true ? Curves.easeOut : null,
    );
  }
}
