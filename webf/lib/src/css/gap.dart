/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

// CSS Gap: https://drafts.csswg.org/css-align-3/#gap-shorthand

mixin CSSGapMixin on RenderStyle {
  @override
  CSSLengthValue get rowGap => _rowGap ?? CSSLengthValue.normal;
  CSSLengthValue? _rowGap;
  set rowGap(CSSLengthValue? value) {
    // Negative value is invalid.
    if ((value != null && ((value.value != null && value.value! < 0))) || _rowGap == value) {
      return;
    }
    _rowGap = value;
    if (isSelfRenderFlexLayout() || isSelfRenderGridLayout()) {
      markNeedsLayout();
    }
  }

  @override
  CSSLengthValue get columnGap => _columnGap ?? CSSLengthValue.normal;
  CSSLengthValue? _columnGap;
  set columnGap(CSSLengthValue? value) {
    // Negative value is invalid.
    if ((value != null && ((value.value != null && value.value! < 0))) || _columnGap == value) {
      return;
    }
    _columnGap = value;
    if (isSelfRenderFlexLayout() || isSelfRenderGridLayout()) {
      markNeedsLayout();
    }
  }

  @override
  CSSLengthValue get gap => _gap ?? CSSLengthValue.normal;
  CSSLengthValue? _gap;
  set gap(CSSLengthValue? value) {
    // Negative value is invalid.
    if ((value != null && ((value.value != null && value.value! < 0))) || _gap == value) {
      return;
    }
    _gap = value;
    if (isSelfRenderFlexLayout() || isSelfRenderGridLayout()) {
      markNeedsLayout();
    }
  }

  static CSSLengthValue resolveGap(String gap, {RenderStyle? renderStyle}) {
    if (gap == 'normal') {
      return CSSLengthValue.normal;
    }
    return CSSLength.parseLength(gap, renderStyle);
  }
}

class CSSGap {
  static bool isValidGapValue(String val) {
    return val == 'normal' || CSSLength.isLength(val);
  }
}
