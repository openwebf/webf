/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart';
import 'package:webf/svg.dart';

final Map<String, ElementCreator> svgElementsRegistry = {
  TAG_SVG: (context) => SVGSVGElement(context),
  TAG_RECT: (context) => SVGRectElement(context),
  TAG_PATH: (context) => SVGPathElement(context),
  TAG_TEXT: (context) => SVGTextElement(context),
  TAG_G: (context) => SVGGElement(context),
  TAG_CIRCLE: (context) => SVGCircleElement(context),
  TAG_ELLIPSE: (context) => SVGEllipseElement(context),
  TAG_STYLE: (context) => SVGStyleElement(context),
  TAG_LINE: (context) => SVGLineElement(context),
};
