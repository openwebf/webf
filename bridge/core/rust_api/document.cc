/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "document.h"
#include "core/dom/document.h"
#include "core/dom/text.h"
#include "core/html/html_html_element.h"

namespace webf {

DocumentRustMethods::DocumentRustMethods(ContainerNodeRustMethods* super_rust_method)
    : container_node(super_rust_method) {}

RustValue<Element, ElementRustMethods> DocumentRustMethods::CreateElement(
    webf::Document* ptr,
    const char* tag_name,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);
  Element* new_element = document->createElement(tag_name_atomic, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return {.value = nullptr, .method_pointer = nullptr};
  }

  // Hold the reference until rust side notify this element was released.
  new_element->KeepAlive();
  return {.value = new_element, .method_pointer = To<ElementRustMethods>(new_element->rustMethodPointer())};
}

RustValue<Element, ElementRustMethods> DocumentRustMethods::CreateElementWithElementCreationOptions(
    webf::Document* ptr,
    const char* tag_name,
    RustElementCreationOptions& options,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);

  std::string value = std::string("{\"is\":\"") + options.is + "\"}";
  const char* value_cstr = value.c_str();
  webf::ScriptValue options_value = webf::ScriptValue::CreateJsonObject(document->ctx(), value_cstr, value.length());

  Element* new_element = document->createElement(
    tag_name_atomic,
    options_value,
    shared_exception_state->exception_state
  );
  if (shared_exception_state->exception_state.HasException()) {
    return {.value = nullptr, .method_pointer = nullptr};
  }

  // Hold the reference until rust side notify this element was released.
  new_element->KeepAlive();
  return {.value = new_element, .method_pointer = To<ElementRustMethods>(new_element->rustMethodPointer())};
}

RustValue<Element, ElementRustMethods> DocumentRustMethods::CreateElementNS(
    webf::Document* ptr,
    const char* uri,
    const char* tag_name,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString uri_atomic = webf::AtomicString(document->ctx(), uri);
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);
  Element* new_element = document->createElementNS(uri_atomic, tag_name_atomic, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return {.value = nullptr, .method_pointer = nullptr};
  }

  // Hold the reference until rust side notify this element was released.
  new_element->KeepAlive();
  return {.value = new_element, .method_pointer = To<ElementRustMethods>(new_element->rustMethodPointer())};
}

RustValue <Element, ElementRustMethods> DocumentRustMethods::CreateElementNSWithElementCreationOptions(
    webf::Document* ptr,
    const char* uri,
    const char* tag_name,
    RustElementCreationOptions& options,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString uri_atomic = webf::AtomicString(document->ctx(), uri);
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);

  std::string value = std::string("{\"is\":\"") + options.is + "\"}";
  const char* value_cstr = value.c_str();
  webf::ScriptValue options_value = webf::ScriptValue::CreateJsonObject(document->ctx(), value_cstr, value.length());

  Element* new_element = document->createElementNS(
    uri_atomic,
    tag_name_atomic,
    options_value,
    shared_exception_state->exception_state
  );
  if (shared_exception_state->exception_state.HasException()) {
    return {.value = nullptr, .method_pointer = nullptr};
  }

  // Hold the reference until rust side notify this element was released.
  new_element->KeepAlive();
  return {.value = new_element, .method_pointer = To<ElementRustMethods>(new_element->rustMethodPointer())};
}

RustValue<Text, TextNodeRustMethods> DocumentRustMethods::CreateTextNode(
    webf::Document* ptr,
    const char* data,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString data_atomic = webf::AtomicString(document->ctx(), data);
  Text* text_node = document->createTextNode(data_atomic, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return {.value = nullptr, .method_pointer = nullptr};
  }

  text_node->KeepAlive();

  return {.value = text_node, .method_pointer = To<TextNodeRustMethods>(text_node->rustMethodPointer())};
}

RustValue<Element, ElementRustMethods> DocumentRustMethods::DocumentElement(webf::Document* document) {
  return {.value = document->documentElement(),
          .method_pointer = To<ElementRustMethods>(document->documentElement()->rustMethodPointer())};
}

}  // namespace webf
