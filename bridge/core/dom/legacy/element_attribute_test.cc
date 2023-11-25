/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(Element, overrideAttribute) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code = R"(
 const text = document.createElement('div');
    text.setAttribute('value', 'Hello');
    document.body.appendChild(text);
    text.setAttribute('value', 'Hi');
)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, false);
}