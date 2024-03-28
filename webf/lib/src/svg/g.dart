/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';

import 'rendering/container.dart';

class SVGGElement extends SVGGraphicsElement {
  RenderSVGContainer? _renderer;

  @override
  get renderBoxModel => _renderer;

  SVGGElement(super.context) {}

  @override
  createRenderer() {
    return _renderer = RenderSVGContainer(renderStyle: renderStyle, element: this);
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _renderer = null;
  }
}
