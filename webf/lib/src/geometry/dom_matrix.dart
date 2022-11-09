/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/foundation.dart';
import 'dom_matrix_readonly.dart';

class DOMMatrix extends DOMMatrixReadonly {
  DOMMatrix(BindingContext context, List<dynamic> domMatrixInit): super(context, domMatrixInit) {
    print('domMatrix init: $domMatrixInit');
  }
}
