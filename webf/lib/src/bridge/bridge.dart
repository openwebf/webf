/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';

import 'package:webf/src/devtools/panel/remote_object_service.dart';

typedef NativeOnDartContextFinalized = Void Function(Pointer<Void> data);
typedef DartOnDartContextFinalized = void Function(Pointer<Void> data);

final _initDartDynamicLinking =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeOnDartContextFinalized>>('on_dart_context_finalized');

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
typedef NativeGetObjectPropertiesAsyncFunc = Void Function(
    Pointer<Void> dartIsolateContext,
    Double contextId,
    Pointer<Utf8> objectId,
    Int32 includePrototype,
    Handle object,
    Pointer<NativeFunction<NativeGetObjectPropertiesCallback>> callback);
typedef NativeGetObjectPropertiesCallback = Void Function(Handle object, Pointer<NativeValue> result);
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
    final getObjectPropertiesPtr =
        WebFDynamicLibrary.ref.lookup<NativeFunction<NativeGetObjectPropertiesFunc>>('GetObjectPropertiesFromDart');
    final getObjectPropertiesAsyncPtr = WebFDynamicLibrary.ref
        .lookup<NativeFunction<NativeGetObjectPropertiesAsyncFunc>>('GetObjectPropertiesFromDartAsync');
    final evaluatePropertyPathPtr =
        WebFDynamicLibrary.ref.lookup<NativeFunction<NativeEvaluatePropertyPathFunc>>('EvaluatePropertyPathFromDart');
    final releaseObjectPtr =
        WebFDynamicLibrary.ref.lookup<NativeFunction<NativeReleaseObjectFunc>>('ReleaseObjectFromDart');

    RemoteObjectService.setNativeFunctions(
      getObjectPropertiesPtr.asFunction<GetObjectPropertiesFunc>(),
      getObjectPropertiesAsyncPtr.asFunction<GetObjectPropertiesAsyncFunc>(),
      evaluatePropertyPathPtr.asFunction<EvaluatePropertyPathFunc>(),
      releaseObjectPtr.asFunction<ReleaseObjectFunc>(),
    );

    _remoteObjectServiceInitialized = true;
  } catch (e) {
    bridgeLogger.severe('Failed to initialize RemoteObjectService', e);
  }
}

/// Init bridge
FutureOr<double> initBridge(WebFViewController view, WebFThread runningThread, bool enableBlink) async {
  // Setup binding bridge.
  BindingBridge.setup();
  defineBuiltInElements();

  dartContext ??= DartContext();

  // Initialize remote object service
  _initRemoteObjectService();

  double newContextId = runningThread.identity();
  await allocateNewPage(runningThread is FlutterUIThread, newContextId, runningThread.syncBufferSize(),
      useLegacyUICommand: runningThread is DedicatedThread ? runningThread.useLegacyUICommand : false,
      enableBlink: enableBlink);

  return newContextId;
}
