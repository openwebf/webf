/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// Tests for the FlushUICommand skip optimization in ModuleManager.
//
// The optimization skips FlushUICommand (a PostToDartSync round-trip) for
// modules that do not read DOM state: Fetch, AsyncStorage, LocalStorage,
// SessionStorage, Clipboard, TextCodec, Navigator.
//
// Two test suites:
//
// 1. ModuleManagerNoFlushBehavior — verifies that whitelisted modules can be
//    invoked without errors and return values correctly (correctness).
//
// 2. ModuleManagerNoFlushCount — replaces the flushUICommand mock with a
//    counting version to assert that FlushUICommand is skipped for whitelist
//    modules and triggered for non-whitelist modules (optimization verified).

#include <gtest/gtest.h>
#include "webf_bridge.h"
#include "webf_test_env.h"

namespace webf {

// ---------------------------------------------------------------------------
// Suite 1: Correctness — whitelist modules work normally after the optimization
// ---------------------------------------------------------------------------

TEST(ModuleManagerNoFlushBehavior, FetchModuleInvokesSuccessfully) {
  static bool errorCalled = false;
  auto env = TEST_init([](double, const char* errmsg) {
    errorCalled = true;
    WEBF_LOG(VERBOSE) << errmsg;
  });
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  // webf.invokeModule returns the module name string in the test mock.
  std::string code = R"(
    let result = webf.invokeModule('Fetch', 'test', null);
    console.assert(result === 'Fetch', 'Fetch module should return its name');
  )";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(ModuleManagerNoFlushBehavior, AsyncStorageModuleInvokesSuccessfully) {
  static bool errorCalled = false;
  auto env = TEST_init([](double, const char* errmsg) {
    errorCalled = true;
    WEBF_LOG(VERBOSE) << errmsg;
  });
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  std::string code = R"(
    let result = webf.invokeModule('AsyncStorage', 'getItem', null);
    console.assert(result === 'AsyncStorage', 'AsyncStorage module should return its name');
  )";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(ModuleManagerNoFlushBehavior, LocalStorageModuleInvokesSuccessfully) {
  static bool errorCalled = false;
  auto env = TEST_init([](double, const char* errmsg) {
    errorCalled = true;
    WEBF_LOG(VERBOSE) << errmsg;
  });
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  std::string code = R"(
    let result = webf.invokeModule('LocalStorage', 'getItem', null);
    console.assert(result === 'LocalStorage', 'LocalStorage module should return its name');
  )";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(ModuleManagerNoFlushBehavior, SessionStorageModuleInvokesSuccessfully) {
  static bool errorCalled = false;
  auto env = TEST_init([](double, const char* errmsg) {
    errorCalled = true;
    WEBF_LOG(VERBOSE) << errmsg;
  });
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  std::string code = R"(
    let result = webf.invokeModule('SessionStorage', 'getItem', null);
    console.assert(result === 'SessionStorage', 'SessionStorage module should return its name');
  )";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(ModuleManagerNoFlushBehavior, ClipboardModuleInvokesSuccessfully) {
  static bool errorCalled = false;
  auto env = TEST_init([](double, const char* errmsg) {
    errorCalled = true;
    WEBF_LOG(VERBOSE) << errmsg;
  });
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  std::string code = R"(
    let result = webf.invokeModule('Clipboard', 'readText', null);
    console.assert(result === 'Clipboard', 'Clipboard module should return its name');
  )";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(ModuleManagerNoFlushBehavior, TextCodecModuleInvokesSuccessfully) {
  static bool errorCalled = false;
  auto env = TEST_init([](double, const char* errmsg) {
    errorCalled = true;
    WEBF_LOG(VERBOSE) << errmsg;
  });
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  std::string code = R"(
    let result = webf.invokeModule('TextCodec', 'encode', null);
    console.assert(result === 'TextCodec', 'TextCodec module should return its name');
  )";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(ModuleManagerNoFlushBehavior, NavigatorModuleInvokesSuccessfully) {
  static bool errorCalled = false;
  auto env = TEST_init([](double, const char* errmsg) {
    errorCalled = true;
    WEBF_LOG(VERBOSE) << errmsg;
  });
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  std::string code = R"(
    let result = webf.invokeModule('Navigator', 'getUserAgent', null);
    console.assert(result === 'Navigator', 'Navigator module should return its name');
  )";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

