/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CHECK_PSEUDO_HAS_TRAVERSAL_ITERATOR_H_
#define WEBF_CORE_CSS_CHECK_PSEUDO_HAS_TRAVERSAL_ITERATOR_H_

#include "core/dom/element.h"
#include "core/dom/element_traversal.h"
#include "core/css/check_pseudo_has_argument_context.h"
#include "foundation/macros.h"
#include <algorithm>
#include <vector>

namespace webf {

template<typename T>
using Vector = std::vector<T>;

// Stub implementation of CheckPseudoHasArgumentTraversalIterator
// TODO: Implement actual traversal for :has() checking
class CheckPseudoHasArgumentTraversalIterator {
  WEBF_STACK_ALLOCATED();
 public:
  CheckPseudoHasArgumentTraversalIterator(Element& element, 
                                          const CheckPseudoHasArgumentContext& context)
      : context_(context) {
    Initialize(element);
  }
  
  bool AtEnd() const { return current_ == nullptr; }
  void operator++() { Advance(); }
  Element* CurrentElement() const { return current_; }
  int CurrentDepth() const { return depth_; }
  
 private:
  struct TraversalEntry {
    Element* element;
    int depth;
  };

  void Initialize(Element& anchor) {
    stack_.clear();

    const CSSSelector::RelationType leftmost_relation = context_.LeftmostRelation();
    if (leftmost_relation == CSSSelector::kRelativeDirectAdjacent ||
        leftmost_relation == CSSSelector::kRelativeIndirectAdjacent) {
      int distance = 0;
      for (Element* sibling = ElementTraversal::NextSibling(anchor); sibling;
           sibling = ElementTraversal::NextSibling(*sibling)) {
        distance++;
        if (context_.AdjacentDistanceFixed() && context_.AdjacentDistanceLimit() > 0 &&
            distance > context_.AdjacentDistanceLimit()) {
          break;
        }
        stack_.push_back({sibling, 0});
        if (context_.AdjacentDistanceFixed() && context_.AdjacentDistanceLimit() > 0 &&
            distance == context_.AdjacentDistanceLimit()) {
          break;
        }
      }
    } else {
      for (Element* child = ElementTraversal::FirstChild(anchor); child;
           child = ElementTraversal::NextSibling(*child)) {
        stack_.push_back({child, 1});
      }
    }

    std::reverse(stack_.begin(), stack_.end());
    Advance();
  }

  bool ShouldDescendFrom(int depth) const {
    if (context_.DepthLimit() == 0) {
      return false;
    }
    if (context_.DepthFixed() && depth >= context_.DepthLimit()) {
      return false;
    }
    return true;
  }

  void PushChildren(Element& element, int depth) {
    if (!ShouldDescendFrom(depth)) {
      return;
    }
    for (Element* child = ElementTraversal::LastChild(element); child;
         child = ElementTraversal::PreviousSibling(*child)) {
      stack_.push_back({child, depth + 1});
    }
  }

  void Advance() {
    if (stack_.empty()) {
      current_ = nullptr;
      return;
    }
    TraversalEntry entry = stack_.back();
    stack_.pop_back();
    current_ = entry.element;
    depth_ = entry.depth;
    if (current_) {
      PushChildren(*current_, depth_);
    }
  }

  const CheckPseudoHasArgumentContext& context_;
  Vector<TraversalEntry> stack_;
  Element* current_{nullptr};
  int depth_{0};
};

// Stub implementation of CheckPseudoHasFastRejectFilter
// TODO: Implement actual fast reject filter for :has() optimization
class CheckPseudoHasFastRejectFilter {
  WEBF_STACK_ALLOCATED();
 public:
  CheckPseudoHasFastRejectFilter() {}
  bool FastReject(const Element* element) const { return false; }
  bool FastReject(const Vector<unsigned>& hashes) const { return false; }
  void AddSelector(const CSSSelector* selector) {}
  void AddElementIdentifierHashes(const Element& element) {}
  bool BloomFilterAllocated() const { return false; }
  void AllocateBloomFilter() {}
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CHECK_PSEUDO_HAS_TRAVERSAL_ITERATOR_H_
