/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/src/svg/rendering/empty.dart';
import 'package:webf/svg.dart';

class SVGUnknownElement extends SVGElement {
  RenderSVGEmpty? _renderer;

  @override
  get renderBoxModel => _renderer;

  SVGUnknownElement(super.context) {}

  @override
  createRenderer() {
    return _renderer = RenderSVGEmpty(renderStyle: renderStyle, element: this);
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _renderer = null;
  }
}
