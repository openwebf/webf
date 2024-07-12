/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/svg.dart';

class SVGLinearGradientElement extends DefsAttributeElement {

  SVGLinearGradientElement([BindingContext? context]) : super(context);

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      DefsAttributeConfig('id', property: true),
      DefsAttributeConfig('x1', property: true),
      DefsAttributeConfig('y1', property: true),
      DefsAttributeConfig('x2', property: true),
      DefsAttributeConfig('y2', property: true),
      DefsAttributeConfig('gradientUnits', property: true),
    ]);

  final List<double> _stops = [];
  final List<Color> _colors = [];

  List<double> get stops => _stops;

  List<Color> get colors => _colors;

  void parseCSSColorStop() {
    // NodeList nodeList = childNodes;
    // Iterator iterator = nodeList.iterator;
    // while (iterator.moveNext()) {
    //   if (iterator.current is SVGGradientStopElement) {
    //     SVGGradientStopElement element = iterator.current;
    //     Color? color = CSSColor.parseColor(element.attributes['stop-color']!);
    //     double stop = double.parse(element.attributes['offset'] ?? '0');
    //     if (color != null) {
    //       _stops.add(stop);
    //       _colors.add(color);
    //     }
    //   }
    // }
  }

}
