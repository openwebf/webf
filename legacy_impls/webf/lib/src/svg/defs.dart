/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/svg.dart';


class SVGDefsElement extends DefsAttributeElement {
  SVGDefsElement(super.context);

  Shader? getShader(attribute, Rect rect) {
    NodeList nodeList = childNodes;
    Iterator iterator = nodeList.iterator;
    while (iterator.moveNext()) {
      if (iterator.current is SVGLinearGradientElement) {
        SVGLinearGradientElement element = iterator.current;
        dynamic id = element.attributeStyle['id'];
        if (attribute == 'url(#$id)') {
          element.parseCSSColorStop();
          double x0 = double.parse(element.attributes['x1']!);
          double y0 = double.parse(element.attributes['y1']!);
          double x1 = double.parse(element.attributes['x2']!);
          double y1 = double.parse(element.attributes['y2']!);
          CanvasLinearGradient glinearGradient = CanvasLinearGradient(x0, y0, x1, y1);
          glinearGradient.stops = element.stops;
          glinearGradient.colors = element.colors;
          LinearGradient linearGradient = _drawLinearGradient(glinearGradient, rect.left, rect.top, rect.width, rect.height);
          return linearGradient.createShader(rect);
        }
      }
    }
    return null;
  }

  SVGClipPath? getClipPath(attribute, Rect rect) {
    NodeList nodeList = childNodes;
    Iterator iterator = nodeList.iterator;
    while (iterator.moveNext()) {
      if (iterator.current is SVGClipPathElement) {
        SVGClipPathElement element = iterator.current;
        dynamic id = element.attributeStyle['id'];
        if (attribute == 'url(#$id)') {
          return element.parseClipPath();
        }
      }
    }
    return null;
  }

  LinearGradient _drawLinearGradient(CanvasLinearGradient gradient, double rX,
      double rY, double rW, double rH) {
    double cW = rW / 2;
    double cH = rH / 2;
    double lX = rX + cW;
    double lY = rY + cH;
    double centerX = (gradient.x0 - lX) / cW;
    double centerY = (gradient.y0 - lY) / cH;
    double focalX = (gradient.x1 - lX) / cW;
    double focalY = (gradient.y1 - lY) / cH;
    List<Color> colors = gradient.colors;
    List<double> stops = gradient.stops;
    return LinearGradient(
        begin: Alignment(centerX, centerY),
        end: Alignment(focalX, focalY),
        colors: colors,
        stops: stops,
        tileMode: TileMode.clamp);
  }
}


class CanvasLinearGradient {
  double x0;
  double y0;
  double x1;
  double y1;

  List<Color> colors = [];
  List<double> stops = [];

  CanvasLinearGradient(this.x0, this.y0, this.x1, this.y1);
}
