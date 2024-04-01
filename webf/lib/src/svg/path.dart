/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/svg.dart';

import 'rendering/path.dart';

class SVGPathElement extends SVGGeometryElement {
  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([SVGPresentationAttributeConfig('d')]);

  SVGPathElement(super.context) {}

  @override
  RenderBoxModel createRenderSVG({RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    return RenderSVGPath(renderStyle: renderStyle);
  }

}
