/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */


import 'dom_matrix_readonly.dart';

class DOMMatrix extends DOMMatrixReadOnly {
  DOMMatrix(super.context, super.domMatrixInit);

  DOMMatrix.fromMatrix4(super.context, super.matrix4, super.flag2D) : super.fromMatrix4();
}
