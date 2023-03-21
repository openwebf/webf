/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(CSSStyleDeclaration, setStyleData) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "document.documentElement.style.backgroundColor = 'white';"
      "document.documentElement.style.backgroundColor = 'white';";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, enumerateStyles) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code = "console.assert(Object.keys(document.body.style).length > 400)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, supportCSSVaraible) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code = R"(
document.body.style.setProperty('--blue', 'lightblue'); console.assert(document.body.style['--blue'] === 'lightblue');
document.body.style.setProperty('--main-color', 'lightblue'); console.assert(document.body.style.getPropertyValue('--main-color') === 'lightblue');
)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  UICommandItem* data = context->uiCommandBuffer()->data();
  size_t commandSize = context->uiCommandBuffer()->size();

  UICommandItem& last = data[commandSize - 1];

  EXPECT_EQ(last.type, (int32_t)UICommand::kSetStyle);
  uint16_t* last_key = (uint16_t*)last.string_01;

  auto native_str = new SharedNativeString(last_key, last.args_01_length);
  EXPECT_STREQ(AtomicString(context->ctx(), std::make_unique<AutoFreeNativeString>(native_str))
                   .ToStdString(context->ctx())
                   .c_str(),
               "--main-color");

  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, supportHyphen) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "document.body.style.setProperty('background-color', 'lightblue'); "
      "console.assert(document.body.style.backgroundColor == 'lightblue');"
      "document.body.style.setProperty('border-top-right-radius', '100%'); "
      "console.assert(document.body.style.borderTopRightRadius, '100%')";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(InlineCSSStyleDeclaration, setNullValue) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "document.body.style.height = null;"
      "console.assert(document.body.style.height === '')";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}