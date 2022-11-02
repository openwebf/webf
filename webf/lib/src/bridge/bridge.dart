/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:webf/module.dart';
import 'package:webf/launcher.dart';

import 'binding.dart';
import 'from_native.dart';
import 'to_native.dart';

bool _firstView = true;
int _contextId = 0;

int newContextId() { return ++_contextId; }

/// Init bridge
int initBridge(WebFViewController view) {
  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_BRIDGE_REGISTER_DART_METHOD_START);
  }

  // Setup binding bridge.
  BindingBridge.setup();

  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_BRIDGE_REGISTER_DART_METHOD_END);
  }

  if (_firstView) {
    List<int> dartMethods = makeDartMethodsData();
    initDartContext(dartMethods);
    _firstView = false;
  }

  int pageId = newContextId();
  allocateNewPage(pageId);

  return pageId;
}
