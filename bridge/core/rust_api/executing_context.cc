/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "executing_context.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/window.h"

namespace webf {

RustValue<Document, DocumentRustMethods> ExecutingContextRustMethods::document(webf::ExecutingContext* context) {
  return {
      .value = context->document(),
      .method_pointer = To<DocumentRustMethods>(context->document()->rustMethodPointer()),
  };
}

RustValue<Window, WindowRustMethods> ExecutingContextRustMethods::window(webf::ExecutingContext* context) {
  return {.value = context->window(), .method_pointer = To<WindowRustMethods>(context->window()->rustMethodPointer())};
}

RustValue<SharedExceptionState, ExceptionStateRustMethods> ExecutingContextRustMethods::CreateExceptionState() {
  return {.value = new SharedExceptionState{webf::ExceptionState()},
          .method_pointer = ExceptionState::rustMethodPointer()};
}

}  // namespace webf