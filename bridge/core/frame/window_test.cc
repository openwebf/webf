/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "window.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(Window, windowIsGlobalThis) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code = "console.log(window === globalThis)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Window, instanceofEventTarget) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code = "console.log(window instanceof EventTarget)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Window, requestAnimationFrame) {
  auto bridge = TEST_init();
  bool static logCalled = false;

  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "456");
    logCalled = true;
  };

  std::string code = R"(
requestAnimationFrame(() => {
  console.log('456');
});
)";

  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(bridge->GetExecutingContext());

  EXPECT_EQ(logCalled, true);
}

TEST(Window, cancelAnimationFrame) {
  auto bridge = TEST_init();

  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { abort(); };

  std::string code = R"(
 let id = requestAnimationFrame(() => {
  console.log('456');
});
 cancelAnimationFrame(id);
)";

  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(bridge->GetExecutingContext());
}

TEST(Window, postMessage) {
  {
    auto bridge = TEST_init();
    static bool logCalled = false;
    webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
      logCalled = true;
      EXPECT_STREQ(message.c_str(), "{\"data\":1234} *");
    };

    std::string code = std::string(R"(
 window.addEventListener('message', (message) => {
  console.log(JSON.stringify(message.data), message.origin);
});
 window.postMessage({
  data: 1234
}, '*');
)");
    bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
    EXPECT_EQ(logCalled, true);
  }
  // Use block scope to release previous page, and allocate new page.
  { TEST_init(); }
}

TEST(Window, location) {
  auto bridge = TEST_init();
  static bool logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true true");
  };

  std::string code = std::string(R"(
    console.log(window.location !== undefined, window.location === location, window.location === document.location);
  )");
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  EXPECT_EQ(logCalled, true);
}

TEST(Window, onloadShouldExist) {
  static bool errorCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  std::string code = std::string(R"(
    console.assert('onload' in window);
  )");
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(Window, atob) {
  static bool errorCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  std::string code = std::string(R"(
    let a = atob('a bcd');
console.log(a.charCodeAt(1))
  )");
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}