/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "webf_bridge_test.h"
#include <atomic>
#include "bindings/qjs/native_string_utils.h"
#include "webf_test_context.h"

std::unordered_map<int, webf::WebFTestContext*> testContextPool = std::unordered_map<int, webf::WebFTestContext*>();

void initTestFramework(int32_t contextId) {
  auto* page = static_cast<webf::WebFPage*>(getPage(contextId));
  auto testContext = new webf::WebFTestContext(page->GetExecutingContext());
  testContextPool[contextId] = testContext;
}

int8_t evaluateTestScripts(int32_t contextId, void* code, const char* bundleFilename, int startLine) {
  auto testContext = testContextPool[contextId];
  return testContext->evaluateTestScripts(static_cast<webf::NativeString*>(code)->string(),
                                          static_cast<webf::NativeString*>(code)->length(), bundleFilename, startLine);
}

void executeTest(int32_t contextId, ExecuteCallback executeCallback) {
  auto testContext = testContextPool[contextId];
  testContext->invokeExecuteTest(executeCallback);
}

void registerTestEnvDartMethods(int32_t contextId, uint64_t* methodBytes, int32_t length) {
  auto testContext = testContextPool[contextId];
  testContext->registerTestEnvDartMethods(methodBytes, length);
}
