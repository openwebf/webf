/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_DOCUMENT_H_
#define WEBF_CORE_RUST_API_DOCUMENT_H_

#include "core/rust_api/rust_value.h"
#include "core/rust_api/container_node.h"
#include "core/rust_api/element.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Element Element;
typedef struct Document Document;

using RustDocumentCreateElement = RustValue<Element, ElementRustMethods> (*)(Document*, const char*, SharedExceptionState* shared_exception_state);
using RustDocumentGetDocumentElement = RustValue<Element, ElementRustMethods> (*)(Document*);

struct DocumentRustMethods : public RustMethods {
  DocumentRustMethods();

  static RustValue<Element, ElementRustMethods> createElement(Document* document,
                            const char* tag_name,
                            SharedExceptionState* shared_exception_state);
  static RustValue<Element, ElementRustMethods> documentElement(Document* document);

  double version{1.0};
  ContainerNodeRustMethods* container_node;
  RustDocumentCreateElement rust_document_create_element{createElement};
  RustDocumentGetDocumentElement rust_document_get_document_element{documentElement};
};

}

#endif  // WEBF_CORE_RUST_API_DOCUMENT_H_
