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

#ifndef BRIDGE_CORE_DOM_NODE_LIST_H_
#define BRIDGE_CORE_DOM_NODE_LIST_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/dom/container_node.h"
#include "core/html/collection_type.h"
#include "core/html/html_collection.h"

namespace webf {

class Node;
class ExceptionState;
class AtomicString;

class NodeList : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = NodeList*;

  static NodeList* Create(ExecutingContext* context, ExceptionState& exception_state) { return nullptr; };

  NodeList(JSContext* ctx) : ScriptWrappable(ctx){};
  ~NodeList() override = default;

  // DOM methods & attributes for NodeList
  virtual unsigned length() const = 0;
  virtual Node* item(unsigned index, ExceptionState& exception_state) const = 0;

  virtual bool NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) = 0;
  virtual void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) = 0;

  // Other methods (not part of DOM)
  virtual bool IsEmptyNodeList() const { return false; }
  virtual bool IsChildNodeList() const { return false; }

  virtual Node* VirtualOwnerNode() const { return nullptr; }

  virtual void InvalidateCache();
  template <typename T>
  T* AddCache(ContainerNode& node, CollectionType collection_type) {
    if (tag_collection_cache_.count(collection_type)) {
      return tag_collection_cache_[collection_type];
    }

    auto* list = MakeGarbageCollected<T>(node, collection_type);
    tag_collection_cache_[collection_type] = list;
    return list;
  }
  void Trace(GCVisitor* visitor) const override;

 protected:
  std::unordered_map<CollectionType, Member<HTMLCollection>> tag_collection_cache_;
};
/*
template <typename Collection>
inline Collection* ContainerNode::EnsureCachedCollection(CollectionType type) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node) {
    return reinterpret_cast<NodeList*>(EnsureRareData().EnsureChildNodeList(*this))->AddCache<Collection>(*this, type);
  }
  return reinterpret_cast<NodeList*>(EnsureRareData().EnsureEmptyChildNodeList(*this))
      ->AddCache<Collection>(*this, type);
}*/

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_NODE_LIST_H_
