/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'package:webf/bridge.dart' as bridge;
import 'package:webf/src/module/dom_point.dart';
import 'package:webf/webf.dart';
import 'local_storage.dart';
import 'session_storage.dart';
import 'websocket.dart';
import 'text_codec.dart';

abstract class WebFBaseModule {
  String get name;

  final ModuleManager? moduleManager;

  WebFBaseModule(this.moduleManager);

  dynamic invoke(String method, List<dynamic> params);

  dynamic dispatchEvent({Event? event, data}) {
    return moduleManager!.emitModuleEvent(name, event: event, data: data);
  }

  Future<void> initialize() async {}

  void dispose();
}

@Deprecated('Use WebFBaseModule instead')
typedef BaseModule = WebFBaseModule;

typedef InvokeModuleCallback = Future<dynamic> Function({String? error, Object? data});
typedef NewModuleCreator = WebFBaseModule Function(ModuleManager);
typedef ModuleCreator = WebFBaseModule Function(ModuleManager? moduleManager);

final magicResultForAsync = 0x01fa2f << 4;

bool _isDefined = false;

void _defineModuleCreator() {
  if (_isDefined) return;
  _isDefined = true;
  _defineModule((ModuleManager? moduleManager) => AsyncStorageModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => ClipBoardModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => FetchModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => MethodChannelModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => NavigationModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => NavigatorModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => HistoryModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => HybridHistoryModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => LocationModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => LocalStorageModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => SessionStorageModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => WebSocketModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => DOMMatrixModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => DOMPointModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => TextCodecModule(moduleManager));
}

final Map<String, ModuleCreator> _creatorMap = {};
final Map<String, ModuleCreator> _customizedCreatorMap = {};

void _defineModule(ModuleCreator moduleCreator) {
  WebFBaseModule fakeModule = moduleCreator(null);
  _creatorMap[fakeModule.name] = moduleCreator;
}

void _defineCustomModule(ModuleCreator moduleCreator) {
  WebFBaseModule customModule = moduleCreator(null);
  _customizedCreatorMap[customModule.name] = moduleCreator;
}

class ModuleManager {
  final double contextId;
  final WebFController controller;
  final Map<String, WebFBaseModule> _moduleMap = {};
  bool disposed = false;

  ModuleManager(this.controller, this.contextId) {
    // Init all module instances.
    _defineModuleCreator();
    _creatorMap.forEach((String name, ModuleCreator creator) {
      _moduleMap[name] = creator(this);
    });
    _customizedCreatorMap.forEach((String name, ModuleCreator creator) {
      _moduleMap[name] = creator(this);
    });
  }

  Future<void> initialize() async {
    await Future.wait(_moduleMap.values.map((module) { return module.initialize(); }));
  }

  T? getModule<T extends WebFBaseModule>(String moduleName) {
    return _moduleMap[moduleName] as T?;
  }

  static void defineModule(ModuleCreator moduleCreator) {
    _defineCustomModule(moduleCreator);
  }

  dynamic emitModuleEvent(String moduleName, {Event? event, data}) {
    return bridge.emitModuleEvent(contextId, moduleName, event, data);
  }

  dynamic invokeModule(String moduleName, String method, params, InvokeModuleCallback callback) {
    ModuleCreator? creator = _customizedCreatorMap[moduleName] ?? _creatorMap[moduleName];
    if (creator == null) {
      throw Exception('ModuleManager: Can not find module of name: $moduleName');
    }

    if (!_moduleMap.containsKey(moduleName)) {
      _moduleMap[moduleName] = creator(this);
    }

    WebFBaseModule module = _moduleMap[moduleName]!;

    handleInvokeModuleWithFuture({String? error, Object? data}) async {
      if (disposed) {
        return null;
      }
      return callback(error: error, data: data);
    }

    dynamic result = module.invoke(method, params);

    if (result is Future) {
      result.then((result) {
        handleInvokeModuleWithFuture(data: result);
      }).catchError((e, stack) {
        String errmsg = '$e\n$stack';
        handleInvokeModuleWithFuture(error: errmsg);
      });
      return magicResultForAsync;
    }

    return result;
  }

  void dispose() {
    disposed = true;
    _moduleMap.forEach((key, module) {
      module.dispose();
    });
  }
}
