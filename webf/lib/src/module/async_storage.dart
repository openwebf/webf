/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';
import 'package:webf/foundation.dart';
import 'package:webf/src/module/module_manager.dart';

class AsyncStorageModule extends BaseModule {
  @override
  String get name => 'AsyncStorage';

  static String getBoxKey(ModuleManager moduleManager) {
    String origin = moduleManager.controller.origin + '_async';
    int fileCheckSum = getCrc32(origin.codeUnits);
    return '_webf_$fileCheckSum';
  }

  AsyncStorageModule(ModuleManager? moduleManager) : super(moduleManager);

  late LazyBox<String> _lazyBox;

  @override
  Future<void> initialize() async {
    final key = getBoxKey(moduleManager!);
    final tmpPath = await getWebFTemporaryPath();
    final storagePath = path.join(tmpPath, 'AsyncStorage');
    try {
      _lazyBox = await Hive.openLazyBox(key, path: storagePath);
    } catch (e) {
      // Try again to avoid resources are temporarily unavailable.
      _lazyBox = await Hive.openLazyBox(key, path: storagePath);
    }
  }

  Future<bool> setItem(String key, String value) async {
    try {
      await _lazyBox.put(key, value);
      return true;
    } catch (e, stack) {
      return false;
    }
  }

  Future<String?> getItem(String key) async {
    return _lazyBox.get(key);
  }

  Future<bool> removeItem(String key) async {
    try {
      await _lazyBox.delete(key);
      return true;
    } catch (e, stack) {
      return false;
    }
  }

  Future<Set<dynamic>> getAllKeys() async {
    Set<dynamic> keys = _lazyBox.keys.toSet();
    return keys;
  }

  Future<bool> clear() async {
    await _lazyBox.clear();
    return true;
  }

  Future<int> length() async {
    return _lazyBox.length;
  }

  @override
  void dispose() {}

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'getItem':
        getItem(params).then((String? value) {
          callback(data: value ?? '');
        }).catchError((e, stack) {
          callback(error: '$e\n$stack');
        });
        break;
      case 'setItem':
        String key = params[0];
        String value = params[1];
        setItem(key, value).then((bool isSuccess) {
          callback(data: isSuccess.toString());
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      case 'removeItem':
        removeItem(params).then((bool isSuccess) {
          callback(data: isSuccess.toString());
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      case 'getAllKeys':
        getAllKeys().then((Set<dynamic> set) {
          List<String> list = List.from(set);
          callback(data: list);
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      case 'clear':
        clear().then((bool isSuccess) {
          callback(data: isSuccess.toString());
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      case 'length':
        length().then((int length) {
          callback(data: length);
        }).catchError((e, stack) {
          callback(error: 'Error: $e\n$stack');
        });
        break;
      default:
        throw Exception('AsyncStorage: Unknown method $method');
    }

    return '';
  }
}
