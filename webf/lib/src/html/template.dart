/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';
import 'package:webf/dom.dart';

// ignore: constant_identifier_names
const String TEMPLATE = 'TEMPLATE';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: NONE,
};

class TemplateElement extends Element {
  TemplateElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}
