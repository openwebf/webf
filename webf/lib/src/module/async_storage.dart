/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:webf/src/module/module_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AsyncStorageModule extends BaseModule {
  @override
  String get name => 'AsyncStorage';

  static Future<SharedPreferences>? _prefs;

  AsyncStorageModule(ModuleManager? moduleManager) : super(moduleManager);

  /// Loads and parses the [SharedPreferences] for this app from disk.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  static Future<SharedPreferences> _getPrefs() {
    _prefs ??= SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<bool> setItem(String key, String value) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.setString(key, value);
  }

  static Future<String?> getItem(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString(key);
  }

  static Future<bool> removeItem(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.remove(key);
  }

  static Future<Set<String>> getAllKeys() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getKeys();
  }

  static Future<bool> clear() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.clear();
  }

  static Future<int> length() async {
    final SharedPreferences prefs = await _getPrefs();
    final Set<String> keys = prefs.getKeys();
    return keys.length;
  }

  @override
  void dispose() {}

  @override
  FutureOr<String> invoke(String method, params, InvokeModuleCallback callback) async {
    try {
      switch (method) {
        case 'getItem':
          String? value = await AsyncStorageModule.getItem(params);
          callback(data: value ?? '');;
          break;
        case 'setItem':
          String key = params[0];
          String value = params[1];
          bool isSuccess = await AsyncStorageModule.setItem(key, value);
          callback(data: isSuccess.toString());
          break;
        case 'removeItem':
          bool isSuccess = await AsyncStorageModule.removeItem(params);
          callback(data: isSuccess.toString());
          break;
        case 'getAllKeys':
          Set<String> set = await AsyncStorageModule.getAllKeys();
          List<String> list = List.from(set);
          callback(data: list);
          break;
        case 'clear':
          bool isSuccess = await AsyncStorageModule.clear();
          callback(data: isSuccess.toString());
          break;
        case 'length':
          int length = await AsyncStorageModule.length();
          callback(data: length);
          break;
        default:
          throw Exception('AsyncStorage: Unknown method $method');
      }
    } catch (e, stack) {
      callback(error: '$e\n$stack');
    }

    return '';
  }
}
