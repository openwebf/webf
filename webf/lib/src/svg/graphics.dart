/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:webf/svg.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';

class SVGGraphicsElement extends SVGElement {
  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      SVGPresentationAttributeConfig('font-size'),
      SVGPresentationAttributeConfig('font-family'),
      SVGPresentationAttributeConfig('fill'),
      SVGPresentationAttributeConfig('fill-rule'),
      SVGPresentationAttributeConfig('clip-path'),
      SVGPresentationAttributeConfig('stroke'),
      SVGPresentationAttributeConfig('stroke-width'),
      SVGPresentationAttributeConfig('stroke-linecap'),
      SVGPresentationAttributeConfig('stroke-linejoin'),
      SVGPresentationAttributeConfig('transform')
    ]);

  @override
  flutter.Widget toWidget({flutter.Key? key}) {
    return WebFReplacedElementWidget(webFElement: this,);
  }

  SVGGraphicsElement([BindingContext? context]) : super(context);
}
