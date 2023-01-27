/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "console.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(Console, rawPrintShouldWork) {
  static bool logExecuted = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logExecuted = true;
    EXPECT_STREQ(message.c_str(), "1234");
  };
  auto env = TEST_init();
  const char* code = "__webf_print__('1234', 'info')";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(logExecuted, true);
}

TEST(Console, debugInspect) {
  static bool logExecuted = false;
  //  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
  //    logExecuted = true;
  ////    EXPECT_STREQ(message.c_str(), "123");
  //  };
  auto bridge = TEST_init();
  const char* code = "function f() { console.log(123); } f();";
  bridge->evaluateScript(code, strlen(code), "/tmp/index.js", 0);
  //  EXPECT_EQ(logExecuted, true);
}

TEST(Console, log) {
  static bool logExecuted = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    WEBF_LOG(VERBOSE) << message;
    logExecuted = true;
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    exit(1);
  });
  const char* code = "console.log(1234);";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(logExecuted, true);
}
