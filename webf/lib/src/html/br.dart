/*
 * Copyright (C) 2024-present The OpenWebF(Cayman) Company. All rights reserved.
 */

import 'package:flutter/widgets.dart' as flutter;
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/bridge.dart';

// https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlbrelement
class BRElement extends Element {
  BRElement([BindingContext? context]) : super(context);

  @override
  void setRenderStyle(String property, String present, { String? baseHref }) {
    // Noop
  }
}
