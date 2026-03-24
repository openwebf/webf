/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:ui' as ui;

import 'package:webf/css.dart';

mixin CSSOpacityMixin on RenderStyle {
  /// The fraction to scale the child's alpha value.
  ///
  /// An opacity of 1.0 is fully opaque. An opacity of 0.0 is fully transparent
  /// (i.e., invisible).
  ///
  /// The opacity must not be null.
  ///
  /// Values 1.0 and 0.0 are painted with a fast path. Other values
  /// require painting the child into an intermediate buffer, which is
  /// expensive.
  @override
  double get opacity => _opacity ?? 1.0;
  double? _opacity;
  set opacity(double? value) {
    if (_opacity == value) return;

    final double previousOpacity = opacity;
    final int previousAlpha = ui.Color.getAlphaFromOpacity(previousOpacity);
    final bool previousCreatesStackingContext = previousOpacity < 1.0;
    final bool previousNeedsCompositing = previousAlpha != 0 && previousAlpha != 255;

    _opacity = value;
    final double nextOpacity = opacity;
    final int alpha = ui.Color.getAlphaFromOpacity(nextOpacity);
    final bool nextCreatesStackingContext = nextOpacity < 1.0;
    final bool nextNeedsCompositing = alpha != 0 && alpha != 255;
    getSelfRenderBoxValue((renderBoxModel, _) {
      renderBoxModel.alpha = alpha;
    });

    // Opacity only changes compositing requirements when it crosses the
    // intermediate alpha range that uses an opacity layer.
    if (previousNeedsCompositing != nextNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }

    // Opacity affects stacking order only when it starts or stops creating a
    // stacking context. Fractional opacity changes within the same range do not
    // require resorting siblings every frame.
    if (previousCreatesStackingContext != nextCreatesStackingContext) {
      getAttachedRenderParentRenderStyle()?.markChildrenNeedsSort();
    }

    markNeedsPaint();
  }

  static double? resolveOpacity(String value) {
    return CSSStyleDeclaration.isNullOrEmptyValue(value) ? 1.0 : CSSLength.toDouble(value);
  }
}
