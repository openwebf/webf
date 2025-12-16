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

// https://developer.mozilla.org/en-US/docs/Web/HTML/Element#demarcating_edits
const String DEL = 'DEL';
const String INS = 'INS';

const Map<String, dynamic> _insDefaultStyle = {TEXT_DECORATION: UNDERLINE};

const Map<String, dynamic> _delDefaultStyle = {TEXT_DECORATION: LINE_THROUGH};

class DelElement extends Element {
  DelElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _delDefaultStyle;
}

class InsElement extends Element {
  InsElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _insDefaultStyle;
}
