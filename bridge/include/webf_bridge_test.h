/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_BRIDGE_TEST_EXPORT_H
#define WEBF_BRIDGE_TEST_EXPORT_H

#include "webf_bridge.h"

WEBF_EXPORT_C
void* initTestFramework(void* page);

using ExecuteResultCallback = void (*)(Dart_Handle dart_handle, void* result);

WEBF_EXPORT_C
void executeTest(void* testContext, Dart_Handle dart_handle, ExecuteResultCallback executeCallback);

WEBF_EXPORT_C
void registerTestEnvDartMethods(void* testContext, uint64_t* methodBytes, int32_t length);

#endif
