/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'package:webf/css.dart';

import '../svg/rendering/shape.dart';

enum CSSFillRule {
  nonzero,
  evenodd;

  get fillType {
    switch (this) {
      case CSSFillRule.nonzero:
        return PathFillType.nonZero;
      case CSSFillRule.evenodd:
        return PathFillType.evenOdd;
    }
  }
}

enum CSSStrokeLinecap {
  butt,
  round,
  square;

  StrokeCap get strokeCap {
    switch (this) {
      case CSSStrokeLinecap.butt:
        return StrokeCap.butt;
      case CSSStrokeLinecap.round:
        return StrokeCap.round;
      case CSSStrokeLinecap.square:
        return StrokeCap.square;
    }
  }
}

enum CSSStrokeLinejoin {
  // arcs,
  miter,
  // miterClip,
  round,
  bevel;

  get strokeJoin {
    switch (this) {
      case CSSStrokeLinejoin.miter:
        return StrokeJoin.miter;
      case CSSStrokeLinejoin.round:
        return StrokeJoin.round;
      case CSSStrokeLinejoin.bevel:
        return StrokeJoin.bevel;
    }
  }
}

final _CSSFillRuleMap = CSSFillRule.values.asNameMap();
final _CSSStrokeLinecapMap = CSSStrokeLinecap.values.asNameMap();
final _CSSStrokeLinejoinMap = CSSStrokeLinejoin.values.asNameMap();

mixin CSSSvgMixin on RenderStyle {
  _markRepaint() {
    renderBoxModel?.markNeedsPaint();
  }

  _markShapeUpdate() {
    if (renderBoxModel is RenderSVGShape) {
      (renderBoxModel as RenderSVGShape).markNeedUpdateShape();
    } else {
      renderBoxModel?.markNeedsLayout();
    }
  }

  CSSPaint? _fill;
  @override
  CSSPaint get fill => _fill ?? parent?.fill ?? CSSPaint.blackPaint;
  set fill(CSSPaint? value) {
    if (_fill == value) return;
    _fill = value;
    _markRepaint();
  }

  CSSPaint? _stroke;
  @override
  CSSPaint get stroke => _stroke ?? parent?.stroke ?? CSSPaint.none;
  set stroke(CSSPaint? value) {
    if (_stroke == value) return;
    _stroke = value;
    _markRepaint();
  }

  CSSLengthValue? _strokeWidth;
  @override
  CSSLengthValue get strokeWidth => _strokeWidth ?? parent?.strokeWidth ?? CSSLengthValue(1, CSSLengthType.PX);
  set strokeWidth(CSSLengthValue? value) {
    if (_strokeWidth == value) return;
    _strokeWidth = value;
    _markRepaint();
  }

  CSSLengthValue? _x;
  @override
  get x => _x ?? CSSLengthValue.zero;
  set x(CSSLengthValue? value) {
    if (_x == value) return;
    _x = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _y;
  @override
  get y => _y ?? CSSLengthValue.zero;
  set y(CSSLengthValue? value) {
    if (_y == value) return;
    _y = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _rx;
  @override
  get rx => _rx ?? CSSLengthValue.zero;
  set rx(CSSLengthValue? value) {
    if (_rx == value) return;
    _rx = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _ry;
  @override
  get ry => _ry ?? CSSLengthValue.zero;
  set ry(CSSLengthValue? value) {
    if (_ry == value) return;
    _ry = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _cx;
  @override get cx => _cx ?? CSSLengthValue.zero;
  set cx(CSSLengthValue? value) {
    if (_cx == value) return;
    _cx = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _cy;
  @override get cy => _cy ?? CSSLengthValue.zero;
  set cy(CSSLengthValue? value) {
    if (_cy == value) return;
    _cy = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _r;
  @override get r => _r ?? CSSLengthValue.zero;
  set r(CSSLengthValue? value) {
    if (_r == value) return;
    _r = value;
    _markShapeUpdate();
  }

  CSSPath? _d;
  @override get d => _d ?? CSSPath.None;
  set d(CSSPath value) {
    if (_d == value) return;
    _d = value;
    _markShapeUpdate();
  }

  CSSFillRule? _fillRule;
  @override get fillRule => _fillRule ?? CSSFillRule.nonzero;
  set fillRule(CSSFillRule value) {
    if (_fillRule == value) return;
    _fillRule = value;
    _markRepaint();
  }

  CSSLengthValue? _x1;
  @override get x1 => _x1 ?? CSSLengthValue.zero;
  set x1(CSSLengthValue value){
    if(_x1 == value) return;
    _x1 = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _y1;
  @override get y1 => _y1 ?? CSSLengthValue.zero;
  set y1(CSSLengthValue value){
    if(_y1 == value) return;
    _y1 = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _x2;
  @override get x2 => _x2 ?? CSSLengthValue.zero;
  set x2(CSSLengthValue value){
    if(_x2 == value) return;
    _x2 = value;
    _markShapeUpdate();
  }

  CSSLengthValue? _y2;
  @override get y2 => _y2 ?? CSSLengthValue.zero;
  set y2(CSSLengthValue value){
    if(_y2 == value) return;
    _y2 = value;
    _markShapeUpdate();
  }

  static resolveFillRule(String value) {
    return _CSSFillRuleMap[value] ?? CSSFillRule.nonzero;
  }

  CSSStrokeLinecap? _strokeLinecap;
  @override get strokeLinecap => _strokeLinecap ?? CSSStrokeLinecap.butt;
  set strokeLinecap(CSSStrokeLinecap value) {
    if (_strokeLinecap == value) return;
    _strokeLinecap = value;
    _markRepaint();
  }

  static resolveStrokeLinecap(String value) {
    return _CSSStrokeLinecapMap[value] ?? CSSStrokeLinecap.butt;
  }

  CSSStrokeLinejoin? _strokeLinejoin;
  @override get strokeLinejoin => _strokeLinejoin ?? CSSStrokeLinejoin.miter;
  set strokeLinejoin(CSSStrokeLinejoin value) {
    if (_strokeLinejoin == value) return;
    _strokeLinejoin = value;
    _markRepaint();
  }

  static resolveStrokeLinejoin(String value) {
    return _CSSStrokeLinejoinMap[value] ?? CSSStrokeLinejoin.miter;
  }
}
