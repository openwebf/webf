/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';

mixin CSSInputMixin on RenderStyle {
  Color? _caretColor;
  @override
  Color? get caretColor => _caretColor;

  set caretColor(Color? value) {
    if (_caretColor == value) return;
    _caretColor = value;
    markNeedsLayout();
  }
}
