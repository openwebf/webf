/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/executing_context.h"
#include "bindings/qjs/exception_state.h"
#include "core/api/exception_state.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/window.h"

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

}  // namespace webf
