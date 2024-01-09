/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */

import 'package:webf/svg.dart';

class SVGGradientStopElement extends DefsAttributeElement {
  SVGGradientStopElement(super.context);

  @override
  get presentationAttributeConfigs => super.presentationAttributeConfigs
    ..addAll([
      DefsAttributeConfig('offset', property: true),
      DefsAttributeConfig('stop-color', property: true)
    ]);
}
