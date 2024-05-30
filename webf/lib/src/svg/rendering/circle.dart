/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'shape.dart';

class RenderSVGCircle extends RenderSVGShape {
  RenderSVGCircle({required super.renderStyle});

  @override
  Path asPath() {
    final cx = renderStyle.cx.computedValue;
    final cy = renderStyle.cy.computedValue;
    final r = renderStyle.r.computedValue;
    return getPath(r, cx, cy);
  }
  Path asDefNodePath() {
    var element = renderStyle.target;
    final cx = double.parse(element.attributes['cx'] ?? '0');
    final cy = double.parse(element.attributes['cy'] ?? '0');
    final r = double.parse(element.attributes['r'] ?? '0');
    return getPath(r, cx, cy);
  }

  Path getPath(double r, double cx, double cy) {
    if (r <= 0) {
      return Path();
    }
    return Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
  }

}
