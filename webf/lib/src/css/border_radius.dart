/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
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
    _invalidateBorderRadiusCache();
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
    _invalidateBorderRadiusCache();
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
    _invalidateBorderRadiusCache();
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
    _invalidateBorderRadiusCache();
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
    // Fast path: if all corners are zero, no radii.
    final CSSBorderRadius tl = _borderTopLeftRadius ?? CSSBorderRadius.zero;
    final CSSBorderRadius tr = _borderTopRightRadius ?? CSSBorderRadius.zero;
    final CSSBorderRadius br = _borderBottomRightRadius ?? CSSBorderRadius.zero;
    final CSSBorderRadius bl = _borderBottomLeftRadius ?? CSSBorderRadius.zero;

    final bool hasAnyRadius = !(tl == CSSBorderRadius.zero && tr == CSSBorderRadius.zero &&
        br == CSSBorderRadius.zero && bl == CSSBorderRadius.zero);
    if (!hasAnyRadius) return null;

    // Cache to avoid recomputing per paint phase.
    // When any axis uses percentages, the result depends on the border box size.
    final bool tlPct = tl.x.isPercentage || tl.y.isPercentage;
    final bool trPct = tr.x.isPercentage || tr.y.isPercentage;
    final bool brPct = br.x.isPercentage || br.y.isPercentage;
    final bool blPct = bl.x.isPercentage || bl.y.isPercentage;
    final bool anyPct = tlPct || trPct || brPct || blPct;

    final double? bw = borderBoxWidth ?? borderBoxLogicalWidth;
    final double? bh = borderBoxHeight ?? borderBoxLogicalHeight;

    // Reuse cached radii when inputs are identical and the size anchor (for %) is unchanged.
    if (_cachedComputedBorderRadius != null &&
        identical(_cachedTLRef, _borderTopLeftRadius) &&
        identical(_cachedTRRef, _borderTopRightRadius) &&
        identical(_cachedBRRef, _borderBottomRightRadius) &&
        identical(_cachedBLRef, _borderBottomLeftRadius) &&
        (!anyPct || (_cachedBorderRadiusW == bw && _cachedBorderRadiusH == bh))) {
      return _cachedComputedBorderRadius;
    }

    final radii = <Radius>[
      tl.computedRadius,
      tr.computedRadius,
      br.computedRadius,
      bl.computedRadius,
    ];

    _cachedComputedBorderRadius = radii;
    _cachedBorderRadiusW = anyPct ? bw : _cachedBorderRadiusW; // only bind size when needed
    _cachedBorderRadiusH = anyPct ? bh : _cachedBorderRadiusH;
    _cachedTLRef = _borderTopLeftRadius;
    _cachedTRRef = _borderTopRightRadius;
    _cachedBRRef = _borderBottomRightRadius;
    _cachedBLRef = _borderBottomLeftRadius;

    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        renderingLogger.finer('[BorderRadius] compute for <${el.tagName.toLowerCase()}> '
            'borderBox=${(bw)?.toStringAsFixed(2) ?? 'null'}×${(bh)?.toStringAsFixed(2) ?? 'null'} '
            'tl=(${radii[0].x.toStringAsFixed(2)},${radii[0].y.toStringAsFixed(2)}) '
            'tr=(${radii[1].x.toStringAsFixed(2)},${radii[1].y.toStringAsFixed(2)}) '
            'br=(${radii[2].x.toStringAsFixed(2)},${radii[2].y.toStringAsFixed(2)}) '
            'bl=(${radii[3].x.toStringAsFixed(2)},${radii[3].y.toStringAsFixed(2)})');
      } catch (_) {}
    }

    return radii;
  }

  // Cached computed radii + inputs used to compute them.
  List<Radius>? _cachedComputedBorderRadius;
  double? _cachedBorderRadiusW;
  double? _cachedBorderRadiusH;
  CSSBorderRadius? _cachedTLRef, _cachedTRRef, _cachedBRRef, _cachedBLRef;

  void _invalidateBorderRadiusCache() {
    _cachedComputedBorderRadius = null;
    _cachedBorderRadiusW = null;
    _cachedBorderRadiusH = null;
    _cachedTLRef = null;
    _cachedTRRef = null;
    _cachedBRRef = null;
    _cachedBLRef = null;
  }

  // Invalidate cache when any individual corner radius changes.
  // Call from setters.
}
