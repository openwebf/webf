/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/rendering.dart';
import 'package:webf/svg.dart';

import 'rendering/container.dart';

class SVGGElement extends SVGGraphicsElement {
  SVGGElement(super.context) {}

  @override
  RenderBoxModel createRenderSVG({RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    return RenderSVGContainer(renderStyle: renderStyle);
  }
}
