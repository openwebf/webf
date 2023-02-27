/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'shape.dart';

class RenderSVGRect extends RenderSVGShape {
  RenderSVGRect({required super.renderStyle, super.element});

  @override
  Path asPath() {
    // TODO: check value is valid
    var x = renderStyle.x.computedValue;
    var y = renderStyle.y.computedValue;
    var width = renderStyle.width.computedValue;
    var height = renderStyle.height.computedValue;
    var rx = renderStyle.rx.computedValue;
    var ry = renderStyle.ry.computedValue;

    final path = Path();

    if (width <= 0 || height <= 0) {
      // https://svgwg.org/svg2-draft/shapes.html#RectElement:~:text=A%20computed%20value%20of%20zero%20for%20either%20dimension%20disables%20rendering%20of%20the%20element.
      return path;
    }

    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, height), Radius.elliptical(rx, ry));

    path.addRRect(rrect);

    return path;
  }
}
