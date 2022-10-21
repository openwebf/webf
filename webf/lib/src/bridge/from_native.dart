/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';
import 'package:webf/module.dart';
import 'package:webf/src/module/performance_timing.dart';

// An native struct can be directly convert to javaScript String without any conversion cost.
class NativeString extends Struct {
  external Pointer<Uint16> string;

  @Uint32()
  external int length;
}

String uint16ToString(Pointer<Uint16> pointer, int length) {
  return String.fromCharCodes(pointer.asTypedList(length));
}

Pointer<Uint16> _stringToUint16(String string) {
  final units = string.codeUnits;
  final Pointer<Uint16> result = malloc.allocate<Uint16>(units.length * sizeOf<Uint16>());
  final Uint16List nativeString = result.asTypedList(units.length);
  nativeString.setAll(0, units);
  return result;
}

Pointer<NativeString> stringToNativeString(String string) {
  Pointer<NativeString> nativeString = malloc.allocate<NativeString>(sizeOf<NativeString>());
  nativeString.ref.string = _stringToUint16(string);
  nativeString.ref.length = string.length;
  return nativeString;
}

int doubleToUint64(double value) {
  var byteData = ByteData(8);
  byteData.setFloat64(0, value);
  return byteData.getUint64(0);
}

int doubleToInt64(double value) {
  var byteData = ByteData(8);
  byteData.setFloat64(0, value);
  return byteData.getInt64(0);
}

double uInt64ToDouble(int value) {
  var byteData = ByteData(8);
  byteData.setInt64(0, value);
  return byteData.getFloat64(0);
}

String nativeStringToString(Pointer<NativeString> pointer) {
  return uint16ToString(pointer.ref.string, pointer.ref.length);
}

void freeNativeString(Pointer<NativeString> pointer) {
  malloc.free(pointer.ref.string);
  malloc.free(pointer);
}

// Steps for using dart:ffi to call a Dart function from C:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the Dart function.
// 3. Create a typedef for the variable that you’ll use when calling the
//    Dart function.
// 4. Open the dynamic library that register in the C.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call from C.

// Register InvokeModule
typedef NativeAsyncModuleCallback = Pointer<NativeValue> Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<Utf8> errmsg, Pointer<NativeValue> ptr);
typedef DartAsyncModuleCallback = Pointer<NativeValue> Function(
    Pointer<Void> callbackContext, int contextId, Pointer<Utf8> errmsg, Pointer<NativeValue> ptr);

typedef NativeInvokeModule = Pointer<NativeValue> Function(
    Pointer<Void> callbackContext,
    Int32 contextId,
    Pointer<NativeString> module,
    Pointer<NativeString> method,
    Pointer<NativeValue> params,
    Pointer<NativeFunction<NativeAsyncModuleCallback>>);

dynamic invokeModule(Pointer<Void> callbackContext, int contextId, String moduleName, String method, params,
    DartAsyncModuleCallback callback) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  dynamic result;

  try {
    Future<dynamic> invokeModuleCallback({String? error, data}) {
      Completer<dynamic> completer = Completer();
      // To make sure Promise then() and catch() executed before Promise callback called at JavaScript side.
      // We should make callback always async.
      Future.microtask(() {
        if (controller.view.disposed) return;

        Pointer<NativeValue> callbackResult = nullptr;
        if (error != null) {
          Pointer<Utf8> errmsgPtr = error.toNativeUtf8();
          callbackResult = callback(callbackContext, contextId, errmsgPtr, nullptr);
          malloc.free(errmsgPtr);
        } else {
          Pointer<NativeValue> dataPtr = malloc.allocate(sizeOf<NativeValue>());
          toNativeValue(dataPtr, data);
          callbackResult = callback(callbackContext, contextId, nullptr, dataPtr);
          malloc.free(dataPtr);
        }
        if (isEnabledLog) {
          print('Invoke module callback from(name: $moduleName method: $method, params: $params) return: ${fromNativeValue(callbackResult)}');
        }

        completer.complete(fromNativeValue(callbackResult));
      });
      return completer.future;
    }

    result = controller.module.moduleManager.invokeModule(
        moduleName, method, params, invokeModuleCallback);
  } catch (e, stack) {
    if (isEnabledLog) {
      print('Invoke module failed: $e\n$stack');
    }
    String error = '$e\n$stack';
    callback(callbackContext, contextId, error.toNativeUtf8(), nullptr);
  }

  if (isEnabledLog) {
    print('Invoke module name: $moduleName method: $method, params: $params return: $result');
  }

  return result;
}

Pointer<NativeValue> _invokeModule(
    Pointer<Void> callbackContext,
    int contextId,
    Pointer<NativeString> module,
    Pointer<NativeString> method,
    Pointer<NativeValue> params,
    Pointer<NativeFunction<NativeAsyncModuleCallback>> callback) {
  dynamic result = invokeModule(callbackContext, contextId, nativeStringToString(module), nativeStringToString(method),
      fromNativeValue(params), callback.asFunction());
  Pointer<NativeValue> returnValue = malloc.allocate(sizeOf<NativeValue>());
  toNativeValue(returnValue, result);
  return returnValue;
}

