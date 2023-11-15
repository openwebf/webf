/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "webf_bridge_wrapper.h"

#include "bindings/qjs/native_string_utils.h"
#include "core/dart_isolate_context.h"
#include "core/page.h"
#include "dispatcher.h"
#include "foundation/logging.h"
#include "foundation/ui_command_buffer.h"
#include "include/webf_bridge.h"

using namespace webf;

void* initDartIsolateContextWrapper(int8_t dedicated_thread,
                                    int64_t dart_port,
                                    uint64_t* dart_methods,
                                    int32_t dart_methods_len) {
  auto dispatcher = std::make_unique<webf::multi_threading::Dispatcher>(dart_port, dedicated_thread);
  auto* ptr = dispatcher->postToJSSync(initDartIsolateContext, dedicated_thread, dart_methods, dart_methods_len);

  WEBF_LOG(VERBOSE) << "[Dart] initDartIsolateContextWrapper, dartIsolate= " << ptr << std::endl;
  auto* dart_isolate_context = (webf::DartIsolateContext*)ptr;
  dart_isolate_context->SetDispatcher(std::move(dispatcher));
  return dart_isolate_context;
}

void* allocateNewPageWrapper(void* dart_isolate_context_, int32_t targetContextId) {
  WEBF_LOG(VERBOSE) << "[Dart] allocateNewPageWrapper, targetContextId= " << targetContextId << std::endl;
  auto* dart_isolate_context = (webf::DartIsolateContext*)dart_isolate_context_;
  return dart_isolate_context->dispatcher()->postToJSSync(allocateNewPage, dart_isolate_context_, targetContextId);
}

void disposePageWrapper(void* dart_isolate_context_, void* page_) {
  auto* dart_isolate_context = (webf::DartIsolateContext*)dart_isolate_context_;
  dart_isolate_context->dispatcher()->postToJS(disposePage, dart_isolate_context_, page_);
}

int8_t evaluateScriptsWrapper(void* page_,
                              ::SharedNativeString* code,
                              uint8_t** parsed_bytecodes,
                              uint64_t* bytecode_len,
                              const char* bundleFilename,
                              int32_t startLine) {
  WEBF_LOG(VERBOSE) << "[Dart] evaluateScriptsWrapper call" << std::endl;
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->postToJS(
      evaluateScripts, page_, code, parsed_bytecodes, bytecode_len, bundleFilename, startLine);
  return 1;
}

int8_t evaluateQuickjsByteCodeWrapper(void* page_, uint8_t* bytes, int32_t byteLen) {
  WEBF_LOG(VERBOSE) << "[Dart] evaluateQuickjsByteCodeWrapper call" << std::endl;
  auto page = reinterpret_cast<webf::WebFPage*>(page_);

  uint8_t* bytes_copy = (uint8_t*)malloc(byteLen * sizeof(uint8_t));
  memcpy(bytes_copy, bytes, byteLen * sizeof(uint8_t));
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->postToJSAndCallback(
      evaluateQuickjsByteCode, [bytes_copy]() mutable { free(bytes_copy); }, page_, bytes_copy, byteLen);
  return 1;
}

void parseHTMLWrapper(void* page_, const char* code, int32_t length) {
  WEBF_LOG(VERBOSE) << "[Dart] parseHTMLWrapper call" << std::endl;
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->postToJS(parseHTML, page_, code, length);
}

::NativeValue* invokeModuleEventWrapper(void* page_,
                                        ::SharedNativeString* module,
                                        const char* eventType,
                                        void* event,
                                        ::NativeValue* extra) {
  WEBF_LOG(VERBOSE) << "[Dart] invokeModuleEventWrapper call" << std::endl;
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->postToJS(invokeModuleEvent, page_, module, eventType,
                                                                            event, extra);
  return nullptr;
}
