/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/node.h"
#include "core/dom/events/event_target.h"
#include "core/dom/node.h"
#include "plugin_api/exception_state.h"

namespace webf {

NodePublicMethods::NodePublicMethods() {}

WebFValue<Node, NodePublicMethods> NodePublicMethods::AppendChild(Node* self_node,
                                                              Node* new_node,
                                                              SharedExceptionState* shared_exception_state) {
  MemberMutationScope member_mutation_scope{self_node->GetExecutingContext()};
  Node* returned_node = self_node->appendChild(new_node, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Node, NodePublicMethods>::Null();
  }

  WebFValueStatus* status_block = returned_node->KeepAlive();
  return WebFValue<Node, NodePublicMethods>(returned_node, returned_node->nodePublicMethods(), status_block);
}

WebFValue<Node, NodePublicMethods> NodePublicMethods::RemoveChild(webf::Node* self_node,
                                                              webf::Node* target_node,
                                                              webf::SharedExceptionState* shared_exception_state) {
  MemberMutationScope member_mutation_scope{self_node->GetExecutingContext()};
  Node* returned_node = target_node->removeChild(target_node, shared_exception_state->exception_state);
  if (shared_exception_state->exception_state.HasException()) {
    return WebFValue<Node, NodePublicMethods>::Null();
  }

  WebFValueStatus* status_block = returned_node->KeepAlive();
  return WebFValue<Node, NodePublicMethods>(returned_node, returned_node->nodePublicMethods(), status_block);
}

}  // namespace webf