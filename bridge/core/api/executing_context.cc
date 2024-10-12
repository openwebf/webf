/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/executing_context.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/window.h"

namespace webf {

WebFValue<Document, DocumentPublicMethods> ExecutingContextWebFMethods::document(webf::ExecutingContext* context) {
  auto* document = context->document();
  document->KeepAlive();
  return {
      .value = document,
      .method_pointer = document->documentPublicMethods(),
  };
}

WebFValue<Window, WindowPublicMethods> ExecutingContextWebFMethods::window(webf::ExecutingContext* context) {
  return {.value = context->window(), .method_pointer = context->window()->windowPublicMethods()};
}

WebFValue<SharedExceptionState, ExceptionStatePublicMethods> ExecutingContextWebFMethods::CreateExceptionState() {
  return {.value = new SharedExceptionState{webf::ExceptionState()},
          .method_pointer = ExceptionState::publicMethodPointer()};
}

}  // namespace webf
