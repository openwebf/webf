/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "api.h"
#include "foundation/logging.h"

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

static std::atomic<int64_t> unique_page_id{0};

namespace webf {

static void* initDartIsolateContextInternal(int8_t dedicated_thread, uint64_t* dart_methods, int32_t dart_methods_len) {
  void* ptr = new webf::DartIsolateContext(dedicated_thread == 1, dart_methods, dart_methods_len);
  return ptr;
}

static void* allocateNewPageInternal(void* dart_isolate_context, int32_t targetContextId) {
  assert(dart_isolate_context != nullptr);
  auto page =
      std::make_unique<webf::WebFPage>((webf::DartIsolateContext*)dart_isolate_context, targetContextId, nullptr);
  void* ptr = page.get();
  ((webf::DartIsolateContext*)dart_isolate_context)->AddNewPage(std::move(page));
  return ptr;
}

static void disposePageInternal(void* dart_isolate_context, void* page_) {
  auto* page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());
  ((webf::DartIsolateContext*)dart_isolate_context)->RemovePage(page);
}

static int8_t evaluateScriptsInternal(void* page_,
                                      const char* code,
                                      uint64_t code_len,
                                      uint8_t** parsed_bytecodes,
                                      uint64_t* bytecode_len,
                                      const char* bundleFilename,
                                      int32_t startLine) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());
  return page->evaluateScript(code, code_len, parsed_bytecodes, bytecode_len, bundleFilename, startLine) ? 1 : 0;
}

static int8_t evaluateQuickjsByteCodeInternal(void* page_, uint8_t* bytes, int32_t byteLen) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());
  return page->evaluateByteCode(bytes, byteLen) ? 1 : 0;
}

static void parseHTMLInternal(void* page_, const char* code, int32_t length) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());
  page->parseHTML(code, length);
}

static void* parseSVGResult(const char* code, int32_t length) {
  auto* result = webf::HTMLParser::parseSVGResult(code, length);
  return result;
}

static void freeSVGResult(void* svgTree) {
  webf::HTMLParser::freeSVGResult(reinterpret_cast<GumboOutput*>(svgTree));
}

static NativeValue* invokeModuleEvent(void* page_,
                                      SharedNativeString* module_name,
                                      const char* eventType,
                                      void* event,
                                      NativeValue* extra) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());
  auto* result = page->invokeModuleEvent(reinterpret_cast<webf::SharedNativeString*>(module_name), eventType, event,
                                         reinterpret_cast<webf::NativeValue*>(extra));
  return reinterpret_cast<NativeValue*>(result);
}

static WebFInfo* webfInfo{nullptr};

int32_t profileModeEnabled() {
#if ENABLE_PROFILE
  return 1;
#else
  return 0;
#endif
}

}  // namespace webf

int64_t newPageId() {
  return unique_page_id++;
}

using namespace webf;

void* initDartIsolateContext(int8_t dedicated_thread,
                             int64_t dart_port,
                             uint64_t* dart_methods,
                             int32_t dart_methods_len) {
  auto dispatcher = std::make_unique<webf::multi_threading::Dispatcher>(dart_port, dedicated_thread);

#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] allocateNewPageWrapper, targetContextId= " << targetContextId << std::endl;
#endif

  auto* ptr =
      dispatcher->PostToJsSync(webf::initDartIsolateContextInternal, dedicated_thread, dart_methods, dart_methods_len);
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  dart_isolate_context->SetDispatcher(std::move(dispatcher));
  return dart_isolate_context;
}

void* allocateNewPage(void* ptr, int32_t targetContextId) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] allocateNewPageWrapper, targetContextId= " << targetContextId << std::endl;
#endif
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  return dart_isolate_context->dispatcher()->PostToJsSync(webf::allocateNewPageInternal, ptr, targetContextId);
}

void disposePage(void* ptr, void* page) {
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  dart_isolate_context->dispatcher()->PostToJs(disposePageInternal, ptr, page);
}

int8_t evaluateScripts(void* page_,
                       const char* code,
                       uint64_t code_len,
                       uint8_t** parsed_bytecodes,
                       uint64_t* bytecode_len,
                       const char* bundleFilename,
                       int32_t startLine) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] evaluateScriptsWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->PostToJs(
      evaluateScriptsInternal, page_, code, code_len, parsed_bytecodes, bytecode_len, bundleFilename, startLine);
  return 1;
}

int8_t evaluateQuickjsByteCode(void* page_, uint8_t* bytes, int32_t byteLen) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] evaluateQuickjsByteCodeWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);

  uint8_t* bytes_copy = (uint8_t*)malloc(byteLen * sizeof(uint8_t));
  memcpy(bytes_copy, bytes, byteLen * sizeof(uint8_t));
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->PostToJsAndCallback(
      evaluateQuickjsByteCodeInternal, [bytes_copy]() mutable { free(bytes_copy); }, page_, bytes_copy, byteLen);
  return 1;
}

void parseHTML(void* page_, const char* code, int32_t length) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] parseHTMLWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->PostToJs(parseHTMLInternal, page_, code, length);
}

void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName) {
  webf::ExecutingContext::plugin_byte_code[pluginName] = webf::NativeByteCode{bytes, length};
}

void registerPluginCode(const char* code, int32_t length, const char* pluginName) {
  webf::ExecutingContext::plugin_string_code[pluginName] = std::string(code, length);
}

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

void dispatchUITask(void* page_, void* context, void* callback) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  reinterpret_cast<void (*)(void*)>(callback)(context);
}

void* getUICommandItems(void* page_) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  return page->GetExecutingContext()->uiCommandBuffer()->data();
}

int64_t getUICommandItemSize(void* page_) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  return page->GetExecutingContext()->uiCommandBuffer()->size();
}

void clearUICommandItems(void* page_) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->GetExecutingContext()->uiCommandBuffer()->clear();
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
  WEBF_LOG(VERBOSE) << "[Dart] executeThreadingRequest call from dart" << std::endl;
  const DartWork dart_work = *work_ptr;
  dart_work();
  WEBF_LOG(VERBOSE) << "[Dart] executeThreadingRequest end" << std::endl;
  delete work_ptr;
}