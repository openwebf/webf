/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'package:webf/dom.dart';
import 'package:webf/css.dart';

const String TOUCH_AREA = 'WEBF-TOUCHAREA';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class WebFTouchAreaElement extends Element {
  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  WebFTouchAreaElement(super.context);
}
