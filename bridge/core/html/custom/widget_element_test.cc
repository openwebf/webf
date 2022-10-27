/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "widget_element.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(WidgetElement, setPropertyEventHandler) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "1111");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let checkbox = document.createElement('flutter-checkbox'); "
      "function f(){ console.log(1111); }; "
      "checkbox.onclick = f; "
      "checkbox.dispatchEvent(new Event('click'));";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(WidgetElement, getPropertyWithSymbolToStringTag) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "FLUTTER-CHECKBOX");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let checkbox = document.createElement('flutter-checkbox'); "
      "console.log(checkbox[Symbol.toStringTag])";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}
