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

}

void* allocateNewPageWrapper(void* dart_isolate_context_, int32_t targetContextId) {

}

void disposePageWrapper(void* dart_isolate_context_, void* page_) {
  auto* dart_isolate_context = (webf::DartIsolateContext*)dart_isolate_context_;
  dart_isolate_context->dispatcher()->PostToJs(disposePage, dart_isolate_context_, page_);
}

int8_t evaluateScriptsWrapper(void* page_,
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
      evaluateScripts, page_, code, code_len, parsed_bytecodes, bytecode_len, bundleFilename, startLine);
  return 1;
}

int8_t evaluateQuickjsByteCodeWrapper(void* page_, uint8_t* bytes, int32_t byteLen) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] evaluateQuickjsByteCodeWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);

  uint8_t* bytes_copy = (uint8_t*)malloc(byteLen * sizeof(uint8_t));
  memcpy(bytes_copy, bytes, byteLen * sizeof(uint8_t));
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->PostToJsAndCallback(
      evaluateQuickjsByteCode, [bytes_copy]() mutable { free(bytes_copy); }, page_, bytes_copy, byteLen);
  return 1;
}

void parseHTMLWrapper(void* page_, const char* code, int32_t length) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] parseHTMLWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->PostToJs(parseHTML, page_, code, length);
}

::NativeValue* invokeModuleEventWrapper(void* page_,
                                        ::SharedNativeString* module,
                                        const char* eventType,
                                        void* event,
                                        ::NativeValue* extra) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dart] invokeModuleEventWrapper call" << std::endl;
#endif
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  page->GetExecutingContext()->dartIsolateContext()->dispatcher()->PostToJs(invokeModuleEvent, page_, module, eventType,
                                                                            event, extra);
  return nullptr;
}
