/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */


import 'package:webf/bridge.dart';
import 'dom_point_readonly.dart';

class DOMPoint extends DOMPointReadOnly {
  DOMPoint(BindingContext context, List<dynamic> domPointInit) : super(context, domPointInit) {}

  DOMPoint.fromPoint(BindingContext context, DOMPoint? point) : super.fromPoint(context, point) {}
}
