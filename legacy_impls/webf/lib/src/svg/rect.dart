/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/rendering.dart';
import 'package:webf/svg.dart';
import 'rendering/rect.dart';

class SVGRectElement extends SVGGeometryElement {
  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      SVGPresentationAttributeConfig('x', property: true),
      SVGPresentationAttributeConfig('y', property: true),
      SVGPresentationAttributeConfig('width', property: true),
      SVGPresentationAttributeConfig('height', property: true),
      SVGPresentationAttributeConfig('rx', property: true),
      SVGPresentationAttributeConfig('ry', property: true)
    ]);

  SVGRectElement(super.context) {}

  @override
  RenderBoxModel createRenderSVG({RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    return RenderSVGRect(renderStyle: renderStyle);
  }
}
