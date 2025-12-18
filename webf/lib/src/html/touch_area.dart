/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:webf/dom.dart';
import 'package:webf/css.dart';

// ignore: constant_identifier_names
const String TOUCH_AREA = 'WEBF-TOUCHAREA';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

// Avoid generate bindings for this special element
class WebFTouchAreaElement extends Element {
  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  WebFTouchAreaElement(super.context);
}
