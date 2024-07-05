/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_DOCUMENT_H_
#define WEBF_CORE_RUST_API_DOCUMENT_H_

#include "element.h"
#include "document_fragment.h"
#include "container_node.h"
#include "text.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Element Element;
typedef struct DocumentFragment DocumentFragment;
typedef struct Document Document;
typedef struct Text Text;

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
using WebFDocumentGetDocumentElement = WebFValue<Element, ElementWebFMethods> (*)(Document*);

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
  static WebFValue<Element, ElementWebFMethods> DocumentElement(Document* document);

  double version{1.0};
  ContainerNodeWebFMethods* container_node;
  WebFDocumentCreateElement document_create_element{CreateElement};
  WebFDocumentCreateElementWithElementCreationOptions document_create_element_with_element_creation_options{CreateElementWithElementCreationOptions};
  WebFDocumentCreateElementNS document_create_element_ns{CreateElementNS};
  WebFDocumentCreateElementNSWithElementCreationOptions document_create_element_ns_with_element_creation_options{CreateElementNSWithElementCreationOptions};
  WebFDocumentCreateTextNode document_create_text_node{CreateTextNode};
  WebFDocumentCreateDocumentFragment document_create_document_fragment{CreateDocumentFragment};
  WebFDocumentGetDocumentElement document_get_document_element{DocumentElement};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_DOCUMENT_H_
