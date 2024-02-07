/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "node.h"
#include "core/dom/events/event_target.h"
#include "core/dom/node.h"

namespace webf {

NodeRustMethods::NodeRustMethods(EventTargetRustMethods* super_rust_methods) : event_target(super_rust_methods) {}

RustValue<Node, NodeRustMethods> NodeRustMethods::AppendChild(Node* self_node,
                                                              Node* new_node,
                                                              SharedExceptionState* shared_exception_state) {
  MemberMutationScope member_mutation_scope{self_node->GetExecutingContext()};
  Node* returned_node = self_node->appendChild(new_node, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return {.value = nullptr, .method_pointer = nullptr};
  }

  returned_node->KeepAlive();

  return {.value = returned_node, .method_pointer = To<NodeRustMethods>(returned_node->rustMethodPointer())};
}

}