/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */


import 'dom_point_readonly.dart';

class DOMPoint extends DOMPointReadOnly {
  DOMPoint(super.context, super.domPointInit);

  DOMPoint.fromPoint(super.context, super.point) : super.fromPoint();
}
