/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_NODE_H_
#define WEBF_CORE_RUST_API_NODE_H_

#include "event_target.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct Node Node;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct NodeWebFMethods;

using WebFNodeAppendChild = WebFValue<Node, NodeWebFMethods> (*)(Node* self_node,
                                                                 Node* new_node,
                                                                 SharedExceptionState* shared_exception_state);
struct NodeWebFMethods : WebFPublicMethods {
  explicit NodeWebFMethods(EventTargetWebFMethods* super_rust_methods);

  static WebFValue<Node, NodeWebFMethods> AppendChild(Node* self_node,
                                                      Node* new_node,
                                                      SharedExceptionState* shared_exception_state);
  static WebFValue<Node, NodeWebFMethods> RemoveChild(Node* self_node,
                                                      Node* target_node,
                                                      SharedExceptionState* shared_exception_state);
  double version{1.0};
  EventTargetWebFMethods* event_target;

  WebFNodeAppendChild rust_node_append_child{AppendChild};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_NODE_H_
