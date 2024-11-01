// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_INVALIDATION_STYLE_INVALIDATOR_H_
#define WEBF_CORE_CSS_INVALIDATION_STYLE_INVALIDATOR_H_

#include "core/css/invalidation/invalidation_flags.h"
#include "core/css/invalidation/pending_invalidations.h"

namespace webf {

class ContainerNode;
class Element;
class HTMLSlotElement;
class InvalidationSet;

// Applies deferred style invalidation for DOM subtrees.
//
// See https://goo.gl/3ane6s and https://goo.gl/z0Z9gn
// for more detailed overviews of style invalidation.
class StyleInvalidator {
  WEBF_STACK_ALLOCATED();

 public:
  StyleInvalidator(PendingInvalidationMap&);

  ~StyleInvalidator();
  void Invalidate(Document& document, Element* invalidation_root);

 private:
  class SiblingData;

  void PushInvalidationSetsForContainerNode(ContainerNode&, SiblingData&);
  void PushInvalidationSet(const InvalidationSet&);
  bool WholeSubtreeInvalid() const {
    return invalidation_flags_.WholeSubtreeInvalid();
  }

  void Invalidate(Element&, SiblingData&);
  void InvalidateShadowRootChildren(Element&);
  void InvalidateChildren(Element&);
  void InvalidateSlotDistributedElements(HTMLSlotElement&) const;
  // Returns true if the element should be invalidated according to the
  // current state. This can also update the current state.
  bool CheckInvalidationSetsAgainstElement(Element&, SiblingData&);

  bool MatchesCurrentInvalidationSets(Element&) const;
  bool MatchesCurrentInvalidationSetsAsSlotted(Element&) const;
  bool MatchesCurrentInvalidationSetsAsParts(Element&) const;

  bool HasInvalidationSets() const {
    return !WholeSubtreeInvalid() &&
           (invalidation_sets_.size() || pending_nth_sets_.size());
  }

  void SetWholeSubtreeInvalid() {
    invalidation_flags_.SetWholeSubtreeInvalid(true);
  }

  bool TreeBoundaryCrossing() const {
    return invalidation_flags_.TreeBoundaryCrossing();
  }
  bool InsertionPointCrossing() const {
    return invalidation_flags_.InsertionPointCrossing();
  }
  bool InvalidatesSlotted() const {
    return invalidation_flags_.InvalidatesSlotted();
  }
  bool InvalidatesParts() const {
    return invalidation_flags_.InvalidatesParts();
  }

  void AddPendingNthSiblingInvalidationSet(
      const NthSiblingInvalidationSet& nth_set) {
    pending_nth_sets_.push_back(&nth_set);
  }
  void PushNthSiblingInvalidationSets(SiblingData& sibling_data) {
    for (const auto* invalidation_set : pending_nth_sets_) {
      sibling_data.PushInvalidationSet(*invalidation_set);
    }
    ClearPendingNthSiblingInvalidationSets();
  }
  void ClearPendingNthSiblingInvalidationSets() { pending_nth_sets_.resize(0); }

  PendingInvalidationMap& pending_invalidation_map_;
  using DescendantInvalidationSets = std::vector<const InvalidationSet*>;
  DescendantInvalidationSets invalidation_sets_;
  // NthSiblingInvalidationSets are added here from the parent node on which it
  // is scheduled, and pushed to SiblingData before invalidating the children.
  // See the NthSiblingInvalidationSet documentation.
  std::vector<const NthSiblingInvalidationSet*> pending_nth_sets_;
  InvalidationFlags invalidation_flags_;

  class SiblingData {
    WEBF_STACK_ALLOCATED();

   public:
    SiblingData() : element_index_(0) {
      invalidation_entries_.reserve(16);
    }

    void PushInvalidationSet(const SiblingInvalidationSet&);
    bool MatchCurrentInvalidationSets(Element&, StyleInvalidator&);

    bool IsEmpty() const { return invalidation_entries_.empty(); }
    void Advance() { element_index_++; }

   private:
    struct Entry {
      WEBF_DISALLOW_NEW();
      Entry(const SiblingInvalidationSet* invalidation_set,
            unsigned invalidation_limit)
          : invalidation_set_(invalidation_set),
            invalidation_limit_(invalidation_limit) {}

      const SiblingInvalidationSet* invalidation_set_;
      unsigned invalidation_limit_;
    };

    // TODO(guopengfei)：替换使用std::vector
    //Vector<Entry, 16> invalidation_entries_;
    std::vector<Entry> invalidation_entries_;
    unsigned element_index_;
  };

  // Saves the state of a StyleInvalidator and automatically restores it when
  // this object is destroyed.
  class RecursionCheckpoint {
    WEBF_STACK_ALLOCATED();

   public:
    RecursionCheckpoint(StyleInvalidator* invalidator)
        : prev_invalidation_sets_size_(invalidator->invalidation_sets_.size()),
          prev_invalidation_flags_(invalidator->invalidation_flags_),
          invalidator_(invalidator) {}
    ~RecursionCheckpoint() {
      // TODO(guopengfei)：
      //invalidator_->invalidation_sets_.Shrink(prev_invalidation_sets_size_);
      invalidator_->invalidation_sets_.clear();
      invalidator_->invalidation_flags_ = prev_invalidation_flags_;
    }

   private:
    int prev_invalidation_sets_size_;
    InvalidationFlags prev_invalidation_flags_;
    StyleInvalidator* invalidator_;
  };
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_INVALIDATION_STYLE_INVALIDATOR_H_
