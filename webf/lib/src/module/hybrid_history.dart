/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';

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
    Navigator.pop(moduleManager!.controller.buildContextStack.last);
  }

  void pushState(state, String name) {
    Navigator.pushNamed(moduleManager!.controller.buildContextStack.last, name, arguments: state);
  }

  String path() {
    String? currentPath = ModalRoute.of(moduleManager!.controller.buildContextStack.last)?.settings.name;
    return currentPath ?? '';
  }

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'state':
        var route = ModalRoute.of(moduleManager!.controller.buildContextStack.last);
        if (route?.settings.arguments != null) {
          return jsonEncode(route!.settings.arguments);
        }
        return '{}';
      case 'back':
        back();
        break;
      case 'pushState':
        pushState(params[0], params[1]);
        break;
      case 'path':
        return path();
    }
    return EMPTY_STRING;
  }

  @override
  void dispose() {}
}
