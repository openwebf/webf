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

#ifndef WEBF_CORE_DOM_NODE_RARE_DATA_H_
#define WEBF_CORE_DOM_NODE_RARE_DATA_H_

#include <unordered_set>
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "bindings/qjs/heap_vector.h"

namespace webf {

enum class DynamicRestyleFlags;
enum class ElementFlags;
class FlatTreeNodeData;
class MutationObserverRegistration;
class NodeListsNodeData;
class NodeRareData;
/*
// TODO(guopengfei)：
class Part;f
class ScrollTimeline;

using PartsList = HeapDeque<Member<Part>>;
*/

class ChildNodeList;
class EmptyNodeList;
class ContainerNode;
class NodeList;
class Node;

class NodeMutationObserverData final {
 public:
  NodeMutationObserverData() = default;
  NodeMutationObserverData(const NodeMutationObserverData&) = delete;
  NodeMutationObserverData& operator=(const NodeMutationObserverData&) = delete;

  const HeapVector<Member<MutationObserverRegistration>>& Registry() { return registry_; }

  const std::unordered_set<Member<MutationObserverRegistration>, Member<MutationObserverRegistration>::KeyHasher>&
  TransientRegistry() {
    return transient_registry_;
  }

  void AddTransientRegistration(MutationObserverRegistration* registration);
  void RemoveTransientRegistration(MutationObserverRegistration* registration);
  void AddRegistration(MutationObserverRegistration* registration);
  void RemoveRegistration(MutationObserverRegistration* registration);

  void Trace(GCVisitor* visitor) const;

 private:
  HeapVector<Member<MutationObserverRegistration>> registry_;
  std::unordered_set<Member<MutationObserverRegistration>, Member<MutationObserverRegistration>::KeyHasher>
      transient_registry_;
};

class NodeRareData {
 public:
  enum : uint32_t {
    kConnectedFrameCountBits = 10,  // Must fit Page::maxNumberOfFrames.
    kNumberOfElementFlags = 8,
    kNumberOfDynamicRestyleFlags = 14
    // 0 bits remaining.
  };

  NodeRareData() : restyle_flags_(0u), connected_frame_count_(0u), element_flags_(0u) {};
  ~NodeRareData() = default;
  NodeRareData(const NodeRareData&) = delete;
  NodeRareData& operator=(const NodeRareData&) = delete;

  void ClearNodeLists() { node_lists_ = nullptr; }
  NodeListsNodeData* NodeLists() const { return node_lists_.get(); }
  // EnsureNodeLists() and a following NodeListsNodeData functions must be
  // wrapped with a ThreadState::GCForbiddenScope in order to avoid an
  // initialized node_lists_ is cleared by NodeRareData::TraceAfterDispatch().
  NodeListsNodeData& EnsureNodeLists() {
    if (!node_lists_)
      return CreateNodeLists();
    return *node_lists_;
  }

  FlatTreeNodeData* GetFlatTreeNodeData() const { return flat_tree_node_data_.get(); }
  FlatTreeNodeData& EnsureFlatTreeNodeData();

  NodeMutationObserverData* MutationObserverData() { return mutation_observer_data_.get(); }
  NodeMutationObserverData& EnsureMutationObserverData() {
    if (!mutation_observer_data_) {
      mutation_observer_data_ = std::make_shared<NodeMutationObserverData>();
    }
    return *mutation_observer_data_;
  }

  uint16_t ConnectedSubframeCount() const { return connected_frame_count_; }
  void IncrementConnectedSubframeCount();
  void DecrementConnectedSubframeCount() {
    assert(connected_frame_count_);
    --connected_frame_count_;
  }

  bool HasElementFlag(ElementFlags mask) const { return element_flags_ & static_cast<uint16_t>(mask); }
  void SetElementFlag(ElementFlags mask, bool value) {
    element_flags_ =
        (element_flags_ & ~static_cast<uint16_t>(mask)) | (-static_cast<uint16_t>(value) & static_cast<uint16_t>(mask));
  }
  void ClearElementFlag(ElementFlags mask) { element_flags_ &= ~static_cast<uint16_t>(mask); }

  bool HasRestyleFlag(DynamicRestyleFlags mask) const { return restyle_flags_ & static_cast<uint16_t>(mask); }
  void SetRestyleFlag(DynamicRestyleFlags mask) { restyle_flags_ |= static_cast<uint16_t>(mask); }
  bool HasRestyleFlags() const { return restyle_flags_; }
  void ClearRestyleFlags() { restyle_flags_ = 0u; }
  virtual void Trace(GCVisitor*) const;

  ChildNodeList* EnsureChildNodeList(ContainerNode& node);
  EmptyNodeList* EnsureEmptyChildNodeList(Node& node);

 protected:
  uint32_t restyle_flags_;
  uint32_t connected_frame_count_;
  uint32_t element_flags_;

 private:
  NodeListsNodeData& CreateNodeLists();

  std::shared_ptr<NodeListsNodeData> node_lists_;
  std::shared_ptr<NodeMutationObserverData> mutation_observer_data_;
  std::shared_ptr<FlatTreeNodeData> flat_tree_node_data_;
  // Keeps strong scroll timeline pointers linked to this node to ensure
  // the timelines are alive as long as the node is alive.
  // Member<std::unordered_set<Member<ScrollTimeline>>> scroll_timelines_;

  // An ordered set of DOM Parts for this Node, in order of construction. This
  // order is important, since `getParts()` returns a tree-ordered set of parts,
  // with parts on the same `Node` returned in `Part` construction order.
  // Member<PartsList> dom_parts_;

  Member<NodeList> node_list_;
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_NODE_RARE_DATA_H_
