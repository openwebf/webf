/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';

// CSS Order: https://drafts.csswg.org/css-flexbox/#order-property

mixin CSSOrderMixin on RenderStyle {
  @override
  int get order => _order ?? 0;
  int? _order;
  set order(int? value) {
    if (_order == value) {
      return;
    }
    _order = value;
    // Order changes require relayout of the flex container
    if (isParentRenderFlexLayout()) {
      markParentNeedsRelayout();
    }
  }

  static int? resolveOrder(String orderValue) {
    if (orderValue == 'initial' || orderValue == 'unset') {
      return 0;
    }
    return int.tryParse(orderValue);
  }
}

class CSSOrder {
  static bool isValidOrderValue(String val) {
    // Order accepts integers (including negative)
    return int.tryParse(val) != null || val == 'initial' || val == 'unset';
  }
}
