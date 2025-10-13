/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "empty_node_list.h"
#include "core/dom/node.h"

namespace webf {

EmptyNodeList::EmptyNodeList(Node* root_node) : owner_(root_node), NodeList(root_node->ctx()) {}

void EmptyNodeList::Trace(GCVisitor* visitor) const {
  // No child members in EmptyNodeList, but trace base for any cached collections.
  NodeList::Trace(visitor);
}

bool EmptyNodeList::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  return false;
}

void EmptyNodeList::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) {}

Node* EmptyNodeList::VirtualOwnerNode() const {
  return &OwnerNode();
}

}  // namespace webf
