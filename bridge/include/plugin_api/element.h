/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_ELEMENT_H_
#define WEBF_CORE_RUST_API_ELEMENT_H_

#include "container_node.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Element Element;
typedef struct Document Document;

struct ElementPublicMethods : WebFPublicMethods {
  double version{1.0};
  ContainerNodePublicMethods container_node;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_ELEMENT_H_
