/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/bridge.dart' as bridge;
import 'package:webf/webf.dart';
import 'local_storage.dart';
import 'session_storage.dart';
import 'websocket.dart';

abstract class BaseModule {
  String get name;
  final ModuleManager? moduleManager;
  BaseModule(this.moduleManager);
  dynamic invoke(String method, params, InvokeModuleCallback callback);
  dynamic dispatchEvent({Event? event, data}) {
    return moduleManager!.emitModuleEvent(name, event: event, data: data);
  }

  Future<void> initialize() async {
  }

  void dispose();
}

typedef InvokeModuleCallback = Future<dynamic> Function({String? error, Object? data});
typedef NewModuleCreator = BaseModule Function(ModuleManager);
typedef ModuleCreator = BaseModule Function(ModuleManager? moduleManager);

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
  _defineModule((ModuleManager? moduleManager) => LocationModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => LocalStorageModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => SessionStorageModule(moduleManager));
  _defineModule((ModuleManager? moduleManager) => WebSocketModule(moduleManager));
}

final Map<String, ModuleCreator> _creatorMap = {};

void _defineModule(ModuleCreator moduleCreator) {
  BaseModule fakeModule = moduleCreator(null);
  if (_creatorMap.containsKey(fakeModule.name)) {
    return;
  }
  _creatorMap[fakeModule.name] = moduleCreator;
}

class ModuleManager {
  final int contextId;
  final WebFController controller;
  final Map<String, BaseModule> _moduleMap = {};
  bool disposed = false;

  ModuleManager(this.controller, this.contextId) {
    // Init all module instances.
    _defineModuleCreator();
    _creatorMap.forEach((String name, ModuleCreator creator) {
      _moduleMap[name] = creator(this);
    });
  }

  Future<void> initialize() async {
    await Future.wait(_moduleMap.values.map((module) { return module.initialize(); }));
  }

  T? getModule<T extends BaseModule>(String moduleName) {
    return _moduleMap[moduleName] as T?;
  }

  static void defineModule(ModuleCreator moduleCreator) {
    _defineModule(moduleCreator);
  }

  dynamic emitModuleEvent(String moduleName, {Event? event, data}) {
    return bridge.emitModuleEvent(contextId, moduleName, event, data);
  }

  dynamic invokeModule(String moduleName, String method, params, InvokeModuleCallback callback) {
    ModuleCreator? creator = _creatorMap[moduleName];
    if (creator == null) {
      throw Exception('ModuleManager: Can not find module of name: $moduleName');
    }

    if (!_moduleMap.containsKey(moduleName)) {
      _moduleMap[moduleName] = creator(this);
    }

    BaseModule module = _moduleMap[moduleName]!;
    return module.invoke(method, params, ({String? error, Object? data}) async {
      if (disposed) {
        return null;
      }
      return callback(error: error, data: data);
    });
  }

  void dispose() {
    disposed = true;
    _moduleMap.forEach((key, module) {
      module.dispose();
    });
  }
}
