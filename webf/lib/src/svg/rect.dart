/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';
import 'rendering/rect.dart';

class SVGRectElement extends SVGGeometryElement {

  @override
  get renderBoxModel => renderSVGBox;

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

  SVGRectElement(super.context);

  @override
  dynamic createRenderBoxModel() {
    return RenderSVGRect(renderStyle: renderStyle, element: this);
  }
}
