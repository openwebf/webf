/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:webf/bridge.dart';
import 'package:webf/module.dart';
import 'package:webf/src/geometry/dom_point.dart';

class DOMPointModule extends BaseModule {
  DOMPointModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  dynamic invoke(String method, params) {
    if (method == 'fromPoint') {
      if (params.runtimeType == DOMPoint) {
        DOMPoint domPoint = (params as DOMPoint);

        return DOMPoint.fromPoint(
            BindingContext(domPoint.ownerView, domPoint.ownerView.contextId, allocateNewBindingObject()), domPoint);
      }
    }
  }

  @override
  String get name => 'DOMPoint';

}
