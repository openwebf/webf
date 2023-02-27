/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';
import 'package:webf/foundation.dart';

class SVGGraphicsElement extends SVGElement {
  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      SVGPresentationAttributeConfig('font-size'),
      SVGPresentationAttributeConfig('font-family'),
      SVGPresentationAttributeConfig('fill'),
      SVGPresentationAttributeConfig('fill-rule'),
      SVGPresentationAttributeConfig('stroke'),
      SVGPresentationAttributeConfig('stroke-width'),
      SVGPresentationAttributeConfig('stroke-linecap'),
      SVGPresentationAttributeConfig('stroke-linejoin'),
      SVGPresentationAttributeConfig('transform')
    ]);

  SVGGraphicsElement([BindingContext? context]) : super(context);
}
