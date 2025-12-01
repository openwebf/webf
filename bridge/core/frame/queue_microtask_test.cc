/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "webf_bridge.h"
#include "webf_test_env.h"
using namespace webf;

TEST(QueueMicrotask, orderingWithPromiseAndTimeout_queueFirst) {
  auto env = TEST_init();

  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    static int logIdx = 0;
    switch (logIdx) {
      case 0:
        EXPECT_STREQ(message.c_str(), "sync");
        break;
      case 1:
        EXPECT_STREQ(message.c_str(), "micro1");
        break;
      case 2:
        EXPECT_STREQ(message.c_str(), "promise1");
        break;
      case 3:
        EXPECT_STREQ(message.c_str(), "timeout");
        break;
    }
    logIdx++;
  };

  std::string code = R"(
queueMicrotask(() => { console.log('micro1'); });
Promise.resolve().then(() => { console.log('promise1'); });
setTimeout(() => { console.log('timeout'); });
console.log('sync');
)";

  env->page()->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(env->page()->executingContext());
}

TEST(QueueMicrotask, orderingWithPromiseAndTimeout_promiseFirst) {
  auto env = TEST_init();

  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    static int logIdx = 0;
    switch (logIdx) {
      case 0:
        EXPECT_STREQ(message.c_str(), "sync");
        break;
      case 1:
        EXPECT_STREQ(message.c_str(), "promise1");
        break;
      case 2:
        EXPECT_STREQ(message.c_str(), "micro1");
        break;
      case 3:
        EXPECT_STREQ(message.c_str(), "timeout");
        break;
    }
    logIdx++;
  };

  std::string code = R"(
Promise.resolve().then(() => { console.log('promise1'); });
queueMicrotask(() => { console.log('micro1'); });
setTimeout(() => { console.log('timeout'); });
console.log('sync');
)";

  env->page()->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(env->page()->executingContext());
}

TEST(QueueMicrotask, nestedQueueMicrotaskSameTick) {
  auto env = TEST_init();

  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    static int logIdx = 0;
    switch (logIdx) {
      case 0:
        EXPECT_STREQ(message.c_str(), "sync");
        break;
      case 1:
        EXPECT_STREQ(message.c_str(), "micro1");
        break;
      case 2:
        EXPECT_STREQ(message.c_str(), "micro2");
        break;
    }
    logIdx++;
  };

  std::string code = R"(
queueMicrotask(() => { console.log('micro1'); queueMicrotask(() => { console.log('micro2'); }); });
console.log('sync');
)";

  env->page()->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(env->page()->executingContext());
}

