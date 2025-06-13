/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';

import 'dynamic_library.dart';
import 'binding_bridge.dart';
import 'from_native.dart';
import 'to_native.dart';
import 'multiple_thread.dart';
import 'native_types.dart';
import 'package:webf/src/devtools/remote_object_service.dart';

typedef NativeOnDartContextFinalized = Void Function(Pointer<Void> data);
typedef DartOnDartContextFinalized = void Function(Pointer<Void> data);

final _initDartDynamicLinking = WebFDynamicLibrary.ref
    .lookup<NativeFunction<NativeOnDartContextFinalized>>('on_dart_context_finalized');

class DartContext implements Finalizable {
  static final _finalizer = NativeFinalizer(_initDartDynamicLinking);

  DartContext() : pointer = initDartIsolateContext(makeDartMethodsData()) {
    initDartDynamicLinking();
    _finalizer.attach(this, pointer);
  }
  final Pointer<Void> pointer;
}

DartContext? dartContext;

bool isJSRunningInDedicatedThread(double contextId) {
  return contextId >= 0;
}

// Native function signatures for RemoteObjectService
typedef NativeGetObjectPropertiesFunc = Pointer<NativeValue> Function(
    Pointer<Void> dartIsolateContext, Double contextId, Pointer<Utf8> objectId, Int32 includePrototype);
typedef NativeEvaluatePropertyPathFunc = Pointer<NativeValue> Function(
    Pointer<Void> dartIsolateContext, Double contextId, Pointer<Utf8> objectId, Pointer<Utf8> propertyPath);
typedef NativeReleaseObjectFunc = Void Function(
    Pointer<Void> dartIsolateContext, Double contextId, Pointer<Utf8> objectId);

// Flag to track if remote object service is initialized
bool _remoteObjectServiceInitialized = false;

// Initialize remote object service functions
void _initRemoteObjectService() {
  if (_remoteObjectServiceInitialized) return;

  try {
    final getObjectPropertiesPtr = WebFDynamicLibrary.ref
        .lookup<NativeFunction<NativeGetObjectPropertiesFunc>>('GetObjectPropertiesFromDart');
    final evaluatePropertyPathPtr = WebFDynamicLibrary.ref
        .lookup<NativeFunction<NativeEvaluatePropertyPathFunc>>('EvaluatePropertyPathFromDart');
    final releaseObjectPtr = WebFDynamicLibrary.ref
        .lookup<NativeFunction<NativeReleaseObjectFunc>>('ReleaseObjectFromDart');

    RemoteObjectService.setNativeFunctions(
      getObjectPropertiesPtr.asFunction<GetObjectPropertiesFunc>(),
      evaluatePropertyPathPtr.asFunction<EvaluatePropertyPathFunc>(),
      releaseObjectPtr.asFunction<ReleaseObjectFunc>(),
    );

    _remoteObjectServiceInitialized = true;
    print('[Bridge] RemoteObjectService functions initialized successfully');
  } catch (e) {
    print('[Bridge] Failed to initialize RemoteObjectService: $e');
  }
}

/// Init bridge
FutureOr<double> initBridge(WebFViewController view, WebFThread runningThread) async {
  // Setup binding bridge.
  BindingBridge.setup();
  defineBuiltInElements();

  dartContext ??= DartContext();

  // Initialize remote object service
  _initRemoteObjectService();

  double newContextId = runningThread.identity();
  await allocateNewPage(runningThread is FlutterUIThread, newContextId, runningThread.syncBufferSize());

  return newContextId;
}
