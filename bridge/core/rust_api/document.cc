/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "document.h"
#include "core/html/html_html_element.h"
#include "core/dom/document.h"

namespace webf {

DocumentRustMethods::DocumentRustMethods() : container_node(ContainerNode::rustMethodPointer()) {}

RustValue<Element, ElementRustMethods> DocumentRustMethods::createElement(webf::Document* ptr,
                                            const char* tag_name,
                                            webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);
  Element* new_element = document->createElement(tag_name_atomic, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return {.value = nullptr, .method_pointer = Element::rustMethodPointer()};
  }

  // Hold the reference until rust side notify this element was released.
  new_element->KeepAlive();
  return {.value = new_element, .method_pointer = Element::rustMethodPointer()};
}

RustValue<Element, ElementRustMethods> DocumentRustMethods::documentElement(webf::Document* document) {
  return {
    .value = document->documentElement(),
    .method_pointer = Element::rustMethodPointer()
  };
}

}  // namespace webf