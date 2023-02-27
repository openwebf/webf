/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/src/svg/rendering/empty.dart';
import 'package:webf/svg.dart';

class SVGUnknownElement extends SVGElement {
  late final RenderSVGEmpty _renderer;

  @override
  get renderBoxModel => _renderer;

  SVGUnknownElement(super.context) {
    _renderer = RenderSVGEmpty(renderStyle: renderStyle, element: this);
  }
}
