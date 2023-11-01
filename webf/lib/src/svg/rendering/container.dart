/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/svg.dart';

// SVG container to accept children
class RenderSVGContainer extends RenderBoxModel
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>> {
  final SVGElement? element;

  RenderSVGContainer({required super.renderStyle, this.element});

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return null;
  }

  @override
  void performLayout() {
    size =
        Size(renderStyle.width.computedValue, renderStyle.height.computedValue);
    visitChildren((child) {
      child.layout(BoxConstraints());
    });
    initOverflowLayout(Rect.fromLTRB(0, 0, size.width, size.height),
        Rect.fromLTRB(0, 0, size.width, size.height));
    dispatchResize(contentSize, boxSize ?? Size.zero);

  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    visitChildren((child) {
      context.paintChild(child, offset);
    });
  }

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = RenderLayoutParentData();
  }
}
