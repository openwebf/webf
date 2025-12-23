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
  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  @override
  EdgeInsets get padding {
    EdgeInsets insets = EdgeInsets.only(
        left: paddingLeft.computedValue,
        right: paddingRight.computedValue,
        bottom: paddingBottom.computedValue,
        top: paddingTop.computedValue);
    assert(insets.isNonNegative);
    return insets;
  }

  CSSLengthValue? _paddingLeft;
  set paddingLeft(CSSLengthValue? value) {
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
    if (_paddingInlineStart == value) return;
    _paddingInlineStart = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _paddingInlineEnd;
  set paddingInlineEnd(CSSLengthValue? value) {
    if (_paddingInlineEnd == value) return;
    _paddingInlineEnd = value;
    _markSelfAndParentNeedsLayout();
  }

  CSSLengthValue? _paddingBottom;
  set paddingBottom(CSSLengthValue? value) {
    if (_paddingBottom == value) return;
    _paddingBottom = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingBottom => _paddingBottom ?? CSSLengthValue.zero;

  CSSLengthValue? _paddingTop;
  set paddingTop(CSSLengthValue? value) {
    if (_paddingTop == value) return;
    _paddingTop = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingTop => _paddingTop ?? CSSLengthValue.zero;

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
    return Size(paddingLeft.computedValue + innerSize.width + paddingRight.computedValue,
        paddingTop.computedValue + innerSize.height + paddingBottom.computedValue);
  }

  Size wrapPaddingSizeRight(Size innerSize) {
    return Size(
        innerSize.width + paddingRight.computedValue,
        paddingTop.computedValue + innerSize.height + paddingBottom.computedValue
    );
  }
  void debugPaddingProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('padding', padding));
  }
}
