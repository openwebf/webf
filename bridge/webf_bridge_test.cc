/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#endif

#include "webf_bridge_test.h"
#ifdef __linux__
#include <execinfo.h>
#include <unistd.h>
#elif defined(_WIN32)
#include <windows.h>
#include <dbghelp.h>
#include <io.h>
// Undefine Windows macros that conflict with WebF code
#ifdef ERROR
#undef ERROR
#endif
#endif
#include <signal.h>
#include <atomic>
#include "bindings/qjs/native_string_utils.h"
#include "logging.h"
#include "webf_test_context.h"

std::unordered_map<int, webf::WebFTestContext*> testContextPool = std::unordered_map<int, webf::WebFTestContext*>();


#define MAX_BACKTRACE_SIZE 50

void handler(int sig) {
#ifdef __linux__
 void* array[MAX_BACKTRACE_SIZE];
 size_t size;

 // get void*'s for all entries on the stack
 size = backtrace(array, MAX_BACKTRACE_SIZE);

 // print out all the frames to stderr
 fprintf(stderr, "Error: signal %d:\n", sig);
 backtrace_symbols_fd(array, size, STDERR_FILENO);
#elif defined(_WIN32)
 // Windows equivalent using CaptureStackBackTrace
 void* stack[MAX_BACKTRACE_SIZE];
 USHORT frames = CaptureStackBackTrace(0, MAX_BACKTRACE_SIZE, stack, NULL);

 fprintf(stderr, "Error: signal %d:\n", sig);

 HANDLE process = GetCurrentProcess();
 SymInitialize(process, NULL, TRUE);

 for (USHORT i = 0; i < frames; i++) {
   DWORD64 address = (DWORD64)(stack[i]);
   fprintf(stderr, "[%d] 0x%p\n", i, (void*)address);
 }

 SymCleanup(process);
#else
 fprintf(stderr, "Error: signal %d\n", sig);
#endif
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
                 Dart_Handle dart_handle,
                 ExecuteResultCallback executeCallback) {
  auto context = reinterpret_cast<webf::WebFTestContext*>(testContext);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);

  context->page()->dartIsolateContext()->dispatcher()->PostToJs(
      context->page()->isDedicated(), context->page()->contextId(),
      [](webf::WebFTestContext* context, Dart_PersistentHandle persistent_handle,
         ExecuteResultCallback executeCallback) {
        context->invokeExecuteTest(persistent_handle, executeCallback);
      },
      context, persistent_handle, executeCallback);
}

void registerTestEnvDartMethods(void* testContext, uint64_t* methodBytes, int32_t length) {
  reinterpret_cast<webf::WebFTestContext*>(testContext)->registerTestEnvDartMethods(methodBytes, length);
}
