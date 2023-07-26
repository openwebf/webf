/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';

import 'rendering/path.dart';

class SVGPathElement extends SVGGeometryElement {
  late final RenderSVGPath _renderer;

  @override
  get renderBoxModel => _renderer;

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([SVGPresentationAttributeConfig('d')]);

  SVGPathElement(super.context) {
    _renderer = RenderSVGPath(renderStyle: renderStyle, element: this);
  }
}
