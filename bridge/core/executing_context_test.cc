/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "include/webf_bridge.h"
#include "page.h"
#include "webf_test_env.h"

using namespace webf;

TEST(Context, isValid) {
  {
    auto env = TEST_init();
    EXPECT_EQ(env->page()->GetExecutingContext()->IsContextValid(), true);
    EXPECT_EQ(env->page()->GetExecutingContext()->IsCtxValid(), true);
  }
  {
    auto env = TEST_init();
    EXPECT_EQ(env->page()->GetExecutingContext()->IsContextValid(), true);
    EXPECT_EQ(env->page()->GetExecutingContext()->IsCtxValid(), true);
  }
}

TEST(Context, evalWithError) {
  static bool errorHandlerExecuted = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    EXPECT_STREQ(errmsg,
                 "TypeError: cannot read property 'toString' of null\n"
                 "    at <eval> (file://:1:27)\n");
  };
  auto env = TEST_init(errorHandler);
  const char* code = "let object = null; object.toString();";
  env->page()->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
}

TEST(Context, recursionThrowError) {
  static bool errorHandlerExecuted = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) { errorHandlerExecuted = true; };
  auto env = TEST_init(errorHandler);
  const char* code =
      "addEventListener('click', (evt) => {\n"
      "  console.log(1);\n"
      "});\n"
      "\n"
      "throw Error('foo');";
  env->page()->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
}

TEST(Context, unrejectPromiseError) {
  static bool errorHandlerExecuted = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    EXPECT_STREQ(errmsg,
                 "TypeError: cannot read property 'forceNullError' of null\n"
                 "    at <anonymous> (file://:4:28)\n"
                 "    at Promise (native)\n"
                 "    at <eval> (file://:6:10)\n");
  };
  auto env = TEST_init(errorHandler);
  const char* code =
      " var p = new Promise(function (resolve, reject) {\n"
      "        var nullObject = null;\n"
      "        // Raise a TypeError: Cannot read property 'forceNullError' of null\n"
      "        var x = nullObject.forceNullError();\n"
      "        resolve();\n"
      "    });\n"
      "\n";
  env->page()->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
}

TEST(Context, globalErrorHandlerTargetReturnToWindow) {
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {};
  auto env = TEST_init(errorHandler);
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;

    EXPECT_STREQ(message.c_str(), "error true true true");
  };

  std::string code = R"(
let oldError = new Error('1234');

window.addEventListener('error', (e) => { console.log(e.type, e.target === window, window === globalThis, e.error === oldError) });
throw oldError;
)";
  env->page()->evaluateScript(code.c_str(), code.size(), "file://", 0);
  EXPECT_EQ(logCalled, true);
  webf::WebFPage::consoleMessageHandler = nullptr;
}

TEST(Context, unrejectPromiseWillTriggerUnhandledRejectionEvent) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    EXPECT_STREQ(errmsg,
                 "TypeError: cannot read property 'forceNullError' of null\n"
                 "    at <anonymous> (file://:12:22)\n"
                 "    at Promise (native)\n"
                 "    at <eval> (file://:14:9)\n");
  };
  auto env = TEST_init(errorHandler);
  static int logIndex = 0;
  static std::string logs[] = {
      "unhandled event PromiseRejectionEvent {} true"};
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(logs[logIndex++].c_str(), message.c_str());
  };

  std::string code = R"(
window.onunhandledrejection = (e) => {
  console.log('unhandled event', e, e.target === window);
};
window.onerror = (e) => {
  console.log('error event', e);
}

var p = new Promise(function (resolve, reject) {
  var nullObject = null;
  // Raise a TypeError: Cannot read property 'forceNullError' of null
  var x = nullObject.forceNullError();
  resolve();
});
)";
  env->page()->evaluateScript(code.c_str(), code.size(), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
  EXPECT_EQ(logCalled, true);
  EXPECT_EQ(logIndex, 1);
  webf::WebFPage::consoleMessageHandler = nullptr;
}

TEST(Context, handledRejectionWillNotTriggerUnHandledRejectionEvent) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) { errorHandlerExecuted = true; };
  auto env = TEST_init(errorHandler);
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "rejected");
  };

  std::string code = R"(
window.addEventListener('unhandledrejection', event => {
  console.log('unhandledrejection fired: ' + event.reason);
});

window.addEventListener('rejectionhandled', event => {
  console.log('rejectionhandled fired: ' + event.reason);
});

function generateRejectedPromise(isEventuallyHandled) {
  // Create a promise which immediately rejects with a given reason.
  var rejectedPromise = Promise.reject('Error at ' +
    new Date().toLocaleTimeString());
  rejectedPromise.catch(() => {
    console.log('rejected');
  });
}

generateRejectedPromise(true);
)";
  env->page()->evaluateScript(code.c_str(), code.size(), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
  webf::WebFPage::consoleMessageHandler = nullptr;
}

TEST(Context, unhandledRejectionEventWillTriggerWhenNotHandled) {
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {};
  auto env = TEST_init(errorHandler);
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "unhandledrejection fired: Error");
  };

  std::string code = R"(
window.addEventListener('unhandledrejection', event => {
  console.log('unhandledrejection fired: ' + event.reason);
});

