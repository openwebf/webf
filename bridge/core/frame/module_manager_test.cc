/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <gtest/gtest.h>
#include "webf_test_env.h"

namespace webf {

TEST(ModuleManager, ShouldReturnCorrectValue) {
  bool static errorCalled = false;
  auto env = TEST_init([](double contextId, const char* errmsg) { errorCalled = true; });
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  auto context = env->page()->executingContext();

  std::string code = std::string(R"(
let object = {
    key: {
        v: {
            a: {
                other: null
            }
        }
    }
};
let result = webf.methodChannel.invokeMethod('abc', 'fn', object);
console.log(result);
)");
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(ModuleManager, shouldThrowErrorWhenBadJSON) {
  bool static errorCalled = false;
  auto env = TEST_init([](double contextId, const char* errmsg) {
    std::string stdErrorMsg = std::string(errmsg);
    EXPECT_EQ(stdErrorMsg.find("TypeError: circular reference") != std::string::npos, true);
    errorCalled = true;
  });
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  auto context = env->page()->executingContext();

  std::string code = std::string(R"(
let object = {
    key: {
        v: {
            a: {
                other: null
            }
        }
    }
};
object.other = object;
webf.methodChannel.invokeMethod('abc', 'fn', object);
)");
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, true);
}

TEST(ModuleManager, invokeModuleError) {
  bool static logCalled = false;
  auto env = TEST_init([](double contextId, const char* errmsg) {});
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "InternalError: Fail!!");
  };

  auto context = env->page()->executingContext();

  std::string code = std::string(R"(
function f() {
  webf.invokeModule('throwError', 'webf://', null);
}
try {
  f();
} catch(e) {
  console.log(e.toString());
}

)");
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(logCalled, true);
}

}  // namespace webf
