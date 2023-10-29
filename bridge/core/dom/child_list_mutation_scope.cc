/*
 * Copyright (C) 2011 Google Inc. All rights reserved.
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

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "child_list_mutation_scope.h"

namespace webf {

// The accumulator map is used to make sure that there is only one mutation
// accumulator for a given node even if there are multiple
// ChildListMutationScopes on the stack. The map is always empty when there are
// no ChildListMutationScopes on the stack.
typedef std::unordered_map<Node*, std::shared_ptr<ChildListMutationAccumulator>> AccumulatorMap;

static AccumulatorMap& GetAccumulatorMap() {
  thread_local static AccumulatorMap map;
  return map;
}

ChildListMutationAccumulator::ChildListMutationAccumulator(Node* target,
                                                           std::shared_ptr<MutationObserverInterestGroup> observers)
    : target_(target), last_added_(nullptr), observers_(std::move(observers)), mutation_scopes_(0) {}

void ChildListMutationAccumulator::LeaveMutationScope() {
  assert(mutation_scopes_ > 0u);
  if (!--mutation_scopes_) {
    if (!IsEmpty())
      EnqueueMutationRecord();
    GetAccumulatorMap().erase(target_.Get());
  }
}

std::shared_ptr<ChildListMutationAccumulator> ChildListMutationAccumulator::GetOrCreate(Node& target) {
  std::shared_ptr<ChildListMutationAccumulator> accumulator;
  if (GetAccumulatorMap().count(&target) > 0) {
    accumulator = GetAccumulatorMap()[&target];
  } else {
    accumulator = std::make_shared<ChildListMutationAccumulator>(
        &target, MutationObserverInterestGroup::CreateForChildListMutation(target));
    GetAccumulatorMap()[&target] = accumulator;
  }
  return accumulator;
}

inline bool ChildListMutationAccumulator::IsAddedNodeInOrder(Node& child) {
  return IsEmpty() || (last_added_ == child.previousSibling() && next_sibling_ == child.nextSibling());
}

void ChildListMutationAccumulator::ChildAdded(Node& child) {
  assert(HasObservers());

  if (!IsAddedNodeInOrder(child))
    EnqueueMutationRecord();

  if (IsEmpty()) {
    previous_sibling_ = child.previousSibling();
    next_sibling_ = child.nextSibling();
  }

  last_added_ = &child;
  added_nodes_.emplace_back(&child);
}

inline bool ChildListMutationAccumulator::IsRemovedNodeInOrder(Node& child) {
  return IsEmpty() || next_sibling_ == &child;
}

void ChildListMutationAccumulator::WillRemoveChild(Node& child) {
  assert(HasObservers());

  if (!added_nodes_.empty() || !IsRemovedNodeInOrder(child))
    EnqueueMutationRecord();

  if (IsEmpty()) {
    previous_sibling_ = child.previousSibling();
    next_sibling_ = child.nextSibling();
    last_added_ = child.previousSibling();
  } else {
    next_sibling_ = child.nextSibling();
  }

  removed_nodes_.emplace_back(&child);
}

void ChildListMutationAccumulator::EnqueueMutationRecord() {
  assert(HasObservers());
  assert(!IsEmpty());

  std::vector<Member<Node>> added_nodes = added_nodes_;
  std::vector<Member<Node>> removed_nodes = removed_nodes_;
  MutationRecord* record = MutationRecord::CreateChildList(target_, std::move(added_nodes), std::move(removed_nodes),
                                                           previous_sibling_.Release(), next_sibling_.Release());
  observers_->EnqueueMutationRecord(record);
  last_added_ = nullptr;
  assert(IsEmpty());
}

bool ChildListMutationAccumulator::IsEmpty() {
  bool result = removed_nodes_.empty() && added_nodes_.empty();
  if (result) {
    assert(!previous_sibling_);
    assert(!next_sibling_);
    assert(!last_added_);
  }
  return result;
}

void ChildListMutationAccumulator::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(target_);

  for(auto& entry : removed_nodes_) {
    visitor->TraceMember(entry);
  }
  for(auto& entry : added_nodes_) {
    visitor->TraceMember(entry);
  }

  visitor->TraceMember(previous_sibling_);
  visitor->TraceMember(next_sibling_);
  visitor->TraceMember(last_added_);
  observers_->Trace(visitor);
}

}  // namespace webf