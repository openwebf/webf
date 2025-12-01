/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */


import 'package:vector_math/vector_math_64.dart';
import 'package:webf/bridge.dart';
import 'dom_matrix_readonly.dart';

class DOMMatrix extends DOMMatrixReadOnly {
  DOMMatrix(BindingContext context, List<dynamic> domMatrixInit) : super(context, domMatrixInit) {
  }

  DOMMatrix.fromMatrix4(BindingContext context, Matrix4? matrix4, bool flag2D) : super.fromMatrix4(context, matrix4, flag2D) {
  }
}
