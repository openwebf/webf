/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "include/webf_bridge.h"
#include <core/binding_object.h>

#include "core/dart_isolate_context.h"
#include "core/html/html_script_element.h"
#include "core/html/parser/html_parser.h"
#include "core/page.h"
#include "foundation/native_type.h"
#include "include/dart_api.h"
#include "multiple_threading/dispatcher.h"
#include "multiple_threading/task.h"

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

void* initDartIsolateContextSync(int64_t dart_port,
                                 uint64_t* dart_methods,
                                 int32_t dart_methods_len) {
  auto dispatcher = std::make_unique<webf::multi_threading::Dispatcher>(dart_port);

#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: initDartIsolateContextSync Call BEGIN";
#endif
  auto* dart_isolate_context = new webf::DartIsolateContext(dart_methods, dart_methods_len);
  dart_isolate_context->SetDispatcher(std::move(dispatcher));

#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: initDartIsolateContextSync Call END";
#endif

  return dart_isolate_context;
}

void* allocateNewPageSync(double thread_identity, void* ptr, void* native_widget_element_shapes, int32_t shape_len, int8_t enable_blink) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: allocateNewPageSync Call BEGIN";
#endif
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  assert(dart_isolate_context != nullptr);

  void* result = static_cast<webf::DartIsolateContext*>(dart_isolate_context)
                     ->AddNewPageSync(thread_identity, native_widget_element_shapes, shape_len, enable_blink);
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: allocateNewPageSync Call END";
#endif

  return result;
}

void allocateNewPage(double thread_identity,
                     int32_t sync_buffer_size,
                     int8_t use_legacy_ui_command,
                     int8_t enable_blink,
                     void* ptr,
                     void* native_widget_element_shapes,
                     int32_t shape_len,
                     Dart_Handle dart_handle,
                     AllocateNewPageCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: allocateNewPage Call BEGIN";
#endif
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  assert(dart_isolate_context != nullptr);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);

  static_cast<webf::DartIsolateContext*>(dart_isolate_context)
      ->AddNewPage(thread_identity, sync_buffer_size, use_legacy_ui_command, enable_blink, native_widget_element_shapes, shape_len, persistent_handle,
                   result_callback);
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: allocateNewPage Call END";
#endif
}

void disposePage(double thread_identity,
                 void* ptr,
                 void* page_,
                 Dart_Handle dart_handle,
                 DisposePageCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: disposePage Call BEGIN";
#endif

  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;

  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);

  ((webf::DartIsolateContext*)dart_isolate_context)
      ->RemovePage(thread_identity, static_cast<webf::WebFPage*>(page_), persistent_handle, result_callback);
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: disposePage Call END";
#endif
}

void disposePageSync(double thread_identity, void* ptr, void* page_) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: disposePageSync Call BEGIN";
#endif
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  ((webf::DartIsolateContext*)dart_isolate_context)
      ->RemovePageSync(thread_identity, static_cast<webf::WebFPage*>(page_));
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: disposePageSync Call END";
#endif
}

void evaluateScripts(void* page_,
                     const char* code,
                     uint64_t code_len,
                     uint8_t** parsed_bytecodes,
                     uint64_t* bytecode_len,
                     const char* bundleFilename,
                     int32_t start_line,
                     void* script_element_,
                     Dart_Handle dart_handle,
                     EvaluateScriptsCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] evaluateScriptsWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  auto script_element = reinterpret_cast<webf::NativeBindingObject*>(script_element_);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);
  page->executingContext()->dartIsolateContext()->dispatcher()->PostToJs(
      page->isDedicated(), static_cast<int32_t>(page->contextId()), webf::WebFPage::EvaluateScriptsInternal, page_,
      code, code_len, parsed_bytecodes, bytecode_len, bundleFilename, start_line, script_element, persistent_handle,
      result_callback);
}

void evaluateModule(void* page_,
                    const char* code,
                    uint64_t code_len,
                    uint8_t** parsed_bytecodes,
                    uint64_t* bytecode_len,
                    const char* bundleFilename,
                    int32_t start_line,
                    void* script_element_,
                    Dart_Handle dart_handle,
                    EvaluateScriptsCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] evaluateModule call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  auto script_element = reinterpret_cast<webf::NativeBindingObject*>(script_element_);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);
  page->executingContext()->dartIsolateContext()->dispatcher()->PostToJs(
      page->isDedicated(), static_cast<int32_t>(page->contextId()), webf::WebFPage::EvaluateModuleInternal, page_,
      code, code_len, parsed_bytecodes, bytecode_len, bundleFilename, start_line, script_element, persistent_handle,
      result_callback);
}

void dumpQuickjsByteCode(void* page_,
                         const char* code,
                         int32_t code_len,
                         uint8_t** parsed_bytecodes,
                         uint64_t* bytecode_len,
                         const char* url,
                         bool is_module,
                         Dart_Handle dart_handle,
                         DumpQuickjsByteCodeCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] dumpQuickjsByteCode call" << std::endl;
#endif

  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);
  page->dartIsolateContext()->dispatcher()->PostToJs(
      page->isDedicated(), static_cast<int32_t>(page->contextId()), webf::WebFPage::DumpQuickJsByteCodeInternal, page,
      code, code_len, parsed_bytecodes, bytecode_len, url, is_module, persistent_handle, result_callback);
}

void evaluateQuickjsByteCode(void* page_,
                             uint8_t* bytes,
                             int32_t byteLen,
                             void* script_element_,
                             Dart_Handle dart_handle,
                             EvaluateQuickjsByteCodeCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] evaluateQuickjsByteCodeWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  auto script_element = reinterpret_cast<webf::NativeBindingObject*>(script_element_);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);
  page->dartIsolateContext()->dispatcher()->PostToJs(page->isDedicated(), static_cast<int32_t>(page->contextId()),
                                                     webf::WebFPage::EvaluateQuickjsByteCodeInternal, page_, bytes,
                                                     byteLen, script_element, persistent_handle, result_callback);
}

