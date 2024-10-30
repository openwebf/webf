/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:typed_data';

import 'package:vector_math/vector_math_64.dart';
import 'package:webf/foundation.dart';
import 'dom_matrix_readonly.dart';

class DOMMatrix extends DOMMatrixReadonly {
  DOMMatrix(BindingContext context, List<dynamic> domMatrixInit) : super(context, domMatrixInit) {
  }

  DOMMatrix.fromMatrix4(BindingContext context, Matrix4? matrix4, bool flag2D) : super.fromMatrix4(context, matrix4, flag2D) {
  }
}
