/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_DOCUMENT_FRAGMENT_H_
#define WEBF_CORE_RUST_API_DOCUMENT_FRAGMENT_H_

#include "container_node.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct DocumentFragment DocumentFragment;
typedef struct Document Document;

struct DocumentFragmentWebFMethods : WebFPublicMethods {
  DocumentFragmentWebFMethods(ContainerNodeWebFMethods* super_rust_methods);

  double version{1.0};
  ContainerNodeWebFMethods* container_node;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_DOCUMENT_FRAGMENT_H_