final Pointer<NativeFunction<NativeInvokeModule>> _nativeInvokeModule = Pointer.fromFunction(_invokeModule);

// Register reloadApp
typedef NativeReloadApp = Void Function(Int32 contextId);

void _reloadApp(int contextId) async {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;

  try {
    await controller.reload();
  } catch (e, stack) {
    print('Dart Error: $e\n$stack');
  }
}

final Pointer<NativeFunction<NativeReloadApp>> _nativeReloadApp = Pointer.fromFunction(_reloadApp);

typedef NativeAsyncCallback = Void Function(Pointer<Void> callbackContext, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncCallback = void Function(Pointer<Void> callbackContext, int contextId, Pointer<Utf8> errmsg);
typedef NativeRAFAsyncCallback = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Double data, Pointer<Utf8> errmsg);
typedef DartRAFAsyncCallback = void Function(Pointer<Void>, int contextId, double data, Pointer<Utf8> errmsg);

// Register requestBatchUpdate
typedef NativeRequestBatchUpdate = Void Function(Int32 contextId);

void _requestBatchUpdate(int contextId) {
  WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
  return controller?.module.requestBatchUpdate();
}

final Pointer<NativeFunction<NativeRequestBatchUpdate>> _nativeRequestBatchUpdate =
    Pointer.fromFunction(_requestBatchUpdate);

// Register setTimeout
typedef NativeSetTimeout = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncCallback>>, Int32);

int _setTimeout(
    Pointer<Void> callbackContext, int contextId, Pointer<NativeFunction<NativeAsyncCallback>> callback, int timeout) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;

  return controller.module.setTimeout(timeout, () {
    DartAsyncCallback func = callback.asFunction();

    void _runCallback() {
      try {
        func(callbackContext, contextId, nullptr);
      } catch (e, stack) {
        Pointer<Utf8> nativeErrorMessage = ('Error: $e\n$stack').toNativeUtf8();
        func(callbackContext, contextId, nativeErrorMessage);
        malloc.free(nativeErrorMessage);
      }
    }

    // Pause if webf page paused.
    if (controller.paused) {
      controller.pushPendingCallbacks(_runCallback);
    } else {
      _runCallback();
    }
  });
}

const int SET_TIMEOUT_ERROR = -1;
final Pointer<NativeFunction<NativeSetTimeout>> _nativeSetTimeout =
    Pointer.fromFunction(_setTimeout, SET_TIMEOUT_ERROR);

// Register setInterval
typedef NativeSetInterval = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncCallback>>, Int32);

int _setInterval(
    Pointer<Void> callbackContext, int contextId, Pointer<NativeFunction<NativeAsyncCallback>> callback, int timeout) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  return controller.module.setInterval(timeout, () {
    void _runCallbacks() {
      DartAsyncCallback func = callback.asFunction();
      try {
        func(callbackContext, contextId, nullptr);
      } catch (e, stack) {
        Pointer<Utf8> nativeErrorMessage = ('Dart Error: $e\n$stack').toNativeUtf8();
        func(callbackContext, contextId, nativeErrorMessage);
        malloc.free(nativeErrorMessage);
      }
    }

    // Pause if webf page paused.
    if (controller.paused) {
      controller.pushPendingCallbacks(_runCallbacks);
    } else {
      _runCallbacks();
    }
  });
}

const int SET_INTERVAL_ERROR = -1;
final Pointer<NativeFunction<NativeSetInterval>> _nativeSetInterval =
    Pointer.fromFunction(_setInterval, SET_INTERVAL_ERROR);

// Register clearTimeout
typedef NativeClearTimeout = Void Function(Int32 contextId, Int32);

void _clearTimeout(int contextId, int timerId) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  return controller.module.clearTimeout(timerId);
}

final Pointer<NativeFunction<NativeClearTimeout>> _nativeClearTimeout = Pointer.fromFunction(_clearTimeout);

// Register requestAnimationFrame
typedef NativeRequestAnimationFrame = Int32 Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeRAFAsyncCallback>>);

int _requestAnimationFrame(
    Pointer<Void> callbackContext, int contextId, Pointer<NativeFunction<NativeRAFAsyncCallback>> callback) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  return controller.module.requestAnimationFrame((double highResTimeStamp) {
    void _runCallback() {
      DartRAFAsyncCallback func = callback.asFunction();
      try {
        func(callbackContext, contextId, highResTimeStamp, nullptr);
      } catch (e, stack) {
        Pointer<Utf8> nativeErrorMessage = ('Error: $e\n$stack').toNativeUtf8();
        func(callbackContext, contextId, highResTimeStamp, nativeErrorMessage);
        malloc.free(nativeErrorMessage);
      }
    }

    // Pause if webf page paused.
    if (controller.paused) {
      controller.pushPendingCallbacks(_runCallback);
    } else {
      _runCallback();
    }
  });
}

