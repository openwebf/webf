/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'shape.dart';

class RenderSVGEllipse extends RenderSVGShape {
  RenderSVGEllipse({required super.renderStyle, super.element});

  @override
  Path asPath() {
    final rxValue = renderStyle.rx;
    final ryValue = renderStyle.ry;

    final _rx = rxValue.computedValue;
    final _ry = ryValue.computedValue;

    // https://svgwg.org/svg2-draft/geometry.html#RxProperty
    final rx = rxValue.isAuto ? _ry : _rx;
    final ry = ryValue.isAuto ? _rx : _ry;

    if (rx <= 0 || ry <= 0) {
      return Path();
    }

    final cx = renderStyle.cx.computedValue;
    final cy = renderStyle.cy.computedValue;

    return Path()
      ..addOval(Rect.fromCenter(
          center: Offset(cx, cy), width: rx * 2, height: ry * 2));
  }
}
