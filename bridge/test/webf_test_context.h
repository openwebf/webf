/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_WEBF_TEST_CONTEXT_H
#define KRAKENBRIDGE_WEBF_TEST_CONTEXT_H

#include "bindings/qjs/qjs_function.h"
#include "core/executing_context.h"
#include "core/page.h"
#include "webf_bridge_test.h"

namespace webf {

struct ImageSnapShotContext {
  JSValue callback;
  ExecutingContext* context;
  list_head link;
};

class KrakenTestContext final {
 public:
  explicit KrakenTestContext() = delete;
  explicit KrakenTestContext(ExecutingContext* context);

  /// Evaluate JavaScript source code with build-in test frameworks, use in test only.
  bool evaluateTestScripts(const uint16_t* code, size_t codeLength, const char* sourceURL, int startLine);
  bool parseTestHTML(const uint16_t* code, size_t codeLength);
  void invokeExecuteTest(ExecuteCallback executeCallback);
  void registerTestEnvDartMethods(uint64_t* methodBytes, int32_t length);

  std::shared_ptr<QJSFunction> execute_test_callback_{nullptr};
  JSValue execute_test_proxy_object_{JS_NULL};

 private:
  /// the pointer of JSContext, ownership belongs to JSContext
  ExecutingContext* context_{nullptr};
  KrakenPage* page_;
};

}  // namespace webf

#endif  // KRAKENBRIDGE_WEBF_TEST_CONTEXT_H
