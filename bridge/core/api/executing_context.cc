/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/executing_context.h"
#include "bindings/qjs/exception_state.h"
#include "core/api/exception_state.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/module_manager.h"
#include "core/frame/window.h"
#include "core/frame/window_or_worker_global_scope.h"
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

WebFValue<SharedExceptionState, ExceptionStatePublicMethods> ExecutingContextWebFMethods::CreateExceptionState() {
  return WebFValue<SharedExceptionState, ExceptionStatePublicMethods>(new SharedExceptionState(),
                                                                      ExceptionState::publicMethodPointer(), nullptr);
}

void ExecutingContextWebFMethods::FinishRecordingUIOperations(webf::ExecutingContext* context) {
  context->uiCommandBuffer()->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr, false);
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

  if (shared_exception_state->exception_state.HasException()) {
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

}  // namespace webf
