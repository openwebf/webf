/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/*
#include "node_data.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "child_node_list.h"
#include "container_node.h"
#include "empty_node_list.h"
#include "node_list.h"

namespace webf {

void NodeMutationObserverData::Trace(GCVisitor* visitor) const {
  for (auto& entry : registry_) {
    visitor->TraceMember(entry);
  }

  for (auto& entry : transient_registry_) {
    visitor->TraceMember(entry);
  }
}

NodeMutationObserverData::~NodeMutationObserverData() {}

void NodeMutationObserverData::AddTransientRegistration(MutationObserverRegistration* registration) {
  transient_registry_.insert(registration);
}

void NodeMutationObserverData::RemoveTransientRegistration(MutationObserverRegistration* registration) {
  assert(transient_registry_.count(registration) > 0);
  transient_registry_.erase(registration);
}

void NodeMutationObserverData::AddRegistration(MutationObserverRegistration* registration) {
  registry_.emplace_back(registration);
}

void NodeMutationObserverData::RemoveRegistration(MutationObserverRegistration* registration) {
  assert(std::find(registry_.begin(), registry_.end(), registration) != registry_.end());
  registry_.erase(std::find(registry_.begin(), registry_.end(), registration));
}

ChildNodeList* NodeData::GetChildNodeList(ContainerNode& node) {
  assert(!node_list_ || &node == node_list_->VirtualOwnerNode());
  return To<ChildNodeList>(node_list_.Get());
}

ChildNodeList* NodeData::EnsureChildNodeList(ContainerNode& node) {
  if (node_list_)
    return To<ChildNodeList>(node_list_.Get());
  auto* list = MakeGarbageCollected<ChildNodeList>(&node);
  node_list_ = list;
  return list;
}

EmptyNodeList* NodeData::EnsureEmptyChildNodeList(Node& node) {
  if (node_list_)
    return To<EmptyNodeList>(node_list_.Get());
  auto* list = MakeGarbageCollected<EmptyNodeList>(&node);
  node_list_ = list;
  return list;
}

void NodeData::Trace(GCVisitor* visitor) const {
  if (node_list_ != nullptr) {
    visitor->TraceValue(node_list_->ToQuickJSUnsafe());
  }
  if (mutation_observer_data_ != nullptr) {
    mutation_observer_data_->Trace(visitor);
  }
}

}  // namespace webf
*/
