/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/document.h"
#include "binding_call_methods.h"
#include "core/api/exception_state.h"
#include "core/dom/comment.h"
#include "core/dom/document.h"
#include "core/dom/document_fragment.h"
#include "core/dom/events/event.h"
#include "core/dom/text.h"
#include "core/html/html_body_element.h"
#include "core/html/html_head_element.h"
#include "core/html/html_html_element.h"

namespace webf {

WebFValue<Element, ElementPublicMethods> DocumentPublicMethods::CreateElement(
    webf::Document* ptr,
    const char* tag_name,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);
  Element* new_element = document->createElement(tag_name_atomic, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Element, ElementPublicMethods>::Null();
  }

  // Hold the reference until rust side notify this element was released.
  WebFValueStatus* status_block = new_element->KeepAlive();
  return WebFValue<Element, ElementPublicMethods>(new_element, new_element->elementPublicMethods(), status_block);
}

WebFValue<Element, ElementPublicMethods> DocumentPublicMethods::CreateElementWithElementCreationOptions(
    webf::Document* ptr,
    const char* tag_name,
    WebFElementCreationOptions& options,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);

  std::string value = std::string(R"({"is":")") + options.is + "\"}";
  const char* value_cstr = value.c_str();
  webf::ScriptValue options_value = webf::ScriptValue::CreateJsonObject(document->ctx(), value_cstr, value.length());

  Element* new_element =
      document->createElement(tag_name_atomic, options_value, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Element, ElementPublicMethods>::Null();
  }

  // Hold the reference until rust side notify this element was released.
  WebFValueStatus* status_block = new_element->KeepAlive();
  return WebFValue<Element, ElementPublicMethods>(new_element, new_element->elementPublicMethods(), status_block);
}

WebFValue<Element, ElementPublicMethods> DocumentPublicMethods::CreateElementNS(
    webf::Document* ptr,
    const char* uri,
    const char* tag_name,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString uri_atomic = webf::AtomicString(document->ctx(), uri);
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);
  Element* new_element =
      document->createElementNS(uri_atomic, tag_name_atomic, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Element, ElementPublicMethods>::Null();
  }

  // Hold the reference until rust side notify this element was released.
  WebFValueStatus* status_block = new_element->KeepAlive();
  return WebFValue<Element, ElementPublicMethods>(new_element, new_element->elementPublicMethods(), status_block);
}

WebFValue<Element, ElementPublicMethods> DocumentPublicMethods::CreateElementNSWithElementCreationOptions(
    webf::Document* ptr,
    const char* uri,
    const char* tag_name,
    WebFElementCreationOptions& options,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString uri_atomic = webf::AtomicString(document->ctx(), uri);
  webf::AtomicString tag_name_atomic = webf::AtomicString(document->ctx(), tag_name);

  std::string value = std::string(R"({"is":")") + options.is + "\"}";
  const char* value_cstr = value.c_str();
  webf::ScriptValue options_value = webf::ScriptValue::CreateJsonObject(document->ctx(), value_cstr, value.length());

  Element* new_element =
      document->createElementNS(uri_atomic, tag_name_atomic, options_value, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Element, ElementPublicMethods>::Null();
  }

  // Hold the reference until rust side notify this element was released.
  WebFValueStatus* status_block = new_element->KeepAlive();
  return WebFValue<Element, ElementPublicMethods>(new_element, new_element->elementPublicMethods(), status_block);
}

WebFValue<Text, TextNodePublicMethods> DocumentPublicMethods::CreateTextNode(
    webf::Document* ptr,
    const char* data,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString data_atomic = webf::AtomicString(document->ctx(), data);
  Text* text_node = document->createTextNode(data_atomic, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Text, TextNodePublicMethods>::Null();
  }

  WebFValueStatus* status_block = text_node->KeepAlive();

  return WebFValue<Text, TextNodePublicMethods>(text_node, text_node->textNodePublicMethods(), status_block);
}

WebFValue<DocumentFragment, DocumentFragmentPublicMethods> DocumentPublicMethods::CreateDocumentFragment(
    webf::Document* ptr,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  DocumentFragment* document_fragment = document->createDocumentFragment(shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<DocumentFragment, DocumentFragmentPublicMethods>::Null();
  }

  WebFValueStatus* status_block = document_fragment->KeepAlive();

  return WebFValue<DocumentFragment, DocumentFragmentPublicMethods>(
      document_fragment, document_fragment->documentFragmentPublicMethods(), status_block);
}

