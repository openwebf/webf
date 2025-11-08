/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';

import 'package:webf/css.dart';
import 'package:webf/src/foundation/logger.dart';
import 'package:webf/src/foundation/debug_flags.dart';

mixin CSSBorderRadiusMixin on RenderStyle {
  CSSBorderRadius? _borderTopLeftRadius;
  set borderTopLeftRadius(CSSBorderRadius? value) {
    if (value == _borderTopLeftRadius) return;
    _borderTopLeftRadius = value;
    markNeedsPaint();
    resetBoxDecoration();
    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        cssLogger.finer('[BorderRadius] set border-top-left-radius on <${el.tagName.toLowerCase()}> -> '
            '${value?.cssText() ?? 'unset'}');
      } catch (_) {}
    }
  }

  @override
  CSSBorderRadius get borderTopLeftRadius => _borderTopLeftRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderTopRightRadius;
  set borderTopRightRadius(CSSBorderRadius? value) {
    if (value == _borderTopRightRadius) return;
    _borderTopRightRadius = value;
    markNeedsPaint();
    resetBoxDecoration();
    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        cssLogger.finer('[BorderRadius] set border-top-right-radius on <${el.tagName.toLowerCase()}> -> '
            '${value?.cssText() ?? 'unset'}');
      } catch (_) {}
    }
  }

  @override
  CSSBorderRadius get borderTopRightRadius => _borderTopRightRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderBottomRightRadius;
  set borderBottomRightRadius(CSSBorderRadius? value) {
    if (value == _borderBottomRightRadius) return;
    _borderBottomRightRadius = value;
    markNeedsPaint();
    resetBoxDecoration();
    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        cssLogger.finer('[BorderRadius] set border-bottom-right-radius on <${el.tagName.toLowerCase()}> -> '
            '${value?.cssText() ?? 'unset'}');
      } catch (_) {}
    }
  }

  @override
  CSSBorderRadius get borderBottomRightRadius => _borderBottomRightRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderBottomLeftRadius;
  set borderBottomLeftRadius(CSSBorderRadius? value) {
    if (value == _borderBottomLeftRadius) return;
    _borderBottomLeftRadius = value;
    markNeedsPaint();
    resetBoxDecoration();
    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        cssLogger.finer('[BorderRadius] set border-bottom-left-radius on <${el.tagName.toLowerCase()}> -> '
            '${value?.cssText() ?? 'unset'}');
      } catch (_) {}
    }
  }

  @override
  CSSBorderRadius get borderBottomLeftRadius => _borderBottomLeftRadius ?? CSSBorderRadius.zero;

  @override
  List<Radius>? get borderRadius {
    bool hasBorderRadius = borderTopLeftRadius != CSSBorderRadius.zero ||
        borderTopRightRadius != CSSBorderRadius.zero ||
        borderBottomRightRadius != CSSBorderRadius.zero ||
        borderBottomLeftRadius != CSSBorderRadius.zero;

    if (!hasBorderRadius) return null;

    final radii = <Radius>[
      borderTopLeftRadius.computedRadius,
      borderTopRightRadius.computedRadius,
      borderBottomRightRadius.computedRadius,
      borderBottomLeftRadius.computedRadius,
    ];

    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        final double? bw = borderBoxWidth ?? borderBoxLogicalWidth;
        final double? bh = borderBoxHeight ?? borderBoxLogicalHeight;
        renderingLogger.finer('[BorderRadius] compute for <${el.tagName.toLowerCase()}> ' 
            'borderBox=${bw?.toStringAsFixed(2) ?? 'null'}×${bh?.toStringAsFixed(2) ?? 'null'} ' 
            'tl=(${radii[0].x.toStringAsFixed(2)},${radii[0].y.toStringAsFixed(2)}) '
            'tr=(${radii[1].x.toStringAsFixed(2)},${radii[1].y.toStringAsFixed(2)}) '
            'br=(${radii[2].x.toStringAsFixed(2)},${radii[2].y.toStringAsFixed(2)}) '
            'bl=(${radii[3].x.toStringAsFixed(2)},${radii[3].y.toStringAsFixed(2)})');
      } catch (_) {}
    }

    return radii;
  }
}
