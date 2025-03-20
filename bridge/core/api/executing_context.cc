/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/executing_context.h"
#include "bindings/qjs/exception_state.h"
#include "core/api/exception_state.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/legacy/location.h"
#include "core/frame/module_manager.h"
#include "core/frame/window.h"
#include "core/frame/window_or_worker_global_scope.h"
#include "core/timing/performance.h"
#include "foundation/native_value_converter.h"

namespace webf {

WebFValue<Document, DocumentPublicMethods> ExecutingContextWebFMethods::document(webf::ExecutingContext* context) {
  auto* document = context->document();
  WebFValueStatus* status_block = document->KeepAlive();
  return WebFValue<Document, DocumentPublicMethods>(document, document->documentPublicMethods(), status_block);
}

WebFValue<Window, WindowPublicMethods> ExecutingContextWebFMethods::window(webf::ExecutingContext* context) {
  return WebFValue<Window, WindowPublicMethods>(context->window(), context->window()->windowPublicMethods(),
                                                context->window()->KeepAlive());
}

WebFValue<Performance, PerformancePublicMethods> ExecutingContextWebFMethods::performance(webf::ExecutingContext* context) {
  return WebFValue<Performance, PerformancePublicMethods>(context->performance(), context->performance()->performancePublicMethods(),
                                                context->performance()->KeepAlive());
}

WebFValue<SharedExceptionState, ExceptionStatePublicMethods> ExecutingContextWebFMethods::CreateExceptionState() {
  return WebFValue<SharedExceptionState, ExceptionStatePublicMethods>(new SharedExceptionState(),
                                                                      ExceptionState::publicMethodPointer(), nullptr);
}

void ExecutingContextWebFMethods::FinishRecordingUIOperations(webf::ExecutingContext* context) {
  context->uiCommandBuffer()->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr, false);
}

void ExecutingContextWebFMethods::WebFSyncBuffer(webf::ExecutingContext* context) {
  context->uiCommandBuffer()->SyncToActive();
}

struct ImageSnapshotNativeFunctionContext {
  ExecutingContext* context_;
  std::shared_ptr<WebFNativeFunction> function_;
};

void ExecutingContextWebFMethods::WebFMatchImageSnapshot(webf::ExecutingContext* context,
                                                         NativeValue* bytes,
                                                         NativeValue* filename,
                                                         WebFNativeFunctionContext* callback_context,
                                                         SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);
  auto imageBytes = static_cast<uint8_t*>(bytes->u.ptr);
  auto filenameNativeString = static_cast<SharedNativeString*>(filename->u.ptr);
  auto* nativeFunctionContext = new ImageSnapshotNativeFunctionContext{context, callback_impl};

  context->FlushUICommand(context->window(), FlushUICommandReason::kDependentsAll);

  auto fn = [](void* ptr, double contextId, int8_t result, char* errmsg) {
    auto* reader = static_cast<ImageSnapshotNativeFunctionContext*>(ptr);
    auto* context = reader->context_;

    reader->context_->dartIsolateContext()->dispatcher()->PostToJs(
        context->isDedicated(), context->contextId(),
        [](ImageSnapshotNativeFunctionContext* reader, int8_t result, char* errmsg) {
          if (errmsg != nullptr) {
            NativeValue error_object = Native_NewCString(errmsg);
            reader->function_->Invoke(reader->context_, 1, &error_object);
            dart_free(errmsg);
          } else {
            auto params = new NativeValue[2];
            params[0] = Native_NewNull();
            params[1] = Native_NewInt64(result);
            reader->function_->Invoke(reader->context_, 2, params);
          }

          reader->context_->RunRustFutureTasks();
          delete reader;
        },
        reader, result, errmsg);
  };

  context->dartMethodPtr()->matchImageSnapshot(context->isDedicated(), nativeFunctionContext, context->contextId(),
                                               imageBytes, bytes->uint32, filenameNativeString, fn);
}

void ExecutingContextWebFMethods::WebFMatchImageSnapshotBytes(webf::ExecutingContext* context,
                                                              NativeValue* imageA,
                                                              NativeValue* imageB,
                                                              WebFNativeFunctionContext* callback_context,
                                                              SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);
  auto imageABytes = static_cast<uint8_t*>(imageA->u.ptr);
  auto imageBBytes = static_cast<uint8_t*>(imageB->u.ptr);

  auto* nativeFunctionContext = new ImageSnapshotNativeFunctionContext{context, callback_impl};

  context->FlushUICommand(context->window(), FlushUICommandReason::kDependentsAll);

  auto fn = [](void* ptr, double contextId, int8_t result, char* errmsg) {
    auto* reader = static_cast<ImageSnapshotNativeFunctionContext*>(ptr);
    auto* context = reader->context_;

    reader->context_->dartIsolateContext()->dispatcher()->PostToJs(
        context->isDedicated(), context->contextId(),
        [](ImageSnapshotNativeFunctionContext* reader, int8_t result, char* errmsg) {
          if (errmsg != nullptr) {
            NativeValue error_object = Native_NewCString(errmsg);
            reader->function_->Invoke(reader->context_, 1, &error_object);
            dart_free(errmsg);
          } else {
            auto params = new NativeValue[2];
            params[0] = Native_NewNull();
            params[1] = Native_NewInt64(result);
            reader->function_->Invoke(reader->context_, 2, params);
          }

          reader->context_->RunRustFutureTasks();
          delete reader;
        },
        reader, result, errmsg);
  };

  context->dartMethodPtr()->matchImageSnapshotBytes(context->isDedicated(), nativeFunctionContext, context->contextId(),
                                                    imageABytes, imageA->uint32, imageBBytes, imageB->uint32, fn);
}

