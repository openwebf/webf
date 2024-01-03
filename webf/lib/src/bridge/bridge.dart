/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';
import 'package:webf/launcher.dart';

import 'binding.dart';
import 'from_native.dart';
import 'to_native.dart';

class DartContext {
  DartContext() : pointer = initDartIsolateContext(makeDartMethodsData()) {
    initDartDynamicLinking();
    registerDartContextFinalizer(this);
  }
  final Pointer<Void> pointer;
}

DartContext dartContext = DartContext();

/// Init bridge
int initBridge(WebFViewController view) {
  // Setup binding bridge.
  BindingBridge.setup();

  int pageId = newPageId();
  allocateNewPage(pageId);

  return pageId;
}
