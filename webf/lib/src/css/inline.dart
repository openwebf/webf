/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// https://www.w3.org/TR/css-inline-3/

import 'package:webf/css.dart';

/// Sets vertical alignment of an inline, inline-block
enum VerticalAlign {
  /// Aligns the baseline of the element with the baseline of its parent.
  baseline,

  /// Aligns the top of the element and its descendants with the top of the entire line.
  top,

  /// Aligns the bottom of the element and its descendants with the bottom of the entire line.
  bottom,

  /// Aligns the middle of the element with the baseline plus half the x-height of the parent.
  middle,

  /// Aligns the bottom of the element with the bottom of the parent element's font.
  textBottom,
  /// Aligns the top of the element with the top of the parent element's font.
  textTop
}

mixin CSSInlineMixin on RenderStyle {
  @override
  VerticalAlign get verticalAlign => _verticalAlign ?? VerticalAlign.baseline;
  VerticalAlign? _verticalAlign;
  set verticalAlign(VerticalAlign? value) {
    if (_verticalAlign != value) {
      _verticalAlign = value;
      markNeedsLayout();
    }
  }

  static VerticalAlign resolveVerticalAlign(String verticalAlign) {
    switch (verticalAlign) {
      case 'super':
        return VerticalAlign.textTop;
      case 'sub':
        return VerticalAlign.textBottom;
      case TOP:
        return VerticalAlign.top;
      case BOTTOM:
        return VerticalAlign.bottom;
      case MIDDLE:
        return VerticalAlign.middle;
      case TEXT_BOTTOM:
        return VerticalAlign.textBottom;
      case TEXT_TOP:
        return VerticalAlign.textTop;
    }
    return VerticalAlign.baseline;
  }
}
