/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';
import 'package:webf/launcher.dart';

import 'dynamic_library.dart';
import 'binding_bridge.dart';
import 'from_native.dart';
import 'to_native.dart';
import 'multiple_thread.dart';

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

/// Init bridge
FutureOr<double> initBridge(WebFViewController view, WebFThread runningThread) async {
  // Setup binding bridge.
  BindingBridge.setup();

  dartContext ??= DartContext();

  double newContextId = runningThread.identity();
  await allocateNewPage(runningThread is FlutterUIThread, newContextId, runningThread.syncBufferSize());

  return newContextId;
}
