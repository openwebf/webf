/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/rendering.dart';
import 'package:webf/src/svg/rendering/line.dart';
import 'package:webf/svg.dart';

class SVGLineElement extends SVGGeometryElement {
  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      SVGPresentationAttributeConfig('x1'),
      SVGPresentationAttributeConfig('y1'),
      SVGPresentationAttributeConfig('x2'),
      SVGPresentationAttributeConfig('y2'),
    ]);

  SVGLineElement(super.context) {}

  @override
  RenderBoxModel createRenderSVG({RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    return RenderSVGLine(renderStyle: renderStyle);
  }

}
