/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "bindings/qjs/cppgc/gc_visitor.h"
#include "node_data.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "child_node_list.h"
#include "container_node.h"
#include "empty_node_list.h"
#include "node_list.h"

namespace webf {

void NodeMutationObserverData::Trace(GCVisitor* visitor) const {
  for(auto& entry : registry_) {
    entry->Trace(visitor);
  }

  for(auto& entry : transient_registry_) {
    entry->Trace(visitor);
  }
}

void NodeMutationObserverData::AddTransientRegistration(const std::shared_ptr<MutationObserverRegistration>& registration) {
  transient_registry_.insert(registration);
}

void NodeMutationObserverData::RemoveTransientRegistration(const std::shared_ptr<MutationObserverRegistration>& registration) {
  assert(transient_registry_.count(registration) > 0);
  transient_registry_.erase(registration);
}

void NodeMutationObserverData::AddRegistration(const std::shared_ptr<MutationObserverRegistration>& registration) {
  registry_.emplace_back(registration);
}

void NodeMutationObserverData::RemoveRegistration(const std::shared_ptr<MutationObserverRegistration>& registration) {
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
}

}  // namespace webf
