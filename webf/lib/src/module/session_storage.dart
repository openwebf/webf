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
  dynamic invoke(String method, List<dynamic> params) {
    WebFController controller = moduleManager!.controller;
    switch (method) {
      case 'getItem':
        if (!controller.sessionStorage.containsKey(params[0])) return null;
        return controller.sessionStorage[params[0]];
      case 'setItem':
        controller.sessionStorage[params[0]] = params[1];
        break;
      case 'removeItem':
        controller.sessionStorage.remove(params[0]);
        break;
      case 'key':
        try {
          return controller.sessionStorage.keys.elementAt(params[0]);
        } catch(e, stack) {
          return null;
        }
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
