/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/webf.dart';

class HybridHistoryItem {
  HybridHistoryItem(this.bundle, this.state, this.needJump);
  final WebFBundle bundle;
  final dynamic state;
  final bool needJump;
}

class HybridHistoryModule extends BaseModule {
  @override
  String get name => 'HybridHistory';

  HybridHistoryModule(ModuleManager? moduleManager) : super(moduleManager);

  void back() async {
    Navigator.pop(moduleManager!.controller.ownerBuildContext!);
  }

  void forward() {}

  void go(num? num) {}

  void pushState(state, {String? url, String? title}) {
    if (url != null) {
      Navigator.pushNamed(moduleManager!.controller.ownerBuildContext!, url, arguments: state);
    }
  }

  void replaceState(state, {String? url, String? title}) {

  }

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'length':
        return '0';
      case 'state':
      case 'back':
        back();
        break;
      case 'forward':
        forward();
        break;
      case 'pushState':
        pushState(params[0], title: params[1], url: params[2]);
        break;
      case 'replaceState':
        replaceState(params[0], title: params[1], url: params[2]);
        break;
      case 'go':
        go(params);
        break;
    }
    return EMPTY_STRING;
  }

  @override
  void dispose() {}
}
