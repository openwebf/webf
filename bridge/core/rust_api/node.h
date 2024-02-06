/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_NODE_H_
#define WEBF_CORE_RUST_API_NODE_H_

#include "core/rust_api/event_target.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct NodeRustMethods {
  NodeRustMethods();

  double version{1.0};
  EventTargetRustMethods* event_target;
};

}

#endif  // WEBF_CORE_RUST_API_NODE_H_
