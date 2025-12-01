/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */


import 'package:webf/bridge.dart';
import 'dom_point_readonly.dart';

class DOMPoint extends DOMPointReadOnly {
  DOMPoint(BindingContext context, List<dynamic> domPointInit) : super(context, domPointInit) {}

  DOMPoint.fromPoint(BindingContext context, DOMPoint? point) : super.fromPoint(context, point) {}
}