// Verify that non-whitelist modules are also unaffected (regression guard).
TEST(ModuleManagerNoFlushBehavior, NonWhitelistModuleInvokesSuccessfully) {
  static bool errorCalled = false;
  auto env = TEST_init([](double, const char* errmsg) {
    errorCalled = true;
    WEBF_LOG(VERBOSE) << errmsg;
  });
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  std::string code = R"(
    let result = webf.invokeModule('WebSocket', 'connect', null);
    console.assert(result === 'WebSocket', 'WebSocket module should return its name');
  )";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

// ---------------------------------------------------------------------------
// Suite 2: FlushUICommand call count verification
//
// We replace the flushUICommand slot in the dart methods array with a
// counting function, then verify the count after invoking each module.
//
// flushUICommand is at index 11 in TEST_getMockDartMethods (0-based).
// See webf_test_env.cc for the ordering.
// ---------------------------------------------------------------------------

static int g_flush_call_count = 0;

static void TEST_flushUICommand_counting(double /*contextId*/) {
  g_flush_call_count++;
}

// Build a test env with the counting flush function substituted in.
// We use the same initialization sequence as TEST_init but swap index 11.
static std::unique_ptr<WebFTestEnv> makeEnvWithCountingFlush(OnJSError onJsError = nullptr) {
  // Index of flushUICommand in the dart methods vector produced by
  // TEST_getMockDartMethods. Keep in sync with webf_test_env.cc.
  constexpr size_t kFlushUICommandIndex = 11;

  auto methods = TEST_getMockDartMethods(onJsError);
  methods[kFlushUICommandIndex] = reinterpret_cast<uint64_t>(TEST_flushUICommand_counting);

  // Use a unique negative context id range to avoid collisions with TEST_init.
  static double sPageContextId = -1000;
  sPageContextId -= 1;

  auto* dart_isolate_context =
      reinterpret_cast<webf::DartIsolateContext*>(initDartIsolateContextSync(0, methods.data(), methods.size()));
  auto* page = reinterpret_cast<webf::WebFPage*>(
      allocateNewPageSync(sPageContextId, dart_isolate_context, nullptr, 0));

  // initTestFramework registers the test polyfill (webf.invokeModule etc.).
  void* testContext = initTestFramework(page);
  TEST_mockTestEnvDartMethods(testContext, onJsError);

  JSThreadState* th = new JSThreadState();
  JS_SetRuntimeOpaque(
      reinterpret_cast<WebFTestContext*>(testContext)->page()->executingContext()->dartIsolateContext()->runtime(), th);

  return std::make_unique<WebFTestEnv>(dart_isolate_context, page);
}

TEST(ModuleManagerNoFlushCount, WhitelistModulesSkipFlush) {
  const std::vector<std::string> whitelist = {
      "Fetch", "AsyncStorage", "LocalStorage", "SessionStorage",
      "Clipboard", "TextCodec", "Navigator",
  };

  for (const auto& moduleName : whitelist) {
    g_flush_call_count = 0;
    auto env = makeEnvWithCountingFlush([](double, const char*) {});
    webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

    auto* context = env->page()->executingContext();
    std::string code = "webf.invokeModule('" + moduleName + "', 'test', null);";
    context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

    EXPECT_EQ(g_flush_call_count, 0)
        << moduleName << " is whitelisted and should NOT trigger FlushUICommand";
  }
}

TEST(ModuleManagerNoFlushCount, NonWhitelistModuleTriggersFlush) {
  g_flush_call_count = 0;
  auto env = makeEnvWithCountingFlush([](double, const char*) {});
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  // "WebSocket" is not in the whitelist.
  std::string code = "webf.invokeModule('WebSocket', 'connect', null);";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_GT(g_flush_call_count, 0)
      << "WebSocket is not whitelisted and MUST trigger FlushUICommand";
}

TEST(ModuleManagerNoFlushCount, CaseSensitivity_LowercaseFetchIsNotWhitelisted) {
  g_flush_call_count = 0;
  auto env = makeEnvWithCountingFlush([](double, const char*) {});
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  // "fetch" (lowercase) must NOT be treated as whitelisted.
  std::string code = "webf.invokeModule('fetch', 'test', null);";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_GT(g_flush_call_count, 0)
      << "Lowercase 'fetch' is not in the whitelist and must trigger FlushUICommand";
}

TEST(ModuleManagerNoFlushCount, MethodChannelTriggersFlush) {
  g_flush_call_count = 0;
  auto env = makeEnvWithCountingFlush([](double, const char*) {});
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto* context = env->page()->executingContext();
  std::string code = "webf.methodChannel.invokeMethod('test', 'fn', null);";
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_GT(g_flush_call_count, 0)
      << "MethodChannel is not whitelisted and must trigger FlushUICommand";
}

}  // namespace webf
