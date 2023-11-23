/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_element.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(HTMLElement, globalEventHandlerRegistered) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "1234");
    logCalled = true;
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div'); function f(){ console.log(1234); }; div.onclick = f; "
      "div.dispatchEvent(new Event('click'));";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}
