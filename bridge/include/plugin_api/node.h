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

struct NodePublicMethods;

using PublicNodeAppendChild = WebFValue<Node, NodePublicMethods> (*)(Node* self_node,
                                                                 Node* new_node,
                                                                 SharedExceptionState* shared_exception_state);

using PublicNodeRemoveChild = WebFValue<Node, NodePublicMethods> (*)(Node* self_node,
                                                                     Node* target_node,
                                                                     SharedExceptionState* shared_exception_state);

struct NodePublicMethods : WebFPublicMethods {
  explicit NodePublicMethods();

  static WebFValue<Node, NodePublicMethods> AppendChild(Node* self_node,
                                                      Node* new_node,
                                                      SharedExceptionState* shared_exception_state);
  static WebFValue<Node, NodePublicMethods> RemoveChild(Node* self_node,
                                                      Node* target_node,
                                                      SharedExceptionState* shared_exception_state);
  double version{1.0};
  EventTargetPublicMethods event_target;
  PublicNodeAppendChild rust_node_append_child{AppendChild};
  PublicNodeRemoveChild public_node_remove_child{RemoveChild};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_NODE_H_
