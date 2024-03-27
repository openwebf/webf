/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_NODE_H_
#define WEBF_CORE_RUST_API_NODE_H_

#include "core/rust_api/event_target.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct Node Node;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct NodeRustMethods;

using RustNodeAppendChild = RustValue<Node, NodeRustMethods> (*)(Node* self_node,
                                                                 Node* new_node,
                                                                 SharedExceptionState* shared_exception_state);

struct NodeRustMethods : RustMethods {
  NodeRustMethods(EventTargetRustMethods* super_rust_methods);

  static RustValue<Node, NodeRustMethods> AppendChild(Node* self_node,
                                                      Node* new_node,
                                                      SharedExceptionState* shared_exception_state);

  double version{1.0};
  EventTargetRustMethods* event_target;

  RustNodeAppendChild rust_node_append_child{AppendChild};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_NODE_H_
