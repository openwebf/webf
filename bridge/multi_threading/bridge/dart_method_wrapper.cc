/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_method_wrapper.h"

#include "core/dart_isolate_context.h"
#include "dispatcher.h"
#include "foundation/logging.h"

using namespace webf;

thread_local DartIsolateContext* currentDartIsolateContext = nullptr;

NativeValue* invokeModuleWrapper(void* callback_context,
                                 int32_t context_id,
                                 SharedNativeString* moduleName,
                                 SharedNativeString* method,
                                 NativeValue* params,
                                 AsyncModuleCallback callback) {
  WEBF_LOG(VERBOSE) << "[CPP] invokeModuleWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return nullptr;
  }

  InvokeModule originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->invokeModule;
  return currentDartIsolateContext->dispatcher()->PostToDartSync(originalPtr, callback_context, context_id, moduleName,
                                                                 method, params, callback);
}

void requestBatchUpdateWrapper(int32_t context_id) {
  WEBF_LOG(VERBOSE) << "[CPP] requestBatchUpdateWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  RequestBatchUpdate originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->requestBatchUpdate;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, context_id);
}

void reloadAppWrapper(int32_t context_id) {
  WEBF_LOG(VERBOSE) << "[CPP] reloadAppWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  ReloadApp originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->reloadApp;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, context_id);
}

int32_t SetTimeoutWrapper(void* callback_context, int32_t context_id, AsyncCallback callback, int32_t timeout) {
  WEBF_LOG(VERBOSE) << "[CPP] SetTimeoutWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return -1;
  }

  SetTimeout originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->setTimeout;
  return currentDartIsolateContext->dispatcher()->PostToDartSync(originalPtr, callback_context, context_id, callback,
                                                                 timeout);
}

int32_t SetIntervalWrapper(void* callback_context, int32_t context_id, AsyncCallback callback, int32_t timeout) {
  WEBF_LOG(VERBOSE) << "[CPP] SetIntervalWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return -1;
  }

  SetInterval originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->setInterval;
  return currentDartIsolateContext->dispatcher()->PostToDartSync(originalPtr, callback_context, context_id, callback,
                                                                 timeout);
}

void ClearTimeoutWrapper(int32_t context_id, int32_t timerId) {
  WEBF_LOG(VERBOSE) << "[CPP] ClearTimeoutWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  ClearTimeout originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->clearTimeout;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, context_id, timerId);
}

int32_t RequestAnimationFrameWrapper(void* callback_context, int32_t context_id, AsyncRAFCallback callback) {
  WEBF_LOG(VERBOSE) << "[CPP] RequestAnimationFrameWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return -1;
  }

  RequestAnimationFrame originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->requestAnimationFrame;
  return currentDartIsolateContext->dispatcher()->PostToDartSync(originalPtr, callback_context, context_id, callback);
}

void CancelAnimationFrameWrapper(int32_t context_id, int32_t id) {
  WEBF_LOG(VERBOSE) << "[CPP] CancelAnimationFrameWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  CancelAnimationFrame originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->cancelAnimationFrame;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, context_id, id);
}

void ToBlobWrapper(void* callback_context,
                   int32_t context_id,
                   AsyncBlobCallback blobCallback,
                   void* element_ptr,
                   double devicePixelRatio) {
  WEBF_LOG(VERBOSE) << "ToBlobWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  ToBlob originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->toBlob;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, callback_context, context_id, blobCallback,
                                                      element_ptr, devicePixelRatio);
}

void OnJSErrorWrapper(int32_t context_id, const char* error) {
  WEBF_LOG(VERBOSE) << "[CPP] OnJSErrorWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  OnJSError originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->onJsError;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, context_id, error);
}

void OnJSLogWrapper(int32_t context_id, int32_t level, const char* log) {
  WEBF_LOG(VERBOSE) << "[CPP] OnJSLogWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  OnJSLog originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->onJsLog;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, context_id, level, log);
}

void FlushUICommandWrapper(int32_t context_id) {
  WEBF_LOG(VERBOSE) << "[CPP] FlushUICommandWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  FlushUICommand originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->flushUICommand;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, context_id);
}

void CreateBindingObjectWrapper(int32_t context_id,
                                void* native_binding_object,
                                int32_t type,
                                void* args,
                                int32_t argc) {
  WEBF_LOG(VERBOSE) << "[CPP] CreateBindingObjectWrapper call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return;
  }

  CreateBindingObject originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->create_binding_object;
  currentDartIsolateContext->dispatcher()->PostToDart(originalPtr, context_id, native_binding_object, type, args, argc);
}

#if ENABLE_PROFILE
NativePerformanceEntryList* GetPerformanceEntriesWrapper(int32_t context_id) {
  WEBF_LOG(VERBOSE) << "[CPP] NativePerformanceEntryList call" << std::endl;
  if (currentDartIsolateContext == nullptr) {
    return nullptr;
  }

  GetPerformanceEntries originalPtr = currentDartIsolateContext->dartMethodOriginalPtr()->getPerformanceEntries;
  return currentDartIsolateContext->dispatcher()->postToDartSync(originalPtr, context_id);
}
#endif

namespace webf {

namespace multi_threading {

// need call on c++ QuickJS thread.
void* DartMethodWrapper::GetDartIsolateContext() {
  return currentDartIsolateContext;
}

DartMethodWrapper::DartMethodWrapper(void* dart_isolate_context,
                                     const uint64_t* dart_methods,
                                     int32_t dart_methods_length)
    : dart_method_ptr_(std::make_unique<DartMethodPointer>(dart_methods, dart_methods_length)) {
  currentDartIsolateContext = static_cast<DartIsolateContext*>(dart_isolate_context);

  dart_method_ptr_->invokeModule = invokeModuleWrapper;
  dart_method_ptr_->requestBatchUpdate = requestBatchUpdateWrapper;
  dart_method_ptr_->reloadApp = reloadAppWrapper;
  dart_method_ptr_->setTimeout = SetTimeoutWrapper;
  dart_method_ptr_->setInterval = SetIntervalWrapper;
  dart_method_ptr_->clearTimeout = ClearTimeoutWrapper;
  dart_method_ptr_->requestAnimationFrame = RequestAnimationFrameWrapper;
  dart_method_ptr_->cancelAnimationFrame = CancelAnimationFrameWrapper;
  dart_method_ptr_->toBlob = ToBlobWrapper;
  dart_method_ptr_->onJsError = OnJSErrorWrapper;
  dart_method_ptr_->onJsLog = OnJSLogWrapper;
  dart_method_ptr_->flushUICommand = FlushUICommandWrapper;
  dart_method_ptr_->create_binding_object = CreateBindingObjectWrapper;
#if ENABLE_PROFILE
  dart_method_ptr_->getPerformanceEntries = GetPerformanceEntriesWrapper;
#endif
}

}  // namespace multi_threading

}  // namespace webf
