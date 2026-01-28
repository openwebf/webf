/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CHECK_PSEUDO_HAS_ARGUMENT_CONTEXT_H_
#define WEBF_CORE_CSS_CHECK_PSEUDO_HAS_ARGUMENT_CONTEXT_H_

#include "core/css/css_selector.h"
#include "core/css/css_selector_list.h"
#include "core/dom/has_invalidation_flags.h"
#include "foundation/macros.h"
#include <vector>

namespace webf {

template<typename T>
using Vector = std::vector<T>;

// Stub implementation of CheckPseudoHasArgumentContext
// TODO: Implement actual context for :has() argument checking
class CheckPseudoHasArgumentContext {
  WEBF_STACK_ALLOCATED();
 public:
  explicit CheckPseudoHasArgumentContext(const CSSSelector* selector)
      : selector_(selector) {
    BuildContext();
  }
  
  CSSSelector::RelationType LeftmostRelation() const { return leftmost_relation_; }
  
  int AdjacentDistanceLimit() const { return adjacent_distance_limit_; }
  bool AdjacentDistanceFixed() const { return adjacent_distance_fixed_; }
  int DepthLimit() const { return depth_limit_; }
  bool DepthFixed() const { return depth_fixed_; }
  bool AllowSiblingsAffectedByHas() const { return allow_siblings_affected_by_has_; }
  unsigned GetSiblingsAffectedByHasFlags() const { return siblings_affected_by_has_flags_; }
  bool SiblingCombinatorAtRightmost() const { return sibling_combinator_at_rightmost_; }
  bool SiblingCombinatorBetweenChildOrDescendantCombinator() const {
    return sibling_combinator_between_child_or_descendant_;
  }
  Vector<unsigned> GetPseudoHasArgumentHashes() const { return pseudo_has_argument_hashes_; }
  
 private:
  static inline bool IsRelativeRelation(CSSSelector::RelationType relation) {
    return relation == CSSSelector::kRelativeDescendant || relation == CSSSelector::kRelativeChild ||
           relation == CSSSelector::kRelativeDirectAdjacent || relation == CSSSelector::kRelativeIndirectAdjacent;
  }

  static inline bool IsAdjacentRelation(CSSSelector::RelationType relation) {
    return relation == CSSSelector::kDirectAdjacent || relation == CSSSelector::kIndirectAdjacent ||
           relation == CSSSelector::kRelativeDirectAdjacent || relation == CSSSelector::kRelativeIndirectAdjacent;
  }

  static inline bool IsIndirectAdjacent(CSSSelector::RelationType relation) {
    return relation == CSSSelector::kIndirectAdjacent || relation == CSSSelector::kRelativeIndirectAdjacent;
  }

  static inline bool IsRelativeAdjacent(CSSSelector::RelationType relation) {
    return relation == CSSSelector::kRelativeDirectAdjacent || relation == CSSSelector::kRelativeIndirectAdjacent;
  }

  static inline bool IsDescendantRelation(CSSSelector::RelationType relation) {
    return relation == CSSSelector::kDescendant || relation == CSSSelector::kRelativeDescendant;
  }

  static inline bool IsChildRelation(CSSSelector::RelationType relation) {
    return relation == CSSSelector::kChild || relation == CSSSelector::kRelativeChild;
  }

  static inline bool IsChildOrDescendantRelation(CSSSelector::RelationType relation) {
    return IsDescendantRelation(relation) || IsChildRelation(relation);
  }

