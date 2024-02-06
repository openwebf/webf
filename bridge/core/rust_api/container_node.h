/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_CONTAINER_NODE_H_
#define WEBF_CORE_RUST_API_CONTAINER_NODE_H_

#include "core/rust_api/node.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;

struct ContainerNodeRustMethods : RustMethods {
  ContainerNodeRustMethods();

  double version{1.0};
  NodeRustMethods* node;
};

}

#endif  // WEBF_CORE_RUST_API_CONTAINER_NODE_H_