NativeValue ExecutingContextWebFMethods::WebFInvokeModule(ExecutingContext* context,
                                                          const char* module_name,
                                                          const char* method,
                                                          SharedExceptionState* shared_exception_state) {
  AtomicString module_name_atomic = AtomicString(context->ctx(), module_name);
  AtomicString method_atomic = webf::AtomicString(context->ctx(), method);

  ScriptValue result = ModuleManager::__webf_invoke_module__(context, module_name_atomic, method_atomic,
                                                             shared_exception_state->exception_state);
  NativeValue return_result = result.ToNative(context->ctx(), shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return Native_NewNull();
  }

  return return_result;
}

NativeValue ExecutingContextWebFMethods::WebFInvokeModuleWithParams(ExecutingContext* context,
                                                                    const char* module_name,
                                                                    const char* method,
                                                                    NativeValue* params,
                                                                    SharedExceptionState* shared_exception_state) {
  AtomicString module_name_atomic = AtomicString(context->ctx(), module_name);
  AtomicString method_atomic = webf::AtomicString(context->ctx(), method);

  const NativeValue* result = ModuleManager::__webf_invoke_module__(context, module_name_atomic, method_atomic, *params,
                                                                    nullptr, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException() || result == nullptr) {
    return Native_NewNull();
  }

  NativeValue return_result = *result;
  return return_result;
}

NativeValue ExecutingContextWebFMethods::WebFInvokeModuleWithParamsAndCallback(
    ExecutingContext* context,
    const char* module_name,
    const char* method,
    NativeValue* params,
    WebFNativeFunctionContext* callback_context,
    SharedExceptionState* shared_exception_state) {
  AtomicString module_name_atomic = AtomicString(context->ctx(), module_name);
  AtomicString method_atomic = webf::AtomicString(context->ctx(), method);

  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);

  const NativeValue* result = ModuleManager::__webf_invoke_module__(
      context, module_name_atomic, method_atomic, *params, callback_impl, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return Native_NewNull();
  }

  NativeValue return_result = *result;
  return return_result;
}

void ExecutingContextWebFMethods::WebFLocationReload(ExecutingContext* context,
                                                     SharedExceptionState* shared_exception_state) {
  Location::__webf_location_reload__(context, shared_exception_state->exception_state);
}

int32_t ExecutingContextWebFMethods::SetTimeout(ExecutingContext* context,
                                                WebFNativeFunctionContext* callback_context,
                                                int32_t timeout,
                                                SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);

  return WindowOrWorkerGlobalScope::setTimeout(context, callback_impl, timeout,
                                               shared_exception_state->exception_state);
}

int32_t ExecutingContextWebFMethods::SetInterval(ExecutingContext* context,
                                                 WebFNativeFunctionContext* callback_context,
                                                 int32_t timeout,
                                                 SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);

  return WindowOrWorkerGlobalScope::setInterval(context, callback_impl, timeout,
                                                shared_exception_state->exception_state);
}

void ExecutingContextWebFMethods::ClearTimeout(ExecutingContext* context,
                                               int32_t timeout_id,
                                               SharedExceptionState* shared_exception_state) {
  WindowOrWorkerGlobalScope::clearTimeout(context, timeout_id, shared_exception_state->exception_state);
}

void ExecutingContextWebFMethods::ClearInterval(ExecutingContext* context,
                                                int32_t interval_id,
                                                SharedExceptionState* shared_exception_state) {
  WindowOrWorkerGlobalScope::clearInterval(context, interval_id, shared_exception_state->exception_state);
}

int32_t ExecutingContextWebFMethods::AddRustFutureTask(ExecutingContext* context,
                                                       WebFNativeFunctionContext* callback_context,
                                                       NativeLibraryMetaData* meta_data,
                                                       SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);

  return context->AddRustFutureTask(callback_impl, meta_data);
}

void ExecutingContextWebFMethods::RemoveRustFutureTask(ExecutingContext* context,
                                                       int32_t callback_id,
                                                       NativeLibraryMetaData* meta_data,
                                                       SharedExceptionState* shared_exception_state) {
  context->RemoveRustFutureTask(callback_id, meta_data);
}

}  // namespace webf
