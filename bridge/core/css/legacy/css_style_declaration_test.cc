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
  const char* code = "document.body.style.setProperty('--blue', 'lightblue'); console.assert(document.body.style['--blue'] === 'lightblue')";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}