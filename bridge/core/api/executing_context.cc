/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/executing_context.h"
#include "bindings/qjs/exception_state.h"
#include "core/api/exception_state.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/window.h"
#include "core/frame/window_or_worker_global_scope.h"

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

void ExecutingContextWebFMethods::ClearTimeout(ExecutingContext* context, int32_t timeout_id,
                                  SharedExceptionState* shared_exception_state) {
  WindowOrWorkerGlobalScope::clearTimeout(context, timeout_id, shared_exception_state->exception_state);
}

void ExecutingContextWebFMethods::ClearInterval(ExecutingContext* context, int32_t interval_id,
                                  SharedExceptionState* shared_exception_state) {
  WindowOrWorkerGlobalScope::clearInterval(context, interval_id, shared_exception_state->exception_state);
}

}  // namespace webf
