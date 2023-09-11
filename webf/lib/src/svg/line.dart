/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/src/svg/rendering/line.dart';
import 'package:webf/svg.dart';

class SVGLineElement extends SVGGeometryElement {

  late final RenderSVGLine _renderer;

  @override
  get renderBoxModel => _renderer;

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      SVGPresentationAttributeConfig('x1'),
      SVGPresentationAttributeConfig('y1'),
      SVGPresentationAttributeConfig('x2'),
      SVGPresentationAttributeConfig('y2'),
    ]);

  SVGLineElement(super.context) {
    _renderer = RenderSVGLine(renderStyle: renderStyle, element: this);
  }
}
