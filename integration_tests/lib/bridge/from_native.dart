/*
 * Copyright (C) 2020-present The WebF authors. All rights reserved.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/launcher.dart';

import 'match_snapshots.dart';
import 'test_input.dart';

// Steps for using dart:ffi to call a Dart function from C:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the Dart function.
// 3. Create a typedef for the variable that you’ll use when calling the Dart function.
// 4. Open the dynamic library that register in the C.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call from C.

typedef NativeJSError = Void Function(Int32 contextId, Pointer<Utf8>);
typedef JSErrorListener = void Function(String);

List<JSErrorListener> _listenerList = List.filled(10, (String string) {
  throw new Exception('unimplemented JS ErrorListener');
});

void addJSErrorListener(int contextId, JSErrorListener listener) {
  _listenerList[contextId] = listener;
}

void _onJSError(int contextId, Pointer<Utf8> charStr) {
  String msg = (charStr).toDartString();
  _listenerList[contextId](msg);
}

final Pointer<NativeFunction<NativeJSError>> _nativeOnJsError = Pointer.fromFunction(_onJSError);

typedef NativeMatchImageSnapshotCallback = Void Function(
    Pointer<Void> callbackContext, Int32 contextId, Int8, Pointer<Utf8>);
typedef DartMatchImageSnapshotCallback = void Function(
    Pointer<Void> callbackContext, int contextId, int, Pointer<Utf8>);
typedef NativeMatchImageSnapshot = Void Function(Pointer<Void> callbackContext, Int32 contextId, Pointer<Uint8>, Int32,
    Pointer<NativeString>, Pointer<NativeFunction<NativeMatchImageSnapshotCallback>>);

void _matchImageSnapshot(Pointer<Void> callbackContext, int contextId, Pointer<Uint8> bytes, int size,
    Pointer<NativeString> snapshotNamePtr, Pointer<NativeFunction<NativeMatchImageSnapshotCallback>> pointer) {
  DartMatchImageSnapshotCallback callback = pointer.asFunction();
  String filename = nativeStringToString(snapshotNamePtr);
  matchImageSnapshot(bytes.asTypedList(size), filename).then((value) {
    callback(callbackContext, contextId, value ? 1 : 0, nullptr);
  }).catchError((e, stack) {
    String errmsg = '$e\n$stack';
    callback(callbackContext, contextId, 0, errmsg.toNativeUtf8());
  });
}

final Pointer<NativeFunction<NativeMatchImageSnapshot>> _nativeMatchImageSnapshot =
    Pointer.fromFunction(_matchImageSnapshot);

typedef NativeEnvironment = Pointer<Utf8> Function();
typedef DartEnvironment = Pointer<Utf8> Function();

Pointer<Utf8> _environment() {
  return (jsonEncode(Platform.environment)).toNativeUtf8();
}

final Pointer<NativeFunction<NativeEnvironment>> _nativeEnvironment = Pointer.fromFunction(_environment);

typedef NativeSimulatePointer = Void Function(Pointer<Void> context, Pointer<MousePointer>, Int32 length, Int32 pointer, Pointer<NativeFunction<NativeAsyncCallback>> callback);
typedef NativeSimulateInputText = Void Function(Pointer<NativeString>);

PointerChange _getPointerChange(double change) {
  return PointerChange.values[change.toInt()];
}

class MousePointer extends Struct {
  @Int32()
  external int contextId;

  @Double()
  external double x;

  @Double()
  external double y;

  @Double()
  external double change;

  @Int32()
  external int signalKind;

  @Double()
  external double delayX;

  @Double()
  external double delayY;
}

void _simulatePointer(Pointer<Void> context, Pointer<MousePointer> mousePointerList, int length, int pointer, Pointer<NativeFunction<NativeAsyncCallback>> callback) {
  int _contextId = 0;
  sendPointerToWindow(List<List<PointerData>> data, int index) {
    if (index >= data.length) {
      DartAsyncCallback fn = callback.asFunction();
      fn(context, _contextId, nullptr);
      return;
    }

    PointerDataPacket dataPacket = PointerDataPacket(data: data[index]);
    window.onPointerDataPacket!(dataPacket);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      sendPointerToWindow(data, index + 1);
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  List<List<PointerData>> dataList = [];

  for (int i = 0; i < length; i++) {
    List<PointerData> data = [];
    int contextId = _contextId = mousePointerList.elementAt(i).ref.contextId;
    double x = mousePointerList.elementAt(i).ref.x;
    double y = mousePointerList.elementAt(i).ref.y;
    PointerSignalKind signalKind = PointerSignalKind.values[mousePointerList.elementAt(i).ref.signalKind];
    double change = mousePointerList.elementAt(i).ref.change;

    if (signalKind == PointerSignalKind.none) {
      data.add(PointerData(
          physicalX: (360 * contextId + x) * window.devicePixelRatio,
          physicalY: (56.0 + y) * window.devicePixelRatio,
          // MouseEvent will trigger [RendererBinding.dispatchEvent] -> [BaseMouseTracker.updateWithEvent]
          // which handle extra mouse connection phase for [event.kind = PointerDeviceKind.mouse].
          // Prefer to use touch event.
          kind: PointerDeviceKind.touch,
          change: _getPointerChange(change),
          pointerIdentifier: pointer));
    } else if (signalKind == PointerSignalKind.scroll) {
      data.add(PointerData(
          physicalX: (360 * contextId + x) * window.devicePixelRatio,
          physicalY: (56.0 + y) * window.devicePixelRatio,
          kind: PointerDeviceKind.mouse,
          signalKind: signalKind,
          change: _getPointerChange(change),
          device: 0,
          embedderId: 0,
          scrollDeltaX: mousePointerList.elementAt(i).ref.delayX,
          scrollDeltaY: mousePointerList.elementAt(i).ref.delayY,
          pointerIdentifier: pointer));
    }

    dataList.add(data);
  }

  sendPointerToWindow(dataList, 0);
}

final Pointer<NativeFunction<NativeSimulatePointer>> _nativeSimulatePointer = Pointer.fromFunction(_simulatePointer);
late TestTextInput testTextInput;

void _simulateInputText(Pointer<NativeString> nativeChars) {
  String text = nativeStringToString(nativeChars);
  testTextInput.enterText(text);
}

final Pointer<NativeFunction<NativeSimulateInputText>> _nativeSimulateInputText =
    Pointer.fromFunction(_simulateInputText);

final List<int> _dartNativeMethods = [
  _nativeOnJsError.address,
  _nativeMatchImageSnapshot.address,
  _nativeEnvironment.address,
  _nativeSimulatePointer.address,
  _nativeSimulateInputText.address
];

typedef Native_RegisterTestEnvDartMethods = Void Function(Int32 contextId, Pointer<Uint64> methodBytes, Int32 length);
typedef Dart_RegisterTestEnvDartMethods = void Function(int contextId, Pointer<Uint64> methodBytes, int length);

final Dart_RegisterTestEnvDartMethods _registerTestEnvDartMethods = WebFDynamicLibrary.ref
    .lookup<NativeFunction<Native_RegisterTestEnvDartMethods>>('registerTestEnvDartMethods')
    .asFunction();

void registerDartTestMethodsToCpp(int contextId) {
  Pointer<Uint64> bytes = malloc.allocate<Uint64>(sizeOf<Uint64>() * _dartNativeMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
  nativeMethodList.setAll(0, _dartNativeMethods);
  _registerTestEnvDartMethods(contextId, bytes, _dartNativeMethods.length);
}
