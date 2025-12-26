/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';

mixin CSSPaddingMixin on RenderStyle {
  CSSLengthValue? _normalizePaddingLength(CSSLengthValue? value) {
    if (value == null) return null;
    final double? raw = value.value;
    if (raw != null && raw < 0) return CSSLengthValue.zero;
    return value;
  }

  double _nonNegativePaddingComputedValue(CSSLengthValue value) {
    final double computed = value.computedValue;
    if (!computed.isFinite || computed < 0) return 0;
    return computed;
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  @override
  EdgeInsets get padding {
    EdgeInsets insets = EdgeInsets.only(
      left: _nonNegativePaddingComputedValue(paddingLeft),
      right: _nonNegativePaddingComputedValue(paddingRight),
      bottom: _nonNegativePaddingComputedValue(paddingBottom),
      top: _nonNegativePaddingComputedValue(paddingTop),
    );
    assert(insets.isNonNegative);
    return insets;
  }

  CSSLengthValue? _paddingLeft;
  set paddingLeft(CSSLengthValue? value) {
    value = _normalizePaddingLength(value);
    if (_paddingLeft == value) return;
    _paddingLeft = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingLeft {
    final CSSLengthValue physical = _paddingLeft ?? CSSLengthValue.zero;
    // Logical properties override the corresponding physical side.
    final CSSLengthValue? logical = (direction == TextDirection.rtl) ? _paddingInlineEnd : _paddingInlineStart;
    return logical ?? physical;
  }

  CSSLengthValue? _paddingRight;
  set paddingRight(CSSLengthValue? value) {
    value = _normalizePaddingLength(value);
    if (_paddingRight == value) return;
    _paddingRight = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingRight {
    final CSSLengthValue physical = _paddingRight ?? CSSLengthValue.zero;
    // Logical properties override the corresponding physical side.
    final CSSLengthValue? logical = (direction == TextDirection.rtl) ? _paddingInlineStart : _paddingInlineEnd;
    return logical ?? physical;
  }

  CSSLengthValue? _paddingInlineStart;
  set paddingInlineStart(CSSLengthValue? value) {
    value = _normalizePaddingLength(value);
    if (_paddingInlineStart == value) return;
    _paddingInlineStart = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _paddingInlineEnd;
  set paddingInlineEnd(CSSLengthValue? value) {
    value = _normalizePaddingLength(value);
    if (_paddingInlineEnd == value) return;
    _paddingInlineEnd = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _paddingBottom;
  set paddingBottom(CSSLengthValue? value) {
    value = _normalizePaddingLength(value);
    if (_paddingBottom == value) return;
    _paddingBottom = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingBottom => _normalizePaddingLength(_paddingBottom) ?? CSSLengthValue.zero;

  CSSLengthValue? _paddingTop;
  set paddingTop(CSSLengthValue? value) {
    value = _normalizePaddingLength(value);
    if (_paddingTop == value) return;
    _paddingTop = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingTop => _normalizePaddingLength(_paddingTop) ?? CSSLengthValue.zero;

  void _markSelfAndParentNeedsLayout() {
    markNeedsLayout();
    // Sizing may affect parent size, mark parent as needsLayout in case
    // renderBoxModel has tight constraints which will prevent parent from marking.
    if (isParentRenderBoxModel()) {
      markParentNeedsLayout();
    }
  }

  BoxConstraints deflatePaddingConstraints(BoxConstraints constraints) {
    return constraints.deflate(padding);
  }

  BoxConstraints deflateMarginConstraints(BoxConstraints constraints) {
    return constraints.deflate(margin);
  }

  Size wrapPaddingSize(Size innerSize) {
    return Size(
      _nonNegativePaddingComputedValue(paddingLeft) + innerSize.width + _nonNegativePaddingComputedValue(paddingRight),
      _nonNegativePaddingComputedValue(paddingTop) + innerSize.height + _nonNegativePaddingComputedValue(paddingBottom),
    );
  }

  Size wrapPaddingSizeRight(Size innerSize) {
    return Size(
      innerSize.width + _nonNegativePaddingComputedValue(paddingRight),
      _nonNegativePaddingComputedValue(paddingTop) + innerSize.height + _nonNegativePaddingComputedValue(paddingBottom),
    );
  }
  void debugPaddingProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('padding', padding));
  }
}
