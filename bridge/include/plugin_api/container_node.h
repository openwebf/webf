/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_CONTAINER_NODE_H_
#define WEBF_CORE_RUST_API_CONTAINER_NODE_H_

#include "node.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;

struct ContainerNodeWebFMethods : WebFPublicMethods {
  ContainerNodeWebFMethods(NodeWebFMethods* super_method);

  double version{1.0};
  NodeWebFMethods* node;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_CONTAINER_NODE_H_
