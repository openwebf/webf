/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_CORE_DOM_CHILD_LIST_MUTATION_SCOPE_H_
#define WEBF_CORE_DOM_CHILD_LIST_MUTATION_SCOPE_H_

#include "foundation/macros.h"
#include "mutation_observer_interest_group.h"
#include "document.h"
#include "static_node_list.h"

namespace webf {

// ChildListMutationAccumulator is not meant to be used directly;
// ChildListMutationScope is the public interface.
//
// One ChildListMutationAccumulator for a given Node is shared between all the
// active ChildListMutationScopes for that Node. Once the last
// ChildListMutationScope is destructed the accumulator enqueues a mutation
// record for the recorded mutations and the accumulator can be garbage
// collected.
class ChildListMutationAccumulator final {
 public:
  static std::shared_ptr<ChildListMutationAccumulator> GetOrCreate(Node&);

  ChildListMutationAccumulator(Node*, const std::shared_ptr<MutationObserverInterestGroup>& observers);
  ~ChildListMutationAccumulator();

  void ChildAdded(Node&);
  void WillRemoveChild(Node&);

  bool HasObservers() const { return observers_ != nullptr; }

  // Register and unregister mutation scopes that are using this mutation
  // accumulator.
  void EnterMutationScope() { mutation_scopes_++; }
  void LeaveMutationScope();

  void Trace(GCVisitor*) const;

 private:
  void EnqueueMutationRecord();
  bool IsEmpty();
  bool IsAddedNodeInOrder(Node&);
  bool IsRemovedNodeInOrder(Node&);

  std::vector<Member<Node>> removed_nodes_;
  std::vector<Member<Node>> added_nodes_;
  Member<Node> target_;
  Member<Node> previous_sibling_;
  Member<Node> next_sibling_;
  Member<Node> last_added_;

  std::shared_ptr<MutationObserverInterestGroup> observers_;

  unsigned mutation_scopes_;
};

class ChildListMutationScope final {
  WEBF_STACK_ALLOCATED();

 public:
  explicit ChildListMutationScope(Node& target) {
    if (!target.IsDocumentNode() && target.ownerDocument()->HasMutationObserversOfType(
            kMutationTypeChildList)) {
      accumulator_ = ChildListMutationAccumulator::GetOrCreate(target);
      // Register another user of the accumulator.
      accumulator_->EnterMutationScope();
    }
  }
  ChildListMutationScope(const ChildListMutationScope&) = delete;
  ChildListMutationScope& operator=(const ChildListMutationScope&) = delete;

  ~ChildListMutationScope() {
    if (accumulator_) {
      // Unregister a user of the accumulator. If this is the last user
      // the accumulator will enqueue a mutation record for the mutations.
      accumulator_->LeaveMutationScope();
    }
  }

  void ChildAdded(Node& child) {
//    if (accumulator_ && accumulator_->HasObservers())
//      accumulator_->ChildAdded(child);
  }

  void WillRemoveChild(Node& child) {
//    if (accumulator_ && accumulator_->HasObservers())
//      accumulator_->WillRemoveChild(child);
  }

 private:
  std::shared_ptr<ChildListMutationAccumulator> accumulator_ = nullptr;
};


}

#endif  // WEBF_CORE_DOM_CHILD_LIST_MUTATION_SCOPE_H_
