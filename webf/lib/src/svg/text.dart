/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';

import 'rendering/text.dart';

class SVGTextElement extends SVGTextPositioningElement {
  late final RenderSVGText _renderer;

  @override
  get renderBoxModel => _renderer;

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs..addAll([
  ]);

  SVGTextElement(super.context) {
    _renderer = RenderSVGText(renderStyle: renderStyle, element: this);
  }
}
