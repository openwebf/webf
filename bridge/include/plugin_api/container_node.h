/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_CONTAINER_NODE_H_
#define WEBF_CORE_RUST_API_CONTAINER_NODE_H_

#include "node.h"

namespace webf {

class EventTarget;
class SharedExceptionState;
class ExecutingContext;

struct ContainerNodePublicMethods : WebFPublicMethods {
  double version{1.0};
  NodePublicMethods node;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_CONTAINER_NODE_H_
