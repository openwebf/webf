/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "webf_bridge_test.h"
#include <atomic>
#include "bindings/qjs/native_string_utils.h"
#include "logging.h"
#include "webf_test_context.h"

std::unordered_map<int, webf::WebFTestContext*> testContextPool = std::unordered_map<int, webf::WebFTestContext*>();

void* initTestFramework(void* page_) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());
  return new webf::WebFTestContext(page->GetExecutingContext());
}

int8_t evaluateTestScripts(void* testContext, void* code, const char* bundleFilename, int startLine) {
  return reinterpret_cast<webf::WebFTestContext*>(testContext)
      ->evaluateTestScripts(static_cast<webf::SharedNativeString*>(code)->string(),
                            static_cast<webf::SharedNativeString*>(code)->length(), bundleFilename, startLine);
}

void executeTest(void* testContext, ExecuteCallback executeCallback) {
  reinterpret_cast<webf::WebFTestContext*>(testContext)->invokeExecuteTest(executeCallback);
}

void registerTestEnvDartMethods(void* testContext, uint64_t* methodBytes, int32_t length) {
  reinterpret_cast<webf::WebFTestContext*>(testContext)->registerTestEnvDartMethods(methodBytes, length);
}
