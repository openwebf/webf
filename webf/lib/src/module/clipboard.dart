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
  Future<dynamic> invoke(String method, params) {
    Completer<dynamic> completer = Completer();
    if (method == 'readText') {
      ClipBoardModule.readText().then((String value) {
        completer.complete(value);
      }).catchError((e, stack) {
        completer.completeError(e, stack);
      });
    } else if (method == 'writeText') {
      ClipBoardModule.writeText(params).then((_) {
        completer.complete();
      }).catchError((e, stack) {
        completer.completeError(e, stack);
      });
    }
    return completer.future;
  }
}
