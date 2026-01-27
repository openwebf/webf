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

  CSSBorderRadius? _borderStartStartRadius;
  set borderStartStartRadius(CSSBorderRadius? value) {
    if (value == _borderStartStartRadius) return;
    _borderStartStartRadius = value;
    markNeedsPaint();
    resetBoxDecoration();
    _invalidateBorderRadiusCache();
    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        cssLogger.finer('[BorderRadius] set border-start-start-radius on <${el.tagName.toLowerCase()}> -> '
            '${value?.cssText() ?? 'unset'}');
      } catch (_) {}
    }
  }

  @override
  CSSBorderRadius get borderStartStartRadius => _borderStartStartRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderStartEndRadius;
  set borderStartEndRadius(CSSBorderRadius? value) {
    if (value == _borderStartEndRadius) return;
    _borderStartEndRadius = value;
    markNeedsPaint();
    resetBoxDecoration();
    _invalidateBorderRadiusCache();
    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        cssLogger.finer('[BorderRadius] set border-start-end-radius on <${el.tagName.toLowerCase()}> -> '
            '${value?.cssText() ?? 'unset'}');
      } catch (_) {}
    }
  }

  @override
  CSSBorderRadius get borderStartEndRadius => _borderStartEndRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderEndStartRadius;
  set borderEndStartRadius(CSSBorderRadius? value) {
    if (value == _borderEndStartRadius) return;
    _borderEndStartRadius = value;
    markNeedsPaint();
    resetBoxDecoration();
    _invalidateBorderRadiusCache();
    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        cssLogger.finer('[BorderRadius] set border-end-start-radius on <${el.tagName.toLowerCase()}> -> '
            '${value?.cssText() ?? 'unset'}');
      } catch (_) {}
    }
  }

  @override
  CSSBorderRadius get borderEndStartRadius => _borderEndStartRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderEndEndRadius;
  set borderEndEndRadius(CSSBorderRadius? value) {
    if (value == _borderEndEndRadius) return;
    _borderEndEndRadius = value;
    markNeedsPaint();
    resetBoxDecoration();
    _invalidateBorderRadiusCache();
    if (DebugFlags.enableBorderRadiusLogs) {
      try {
        final el = target;
        cssLogger.finer('[BorderRadius] set border-end-end-radius on <${el.tagName.toLowerCase()}> -> '
            '${value?.cssText() ?? 'unset'}');
      } catch (_) {}
    }
  }

  @override
  CSSBorderRadius get borderEndEndRadius => _borderEndEndRadius ?? CSSBorderRadius.zero;

  static const List<int> _startStartMap = <int>[0, 1, 0]; // TL, TR, TL
  static const List<int> _startEndMap = <int>[1, 2, 3]; // TR, BR, BL
  static const List<int> _endStartMap = <int>[3, 0, 1]; // BL, TL, TR
  static const List<int> _endEndMap = <int>[2, 3, 2]; // BR, BL, BR

  int _writingModeIndex(CSSWritingMode mode) {
    switch (mode) {
      case CSSWritingMode.horizontalTb:
        return 0;
      case CSSWritingMode.verticalRl:
        return 1;
      case CSSWritingMode.verticalLr:
        return 2;
    }
  }

  int _resolveStartStartCorner(TextDirection dir, CSSWritingMode mode) {
    final idx = _writingModeIndex(mode);
    return dir == TextDirection.ltr ? _startStartMap[idx] : _startEndMap[idx];
  }

  int _resolveStartEndCorner(TextDirection dir, CSSWritingMode mode) {
    final idx = _writingModeIndex(mode);
    return dir == TextDirection.ltr ? _startEndMap[idx] : _startStartMap[idx];
  }

  int _resolveEndStartCorner(TextDirection dir, CSSWritingMode mode) {
    final idx = _writingModeIndex(mode);
    return dir == TextDirection.ltr ? _endStartMap[idx] : _endEndMap[idx];
  }

  int _resolveEndEndCorner(TextDirection dir, CSSWritingMode mode) {
    final idx = _writingModeIndex(mode);
    return dir == TextDirection.ltr ? _endEndMap[idx] : _endStartMap[idx];
  }

  @override
  List<Radius>? get borderRadius {
    final TextDirection currentDirection = direction;
    final CSSWritingMode currentWritingMode = writingMode;

    CSSBorderRadius? tl = _borderTopLeftRadius;
    CSSBorderRadius? tr = _borderTopRightRadius;
    CSSBorderRadius? br = _borderBottomRightRadius;
    CSSBorderRadius? bl = _borderBottomLeftRadius;

    void applyLogical(CSSBorderRadius? logical, int physicalCorner) {
      if (logical == null) return;
      switch (physicalCorner) {
        case 0:
          tl ??= logical;
          break;
        case 1:
          tr ??= logical;
          break;
        case 2:
          br ??= logical;
          break;
        case 3:
          bl ??= logical;
          break;
      }
    }

    applyLogical(_borderStartStartRadius, _resolveStartStartCorner(currentDirection, currentWritingMode));
    applyLogical(_borderStartEndRadius, _resolveStartEndCorner(currentDirection, currentWritingMode));
    applyLogical(_borderEndStartRadius, _resolveEndStartCorner(currentDirection, currentWritingMode));
    applyLogical(_borderEndEndRadius, _resolveEndEndCorner(currentDirection, currentWritingMode));

    // Fast path: if all corners are zero, no radii.
    final CSSBorderRadius tlResolved = tl ?? CSSBorderRadius.zero;
    final CSSBorderRadius trResolved = tr ?? CSSBorderRadius.zero;
    final CSSBorderRadius brResolved = br ?? CSSBorderRadius.zero;
    final CSSBorderRadius blResolved = bl ?? CSSBorderRadius.zero;

    final bool hasAnyRadius = !(tlResolved == CSSBorderRadius.zero &&
        trResolved == CSSBorderRadius.zero &&
        brResolved == CSSBorderRadius.zero &&
        blResolved == CSSBorderRadius.zero);
    if (!hasAnyRadius) return null;

    // Cache to avoid recomputing per paint phase.
    // When any axis uses percentages, the result depends on the border box size.
    final bool tlPct = tlResolved.x.isPercentage || tlResolved.y.isPercentage;
    final bool trPct = trResolved.x.isPercentage || trResolved.y.isPercentage;
    final bool brPct = brResolved.x.isPercentage || brResolved.y.isPercentage;
    final bool blPct = blResolved.x.isPercentage || blResolved.y.isPercentage;
    final bool anyPct = tlPct || trPct || brPct || blPct;

    final double? bw = borderBoxWidth ?? borderBoxLogicalWidth;
    final double? bh = borderBoxHeight ?? borderBoxLogicalHeight;

    // Reuse cached radii when inputs are identical and the size anchor (for %) is unchanged.
    if (_cachedComputedBorderRadius != null &&
        _cachedBorderRadiusDirection == currentDirection &&
        _cachedBorderRadiusWritingMode == currentWritingMode &&
        identical(_cachedTLRef, _borderTopLeftRadius) &&
        identical(_cachedTRRef, _borderTopRightRadius) &&
        identical(_cachedBRRef, _borderBottomRightRadius) &&
        identical(_cachedBLRef, _borderBottomLeftRadius) &&
        identical(_cachedStartStartRef, _borderStartStartRadius) &&
        identical(_cachedStartEndRef, _borderStartEndRadius) &&
        identical(_cachedEndStartRef, _borderEndStartRadius) &&
        identical(_cachedEndEndRef, _borderEndEndRadius) &&
        (!anyPct || (_cachedBorderRadiusW == bw && _cachedBorderRadiusH == bh))) {
      return _cachedComputedBorderRadius;
    }

    final radii = <Radius>[
      tlResolved.computedRadius,
      trResolved.computedRadius,
      brResolved.computedRadius,
      blResolved.computedRadius,
    ];

    _cachedComputedBorderRadius = radii;
    _cachedBorderRadiusW = anyPct ? bw : _cachedBorderRadiusW; // only bind size when needed
    _cachedBorderRadiusH = anyPct ? bh : _cachedBorderRadiusH;
    _cachedTLRef = _borderTopLeftRadius;
    _cachedTRRef = _borderTopRightRadius;
    _cachedBRRef = _borderBottomRightRadius;
    _cachedBLRef = _borderBottomLeftRadius;
    _cachedStartStartRef = _borderStartStartRadius;
    _cachedStartEndRef = _borderStartEndRadius;
    _cachedEndStartRef = _borderEndStartRadius;
    _cachedEndEndRef = _borderEndEndRadius;
    _cachedBorderRadiusDirection = currentDirection;
    _cachedBorderRadiusWritingMode = currentWritingMode;

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
  CSSBorderRadius? _cachedStartStartRef, _cachedStartEndRef, _cachedEndStartRef, _cachedEndEndRef;
  TextDirection? _cachedBorderRadiusDirection;
  CSSWritingMode? _cachedBorderRadiusWritingMode;

  void _invalidateBorderRadiusCache() {
    _cachedComputedBorderRadius = null;
    _cachedBorderRadiusW = null;
    _cachedBorderRadiusH = null;
    _cachedTLRef = null;
    _cachedTRRef = null;
    _cachedBRRef = null;
    _cachedBLRef = null;
    _cachedStartStartRef = null;
    _cachedStartEndRef = null;
    _cachedEndStartRef = null;
    _cachedEndEndRef = null;
    _cachedBorderRadiusDirection = null;
    _cachedBorderRadiusWritingMode = null;
  }

  // Invalidate cache when any individual corner radius changes.
  // Call from setters.
}
