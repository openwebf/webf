/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "foundation/native_type.h"
#include "foundation/string/wtf_string.h"
#include "webf_test_env.h"

using namespace webf;

TEST(CSSStyleDeclaration, setStyleData) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "document.documentElement.style.backgroundColor = 'white';"
      "document.documentElement.style.backgroundColor = 'white';";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, enumerateStyles) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code = "console.assert(Object.keys(document.body.style).length > 400)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, supportCSSVaraible) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code = R"(
document.body.style.setProperty('--blue', 'lightblue'); console.assert(document.body.style['--blue'] === 'lightblue');
document.body.style.setProperty('--main-color', 'lightblue'); console.assert(document.body.style.getPropertyValue('--main-color') === 'lightblue');
)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  UICommandBufferPack* p_buffer_pack = static_cast<UICommandBufferPack*>(context->uiCommandBuffer()->data());
  size_t commandSize = p_buffer_pack->length;

  UICommandItem& last = ((UICommandItem*)p_buffer_pack->data)[commandSize - 1];

  EXPECT_EQ(last.type, (int32_t)UICommand::kSetInlineStyle);
  const auto* last_key = reinterpret_cast<const UChar*>(static_cast<uintptr_t>(last.string_01));
  EXPECT_EQ(String(last_key, static_cast<size_t>(last.args_01_length)).ToUTF8String(), "--main-color");

  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, supportImportantInPayload) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code = "document.body.style.setProperty('color', 'red', 'important');";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);

  UICommandBufferPack* p_buffer_pack = static_cast<UICommandBufferPack*>(context->uiCommandBuffer()->data());
  size_t commandSize = p_buffer_pack->length;
  UICommandItem& last = ((UICommandItem*)p_buffer_pack->data)[commandSize - 1];

  ASSERT_EQ(last.type, (int32_t)UICommand::kSetInlineStyle);
  auto* payload = reinterpret_cast<NativeStyleValueWithHref*>(static_cast<uintptr_t>(last.nativePtr2));
  ASSERT_NE(payload, nullptr);
  EXPECT_EQ(payload->important, 1);

  const auto* value_chars = reinterpret_cast<const UChar*>(payload->value->string());
  EXPECT_EQ(String(value_chars, static_cast<size_t>(payload->value->length())).ToUTF8String(), "red");

  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, assignmentDoesNotAcceptImportantValue) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "document.body.style.color = 'red !important';"
      "console.assert(document.body.style.color === '');";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, supportHyphen) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "document.body.style.setProperty('background-color', 'lightblue'); "
      "console.assert(document.body.style.backgroundColor == 'lightblue');"
      "document.body.style.setProperty('border-top-right-radius', '100%'); "
      "console.assert(document.body.style.borderTopRightRadius, '100%')";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(InlineCSSStyleDeclaration, setNullValue) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "document.body.style.height = null;"
      "console.assert(document.body.style.height === '')";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}
