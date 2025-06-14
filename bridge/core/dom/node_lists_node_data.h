/*
 * Copyright (C) 2008, 2010 Apple Inc. All rights reserved.
 * Copyright (C) 2008 David Smith <catfish.man@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_DOM_NODE_LISTS_NODE_DATA_H_
#define WEBF_CORE_DOM_NODE_LISTS_NODE_DATA_H_

#include <unordered_map>
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "core/dom/child_node_list.h"
#include "core/dom/empty_node_list.h"
#include "core/dom/qualified_name.h"
#include "core/dom/tag_collection.h"
#include "core/html/collection_type.h"

namespace webf {

class NodeListsNodeData final {
 public:
  ChildNodeList* GetChildNodeList(ContainerNode& node) {
    assert(!child_node_list_ || node == child_node_list_->VirtualOwnerNode());
    return To<ChildNodeList>(child_node_list_.Get());
  }

  ChildNodeList* EnsureChildNodeList(ContainerNode& node) {
    if (child_node_list_)
      return To<ChildNodeList>(child_node_list_.Get());
    auto* list = MakeGarbageCollected<ChildNodeList>(&node);
    child_node_list_ = list;
    return list;
  }

  EmptyNodeList* EnsureEmptyChildNodeList(Node& node) {
    if (child_node_list_)
      return To<EmptyNodeList>(child_node_list_.Get());
    auto* list = MakeGarbageCollected<EmptyNodeList>(&node);
    child_node_list_ = list;
    return list;
  }

  using NamedNodeListKey = std::pair<CollectionType, AtomicString>;
  struct NodeListAtomicCacheMapEntryHashTraits {
    NodeListAtomicCacheMapEntryHashTraits() = default;

    struct Hash {
      size_t operator()(const NamedNodeListKey& entry) const {
        size_t hash1 = entry.second == CSSSelector::UniversalSelectorAtom() ? g_star_atom.Hash() : entry.second.Hash();
        size_t hash2 = std::hash<CollectionType>()(entry.first);
        return hash1 ^ (hash2 << 1);  // Combine the two hash values
      }
    };

    struct Equal {
      bool operator()(const NamedNodeListKey& lhs, const NamedNodeListKey& rhs) const { return lhs == rhs; }
    };

    static constexpr bool kSafeToCompareToEmptyOrDeleted = true;
  };

  typedef std::unordered_map<NamedNodeListKey,
                             std::shared_ptr<LiveNodeListBase>,
                             NodeListAtomicCacheMapEntryHashTraits::Hash,
                             NodeListAtomicCacheMapEntryHashTraits::Equal>
      NodeListAtomicNameCacheMap;
  typedef std::unordered_map<QualifiedName, Member<TagCollectionNS>> TagCollectionNSCache;

  template <typename T>
  T* AddCache(ContainerNode& node, CollectionType collection_type, const AtomicString& name) {
    NamedNodeListKey key(collection_type, name);
    auto result = atomic_name_caches_.insert({key, nullptr});
    if (!result.second) {
      return static_cast<T*>(result.first->second.get());
    }

    auto* list = MakeGarbageCollected<T>(node, collection_type, name);
    result.first->second = list;
    return list;
  }

  template <typename T>
  T* AddCache(ContainerNode& node, CollectionType collection_type) {
    NamedNodeListKey key(collection_type, CSSSelector::UniversalSelectorAtom());
    auto result = atomic_name_caches_.insert({key, nullptr});
    if (!result.second) {
      return static_cast<T*>(result.first->second.get());
    }

    auto list = std::make_shared<T>(node, collection_type);
    result.first->second = list;
    return list.get();
  }

  template <typename T>
  T* Cached(CollectionType collection_type) {
    auto it = atomic_name_caches_.find(NamedNodeListKey(collection_type, CSSSelector::UniversalSelectorAtom()));
    return static_cast<T*>(it != atomic_name_caches_.end() ? it->second.get() : nullptr);
  }

  TagCollectionNS* AddCache(ContainerNode& node, const AtomicString& namespace_uri, const AtomicString& local_name) {
    QualifiedName name(g_null_atom, local_name, namespace_uri);
    auto result = tag_collection_ns_caches_.insert({name, nullptr});
    if (!result.second) {  // result.second 表示插入是否成功
      return result.first->second.Get();
    }

    auto* list = MakeGarbageCollected<TagCollectionNS>(node, kTagCollectionNSType, namespace_uri, local_name);
    result.first->second = list;
    return list;
  }

  NodeListsNodeData() : child_node_list_(nullptr) {}
  NodeListsNodeData(const NodeListsNodeData&) = delete;
  NodeListsNodeData& operator=(const NodeListsNodeData&) = delete;

  void InvalidateCaches(const QualifiedName* attr_name = nullptr);

  bool IsEmpty() const { return !child_node_list_ && atomic_name_caches_.empty() && tag_collection_ns_caches_.empty(); }

  void AdoptTreeScope() { InvalidateCaches(); }

  void AdoptDocument(Document& old_document, Document& new_document) {
    assert(old_document != new_document);

    NodeListAtomicNameCacheMap::const_iterator atomic_name_cache_end = atomic_name_caches_.end();
    for (NodeListAtomicNameCacheMap::const_iterator it = atomic_name_caches_.begin(); it != atomic_name_cache_end;
         ++it) {
      LiveNodeListBase* list = it->second.get();
      list->DidMoveToDocument(old_document, new_document);
    }

    TagCollectionNSCache::const_iterator tag_end = tag_collection_ns_caches_.end();
    for (TagCollectionNSCache::const_iterator it = tag_collection_ns_caches_.begin(); it != tag_end; ++it) {
      LiveNodeListBase* list = it->second.Get();
      assert(!list->IsRootedAtTreeScope());
      list->DidMoveToDocument(old_document, new_document);
    }
  }

  void Trace(GCVisitor*) const;

 private:
  // Can be a ChildNodeList or an EmptyNodeList.
  Member<NodeList> child_node_list_;
  NodeListAtomicNameCacheMap atomic_name_caches_;
  TagCollectionNSCache tag_collection_ns_caches_;
};

template <typename Collection>
inline Collection* ContainerNode::EnsureCachedCollection(CollectionType type) {
  return EnsureNodeLists().AddCache<Collection>(*this, type);
}

template <typename Collection>
inline Collection* ContainerNode::EnsureCachedCollection(CollectionType type, const AtomicString& name) {
  return EnsureNodeLists().AddCache<Collection>(*this, type, name);
}

template <typename Collection>
inline Collection* ContainerNode::EnsureCachedCollection(CollectionType type,
                                                         const AtomicString& namespace_uri,
                                                         const AtomicString& local_name) {
  assert(type == kTagCollectionNSType);
  return EnsureNodeLists().AddCache(*this, namespace_uri, local_name);
}

template <typename Collection>
inline Collection* ContainerNode::CachedCollection(CollectionType type) {
  NodeListsNodeData* node_lists = NodeLists();
  return node_lists ? node_lists->Cached<Collection>(type) : nullptr;
}

}  // namespace webf

#endif  // WEBF_CORE_DOM_NODE_LISTS_NODE_DATA_H_
