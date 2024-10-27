/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:typed_data';

import 'package:vector_math/vector_math_64.dart';
import 'package:webf/foundation.dart';
import 'dom_matrix_readonly.dart';

class DOMMatrix extends DOMMatrixReadonly {
  DOMMatrix(BindingContext context, List<dynamic> domMatrixInit) : super(context, domMatrixInit) {
    // print('domMatrix init: $domMatrixInit');
  }

  DOMMatrix.fromFloat64List(BindingContext context, Float64List list) : super.fromFloat64List(context, list) {
    // print('domMatrix init Float64List: list');
  }

  DOMMatrix.fromMatrix4(BindingContext context, Matrix4? matrix4) : super.fromMatrix4(context, matrix4) {
    // print('domMatrix init Matrix4: $matrix4');
  }
}
