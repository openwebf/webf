/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "webf_bridge_test.h"
#include <execinfo.h>
#include <signal.h>
#include <unistd.h>
#include <atomic>
#include "bindings/qjs/native_string_utils.h"
#include "logging.h"
#include "webf_test_context.h"

std::unordered_map<int, webf::WebFTestContext*> testContextPool = std::unordered_map<int, webf::WebFTestContext*>();

void handler(int sig) {
  void* array[10];
  size_t size;

  // get void*'s for all entries on the stack
  size = backtrace(array, 10);

  // print out all the frames to stderr
  fprintf(stderr, "Error: signal %d:\n", sig);
  backtrace_symbols_fd(array, size, STDERR_FILENO);
  exit(1);
}

void* initTestFramework(void* page_) {
  signal(SIGSEGV, handler);  // install handler when crashed.
  signal(SIGABRT, handler);
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  return page->dartIsolateContext()->dispatcher()->PostToJsSync(
      page->isDedicated(), page->contextId(),
      [](webf::WebFPage* page) -> void* { return new webf::WebFTestContext(page->executingContext()); }, page);
}

void executeTest(void* testContext, Dart_Handle dart_handle, ExecuteResultCallback executeCallback) {
  auto context = reinterpret_cast<webf::WebFTestContext*>(testContext);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);

  context->page()->dartIsolateContext()->dispatcher()->PostToJs(
      context->page()->isDedicated(), context->page()->contextId(),
      [](webf::WebFTestContext* context, Dart_PersistentHandle persistent_handle, ExecuteResultCallback executeCallback) {
        context->invokeExecuteTest(persistent_handle, executeCallback);
      },
      context, persistent_handle, executeCallback);
}

void registerTestEnvDartMethods(void* testContext, uint64_t* methodBytes, int32_t length) {
  reinterpret_cast<webf::WebFTestContext*>(testContext)->registerTestEnvDartMethods(methodBytes, length);
}
