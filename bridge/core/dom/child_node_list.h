/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_CHILD_NODE_LIST_H_
#define BRIDGE_CORE_DOM_CHILD_NODE_LIST_H_

#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/dom/collection_index_cache.h"
#include "core/dom/container_node.h"
#include "core/dom/node_list.h"

namespace webf {

class ExceptionState;

class ChildNodeList : public NodeList {
 public:
  explicit ChildNodeList(ContainerNode* root_node);
  ~ChildNodeList() override;

  // DOM API.
  unsigned length() const override { return collection_index_cache_.NodeCount(*this); }

  Node* item(unsigned index, ExceptionState& exception_state) const override;

  bool NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) override;
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) override;

  // Non-DOM API.
  void InvalidateCache() { collection_index_cache_.Invalidate(); }
  ContainerNode& OwnerNode() const { return *parent_.Get(); }

  ContainerNode& RootNode() const { return OwnerNode(); }

  // CollectionIndexCache API.
  bool CanTraverseBackward() const { return true; }
  Node* TraverseToFirst() const { return RootNode().firstChild(); }
  Node* TraverseToLast() const { return RootNode().lastChild(); }
  Node* TraverseForwardToOffset(unsigned offset, Node& current_node, unsigned& current_offset) const;
  Node* TraverseBackwardToOffset(unsigned offset, Node& current_node, unsigned& current_offset) const;

  void Trace(GCVisitor*) const override;

 private:
  bool IsChildNodeList() const override { return true; }
  Node* VirtualOwnerNode() const override;

  Member<ContainerNode> parent_;
  mutable CollectionIndexCache<ChildNodeList, Node> collection_index_cache_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_CHILD_NODE_LIST_H_
