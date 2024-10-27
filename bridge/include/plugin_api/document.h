/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_DOCUMENT_H_
#define WEBF_CORE_RUST_API_DOCUMENT_H_

#include "comment.h"
#include "container_node.h"
#include "document_fragment.h"
#include "element.h"
#include "event.h"
#include "html_element.h"
#include "text.h"

namespace webf {

class EventTarget;
class SharedExceptionState;
class ExecutingContext;
class Element;
class DocumentFragment;
class Document;
class Text;
class Comment;
class Event;

struct WebFElementCreationOptions {
  const char* is;
};

using PublicDocumentCreateElement =
    WebFValue<Element, ElementPublicMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using PublicDocumentCreateElementWithElementCreationOptions =
    WebFValue<Element, ElementPublicMethods> (*)(Document*,
                                                 const char*,
                                                 WebFElementCreationOptions&,
                                                 SharedExceptionState* shared_exception_state);
using PublicDocumentCreateElementNS =
    WebFValue<Element, ElementPublicMethods> (*)(Document*,
                                                 const char*,
                                                 const char*,
                                                 SharedExceptionState* shared_exception_state);
using PublicDocumentCreateElementNSWithElementCreationOptions =
    WebFValue<Element, ElementPublicMethods> (*)(Document*,
                                                 const char*,
                                                 const char*,
                                                 WebFElementCreationOptions&,
                                                 SharedExceptionState* shared_exception_state);
using PublicDocumentCreateTextNode =
    WebFValue<Text, TextNodePublicMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using PublicDocumentCreateDocumentFragment =
    WebFValue<DocumentFragment, DocumentFragmentPublicMethods> (*)(Document*,
                                                                   SharedExceptionState* shared_exception_state);
using PublicDocumentCreateComment =
    WebFValue<Comment, CommentPublicMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using PublicDocumentCreateEvent =
    WebFValue<Event, EventPublicMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using PublicDocumentQuerySelector =
    WebFValue<Element, ElementPublicMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using PublicDocumentGetElementById =
    WebFValue<Element, ElementPublicMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using PublicDocumentElementFromPoint =
    WebFValue<Element, ElementPublicMethods> (*)(Document*,
                                                 double,
                                                 double,
                                                 SharedExceptionState* shared_exception_state);
using PublicDocumentGetDocumentElement = WebFValue<Element, HTMLElementPublicMethods> (*)(Document*);
using PublicDocumentGetDocumentHeader = WebFValue<Element, HTMLElementPublicMethods> (*)(Document*);
using PublicDocumentGetDocumentBody = WebFValue<Element, HTMLElementPublicMethods> (*)(Document*);

struct DocumentPublicMethods : public WebFPublicMethods {
  static WebFValue<Element, ElementPublicMethods> CreateElement(Document* document,
                                                                const char* tag_name,
                                                                SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementPublicMethods> CreateElementWithElementCreationOptions(
      Document* document,
      const char* tag_name,
      WebFElementCreationOptions& options,
      SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementPublicMethods> CreateElementNS(Document* document,
                                                                  const char* uri,
                                                                  const char* tag_name,
                                                                  SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementPublicMethods> CreateElementNSWithElementCreationOptions(
      Document* document,
      const char* uri,
      const char* tag_name,
      WebFElementCreationOptions& options,
      SharedExceptionState* shared_exception_state);
  static WebFValue<Text, TextNodePublicMethods> CreateTextNode(Document* document,
                                                               const char* data,
                                                               SharedExceptionState* shared_exception_state);
  static WebFValue<DocumentFragment, DocumentFragmentPublicMethods> CreateDocumentFragment(
      Document* document,
      SharedExceptionState* shared_exception_state);
  static WebFValue<Comment, CommentPublicMethods> CreateComment(Document* document,
                                                                const char* data,
                                                                SharedExceptionState* shared_exception_state);
  static WebFValue<Event, EventPublicMethods> CreateEvent(Document* document,
                                                          const char* type,
                                                          SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementPublicMethods> QuerySelector(Document* document,
                                                                const char* selectors,
                                                                SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementPublicMethods> GetElementById(Document* document,
                                                                 const char* id,
                                                                 SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementPublicMethods> ElementFromPoint(Document* document,
                                                                   double x,
                                                                   double y,
                                                                   SharedExceptionState* shared_exception_state);
  static WebFValue<Element, HTMLElementPublicMethods> DocumentElement(Document* document);
  static WebFValue<Element, HTMLElementPublicMethods> Head(Document* document);
  static WebFValue<Element, HTMLElementPublicMethods> Body(Document* document);

  double version{1.0};
  ContainerNodePublicMethods container_node;
  PublicDocumentCreateElement document_create_element{CreateElement};
  PublicDocumentCreateElementWithElementCreationOptions document_create_element_with_element_creation_options{
      CreateElementWithElementCreationOptions};
  PublicDocumentCreateElementNS document_create_element_ns{CreateElementNS};
  PublicDocumentCreateElementNSWithElementCreationOptions document_create_element_ns_with_element_creation_options{
      CreateElementNSWithElementCreationOptions};
  PublicDocumentCreateTextNode document_create_text_node{CreateTextNode};
  PublicDocumentCreateDocumentFragment document_create_document_fragment{CreateDocumentFragment};
  PublicDocumentCreateComment document_create_comment{CreateComment};
  PublicDocumentCreateEvent document_create_event{CreateEvent};
  PublicDocumentQuerySelector document_query_selector{QuerySelector};
  PublicDocumentGetElementById document_get_element_by_id{GetElementById};
  PublicDocumentElementFromPoint document_element_from_point{ElementFromPoint};
  PublicDocumentGetDocumentElement document_get_document_element{DocumentElement};
  PublicDocumentGetDocumentHeader document_get_document_header{Head};
  PublicDocumentGetDocumentBody document_get_document_body{Body};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_DOCUMENT_H_
