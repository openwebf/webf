/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/node.h"
#include "plugin_api/exception_state.h"
#include "core/dom/events/event_target.h"
#include "core/dom/node.h"

namespace webf {

NodeWebFMethods::NodeWebFMethods(EventTargetWebFMethods* super_webf_methods) : event_target(super_webf_methods) {}

WebFValue<Node, NodeWebFMethods> NodeWebFMethods::AppendChild(Node* self_node,
                                                              Node* new_node,
                                                              SharedExceptionState* shared_exception_state) {
  MemberMutationScope member_mutation_scope{self_node->GetExecutingContext()};
  Node* returned_node = self_node->appendChild(new_node, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return {.value = nullptr, .method_pointer = nullptr};
  }

  returned_node->KeepAlive();

  return {.value = returned_node, .method_pointer = To<NodeWebFMethods>(returned_node->publicMethodPointer())};
}

}  // namespace webf