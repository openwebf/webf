/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "child_node_list.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

ChildNodeList::ChildNodeList(ContainerNode* parent) : parent_(parent), NodeList(parent->ctx()) {}
ChildNodeList::~ChildNodeList() = default;

Node* ChildNodeList::VirtualOwnerNode() const {
  return &OwnerNode();
}

Node* ChildNodeList::item(unsigned index, ExceptionState& exception_state) const {
  return collection_index_cache_.NodeAt(*this, index);
}

bool ChildNodeList::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  int32_t index = std::stoi(key.ToStdString(ctx()));
  return collection_index_cache_.NodeAt(*this, index);
}

void ChildNodeList::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) {
  uint32_t size = collection_index_cache_.NodeCount(*this);
  for (int i = 0; i < size; i++) {
    names.emplace_back(AtomicString(ctx(), std::to_string(i)));
  }
}

Node* ChildNodeList::TraverseForwardToOffset(unsigned offset, Node& current_node, unsigned& current_offset) const {
  assert(current_offset < offset);
  assert(OwnerNode().childNodes() == this);
  assert(&OwnerNode() == current_node.parentNode());
  for (Node* next = current_node.nextSibling(); next; next = next->nextSibling()) {
    if (++current_offset == offset)
      return next;
  }
  return nullptr;
}

Node* ChildNodeList::TraverseBackwardToOffset(unsigned offset, Node& current_node, unsigned& current_offset) const {
  assert(current_offset > offset);
  assert(OwnerNode().childNodes() == this);
  assert(&OwnerNode() == current_node.parentNode());
  for (Node* previous = current_node.previousSibling(); previous; previous = previous->previousSibling()) {
    if (--current_offset == offset)
      return previous;
  }
  return nullptr;
}

void ChildNodeList::Trace(GCVisitor* visitor) const {
  visitor->Trace(parent_);
  collection_index_cache_.Trace(visitor);
  NodeList::Trace(visitor);
}

}  // namespace webf