window.addEventListener('rejectionhandled', event => {
  console.log('rejectionhandled fired: ' + event.reason);
});

function generateRejectedPromise(isEventuallyHandled) {
  // Create a promise which immediately rejects with a given reason.
  var rejectedPromise = Promise.reject('Error');
}

generateRejectedPromise(true);
)";
  env->page()->evaluateScript(code.c_str(), code.size(), "file://", 0);
  EXPECT_EQ(logCalled, true);
  webf::WebFPage::consoleMessageHandler = nullptr;
}

TEST(Context, handledRejectionEventWillTriggerWhenUnHandledRejectHandled) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) { errorHandlerExecuted = true; };
  auto env = TEST_init(errorHandler);
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };

  std::string code = R"(
window.addEventListener('unhandledrejection', event => {
  console.log('unhandledrejection fired: ' + event.reason);
});

window.addEventListener('rejectionhandled', event => {
  console.log('rejectionhandled fired: ' + event.reason);
});

function generateRejectedPromise() {
  // Create a promise which immediately rejects with a given reason.
  var rejectedPromise = Promise.reject('Error');
    // We need to handle the rejection "after the fact" in order to trigger a
    // unhandledrejection followed by rejectionhandled. Here we simulate that
    // via a setTimeout(), but in a real-world system this might take place due
    // to, e.g., fetch()ing resources at startup and then handling any rejected
    // requests at some point later on.
    setTimeout(() => {
      // We need to provide an actual function to .catch() or else the promise
      // won't be considered handled.
      rejectedPromise.catch(() => {});
    });
}

generateRejectedPromise();
)";
  env->page()->evaluateScript(code.c_str(), code.size(), "file://", 0);

  TEST_runLoop(env->page()->GetExecutingContext());
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
  webf::WebFPage::consoleMessageHandler = nullptr;
}

TEST(Context, unrejectPromiseErrorWithMultipleContext) {
  static bool errorHandlerExecuted = false;
  static int32_t errorCalledCount = 0;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    errorCalledCount++;
    EXPECT_STREQ(errmsg,
                 "TypeError: cannot read property 'forceNullError' of null\n"
                 "    at <anonymous> (file://:4:28)\n"
                 "    at Promise (native)\n"
                 "    at <eval> (file://:6:10)\n");
  };

  auto env = TEST_init(errorHandler);
  auto env2 = TEST_init(errorHandler);
  const char* code =
      " var p = new Promise(function (resolve, reject) {\n"
      "        var nullObject = null;\n"
      "        // Raise a TypeError: Cannot read property 'forceNullError' of null\n"
      "        var x = nullObject.forceNullError();\n"
      "        resolve();\n"
      "    });\n"
      "\n";
  env->page()->evaluateScript(code, strlen(code), "file://", 0);
  env2->page()->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
  EXPECT_EQ(errorCalledCount, 2);
}

TEST(Context, disposeContext) {
  auto mockedDartMethods = TEST_getMockDartMethods(nullptr);
  void* dart_context = initDartIsolateContext(mockedDartMethods.data(), mockedDartMethods.size());
  uint32_t contextId = 0;
  auto* page = reinterpret_cast<webf::WebFPage*>(allocateNewPage(dart_context, contextId));
  static bool disposed = false;
  page->disposeCallback = [](webf::WebFPage* bridge) { disposed = true; };
  disposePage(dart_context, page);
  EXPECT_EQ(disposed, true);
}

TEST(Context, window) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };

  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    WEBF_LOG(VERBOSE) << errmsg;
  };
  auto env = TEST_init(errorHandler);
  const char* code = "console.log(window == globalThis)";
  env->page()->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Context, windowInheritEventTarget) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ () ƒ () ƒ () true");
  };

  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    WEBF_LOG(VERBOSE) << errmsg;
  };
  auto env = TEST_init(errorHandler);
  const char* code =
      "console.log(window.addEventListener, addEventListener, globalThis.addEventListener, window.addEventListener === "
      "addEventListener)";
  env->page()->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Context, evaluateByteCode) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "Arguments {0: 1, 1: 2, 2: 3, 3: 4, callee: ƒ (), length: 4}");
  };

  auto errorHandler = [](int32_t contextId, const char* errmsg) { errorHandlerExecuted = true; };
  auto env = TEST_init(errorHandler);
  const char* code = "function f() { console.log(arguments)} f(1,2,3,4);";
  size_t byteLen;
  uint8_t* bytes = env->page()->dumpByteCode(code, strlen(code), "vm://", &byteLen);
  env->page()->evaluateByteCode(bytes, byteLen);

  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
}

TEST(jsValueToNativeString, utf8String) {
  auto env = TEST_init([](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(env->page()->GetExecutingContext()->ctx(), "helloworld");
  std::unique_ptr<webf::SharedNativeString> nativeString =
      webf::jsValueToNativeString(env->page()->GetExecutingContext()->ctx(), str);
  EXPECT_EQ(nativeString->length(), 10);
  uint8_t expectedString[10] = {104, 101, 108, 108, 111, 119, 111, 114, 108, 100};
  for (int i = 0; i < 10; i++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string() + i));
  }
  JS_FreeValue(env->page()->GetExecutingContext()->ctx(), str);
}
