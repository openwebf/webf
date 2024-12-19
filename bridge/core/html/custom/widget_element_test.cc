/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "widget_element.h"
#include "core/html/custom/widget_element_shape.h"
#include "foundation/native_value.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(WidgetElement, setPropertyEventHandler) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    // EXPECT_STREQ(message.c_str(), "1111");
    // logCalled = true;
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "let checkbox = document.createElement('flutter-checkbox'); "
      "function f(){ console.log(1111); }; "
      "checkbox.onclick = f; "
      "checkbox.dispatchEvent(new Event('click'));"
      "checkbox.dispatchEvent = '1234';"
      "checkbox.abc = '1234';"
      "console.log(checkbox.onclick.toString());"
      "console.log(checkbox.dispatchEvent);"
      "console.log(checkbox.abc)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(WidgetElement, safeForMultipleInstance) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    // EXPECT_STREQ(message.c_str(), "1111");
    // logCalled = true;
  };

  NativeWidgetElementShape native_widget_element_shape{
      .name = "FLUTTER-CHECKBOX",
  };
  native_widget_element_shape.name = "FLUTTER-CHECKBOX";

  auto* properties = new webf::NativeValue[5];
  for (int i = 0; i < 5; i++) {
    properties[i] = Native_NewCString(std::to_string(i));
  }
  auto property_list = Native_NewList(5, properties);
  native_widget_element_shape.properties = &property_list;

  auto* methods = new webf::NativeValue[5];
  for (int i = 0; i < 5; i++) {
    methods[i] = Native_NewCString(std::to_string(i));
  }
  auto functions = Native_NewList(5, methods);
  native_widget_element_shape.methods = &functions;

  auto* async_methods = new webf::NativeValue[5];
  for (int i = 0; i < 5; i++) {
    async_methods[i] = Native_NewCString(std::to_string(i));
  }
  auto async_functions = Native_NewList(5, async_methods);
  native_widget_element_shape.async_methods = &async_functions;

  auto env = TEST_init(
      [](double contextId, const char* errmsg) {
        WEBF_LOG(VERBOSE) << errmsg;
        errorCalled = true;
      },
      &native_widget_element_shape, 1);

  auto env2 = TEST_init(
      [](double contextId, const char* errmsg) {
        WEBF_LOG(VERBOSE) << errmsg;
        errorCalled = true;
      },
      &native_widget_element_shape, 1);

  const char* code =
      "let checkbox = document.createElement('flutter-checkbox'); "
      "function f(){ console.log(1111); }; "
      "checkbox.onclick = f; "
      "checkbox.dispatchEvent(new Event('click'));"
      "checkbox.dispatchEvent = '1234';"
      "checkbox.abc = '1234';";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  env2->page()->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}
