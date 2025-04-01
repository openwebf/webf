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

abstract class HybridHistoryDelegate {
  void back(BuildContext context);

  void pushState(BuildContext context, state, String name);

  void replaceState(BuildContext context, state, String name);

  String path(BuildContext context);

  dynamic state(BuildContext context, Map<String, dynamic>? initialState);
}

class HybridHistoryModule extends BaseModule {
  @override
  String get name => 'HybridHistory';

  HybridHistoryDelegate? _delegate;

  set delegate(HybridHistoryDelegate value) {
    _delegate = value;
  }

  HybridHistoryModule(ModuleManager? moduleManager) : super(moduleManager);

  void back() async {
    if (_delegate != null) {
      _delegate!.back((moduleManager!.controller.currentBuildContext!));
      return;
    }
    Navigator.pop(moduleManager!.controller.currentBuildContext!);
  }

  void pushState(state, String name) {
    if (_delegate != null) {
      _delegate!.pushState(moduleManager!.controller.currentBuildContext!, state, name);
      return;
    }
    Navigator.pushNamed(moduleManager!.controller.currentBuildContext!, name, arguments: state);
  }

  void replaceState(state, String name) {
    if (_delegate != null) {
      _delegate!.replaceState(moduleManager!.controller.currentBuildContext!, state, name);
      return;
    }
    Navigator.pushReplacementNamed(moduleManager!.controller.currentBuildContext!, name, arguments: state);
  }

  String path() {
    if (_delegate != null) {
      return _delegate!.path(moduleManager!.controller.currentBuildContext!);
    }
    String? currentPath = ModalRoute.of(moduleManager!.controller.currentBuildContext!)?.settings.name;
    return currentPath ?? '';
  }

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'state':
        Map<String, dynamic>? initialState = moduleManager!.controller.initialState;

        if (_delegate != null) {
          return _delegate!.state(moduleManager!.controller.currentBuildContext!, initialState);
        }

        var route = ModalRoute.of(moduleManager!.controller.currentBuildContext!);

        if (route?.settings.arguments != null) {
          return jsonEncode(route!.settings.arguments);
        } else if (route?.settings.name == null && initialState != null) {
          return jsonEncode(initialState);
        }
        return '{}';
      case 'back':
        back();
        break;
      case 'pushState':
        pushState(params[0], params[1]);
        break;
      case 'replaceState':
        replaceState(params[0], params[1]);
        break;
      case 'path':
        return path();
    }
    return EMPTY_STRING;
  }

  @override
  void dispose() {}
}
