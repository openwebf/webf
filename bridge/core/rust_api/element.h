/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_ELEMENT_H_
#define WEBF_CORE_RUST_API_ELEMENT_H_

#include "core/rust_api/container_node.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Element Element;
typedef struct Document Document;

struct ElementRustMethods {
  ElementRustMethods();

  double version{1.0};
  ContainerNodeRustMethods* container_node;
};

}

#endif  // WEBF_CORE_RUST_API_ELEMENT_H_
