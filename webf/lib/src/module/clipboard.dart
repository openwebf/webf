/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:webf/src/module/module_manager.dart';

class ClipBoardModule extends BaseModule {
  @override
  String get name => 'Clipboard';
  ClipBoardModule(ModuleManager? moduleManager) : super(moduleManager);

  static Future<String> readText() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null) return '';
    return data.text ?? '';
  }

  static Future<void> writeText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  void dispose() {}

  @override
  FutureOr<String> invoke(String method, params, callback) async {
    try {

    } catch (e, stack) {
      callback(error: '$e\n$stack');
    }
    if (method == 'readText') {
      String value = await ClipBoardModule.readText();
      callback(data: value);
    } else if (method == 'writeText') {
      await ClipBoardModule.writeText(params);
      callback();
    }

    return '';
  }
}
