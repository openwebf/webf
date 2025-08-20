/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'package:webf/css.dart';

enum CSSPaintType {
  color,
  none,
  currentColor,
  contextFill,
  contextStroke,
}

class CSSPaint {
  static const _blackColor = Color.fromARGB(255, 0, 0, 0);
  static const _transparentColor = Color.fromARGB(0, 0, 0, 0);
  static const none = CSSPaint(CSSPaintType.none);
  static const currentColor = CSSPaint(CSSPaintType.currentColor);
  static const contextFill = CSSPaint(CSSPaintType.contextFill);
  static const contextStroke = CSSPaint(CSSPaintType.contextStroke);
  static const blackPaint = CSSPaint(CSSPaintType.color, color: _blackColor);

  static CSSPaint? parsePaint(String paint, { required RenderStyle renderStyle }) {
    if (paint == NONE) {
      return none;
    }
    switch(paint) {
      case NONE: return none;
      case CURRENT_COLOR: return currentColor;
      case CONTEXT_FILL: return contextFill;
      case CONTEXT_STROKE: return contextStroke;
    }

    final color = CSSColor.parseColor(paint, renderStyle: renderStyle);
    if (color != null) {
      return CSSPaint(CSSPaintType.color, color: color);
    }
    return null;
  }

  final CSSPaintType type;
  final Color? color;

  const CSSPaint(this.type, {this.color});

  get isNone => type == CSSPaintType.none;

  Color getColor() {
    assert(type == CSSPaintType.color);
    return color!;
  }

  Color resolve(RenderStyle renderStyle) {
    switch (type) {
      case CSSPaintType.color: return getColor();
      case CSSPaintType.none: return _transparentColor;
      case CSSPaintType.currentColor: return renderStyle.color.value;
      // TODO: implements others in the future
      case CSSPaintType.contextFill:
      case CSSPaintType.contextStroke:
        break;
    }
    return _blackColor;
  }

  String cssText() {
    switch(type) {
      case CSSPaintType.color: return getColor().toString();
      case CSSPaintType.none: return _transparentColor.toString();
      case CSSPaintType.currentColor: return CURRENT_COLOR;
      case CSSPaintType.contextFill: return CONTEXT_FILL;
      case CSSPaintType.contextStroke: return CONTEXT_STROKE;
    }
  }
}
