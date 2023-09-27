/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
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
    String tmpPath = await getWebFTemporaryPath();
    Hive.init(path.join(tmpPath, 'LocalStorage'));
    String key = getBoxKey(moduleManager!);
    File lockFile = File(path.join(tmpPath, 'LocalStorage', '$key.lock'));
    if (await lockFile.exists()) {
      await lockFile.delete();
    }

    try {
      await Hive.openBox(key);
    } catch (e) {
      // Try twice to avoid Resource temporarily unavailable.
      await Hive.openBox(key);
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
