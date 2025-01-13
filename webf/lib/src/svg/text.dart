/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/rendering.dart';
import 'package:webf/svg.dart';


class SVGTextElement extends SVGTextPositioningElement {
  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs..addAll([]);

  SVGTextElement(super.context) {}

  @override
  RenderBoxModel createRenderSVG({RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    return RenderSVGText(renderStyle: renderStyle);
  }
}
