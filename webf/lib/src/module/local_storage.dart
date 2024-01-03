/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';
import 'package:webf/foundation.dart';
import 'package:webf/module.dart';

class LocalStorageModule extends BaseModule {
  @override
  String get name => 'LocalStorage';

  static String getBoxKey(ModuleManager moduleManager) {
    String origin = moduleManager.controller.origin;
    int fileCheckSum = getCrc32(origin.codeUnits);
    return '_webf_$fileCheckSum';
  }

  @override
  Future<void> initialize() async {
    final key = getBoxKey(moduleManager!);
    final tmpPath = await getWebFTemporaryPath();
    final storagePath = path.join(tmpPath, 'LocalStorage');
    try {
      await Hive.openBox(key, path: storagePath);
    } catch (e) {
      // Try again to avoid resources are temporarily unavailable.
      await Hive.openBox(key, path: storagePath);
    }
  }

  LocalStorageModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  dynamic invoke(String method, params, InvokeModuleCallback callback) {
    Box box = Hive.box(getBoxKey(moduleManager!));

    switch (method) {
      case 'getItem':
        return box.get(params);
      case 'setItem':
        box.put(params[0], params[1]);
        break;
      case 'removeItem':
        box.delete(params);
        break;
      case '_getAllKeys':
        List<dynamic> keys = box.keys.toList();
        return keys;
      case 'key':
        return box.keyAt(params);
      case 'clear':
        box.keys.forEach((key) {
          box.delete(key);
        });
        break;
      case 'length':
        return box.length;
      default:
        throw Exception('LocalStorage: Unknown method $method');
    }

    return '';
  }
}
