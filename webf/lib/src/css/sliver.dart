/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';

mixin CSSSliverMixin on RenderStyle {
  @override
  Axis get sliverDirection => _sliverDirection ?? Axis.vertical;
  Axis? _sliverDirection;
  set sliverDirection(Axis? value) {
    if (_sliverDirection == value) return;
    _sliverDirection = value;
    markNeedsLayout();
  }

  static Axis resolveAxis(String sliverDirection) {
    switch (sliverDirection) {
      case ROW:
        return Axis.horizontal;

      case COLUMN:
      default:
        return Axis.vertical;
    }
  }
}
