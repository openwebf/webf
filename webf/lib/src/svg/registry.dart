/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart';
import 'package:webf/src/svg/line.dart';
import 'package:webf/svg.dart';

final Map<String, ElementCreator> svgElementsRegistry = {
  'SVG': (context) => SVGSVGElement(context),
  'RECT': (context) => SVGRectElement(context),
  'PATH': (context) => SVGPathElement(context),
  'TEXT': (context) => SVGTextElement(context),
  'G': (context) => SVGGElement(context),
  'CIRCLE': (context) => SVGCircleElement(context),
  'ELLIPSE': (context) => SVGEllipseElement(context),
  'STYLE': (context) => SVGStyleElement(context),
  'LINE': (context) => SVGLineElement(context),
};