void parseHTML(void* page_,
               char* code,
               int32_t length,
               Dart_Handle dart_handle,
               ParseHTMLCallback result_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] parseHTMLWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  Dart_PersistentHandle persistent_handle = Dart_NewPersistentHandle_DL(dart_handle);
  page->executingContext()->dartIsolateContext()->dispatcher()->PostToJs(
      page->isDedicated(), static_cast<int32_t>(page->contextId()), webf::WebFPage::ParseHTMLInternal, page_, code,
      length, persistent_handle, result_callback);
}

void onViewportSizeChanged(void* page_, double inner_width, double inner_height) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] onViewportSizeChanged call width=" << inner_width << " height=" << inner_height
                    << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  if (!page) {
    return;
  }

  auto* dart_isolate_context = page->dartIsolateContext();
  if (!dart_isolate_context || !dart_isolate_context->dispatcher()) {
    return;
  }

  // Run the callback on the JS thread (or current thread for non-dedicated
  // mode) so we can safely touch the DOM / style engine.
  dart_isolate_context->dispatcher()->PostToJs(page->isDedicated(),
                                               static_cast<int32_t>(page->contextId()),
                                               webf::WebFPage::OnViewportSizeChangedInternal,
                                               page_,
                                               inner_width,
                                               inner_height);
}

void onDevicePixelRatioChanged(void* page_, double device_pixel_ratio) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] onDevicePixelRatioChanged call dpr=" << device_pixel_ratio << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  if (!page) {
    return;
  }

  auto* dart_isolate_context = page->dartIsolateContext();
  if (!dart_isolate_context || !dart_isolate_context->dispatcher()) {
    return;
  }

  dart_isolate_context->dispatcher()->PostToJs(page->isDedicated(),
                                               static_cast<int32_t>(page->contextId()),
                                               webf::WebFPage::OnDevicePixelRatioChangedInternal,
                                               page_,
                                               device_pixel_ratio);
}

void onColorSchemeChanged(void* page_, const char* scheme, int32_t length) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] onColorSchemeChanged call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  if (!page) {
    return;
  }

  auto* dart_isolate_context = page->dartIsolateContext();
  if (!dart_isolate_context || !dart_isolate_context->dispatcher()) {
    return;
  }

  // Copy the scheme string into a temporary std::string so it stays valid
  // until the JS-thread callback consumes it.
  std::string scheme_copy;
  if (scheme && length > 0) {
    scheme_copy.assign(scheme, static_cast<size_t>(length));
  }

  dart_isolate_context->dispatcher()->PostToJs(
      page->isDedicated(),
      static_cast<int32_t>(page->contextId()),
      webf::WebFPage::OnColorSchemeChangedInternal,
      page_,
      scheme_copy);
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
  dart_isolate_context->dispatcher()->PostToJs(is_dedicated, static_cast<int32_t>(context_id),
                                               webf::WebFPage::InvokeModuleEventInternal, page_, module, eventType,
                                               event, extra, persistent_handle, result_callback);
}

void* allocateNativeBindingObject() {
  return new webf::NativeBindingObject(nullptr);
}

bool isNativeBindingObjectDisposed(void* native_binding_object) {
  return webf::NativeBindingObject::IsDisposed(static_cast<webf::NativeBindingObject*>(native_binding_object));
}

void batchFreeNativeBindingObjects(void** pointers, int32_t count) {
  if (pointers == nullptr || count <= 0) {
    return;
  }

  // Batch free all the native binding object pointers
  for (int32_t i = 0; i < count; i++) {
    if (pointers[i] != nullptr) {
      delete static_cast<webf::NativeBindingObject*>(pointers[i]);
    }
  }
}

void dispatchUITask(void* page_, void* context, void* callback) {
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

void freeActiveCommandBuffer(void* ui_command_buffer) {
  auto* buffer = static_cast<webf::UICommandBuffer*>(ui_command_buffer);
  delete buffer;
}

void clearUICommandItems(void* page_) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->executingContext()->uiCommandBuffer()->clear();
}

// Callbacks when dart context object was finalized by Dart GC.
static void finalize_dart_context(void* peer) {
  WEBF_LOG(VERBOSE) << "[Dispatcher]: BEGIN FINALIZE DART CONTEXT: ";
  auto* dart_isolate_context = (webf::DartIsolateContext*)peer;
  dart_isolate_context->Dispose([dart_isolate_context]() {
    free(dart_isolate_context);
#if ENABLE_LOG
    WEBF_LOG(VERBOSE) << "[Dispatcher]: SUCCESS FINALIZE DART CONTEXT";
#endif
  });
}

void init_dart_dynamic_linking(void* data) {
  if (Dart_InitializeApiDL(data) != 0) {
    printf("Failed to initialize dart VM API\n");
  }
}

void on_dart_context_finalized(void* dart_isolate_context) {
  finalize_dart_context(dart_isolate_context);
}

int8_t isJSThreadBlocked(void* dart_isolate_context_, double context_id) {
  auto* dart_isolate_context = static_cast<webf::DartIsolateContext*>(dart_isolate_context_);
  auto thread_group_id = static_cast<int32_t>(context_id);
  return dart_isolate_context->dispatcher()->IsThreadBlocked(thread_group_id) ? 1 : 0;
}

// run in the dart isolate thread
void executeNativeCallback(DartWork* work_ptr) {
  auto dart_work = *(work_ptr);
  dart_work(false);
  delete work_ptr;
}