WebFValue<Comment, CommentPublicMethods> DocumentPublicMethods::CreateComment(
    webf::Document* ptr,
    const char* data,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString data_atomic = webf::AtomicString(document->ctx(), data);
  Comment* comment = document->createComment(data_atomic, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Comment, CommentPublicMethods>::Null();
  }

  WebFValueStatus* status_block = comment->KeepAlive();

  return WebFValue<Comment, CommentPublicMethods>(comment, comment->commentPublicMethods(), status_block);
}

WebFValue<Event, EventPublicMethods> DocumentPublicMethods::CreateEvent(
    webf::Document* ptr,
    const char* type,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString type_atomic = webf::AtomicString(document->ctx(), type);
  Event* event = document->createEvent(type_atomic, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Event, EventPublicMethods>::Null();
  }

  WebFValueStatus* status_block = event->KeepAlive();

  return WebFValue<Event, EventPublicMethods>(event, event->eventPublicMethods(), status_block);
}

WebFValue<Element, ElementPublicMethods> DocumentPublicMethods::QuerySelector(
    webf::Document* ptr,
    const char* selectors,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString selectors_atomic = webf::AtomicString(document->ctx(), selectors);
  Element* element = document->querySelector(selectors_atomic, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Element, ElementPublicMethods>::Null();
  }

  WebFValueStatus* status_block = element->KeepAlive();

  return WebFValue<Element, ElementPublicMethods>(element, element->elementPublicMethods(), status_block);
}

WebFValue<Element, ElementPublicMethods> DocumentPublicMethods::GetElementById(
    webf::Document* ptr,
    const char* id,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  webf::AtomicString id_atomic = webf::AtomicString(document->ctx(), id);
  Element* element = document->getElementById(id_atomic, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Element, ElementPublicMethods>::Null();
  }

  WebFValueStatus* status_block = element->KeepAlive();

  return WebFValue<Element, ElementPublicMethods>(element, element->elementPublicMethods(), status_block);
}

WebFValue<Element, ElementPublicMethods> DocumentPublicMethods::ElementFromPoint(
    webf::Document* ptr,
    double x,
    double y,
    webf::SharedExceptionState* shared_exception_state) {
  auto* document = static_cast<webf::Document*>(ptr);
  MemberMutationScope scope{document->GetExecutingContext()};
  Element* element = document->elementFromPoint(x, y, shared_exception_state->exception_state);

  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Element, ElementPublicMethods>::Null();
  }

  WebFValueStatus* status_block = element->KeepAlive();

  return WebFValue<Element, ElementPublicMethods>(element, element->elementPublicMethods(), status_block);
}

WebFValue<Element, HTMLElementPublicMethods> DocumentPublicMethods::DocumentElement(webf::Document* document) {
  auto* document_element = document->documentElement();
  WebFValueStatus* status_block = document_element->KeepAlive();
  return WebFValue<Element, HTMLElementPublicMethods>{document_element, document_element->htmlElementPublicMethods(),
                                                      status_block};
}

WebFValue<Element, HTMLElementPublicMethods> DocumentPublicMethods::Head(webf::Document* document) {
  auto* head = document->head();
  WebFValueStatus* status_block = head->KeepAlive();
  return WebFValue<Element, HTMLElementPublicMethods>{head, head->htmlElementPublicMethods(), status_block};
}

WebFValue<Element, HTMLElementPublicMethods> DocumentPublicMethods::Body(webf::Document* document) {
  auto* body = document->body();
  WebFValueStatus* status_block = body->KeepAlive();
  return WebFValue<Element, HTMLElementPublicMethods>{body, body->htmlElementPublicMethods(), status_block};
}

void DocumentPublicMethods::ClearCookie(webf::Document* document, webf::SharedExceptionState* shared_exception_state) {
  document->InvokeBindingMethod(binding_call_methods::k___clear_cookies__, 0, nullptr,
                                FlushUICommandReason::kDependentsOnElement, shared_exception_state->exception_state);
}

}  // namespace webf
