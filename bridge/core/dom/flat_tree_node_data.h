// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_DOM_FLAT_TREE_NODE_DATA_H_
#define WEBF_CORE_DOM_FLAT_TREE_NODE_DATA_H_

#include "bindings/qjs/cppgc/garbage_collected.h"
#include "core/dom/node.h"

namespace webf {

// class HTMLSlotElement;

class FlatTreeNodeData final {
 public:
  FlatTreeNodeData() {}
  FlatTreeNodeData(const FlatTreeNodeData&) = delete;
  FlatTreeNodeData& operator=(const FlatTreeNodeData&) = delete;
  void Clear() {
    // assigned_slot_ = nullptr;
    previous_in_assigned_nodes_ = std::shared_ptr<Node>(nullptr);
    next_in_assigned_nodes_ = std::shared_ptr<Node>(nullptr);
  }

  void Trace(GCVisitor*) const;
  /*
  #if DCHECK_IS_ON()
    bool IsCleared() const {
      return !assigned_slot_ && !previous_in_assigned_nodes_ &&
             !next_in_assigned_nodes_;
    }
  #endif
   */

 private:
  // void SetAssignedSlot(HTMLSlotElement* assigned_slot) {
  //   assigned_slot_ = assigned_slot;
  //      }

  void SetPreviousInAssignedNodes(const std::shared_ptr<Node>& previous) { previous_in_assigned_nodes_ = previous; }
  void SetNextInAssignedNodes(const std::shared_ptr<Node>& next) { next_in_assigned_nodes_ = next; }

  // void SetManuallyAssignedSlot(HTMLSlotElement* slot) {
  //   manually_assigned_slot_ = slot;
  // }

  // HTMLSlotElement* AssignedSlot() { return assigned_slot_.Get(); }

  Node* PreviousInAssignedNodes() {
    if (std::shared_ptr<Node> tempPtr = previous_in_assigned_nodes_.lock()) {
      return tempPtr.get();
    }
    return nullptr;  // Node has been destroyed
  }
  Node* NextInAssignedNodes() {
    if (std::shared_ptr<Node> tempPtr = next_in_assigned_nodes_.lock()) {
      return tempPtr.get();
    }
    return nullptr;  // Node has been destroyed
  }

  // HTMLSlotElement* ManuallyAssignedSlot() const {
  //   return manually_assigned_slot_.Get();
  // }

  friend class FlatTreeTraversal;
  // friend class HTMLSlotElement;
  // friend HTMLSlotElement* Node::AssignedSlot() const;
  // friend HTMLSlotElement* Node::AssignedSlotWithoutRecalc() const;
  friend void Node::ClearFlatTreeNodeDataIfHostChanged(const ContainerNode&);
  // friend void Node::SetManuallyAssignedSlot(HTMLSlotElement* slot);
  // friend HTMLSlotElement* Node::ManuallyAssignedSlot();
  friend Element* Node::FlatTreeParentForChildDirty() const;

  // WeakMember<HTMLSlotElement> assigned_slot_;
  std::weak_ptr<Node> previous_in_assigned_nodes_;
  std::weak_ptr<Node> next_in_assigned_nodes_;
  // Used by the imperative slot distribution API (not cleared by Clear()).
  // WeakMember<HTMLSlotElement> manually_assigned_slot_;
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_FLAT_TREE_NODE_DATA_H_
