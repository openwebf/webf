/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';

class SVGTextPositioningElement extends SVGTextContentElement {
  SVGTextPositioningElement(super.context);

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      SVGPresentationAttributeConfig('x', property: true),
      SVGPresentationAttributeConfig('y', property: true),
      SVGPresentationAttributeConfig('dx', property: true),
      SVGPresentationAttributeConfig('dy', property: true),
    ]);
}
