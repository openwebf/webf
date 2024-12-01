/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/src/svg/rendering/rect.dart';
import 'package:webf/svg.dart';

import 'rendering/circle.dart';

class SVGClipPath {
  SVGClipPath(this.clipPath, this.boxShape);

  Path clipPath;
  BoxShape boxShape;
}

class SVGClipPathElement extends DefsAttributeElement {
  SVGClipPathElement([BindingContext? context]) : super(context);

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      DefsAttributeConfig('id', property: true),
    ]);

  SVGClipPath? parseClipPath() {
    NodeList nodeList = childNodes;
    Iterator iterator = nodeList.iterator;
    while (iterator.moveNext()) {
      if (iterator.current is SVGRectElement) {
        RenderBox? renderBox = (iterator.current as SVGRectElement).getRenderer();
        if (renderBox is RenderSVGRect) {
          return SVGClipPath(renderBox.asDefNodePath(), BoxShape.rectangle);
        }
      } else if (iterator.current is SVGCircleElement) {
        RenderBox? renderBox = (iterator.current as SVGCircleElement).getRenderer();
        if (renderBox is RenderSVGCircle) {
          return SVGClipPath(renderBox.asDefNodePath(), BoxShape.circle);
        }
      }
    }
    return null;
  }
}
