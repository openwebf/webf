/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_BRIDGE_TEST_EXPORT_H
#define WEBF_BRIDGE_TEST_EXPORT_H

#include "webf_bridge.h"

WEBF_EXPORT_C
void initTestFramework(int32_t contextId);
WEBF_EXPORT_C
int8_t evaluateTestScripts(int32_t contextId, void* code, const char* bundleFilename, int startLine);

using ExecuteCallback = void* (*)(int32_t contextId, void* status);

WEBF_EXPORT_C
void executeTest(int32_t contextId, ExecuteCallback executeCallback);

WEBF_EXPORT_C
void registerTestEnvDartMethods(int32_t contextId, uint64_t* methodBytes, int32_t length);

#endif
