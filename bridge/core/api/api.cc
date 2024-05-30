/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "api.h"
#include "core/dart_isolate_context.h"
#include "core/html/parser/html_parser.h"
#include "core/page.h"
#include "multiple_threading/dispatcher.h"

namespace webf {

static void ReturnEvaluateScriptsInternal(Dart_PersistentHandle persistent_handle,
                                          EvaluateQuickjsByteCodeCallback result_callback,
                                          bool is_success) {
  Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle, is_success ? 1 : 0);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

void evaluateScriptsInternal(void* page_,
                             const char* code,
                             uint64_t code_len,
                             uint8_t** parsed_bytecodes,
                             uint64_t* bytecode_len,
                             const char* bundleFilename,
                             int32_t startLine,
                             int64_t profile_id,
                             Dart_Handle persistent_handle,
                             EvaluateScriptsCallback result_callback) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());

  page->dartIsolateContext()->profiler()->StartTrackEvaluation(profile_id);

  bool is_success = page->evaluateScript(code, code_len, parsed_bytecodes, bytecode_len, bundleFilename, startLine);

  page->dartIsolateContext()->profiler()->FinishTrackEvaluation(profile_id);

  page->dartIsolateContext()->dispatcher()->PostToDart(page->isDedicated(), ReturnEvaluateScriptsInternal,
                                                       persistent_handle, result_callback, is_success);
}

static void ReturnEvaluateQuickjsByteCodeResultToDart(Dart_PersistentHandle persistent_handle,
                                                      EvaluateQuickjsByteCodeCallback result_callback,
                                                      bool is_success) {
  Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle, is_success ? 1 : 0);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

void evaluateQuickjsByteCodeInternal(void* page_,
                                     uint8_t* bytes,
                                     int32_t byteLen,
                                     int64_t profile_id,
                                     Dart_PersistentHandle persistent_handle,
                                     EvaluateQuickjsByteCodeCallback result_callback) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());

  page->dartIsolateContext()->profiler()->StartTrackEvaluation(profile_id);

  bool is_success = page->evaluateByteCode(bytes, byteLen);

  page->dartIsolateContext()->profiler()->FinishTrackEvaluation(profile_id);

  page->dartIsolateContext()->dispatcher()->PostToDart(page->isDedicated(), ReturnEvaluateQuickjsByteCodeResultToDart,
                                                       persistent_handle, result_callback, is_success);
}

static void ReturnParseHTMLToDart(Dart_PersistentHandle persistent_handle, ParseHTMLCallback result_callback) {
  Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

void parseHTMLInternal(void* page_,
                       char* code,
                       int32_t length,
                       int64_t profile_id,
                       Dart_PersistentHandle dart_handle,
                       ParseHTMLCallback result_callback) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  assert(std::this_thread::get_id() == page->currentThread());

  page->dartIsolateContext()->profiler()->StartTrackEvaluation(profile_id);

  page->parseHTML(code, length);
  dart_free(code);

  page->dartIsolateContext()->profiler()->FinishTrackEvaluation(profile_id);

  page->dartIsolateContext()->dispatcher()->PostToDart(page->isDedicated(), ReturnParseHTMLToDart, dart_handle,
                                                       result_callback);
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
  auto dart_isolate_context = page->executingContext()->dartIsolateContext();
  assert(std::this_thread::get_id() == page->currentThread());

  page->dartIsolateContext()->profiler()->StartTrackAsyncEvaluation();

  auto* result = page->invokeModuleEvent(reinterpret_cast<webf::SharedNativeString*>(module_name), eventType, event,
                                         reinterpret_cast<webf::NativeValue*>(extra));

  page->dartIsolateContext()->profiler()->FinishTrackAsyncEvaluation();

  dart_isolate_context->dispatcher()->PostToDart(page->isDedicated(), ReturnInvokeEventResultToDart, persistent_handle,
                                                 result_callback, result);
}

static void ReturnDumpByteCodeResultToDart(Dart_Handle persistent_handle, DumpQuickjsByteCodeCallback result_callback) {
  Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

void dumpQuickJsByteCodeInternal(void* page_,
                                 int64_t profile_id,
                                 const char* code,
                                 int32_t code_len,
                                 uint8_t** parsed_bytecodes,
                                 uint64_t* bytecode_len,
                                 const char* url,
                                 Dart_PersistentHandle persistent_handle,
                                 DumpQuickjsByteCodeCallback result_callback) {
  auto page = reinterpret_cast<webf::WebFPage*>(page_);
  auto dart_isolate_context = page->executingContext()->dartIsolateContext();

  dart_isolate_context->profiler()->StartTrackEvaluation(profile_id);

  assert(std::this_thread::get_id() == page->currentThread());
  uint8_t* bytes = page->dumpByteCode(code, code_len, url, bytecode_len);
  *parsed_bytecodes = bytes;

  dart_isolate_context->profiler()->FinishTrackEvaluation(profile_id);

  dart_isolate_context->dispatcher()->PostToDart(page->isDedicated(), ReturnDumpByteCodeResultToDart, persistent_handle,
                                                 result_callback);
}

}  // namespace webf
