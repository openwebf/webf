/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "include/webf_bridge.h"
#include "core/api/api.h"
#include "core/dart_isolate_context.h"
#include "core/html/parser/html_parser.h"
#include "core/page.h"
#include "multiple_threading/dispatcher.h"

#if defined(_WIN32)
#define SYSTEM_NAME "windows"  // Windows
#elif defined(_WIN64)
#define SYSTEM_NAME "windows"  // Windows
#elif defined(__CYGWIN__) && !defined(_WIN32)
#define SYSTEM_NAME "windows"  // Windows (Cygwin POSIX under Microsoft Window)
#elif defined(__ANDROID__)
#define SYSTEM_NAME "android"  // Android (implies Linux, so it must come first)
#elif defined(__linux__)
#define SYSTEM_NAME "linux"                    // Debian, Ubuntu, Gentoo, Fedora, openSUSE, RedHat, Centos and other
#elif defined(__APPLE__) && defined(__MACH__)  // Apple OSX and iOS (Darwin)
#include <TargetConditionals.h>
#if TARGET_IPHONE_SIMULATOR == 1
#define SYSTEM_NAME "ios"  // Apple iOS Simulator
#elif TARGET_OS_IPHONE == 1
#define SYSTEM_NAME "ios"  // Apple iOS
#elif TARGET_OS_MAC == 1
#define SYSTEM_NAME "macos"  // Apple macOS
#endif
#else
#define SYSTEM_NAME "unknown"
#endif

static std::atomic<int64_t> unique_page_id{1};

int64_t newPageIdSync() {
  return unique_page_id++;
}

void* initDartIsolateContextSync(int64_t dart_port, uint64_t* dart_methods, int32_t dart_methods_len) {
  auto dispatcher = std::make_unique<webf::multi_threading::Dispatcher>(dart_port);

#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] allocateNewPageWrapper, targetContextId= " << targetContextId << std::endl;
#endif
  auto* dart_isolate_context = new webf::DartIsolateContext(dart_methods, dart_methods_len);
  dart_isolate_context->SetDispatcher(std::move(dispatcher));
  return dart_isolate_context;
}

void* allocateNewPageSync(double thread_identity, void* ptr) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] allocateNewPageWrapper, targetContextId= " << targetContextId << std::endl;
#endif
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  assert(dart_isolate_context != nullptr);
  return static_cast<webf::DartIsolateContext*>(dart_isolate_context)->AddNewPage(thread_identity);
}

void disposePageSync(double thread_identity, void* ptr, void* page_) {
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  ((webf::DartIsolateContext*)dart_isolate_context)->RemovePage(thread_identity, static_cast<webf::WebFPage*>(page_));
}

void evaluateScripts(void* page_,
                       const char* code,
                       uint64_t code_len,
                       uint8_t** parsed_bytecodes,
                       uint64_t* bytecode_len,
                       const char* bundleFilename,
                       int32_t startLine,
                       Dart_Handle dart_handle,
                       EvaluateScriptsCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] evaluateScriptsWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);
  page->executingContext()->dartIsolateContext()->dispatcher()->PostToJs(
      page->isDedicated(), page->contextId(), webf::evaluateScriptsInternal, page_, code, code_len, parsed_bytecodes,
      bytecode_len, bundleFilename, startLine, persistent_handle, result_callback);
}

void evaluateQuickjsByteCode(void* page_,
                             uint8_t* bytes,
                             int32_t byteLen,
                             Dart_Handle dart_handle,
                             EvaluateQuickjsByteCodeCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] evaluateQuickjsByteCodeWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);
  page->dartIsolateContext()->dispatcher()->PostToJs(page->isDedicated(), page->contextId(),
                                                     webf::evaluateQuickjsByteCodeInternal, page_, bytes, byteLen,
                                                     persistent_handle, result_callback);
}

void parseHTML(void* page_, const char* code, int32_t length) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] parseHTMLWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->executingContext()->dartIsolateContext()->dispatcher()->PostToJs(page->isDedicated(), page->contextId(),
                                                                         webf::parseHTMLInternal, page_, code, length);
}

void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName) {
  webf::ExecutingContext::plugin_byte_code[pluginName] = webf::NativeByteCode{bytes, length};
}

void registerPluginCode(const char* code, int32_t length, const char* pluginName) {
  webf::ExecutingContext::plugin_string_code[pluginName] = std::string(code, length);
}

static WebFInfo* webfInfo{nullptr};

WebFInfo* getWebFInfo() {
  if (webfInfo == nullptr) {
    webfInfo = new WebFInfo();
    webfInfo->app_name = "WebF";
    webfInfo->app_revision = APP_REV;
    webfInfo->app_version = APP_VERSION;
    webfInfo->system_name = SYSTEM_NAME;
  }

  return webfInfo;
}

void* parseSVGResult(const char* code, int32_t length) {
  auto* result = webf::HTMLParser::parseSVGResult(code, length);
  return result;
}

void freeSVGResult(void* svgTree) {
  webf::HTMLParser::freeSVGResult(reinterpret_cast<GumboOutput*>(svgTree));
}

void invokeModuleEvent(void* page_,
                       SharedNativeString* module,
                       const char* eventType,
                       void* event,
                       NativeValue* extra,
                       Dart_Handle dart_handle,
                       InvokeModuleEventCallback result_callback) {
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  auto dart_isolate_context = page->executingContext()->dartIsolateContext();
  auto is_dedicated = page->executingContext()->isDedicated();
  auto context_id = page->contextId();
  dart_isolate_context->dispatcher()->PostToJs(is_dedicated, context_id, webf::invokeModuleEventInternal, page_, module,
                                               eventType, event, extra, persistent_handle, result_callback);
}

void dispatchUITask(void* page_, void* context, void* callback) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  reinterpret_cast<void (*)(void*)>(callback)(context);
}

void* getUICommandItems(void* page_) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  return page->executingContext()->uiCommandBuffer()->data();
}

int64_t getUICommandItemSize(void* page_) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  return page->executingContext()->uiCommandBuffer()->size();
}

void clearUICommandItems(void* page_) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->executingContext()->uiCommandBuffer()->clear();
}

// Callbacks when dart context object was finalized by Dart GC.
static void finalize_dart_context(void* isolate_callback_data, void* peer) {
  auto* dart_isolate_context = (webf::DartIsolateContext*)peer;
  delete dart_isolate_context;
}

void init_dart_dynamic_linking(void* data) {
  if (Dart_InitializeApiDL(data) != 0) {
    printf("Failed to initialize dart VM API\n");
  }
}

void register_dart_context_finalizer(Dart_Handle dart_handle, void* dart_isolate_context) {
  Dart_NewFinalizableHandle_DL(dart_handle, reinterpret_cast<void*>(dart_isolate_context),
                               sizeof(webf::DartIsolateContext), finalize_dart_context);
}

// run in the dart isolate thread
void executeNativeCallback(DartWork* work_ptr) {
  const DartWork dart_work = *work_ptr;
  dart_work();
  delete work_ptr;
}