/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';
import 'rendering/rect.dart';

class SVGRectElement extends SVGGeometryElement {
  late final RenderSVGRect _renderer;

  @override
  get renderBoxModel => _renderer;

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

  SVGRectElement(super.context) {
    _renderer = RenderSVGRect(renderStyle: renderStyle, element: this);
  }
}
