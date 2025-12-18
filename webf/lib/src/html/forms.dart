/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'package:webf/css.dart';
import 'package:webf/dom.dart';

const String LABEL = 'LABEL';
const String BUTTON = 'BUTTON';

// UA default styling for <button>: inline-block with a visible border and padding.
// We keep values conservative and consistent with input[type=button] UA defaults.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '2px solid rgb(118, 118, 118)',
  PADDING: '1px 6px',
};

class LabelElement extends Element {
  LabelElement([super.context]);
}

class ButtonElement extends Element {
  ButtonElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}
