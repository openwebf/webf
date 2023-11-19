/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_methods.h"
#include <cassert>
#include "dart_isolate_context.h"

using namespace webf;

thread_local DartIsolateContext* currentDartIsolateContext = nullptr;

namespace webf {

webf::DartMethodPointer::DartMethodPointer(void* dart_isolate_context,
                                           const uint64_t* dart_methods,
                                           int32_t dart_methods_length) {
  currentDartIsolateContext = static_cast<DartIsolateContext*>(dart_isolate_context);

  size_t i = 0;
  invoke_module_ = reinterpret_cast<InvokeModule>(dart_methods[i++]);
  request_batch_update_ = reinterpret_cast<RequestBatchUpdate>(dart_methods[i++]);
  reload_app_ = reinterpret_cast<ReloadApp>(dart_methods[i++]);
  set_timeout_ = reinterpret_cast<SetTimeout>(dart_methods[i++]);
  set_interval_ = reinterpret_cast<SetInterval>(dart_methods[i++]);
  clear_timeout_ = reinterpret_cast<ClearTimeout>(dart_methods[i++]);
  request_animation_frame_ = reinterpret_cast<RequestAnimationFrame>(dart_methods[i++]);
  cancel_animation_frame_ = reinterpret_cast<CancelAnimationFrame>(dart_methods[i++]);
  to_blob_ = reinterpret_cast<ToBlob>(dart_methods[i++]);
  flush_ui_command_ = reinterpret_cast<FlushUICommand>(dart_methods[i++]);
  create_binding_object_ = reinterpret_cast<CreateBindingObject>(dart_methods[i++]);
  on_js_error_ = reinterpret_cast<OnJSError>(dart_methods[i++]);
  on_js_log_ = reinterpret_cast<OnJSLog>(dart_methods[i++]);

  assert_m(i == dart_methods_length, "Dart native methods count is not equal with C++ side method registrations.");
}

NativeValue* DartMethodPointer::invokeModule(void* callback_context,
                                             int32_t context_id,
                                             webf::SharedNativeString* moduleName,
                                             webf::SharedNativeString* method,
                                             webf::NativeValue* params,
                                             webf::AsyncModuleCallback callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] invokeModuleWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return nullptr;
  }

  return currentDartIsolateContext->dispatcher()->PostToDartSync(invoke_module_, callback_context, context_id,
                                                                 moduleName, method, params, callback);
}

void DartMethodPointer::requestBatchUpdate(int32_t context_id) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] requestBatchUpdateWrapper call" << std::endl;
#endif

  if (currentDartIsolateContext == nullptr) {
    return;
  }

  currentDartIsolateContext->dispatcher()->PostToDart(request_batch_update_, context_id);
}

void DartMethodPointer::reloadApp(int32_t context_id) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] reloadAppWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  currentDartIsolateContext->dispatcher()->PostToDart(reload_app_, context_id);
}

int32_t DartMethodPointer::setTimeout(void* callback_context,
                                      int32_t context_id,
                                      webf::AsyncCallback callback,
                                      int32_t timeout) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] SetTimeoutWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return -1;
  }

  return currentDartIsolateContext->dispatcher()->PostToDartSync(set_timeout_, callback_context, context_id, callback,
                                                                 timeout);
}

int32_t DartMethodPointer::setInterval(void* callback_context,
                                       int32_t context_id,
                                       webf::AsyncCallback callback,
                                       int32_t timeout) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] SetIntervalWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return -1;
  }

  return currentDartIsolateContext->dispatcher()->PostToDartSync(set_interval_, callback_context, context_id, callback,
                                                                 timeout);
}

void DartMethodPointer::clearTimeout(int32_t context_id, int32_t timerId) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] ClearTimeoutWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  currentDartIsolateContext->dispatcher()->PostToDart(clear_timeout_, context_id, timerId);
}

int32_t DartMethodPointer::requestAnimationFrame(void* callback_context,
                                                 int32_t context_id,
                                                 webf::AsyncRAFCallback callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] RequestAnimationFrameWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return -1;
  }

  return currentDartIsolateContext->dispatcher()->PostToDartSync(request_animation_frame_, callback_context, context_id,
                                                                 callback);
}

void DartMethodPointer::cancelAnimationFrame(int32_t context_id, int32_t id) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] CancelAnimationFrameWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  currentDartIsolateContext->dispatcher()->PostToDart(cancel_animation_frame_, context_id, id);
}

void DartMethodPointer::toBlob(void* callback_context,
                               int32_t context_id,
                               webf::AsyncBlobCallback blobCallback,
                               void* element_ptr,
                               double devicePixelRatio) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "ToBlobWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  currentDartIsolateContext->dispatcher()->PostToDart(to_blob_, callback_context, context_id, blobCallback, element_ptr,
                                                      devicePixelRatio);
}

void DartMethodPointer::flushUICommand(int32_t context_id) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] FlushUICommandWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  currentDartIsolateContext->dispatcher()->PostToDart(flush_ui_command_, context_id);
}

void DartMethodPointer::createBindingObject(int32_t context_id,
                                            void* native_binding_object,
                                            int32_t type,
                                            void* args,
                                            int32_t argc) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] CreateBindingObjectWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  currentDartIsolateContext->dispatcher()->PostToDart(create_binding_object_, context_id, native_binding_object, type,
                                                      args, argc);
}

void DartMethodPointer::onJSError(int32_t context_id, const char* error) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] OnJSErrorWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  currentDartIsolateContext->dispatcher()->PostToDart(on_js_error_, context_id, error);
}

void DartMethodPointer::onJSLog(int32_t context_id, int32_t level, const char* log) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] OnJSLogWrapper call" << std::endl;
#endif
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  if (on_js_log_ == nullptr)
    return;

  currentDartIsolateContext->dispatcher()->PostToDart(on_js_log_, context_id, level, log);
}

void DartMethodPointer::matchImageSnapshot(void* callback_context,
                                           int32_t context_id,
                                           uint8_t* bytes,
                                           int32_t length,
                                           webf::SharedNativeString* name,
                                           webf::MatchImageSnapshotCallback callback) {}

}  // namespace webf
