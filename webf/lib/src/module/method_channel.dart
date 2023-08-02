/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:webf/webf.dart';

// ignore: avoid_annotating_with_dynamic
typedef MethodCallCallback = Future<dynamic> Function(String method, dynamic args);
const String METHOD_CHANNEL_NOT_INITIALIZED = 'MethodChannel not initialized.';
const String CONTROLLER_NOT_INITIALIZED = 'WebF controller not initialized.';
const String METHOD_CHANNEL_NAME = 'MethodChannel';

class MethodChannelModule extends BaseModule {
  @override
  String get name => METHOD_CHANNEL_NAME;
  MethodChannelModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  dynamic invoke(String method, params, callback) {
    if (method == 'invokeMethod') {
      _invokeMethodFromJavaScript(moduleManager!.controller, params[0], params[1]).then((result) {
        callback(data: result);
      }).catchError((e, stack) {
        callback(error: '$e\n$stack');
      });
    }
    return '';
  }
}

abstract class WebFMethodChannel {
  MethodCallCallback? _onJSMethodCallCallback;

  set _onJSMethodCall(MethodCallCallback? value) {
    assert(value != null);
    _onJSMethodCallCallback = value;
  }

  Future<dynamic> invokeMethodFromJavaScript(String method, List arguments);

  static void setJSMethodCallCallback(WebFController controller) {
    controller.methodChannel?._onJSMethodCall = (String method, arguments) async {
      try {
        return controller.module.moduleManager.emitModuleEvent(METHOD_CHANNEL_NAME, data: [method, arguments]);
      } catch (e, stack) {
        print('Error invoke module event: $e, $stack');
      }
    };
  }
}

class WebFJavaScriptChannel extends WebFMethodChannel {
  Future<dynamic> invokeMethod(String method, arguments) async {
    MethodCallCallback? jsMethodCallCallback = _onJSMethodCallCallback;
    if (jsMethodCallCallback != null) {
      return jsMethodCallCallback(method, arguments);
    } else {
      return null;
    }
  }

  MethodCallCallback? _methodCallCallback;

  MethodCallCallback? get methodCallCallback => _methodCallCallback;

  set onMethodCall(MethodCallCallback? value) {
    assert(value != null);
    _methodCallCallback = value;
  }

  @override
  Future<dynamic> invokeMethodFromJavaScript(String method, List arguments) {
    MethodCallCallback? methodCallCallback = _methodCallCallback;
    if (methodCallCallback != null) {
      return _methodCallCallback!(method, arguments);
    } else {
      return Future.value(null);
    }
  }
}

Future<dynamic> _invokeMethodFromJavaScript(WebFController? controller, String method, List args) {
  WebFMethodChannel? webFMethodChannel = controller?.methodChannel;
  if (webFMethodChannel != null) {
    return webFMethodChannel.invokeMethodFromJavaScript(method, args);
  } else {
    return Future.error(FlutterError(METHOD_CHANNEL_NOT_INITIALIZED));
  }
}
