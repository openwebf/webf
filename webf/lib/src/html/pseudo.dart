/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

const String BEFORE = 'before';
const String AFTER = 'after';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class BeforePseudoElement extends Element {
  BeforePseudoElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}

class AfterPseudoElement extends Element {
  AfterPseudoElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}
