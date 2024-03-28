/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';

import 'rendering/path.dart';

class SVGPathElement extends SVGGeometryElement {

  @override
  get renderBoxModel => renderSVGBox;

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([SVGPresentationAttributeConfig('d')]);

  SVGPathElement(super.context);

  @override
  dynamic createRenderBoxModel() {
    return RenderSVGPath(renderStyle: renderStyle, element: this);
  }
}