  void BuildContext() {
    leftmost_relation_ = CSSSelector::kRelativeDescendant;
    adjacent_distance_limit_ = 0;
    adjacent_distance_fixed_ = true;
    depth_limit_ = 0;
    depth_fixed_ = true;
    allow_siblings_affected_by_has_ = false;
    siblings_affected_by_has_flags_ = kNoSiblingsAffectedByHasFlags;
    sibling_combinator_at_rightmost_ = false;
    sibling_combinator_between_child_or_descendant_ = false;
    pseudo_has_argument_hashes_.clear();

    if (!selector_) {
      return;
    }

    // Collect relations from rightmost to leftmost (towards the relative anchor).
    Vector<CSSSelector::RelationType> relations;
    bool found_relative_relation = false;
    for (const CSSSelector* current = selector_; current; current = current->NextSimpleSelector()) {
      AddHashesForSimpleSelector(*current);

      CSSSelector::RelationType relation = current->Relation();
      if (relation == CSSSelector::kSubSelector || relation == CSSSelector::kScopeActivation) {
        continue;
      }
      relations.push_back(relation);
      if (IsRelativeRelation(relation)) {
        found_relative_relation = true;
        break;
      }
    }

    if (relations.empty()) {
      return;
    }

    leftmost_relation_ = relations.back();
    if (!found_relative_relation) {
      // Be defensive: if the parser didn't convert the leftmost combinator
      // to a relative relation, map it here so :has() matching can proceed.
      leftmost_relation_ = ConvertRelationToRelative(leftmost_relation_);
    }
    sibling_combinator_at_rightmost_ = IsAdjacentRelation(relations.front());

    // Determine if an adjacent combinator appears between child/descendant combinators.
    bool seen_child_or_descendant_to_right = false;
    for (const auto& relation : relations) {
      if (IsChildOrDescendantRelation(relation)) {
        seen_child_or_descendant_to_right = true;
        continue;
      }
      if (IsAdjacentRelation(relation) && seen_child_or_descendant_to_right) {
        sibling_combinator_between_child_or_descendant_ = true;
      }
    }

    // Compute adjacency and depth constraints from leftmost (anchor side) to rightmost.
    bool in_sibling_phase = IsRelativeAdjacent(leftmost_relation_);
    for (auto it = relations.rbegin(); it != relations.rend(); ++it) {
      CSSSelector::RelationType relation = *it;
      if (IsChildOrDescendantRelation(relation)) {
        depth_limit_++;
        if (IsDescendantRelation(relation)) {
          depth_fixed_ = false;
        }
        in_sibling_phase = false;
        continue;
      }

      if (IsAdjacentRelation(relation) && in_sibling_phase) {
        if (IsIndirectAdjacent(relation)) {
          // Indirect adjacency is unbounded.
          adjacent_distance_fixed_ = false;
          adjacent_distance_limit_ = 0;
        } else if (adjacent_distance_fixed_) {
          adjacent_distance_limit_++;
        }
      }
    }

    allow_siblings_affected_by_has_ = IsRelativeAdjacent(leftmost_relation_);
    if (allow_siblings_affected_by_has_) {
      siblings_affected_by_has_flags_ =
          depth_limit_ > 0 ? kFlagForSiblingDescendantRelationship : kFlagForSiblingRelationship;
    }
  }

  void AddHash(unsigned hash) {
    if (hash) {
      pseudo_has_argument_hashes_.push_back(hash);
    }
  }

  void AddHashesForSelectorList(const CSSSelector* selector_list_first) {
    if (!selector_list_first) {
      return;
    }
    for (const CSSSelector* complex = selector_list_first; complex; complex = CSSSelectorList::Next(*complex)) {
      for (const CSSSelector* simple = complex; simple; simple = simple->NextSimpleSelector()) {
        AddHashesForSimpleSelector(*simple);
      }
    }
  }

  void AddHashesForSimpleSelector(const CSSSelector& selector) {
    switch (selector.Match()) {
      case CSSSelector::kTag:
        if (selector.TagQName().LocalName() != CSSSelector::UniversalSelectorAtom()) {
          AddHash(selector.TagQName().LocalName().Hash() * kTagSalt);
        }
        break;
      case CSSSelector::kId:
        AddHash(selector.Value().Hash() * kIdSalt);
        break;
      case CSSSelector::kClass:
        AddHash(selector.Value().Hash() * kClassSalt);
        break;
      case CSSSelector::kAttributeExact:
      case CSSSelector::kAttributeSet:
      case CSSSelector::kAttributeList:
      case CSSSelector::kAttributeHyphen:
      case CSSSelector::kAttributeContain:
      case CSSSelector::kAttributeBegin:
      case CSSSelector::kAttributeEnd:
        AddHash(selector.Attribute().LocalName().Hash() * kAttributeSalt);
        break;
      case CSSSelector::kPseudoClass: {
        CSSSelector::PseudoType pseudo_type = selector.GetPseudoType();
        switch (pseudo_type) {
          case CSSSelector::kPseudoNot:
          case CSSSelector::kPseudoIs:
          case CSSSelector::kPseudoWhere:
          case CSSSelector::kPseudoParent:
            AddHashesForSelectorList(selector.SelectorListOrParent());
            break;
          case CSSSelector::kPseudoVisited:
          case CSSSelector::kPseudoRelativeAnchor:
            break;
          default:
            AddHash(static_cast<unsigned>(pseudo_type) * kPseudoSalt);
            if (const CSSSelectorList* list = selector.SelectorList()) {
              AddHashesForSelectorList(list->First());
            }
            break;
        }
        break;
      }
      default:
        break;
    }
  }

  static constexpr unsigned kClassSalt = 13;
  static constexpr unsigned kIdSalt = 29;
  static constexpr unsigned kTagSalt = 7;
  static constexpr unsigned kAttributeSalt = 19;
  static constexpr unsigned kPseudoSalt = 23;

  const CSSSelector* selector_;

  CSSSelector::RelationType leftmost_relation_;
  int adjacent_distance_limit_;
  bool adjacent_distance_fixed_;
  int depth_limit_;
  bool depth_fixed_;
  bool allow_siblings_affected_by_has_;
  unsigned siblings_affected_by_has_flags_;
  bool sibling_combinator_at_rightmost_;
  bool sibling_combinator_between_child_or_descendant_;
  Vector<unsigned> pseudo_has_argument_hashes_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CHECK_PSEUDO_HAS_ARGUMENT_CONTEXT_H_
