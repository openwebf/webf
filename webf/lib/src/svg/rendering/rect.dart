/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math';
import 'dart:ui';

import 'shape.dart';

class RenderSVGRect extends RenderSVGShape {
  RenderSVGRect({required super.renderStyle});

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
    return getPath(width, height, path, rx, ry, x, y);
  }

  Path asDefNodePath() {
    final path = Path();
    var element = renderStyle.target;
    var x = double.parse(element.attributes['x'] ?? '0');
    var y = double.parse(element.attributes['y'] ?? '0');
    var width = double.parse(element.attributes['width'] ?? '0');
    var height = double.parse(element.attributes['height'] ?? '0');
    var rx = double.parse(element.attributes['rx'] ?? '0');
    var ry = double.parse(element.attributes['ry'] ?? '0');

    return getPath(width, height, path, rx, ry, x, y);
  }

  Path getPath(double width, double height, Path path, double rx, double ry, double x, double y) {
    if (width <= 0 || height <= 0) {
      // https://svgwg.org/svg2-draft/shapes.html#RectElement:~:text=A%20computed%20value%20of%20zero%20for%20either%20dimension%20disables%20rendering%20of%20the%20element.
      return path;
    }
    if ((rx == 0 && ry != 0) || (ry == 0 && rx != 0)) {
      var r = max(rx, ry);
      path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, width, height), Radius.circular(r)));
    } else {
      path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, width, height), Radius.elliptical(rx, ry)));
    }
    return path;
  }


}
