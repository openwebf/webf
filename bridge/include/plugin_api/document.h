/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_DOCUMENT_H_
#define WEBF_CORE_RUST_API_DOCUMENT_H_

#include "element.h"
#include "document_fragment.h"
#include "container_node.h"
#include "text.h"
#include "comment.h"
#include "event.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Element Element;
typedef struct DocumentFragment DocumentFragment;
typedef struct Document Document;
typedef struct Text Text;
typedef struct Comment Comment;
typedef struct Event Event;

struct WebFElementCreationOptions {
  const char* is;
};

using WebFDocumentCreateElement =
    WebFValue<Element, ElementWebFMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using WebFDocumentCreateElementWithElementCreationOptions =
    WebFValue<Element, ElementWebFMethods> (*)(Document*, const char*, WebFElementCreationOptions&,
                                               SharedExceptionState* shared_exception_state);
using WebFDocumentCreateElementNS =
    WebFValue<Element, ElementWebFMethods> (*)(Document*, const char*, const char*, SharedExceptionState* shared_exception_state);
using WebFDocumentCreateElementNSWithElementCreationOptions =
    WebFValue<Element, ElementWebFMethods> (*)(Document*, const char*, const char*, WebFElementCreationOptions&,
                                               SharedExceptionState* shared_exception_state);
using WebFDocumentCreateTextNode =
    WebFValue<Text, TextNodeWebFMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using WebFDocumentCreateDocumentFragment =
    WebFValue<DocumentFragment, DocumentFragmentWebFMethods> (*)(Document*, SharedExceptionState* shared_exception_state);
using WebFDocumentCreateComment =
    WebFValue<Comment, CommentWebFMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using WebFDocumentCreateEvent = WebFValue<Event, EventWebFMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using WebFDocumentQuerySelector = WebFValue<Element, ElementWebFMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using WebFDocumentGetElementById = WebFValue<Element, ElementWebFMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using WebFDocumentElementFromPoint = WebFValue<Element, ElementWebFMethods> (*)(Document*, double, double, SharedExceptionState* shared_exception_state);
using WebFDocumentGetDocumentElement = WebFValue<Element, ElementWebFMethods> (*)(Document*);
using WebFDocumentGetDocumentHeader = WebFValue<Element, ElementWebFMethods> (*)(Document*);
using WebFDocumentGetDocumentBody = WebFValue<Element, ElementWebFMethods> (*)(Document*);

struct DocumentWebFMethods : public WebFPublicMethods {
  DocumentWebFMethods(ContainerNodeWebFMethods* super_rust_method);

  static WebFValue<Element, ElementWebFMethods> CreateElement(Document* document,
                                                              const char* tag_name,
                                                              SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementWebFMethods> CreateElementWithElementCreationOptions(Document* document,
                                                                const char* tag_name,
                                                                WebFElementCreationOptions& options,
                                                                SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementWebFMethods> CreateElementNS(Document* document,
                                                              const char* uri,
                                                              const char* tag_name,
                                                              SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementWebFMethods> CreateElementNSWithElementCreationOptions(Document* document,
                                                              const char* uri,
                                                              const char* tag_name,
                                                              WebFElementCreationOptions& options,
                                                              SharedExceptionState* shared_exception_state);
  static WebFValue<Text, TextNodeWebFMethods> CreateTextNode(Document* document,
                                                             const char* data,
                                                             SharedExceptionState* shared_exception_state);
  static WebFValue<DocumentFragment, DocumentFragmentWebFMethods> CreateDocumentFragment(Document* document,
                                                                                         SharedExceptionState* shared_exception_state);
  static WebFValue<Comment, CommentWebFMethods> CreateComment(Document* document, const char* data, SharedExceptionState* shared_exception_state);
  static WebFValue<Event, EventWebFMethods> CreateEvent(Document* document, const char* type, SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementWebFMethods> QuerySelector(Document* document, const char* selectors, SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementWebFMethods> GetElementById(Document* document, const char* id, SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementWebFMethods> ElementFromPoint(Document* document, double x, double y, SharedExceptionState* shared_exception_state);
  static WebFValue<Element, ElementWebFMethods> DocumentElement(Document* document);
  static WebFValue<Element, ElementWebFMethods> Head(Document* document);
  static WebFValue<Element, ElementWebFMethods> Body(Document* document);

  double version{1.0};
  ContainerNodeWebFMethods* container_node;
  WebFDocumentCreateElement document_create_element{CreateElement};
  WebFDocumentCreateElementWithElementCreationOptions document_create_element_with_element_creation_options{CreateElementWithElementCreationOptions};
  WebFDocumentCreateElementNS document_create_element_ns{CreateElementNS};
  WebFDocumentCreateElementNSWithElementCreationOptions document_create_element_ns_with_element_creation_options{CreateElementNSWithElementCreationOptions};
  WebFDocumentCreateTextNode document_create_text_node{CreateTextNode};
  WebFDocumentCreateDocumentFragment document_create_document_fragment{CreateDocumentFragment};
  WebFDocumentCreateComment document_create_comment{CreateComment};
  WebFDocumentCreateEvent document_create_event{CreateEvent};
  WebFDocumentQuerySelector document_query_selector{QuerySelector};
  WebFDocumentGetElementById document_get_element_by_id{GetElementById};
  WebFDocumentElementFromPoint document_element_from_point{ElementFromPoint};
  WebFDocumentGetDocumentElement document_get_document_element{DocumentElement};
  WebFDocumentGetDocumentHeader document_get_document_header{Head};
  WebFDocumentGetDocumentBody document_get_document_body{Body};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_DOCUMENT_H_
