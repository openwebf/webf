/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/svg.dart';

import 'rendering/path.dart';

class SVGPathElement extends SVGGeometryElement {
  RenderSVGPath? _renderer;

  @override
  get renderBoxModel => _renderer;

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([SVGPresentationAttributeConfig('d')]);

  SVGPathElement(super.context) {}

  @override
  RenderBox createRenderer() {
    return _renderer = RenderSVGPath(renderStyle: renderStyle, element: this);
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _renderer = null;
  }
}
