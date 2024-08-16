/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(FormData, append) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  std::string code = R"(
    let formData = new FormData();
    formData.append('1234', '4567');
    formData.append('1234', '4567');
    console.log(formData.keys());
  )";
  env->page()->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}