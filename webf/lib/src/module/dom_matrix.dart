/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:webf/bridge.dart';
import 'package:webf/geometry.dart';
import 'package:webf/module.dart';

class DOMMatrixModule extends BaseModule {
  DOMMatrixModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  dynamic invoke(String method, List<dynamic> params) {
    if (method == 'fromMatrix') {
      final firstValue = params[0];
      if (firstValue.runtimeType == DOMMatrix) {
        DOMMatrix domMatrix = firstValue;
        return DOMMatrix.fromMatrix4(
            BindingContext(domMatrix.ownerView, domMatrix.ownerView.contextId, allocateNewBindingObject()),
            domMatrix.matrix.clone(),
            domMatrix.is2D);
      }
    }
  }

  @override
  String get name => 'DOMMatrix';

}
