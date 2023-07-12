/*
 * Copyright (c) 2013, Opera Software ASA. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of Opera Software ASA nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
  void ChildrenChanged(const ContainerNode::ChildrenChange&);
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
