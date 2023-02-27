/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/svg.dart';

class RenderSVGText extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderTextBox> {
  SVGTextElement? element;

  var _baseline = 0.0;

  RenderSVGText({required super.renderStyle, this.element});

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    if (child != null) {
      final result = child!.getDistanceToBaseline(baseline);
      return result;
    }
    return null;
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    final dx = renderStyle.x.computedValue + offset.dx;
    final dy = renderStyle.y.computedValue + offset.dy - _baseline;
    visitChildren((child) {
      context.paintChild(child, Offset(dx, dy));
    });
  }

  @override
  void performLayout() {
    visitChildren((child) {
      // Don't constraint child
      child.layout(BoxConstraints());
    });
    _baseline = child?.getDistanceToBaseline(TextBaseline.alphabetic) ?? 0.0;
    size = child?.size ?? Size(0, 0);
  }
}
