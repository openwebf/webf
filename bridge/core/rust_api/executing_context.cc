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
      .method_pointer = Document::rustMethodPointer(),
  };
}

RustValue<Window, WindowRustMethods> ExecutingContextRustMethods::window(webf::ExecutingContext* context) {
  return {
      .value = context->window(),
      .method_pointer = Window::rustMethodPointer(),
  };
}

RustValue<SharedExceptionState, ExceptionStateRustMethods> ExecutingContextRustMethods::create_exception_state() {
  return {.value = new SharedExceptionState{webf::ExceptionState()},
          .method_pointer = ExceptionState::rustMethodPointer()};
}

}  // namespace webf