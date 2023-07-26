/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';

import 'rendering/container.dart';

class SVGGElement extends SVGGraphicsElement {
  late final RenderSVGContainer _renderer;

  @override
  get renderBoxModel => _renderer;

  SVGGElement(super.context) {
    _renderer = RenderSVGContainer(renderStyle: renderStyle, element: this);
  }
}
