/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/executing_context.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/window.h"

namespace webf {

WebFValue<Document, DocumentWebFMethods> ExecutingContextWebFMethods::document(webf::ExecutingContext* context) {
  return {
      .value = context->document(),
      .method_pointer = To<DocumentWebFMethods>(context->document()->publicMethodPointer()),
  };
}

WebFValue<Window, WindowWebFMethods> ExecutingContextWebFMethods::window(webf::ExecutingContext* context) {
  return {.value = context->window(), .method_pointer = To<WindowWebFMethods>(context->window()->publicMethodPointer())};
}

WebFValue<SharedExceptionState, ExceptionStateWebFMethods> ExecutingContextWebFMethods::CreateExceptionState() {
  return {.value = new SharedExceptionState{webf::ExceptionState()},
          .method_pointer = ExceptionState::publicMethodPointer()};
}

}  // namespace webf