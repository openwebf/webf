/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';

import 'rendering/circle.dart';

class SVGCircleElement extends SVGGeometryElement {

  @override
  get renderBoxModel => renderSVGBox;

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      SVGPresentationAttributeConfig('cx'),
      SVGPresentationAttributeConfig('cy'),
      SVGPresentationAttributeConfig('r'),
    ]);

  SVGCircleElement(super.context);

  @override
  dynamic createRenderBoxModel() {
    return RenderSVGCircle(renderStyle: renderStyle, element: this);
  }
}
