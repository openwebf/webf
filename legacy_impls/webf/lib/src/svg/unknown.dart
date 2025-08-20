/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/rendering.dart';
import 'package:webf/src/svg/rendering/empty.dart';
import 'package:webf/svg.dart';

class SVGUnknownElement extends SVGElement {
  SVGUnknownElement(super.context) {}

  @override
  RenderBoxModel createRenderSVG({RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    return RenderSVGEmpty(renderStyle: renderStyle);
  }
}
