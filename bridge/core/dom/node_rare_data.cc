/*
 * Copyright (C) 2012 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/dom/node_rare_data.h"

//#include "third_party/blink/renderer/core/animation/scroll_timeline.h"
#include "core/dom/container_node.h"
#include "core/dom/element.h"
#include "core/dom/flat_tree_node_data.h"
#include "core/dom/mutation_observer_registration.h"
#include "core/dom/node_lists_node_data.h"
//#include "core/dom/part.h"
//#include "third_party/blink/renderer/core/layout/layout_object.h"
#include "core/page.h"
#include "bindings/qjs/cppgc/garbage_collected.h"

namespace webf {

void NodeMutationObserverData::Trace(GCVisitor* visitor) const {
  //visitor->Trace(registry_);
  //visitor->Trace(transient_registry_);
}

void NodeMutationObserverData::AddTransientRegistration(
    MutationObserverRegistration* registration) {
  transient_registry_.insert(registration);
}

void NodeMutationObserverData::RemoveTransientRegistration(
    MutationObserverRegistration* registration) {
  assert(transient_registry_.find(registration) != transient_registry_.end());
  transient_registry_.erase(registration);
}

void NodeMutationObserverData::AddRegistration(
    MutationObserverRegistration* registration) {
  registry_.push_back(registration);
}

void NodeMutationObserverData::RemoveRegistration(
    MutationObserverRegistration* registration) {
  assert(registry_.contains(registration));
  registry_.erase_at(registry_.find(registration));
}

/*
// TODO(guopengfei)：先注释
void NodeRareData::RegisterScrollTimeline(ScrollTimeline* timeline) {
  if (!scroll_timelines_) {
    scroll_timelines_ =
        MakeGarbageCollected<HeapHashSet<Member<ScrollTimeline>>>();
  }
  scroll_timelines_->insert(timeline);
}
void NodeRareData::UnregisterScrollTimeline(ScrollTimeline* timeline) {
  scroll_timelines_->erase(timeline);
}

void NodeRareData::InvalidateAssociatedAnimationEffects() {
  if (!scroll_timelines_)
    return;

  for (ScrollTimeline* scroll_timeline : *scroll_timelines_) {
    scroll_timeline->InvalidateEffectTargetStyle();
  }
}

void NodeRareData::AddDOMPart(Part& part) {
  assert(!RuntimeEnabledFeatures::DOMPartsAPIMinimalEnabled());
  if (!dom_parts_) {
    dom_parts_ = MakeGarbageCollected<PartsList>();
  }
  assert(!base::Contains(*dom_parts_, &part));
  dom_parts_->push_back(&part);
}

void NodeRareData::RemoveDOMPart(Part& part) {
  assert(!RuntimeEnabledFeatures::DOMPartsAPIMinimalEnabled());
  assert(dom_parts_ && base::Contains(*dom_parts_, &part));
  // Common case is that one node has one part:
  if (dom_parts_->size() == 1) {
    DCHECK_EQ(dom_parts_->front(), &part);
    dom_parts_->clear();
  } else {
    // This is the very slow case - multiple parts for a single node.
    PartsList new_list;
    for (auto p : *dom_parts_) {
      if (p != &part) {
        new_list.push_back(p);
      }
    }
    dom_parts_->Swap(new_list);
  }
  if (dom_parts_->empty()) {
    dom_parts_ = nullptr;
  }
}

PartsList* NodeRareData::GetDOMParts() const {
  assert(!dom_parts_ || !RuntimeEnabledFeatures::DOMPartsAPIMinimalEnabled());
  return dom_parts_.Get();
}
*/
void NodeRareData::Trace(GCVisitor* visitor) const {
  //visitor->TraceMember(mutation_observer_data_);
  //visitor->TraceMember(flat_tree_node_data_);
  //visitor->TraceMember(node_lists_);
  //visitor->TraceMember(scroll_timelines_);
  //visitor->TraceMember(dom_parts_);
}

void NodeRareData::IncrementConnectedSubframeCount() {
  assert((connected_frame_count_ + 1) <= WebFPage::MaxNumberOfFrames());
  ++connected_frame_count_;
}

NodeListsNodeData& NodeRareData::CreateNodeLists() {
  node_lists_ = std::make_shared<NodeListsNodeData>();
  return *node_lists_;
}

FlatTreeNodeData& NodeRareData::EnsureFlatTreeNodeData() {
  if (!flat_tree_node_data_)
    flat_tree_node_data_ = std::make_shared<FlatTreeNodeData>();
  return *flat_tree_node_data_;
}

ChildNodeList* NodeRareData::EnsureChildNodeList(ContainerNode& node) {
  if (node_list_)
    return To<ChildNodeList>(node_list_.Get());
  auto* list = MakeGarbageCollected<ChildNodeList>(&node);
  node_list_ = list;
  return list;
}

EmptyNodeList* NodeRareData::EnsureEmptyChildNodeList(Node& node) {
  if (node_list_)
    return To<EmptyNodeList>(node_list_.Get());
  auto* list = MakeGarbageCollected<EmptyNodeList>(&node);
  node_list_ = list;
  return list;
}

// TODO(guopengfei)：
static_assert(static_cast<int>(NodeRareData::kNumberOfElementFlags) ==
                  static_cast<int>(ElementFlags::kNumberOfElementFlags),
              "kNumberOfElementFlags must match.");
static_assert(
    static_cast<int>(NodeRareData::kNumberOfDynamicRestyleFlags) ==
        static_cast<int>(DynamicRestyleFlags::kNumberOfDynamicRestyleFlags),
    "kNumberOfDynamicRestyleFlags must match.");

}  // namespace webf
