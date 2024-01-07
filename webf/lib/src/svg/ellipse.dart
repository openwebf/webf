/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/svg.dart';

import 'rendering/ellipse.dart';

class SVGEllipseElement extends SVGGeometryElement {
  RenderSVGEllipse? _renderer;

  @override
  // TODO: implement defaultStyle
  Map<String, dynamic> get defaultStyle => super.defaultStyle
    ..addAll({
      RX: 'auto',
      RY: 'auto',
    });

  @override
  get renderBoxModel => _renderer;

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
  createRenderer() {
    return _renderer = RenderSVGEllipse(renderStyle: renderStyle, element: this);
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _renderer = null;
  }
}