const int RAF_ERROR_CODE = -1;
final Pointer<NativeFunction<NativeRequestAnimationFrame>> _nativeRequestAnimationFrame =
    Pointer.fromFunction(_requestAnimationFrame, RAF_ERROR_CODE);

// Register cancelAnimationFrame
typedef NativeCancelAnimationFrame = Void Function(Int32 contextId, Int32 id);

void _cancelAnimationFrame(int contextId, int timerId) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  controller.module.cancelAnimationFrame(timerId);
}

final Pointer<NativeFunction<NativeCancelAnimationFrame>> _nativeCancelAnimationFrame =
    Pointer.fromFunction(_cancelAnimationFrame);

typedef NativeAsyncBlobCallback = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<Utf8>, Pointer<Uint8>, Int32);
typedef DartAsyncBlobCallback = void Function(
    Pointer<Void> callbackContext, int contextId, Pointer<Utf8>, Pointer<Uint8>, int);
typedef NativeToBlob = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Pointer<NativeFunction<NativeAsyncBlobCallback>>, Int32, Double);

void _toBlob(Pointer<Void> callbackContext, int contextId, Pointer<NativeFunction<NativeAsyncBlobCallback>> callback,
    int id, double devicePixelRatio) {
  DartAsyncBlobCallback func = callback.asFunction();
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  controller.view.toImage(devicePixelRatio, id).then((Uint8List bytes) {
    Pointer<Uint8> bytePtr = malloc.allocate<Uint8>(sizeOf<Uint8>() * bytes.length);
    Uint8List byteList = bytePtr.asTypedList(bytes.length);
    byteList.setAll(0, bytes);
    func(callbackContext, contextId, nullptr, bytePtr, bytes.length);
  }).catchError((error, stack) {
    Pointer<Utf8> nativeErrorMessage = ('$error\n$stack').toNativeUtf8();
    func(callbackContext, contextId, nativeErrorMessage, nullptr, 0);
    malloc.free(nativeErrorMessage);
  });
}

final Pointer<NativeFunction<NativeToBlob>> _nativeToBlob = Pointer.fromFunction(_toBlob);

typedef NativeFlushUICommand = Void Function(Int32 contextId);
typedef DartFlushUICommand = void Function(int contextId);

void _flushUICommand(int contextId) {
  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_DOM_FLUSH_UI_COMMAND_START);
  }
  flushUICommandWithContextId(contextId);
  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_DOM_FLUSH_UI_COMMAND_END);
  }
}

final Pointer<NativeFunction<NativeFlushUICommand>> _nativeFlushUICommand = Pointer.fromFunction(_flushUICommand);

typedef NativePerformanceGetEntries = Pointer<NativePerformanceEntryList> Function(Int32 contextId);
typedef DartPerformanceGetEntries = Pointer<NativePerformanceEntryList> Function(int contextId);

Pointer<NativePerformanceEntryList> _performanceGetEntries(int contextId) {
  if (kProfileMode) {
    return PerformanceTiming.instance().toNative();
  }
  return nullptr;
}

final Pointer<NativeFunction<NativePerformanceGetEntries>> _nativeGetEntries =
    Pointer.fromFunction(_performanceGetEntries);

typedef NativeJSError = Void Function(Int32 contextId, Pointer<Utf8>);

void _onJSError(int contextId, Pointer<Utf8> charStr) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  JSErrorHandler? handler = controller.onJSError;
  if (handler != null) {
    String msg = charStr.toDartString();
    handler(msg);
  }
}

final Pointer<NativeFunction<NativeJSError>> _nativeOnJsError = Pointer.fromFunction(_onJSError);

typedef NativeJSLog = Void Function(Int32 contextId, Int32 level, Pointer<Utf8>);

void _onJSLog(int contextId, int level, Pointer<Utf8> charStr) {
  String msg = charStr.toDartString();
  WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
  if (controller != null) {
    JSLogHandler? jsLogHandler = controller.onJSLog;
    if (jsLogHandler != null) {
      jsLogHandler(level, msg);
    }
  }
}

final Pointer<NativeFunction<NativeJSLog>> _nativeOnJsLog = Pointer.fromFunction(_onJSLog);

final List<int> _dartNativeMethods = [
  _nativeInvokeModule.address,
  _nativeRequestBatchUpdate.address,
  _nativeReloadApp.address,
  _nativeSetTimeout.address,
  _nativeSetInterval.address,
  _nativeClearTimeout.address,
  _nativeRequestAnimationFrame.address,
  _nativeCancelAnimationFrame.address,
  _nativeToBlob.address,
  _nativeFlushUICommand.address,
  _nativeGetEntries.address,
  _nativeOnJsError.address,
  _nativeOnJsLog.address,
];

List<int> makeDartMethodsData() {
  return _dartNativeMethods;
}
