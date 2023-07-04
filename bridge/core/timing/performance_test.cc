/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(Performance, now) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code = "console.log(performance.now() < 20);";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Performance, timeOrigin) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code = "console.log(typeof performance.timeOrigin === 'number');";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Performance, toJSON) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code =
      "let json = performance.toJSON();"
      "console.log('now' in json, 'timeOrigin' in json);";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Performance, mark) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "{constructor: ƒ (), detail: null}");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code =
      "performance.mark('abc');"
      "let entries = performance.getEntries();"
      "console.log(entries[0])";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Performance, markWithDetail) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "{constructor: ƒ (), detail: {...}}");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code =
      "performance.mark('abc', { detail: {value: 1}});"
      "let entries = performance.getEntries();"
      "console.log(entries[0])";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Performance, markWithName) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "[{...}, {...}]");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code =
      "performance.mark('abc', { detail: 1});"
      "performance.mark('efg', { detail: 2});"
      "performance.mark('abc', { detail: 3});"
      "let entries = performance.getEntriesByName('abc');"
      "console.log(entries)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Performance, clearMarks) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "[]");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code =
      "performance.mark('abc', { detail: 1});"
      "performance.mark('efg', { detail: 2});"
      "performance.mark('abc', { detail: 3});"
      "performance.clearMarks();"
      "let entries = performance.getEntries();"
      "console.log(entries);";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Performance, clearMarksByName) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "[{...}]");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code =
      "performance.mark('abc', { detail: 1});"
      "performance.mark('efg', { detail: 2});"
      "performance.mark('abc', { detail: 3});"
      "performance.clearMarks('abc');"
      "let entries = performance.getEntries();"
      "console.log(entries);";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Performance, measure) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->GetExecutingContext();
  const char* code = R"(
performance.mark('A');

setTimeout(() => {
performance.mark('B');
setTimeout(() => {
  performance.measure("measure a to b", 'A', 'B');
  let duration = performance.getEntriesByType("measure")[0].duration;
  console.log(duration > 90 && duration < 101);
}, 100);
}, 100);

)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);

  TEST_runLoop(context);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
