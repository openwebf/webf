/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'package:webf/module.dart';
import 'package:webf/launcher.dart';

class SessionStorageModule extends BaseModule {
  @override
  String get name => 'SessionStorage';

  @override
  Future<void> initialize() async {}

  SessionStorageModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  dynamic invoke(String method, params, InvokeModuleCallback callback) {
    WebFController controller = moduleManager!.controller;
    switch (method) {
      case 'getItem':
        if (!controller.sessionStorage.containsKey(params)) return null;
        return controller.sessionStorage[params];
      case 'setItem':
        controller.sessionStorage[params[0]] = params[1];
        break;
      case 'removeItem':
        controller.sessionStorage.remove(params);
        break;
      case 'key':
        return controller.sessionStorage.keys.elementAt(params);
      case 'clear':
        controller.sessionStorage.clear();
        break;
      case 'length':
        return controller.sessionStorage.length;
      case '_getAllKeys':
        return controller.sessionStorage.keys.toList();
      default:
        throw Exception('SessionStorage: Unknown method $method');
    }

    return '';
  }
}
