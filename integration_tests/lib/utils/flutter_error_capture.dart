import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

class FlutterErrorCapture {
  static bool _installed = false;

  static FlutterExceptionHandler? _previousFlutterOnError;
  static ui.PlatformDispatcher? _platformDispatcher;
  static ui.ErrorCallback? _previousPlatformOnError;

  static FlutterErrorDetails? _lastFlutterError;
  static Object? _lastZoneError;
  static StackTrace? _lastZoneStack;

  static void install() {
    if (_installed) return;
    _installed = true;

    _previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      _lastFlutterError = details;
      if (_previousFlutterOnError != null) {
        _previousFlutterOnError!(details);
      } else {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    _platformDispatcher = ui.PlatformDispatcher.instance;
    _previousPlatformOnError = _platformDispatcher!.onError;
    _platformDispatcher!.onError = (Object error, StackTrace stack) {
      _lastZoneError = error;
      _lastZoneStack = stack;
      return _previousPlatformOnError?.call(error, stack) ?? false;
    };
  }

  static void recordZoneError(Object error, StackTrace stack) {
    _lastZoneError = error;
    _lastZoneStack = stack;
  }

  static void clear() {
    _lastFlutterError = null;
    _lastZoneError = null;
    _lastZoneStack = null;
  }

  static String? peekAsString() {
    final FlutterErrorDetails? flutterError = _lastFlutterError;
    if (flutterError != null) {
      final buffer = StringBuffer();
      buffer.writeln(flutterError.exceptionAsString());
      final StackTrace? stack = flutterError.stack;
      if (stack != null) buffer.writeln(stack.toString());
      return buffer.toString().trim();
    }

    final Object? zoneError = _lastZoneError;
    if (zoneError != null) {
      final buffer = StringBuffer();
      buffer.writeln(zoneError.toString());
      final StackTrace? stack = _lastZoneStack;
      if (stack != null) buffer.writeln(stack.toString());
      return buffer.toString().trim();
    }

    return null;
  }

  static String? takeAsString() {
    final String? result = peekAsString();
    clear();
    return result;
  }
}
