/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/svg.dart';

import 'rendering/ellipse.dart';

class SVGEllipseElement extends SVGGeometryElement {
  @override
  // TODO: implement defaultStyle
  Map<String, dynamic> get defaultStyle => super.defaultStyle
    ..addAll({
      RX: 'auto',
      RY: 'auto',
    });

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      SVGPresentationAttributeConfig('cx'),
      SVGPresentationAttributeConfig('cy'),
      SVGPresentationAttributeConfig('rx'),
      SVGPresentationAttributeConfig('ry'),
      SVGPresentationAttributeConfig('r'),
    ]);

  SVGEllipseElement(super.context) {}

  @override
  RenderBoxModel createRenderSVG({RenderBoxModel? previous, bool isRepaintBoundary = false}) {
    return RenderSVGEllipse(renderStyle: renderStyle);
  }

}
