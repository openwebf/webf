/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "webf_bridge_test.h"
#include <signal.h>
#include <atomic>
#include "bindings/qjs/native_string_utils.h"
#include "logging.h"
#include "webf_test_context.h"

#ifdef __linux__
#include <execinfo.h>
#include <signal.h>
#include <unistd.h>
#elif _WIN32
#include <dbghelp.h>
#include <windows.h>
#pragma comment(lib, "dbghelp.lib")  // Link with dbghelp library on Windows
#endif

std::unordered_map<int, webf::WebFTestContext*> testContextPool = std::unordered_map<int, webf::WebFTestContext*>();

void printStackTrace() {
#ifdef __linux__
  void* array[10];
  size_t size = backtrace(array, 10);
  char** strings = backtrace_symbols(array, size);

  std::cout << "Stack trace:" << std::endl;
  for (size_t i = 0; i < size; i++) {
    std::cout << strings[i] << std::endl;
  }

  free(strings);
#elif _WIN32
  void* stack[62];
  HANDLE process = GetCurrentProcess();
  SymInitialize(process, NULL, TRUE);
  WORD frames = CaptureStackBackTrace(0, 62, stack, NULL);
  SYMBOL_INFO* symbol = (SYMBOL_INFO*)calloc(sizeof(SYMBOL_INFO) + 256 * sizeof(char), 1);
  symbol->MaxNameLen = 255;
  symbol->SizeOfStruct = sizeof(SYMBOL_INFO);

  std::cout << "Stack trace:" << std::endl;
  for (WORD i = 0; i < frames; i++) {
    SymFromAddr(process, (DWORD64)(stack[i]), 0, symbol);
    std::cout << i << ": " << symbol->Name << " - 0x" << symbol->Address << std::endl;
  }

  free(symbol);
  SymCleanup(process);
#endif
}

void handler(int sig) {
  void* array[10];
  size_t size;

  printStackTrace();
  exit(1);
}

void* initTestFramework(void* page_) {
  signal(SIGSEGV, handler);  // install handler when crashed.
  signal(SIGABRT, handler);
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  return page->dartIsolateContext()->dispatcher()->PostToJsSync(
      page->isDedicated(), page->contextId(),
      [](bool cancel, webf::WebFPage* page) -> void* { return new webf::WebFTestContext(page->executingContext()); },
      page);
}

void executeTest(void* testContext,
                 int64_t profile_id,
                 Dart_Handle dart_handle,
                 ExecuteResultCallback executeCallback) {
  auto context = reinterpret_cast<webf::WebFTestContext*>(testContext);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);

  context->page()->dartIsolateContext()->dispatcher()->PostToJs(
      context->page()->isDedicated(), context->page()->contextId(),
      [](webf::WebFTestContext* context, int64_t profile_id, Dart_PersistentHandle persistent_handle,
         ExecuteResultCallback executeCallback) {
        context->page()->dartIsolateContext()->profiler()->StartTrackEvaluation(profile_id);
        context->invokeExecuteTest(persistent_handle, executeCallback);
        context->page()->dartIsolateContext()->profiler()->FinishTrackEvaluation(profile_id);
      },
      context, profile_id, persistent_handle, executeCallback);
}

void registerTestEnvDartMethods(void* testContext, uint64_t* methodBytes, int32_t length) {
  reinterpret_cast<webf::WebFTestContext*>(testContext)->registerTestEnvDartMethods(methodBytes, length);
}
