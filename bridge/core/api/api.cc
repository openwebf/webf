/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "api.h"
#include "core/dart_isolate_context.h"
#include "core/html/parser/html_parser.h"
#include "core/page.h"
#include "multiple_threading/dispatcher.h"

namespace webf {

int8_t evaluateScriptsInternal(void* page_,
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

int8_t evaluateQuickjsByteCodeInternal(void* page_, uint8_t* bytes, int32_t byteLen) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());
  return page->evaluateByteCode(bytes, byteLen) ? 1 : 0;
}

void parseHTMLInternal(void* page_, const char* code, int32_t length) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());
  page->parseHTML(code, length);
  delete code;
}

static void ReturnInvokeEventResultToDart(Dart_Handle persistent_handle,
                                          InvokeModuleEventCallback result_callback,
                                          webf::NativeValue* result) {
  Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle, result);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

void invokeModuleEventInternal(void* page_,
                               void* module_name,
                               const char* eventType,
                               void* event,
                               void* extra,
                               Dart_Handle persistent_handle,
                               InvokeModuleEventCallback result_callback) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  auto dart_isolate_context = page->GetExecutingContext()->dartIsolateContext();
  assert(std::this_thread::get_id() == page->currentThread());
  auto* result = page->invokeModuleEvent(reinterpret_cast<webf::SharedNativeString*>(module_name), eventType, event,
                                         reinterpret_cast<webf::NativeValue*>(extra));
  dart_isolate_context->dispatcher()->PostToDart(page->isDedicated(), ReturnInvokeEventResultToDart, persistent_handle,
                                                 result_callback, result);
}

}  // namespace webf
