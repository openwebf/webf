/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "selector_filter.h"

#include "core/css/css_selector.h"
#include "core/css/css_selector_list.h"
#include "core/dom/element.h"
#include "foundation/string/atomic_string.h"

namespace webf {

SelectorFilter::SelectorFilter() { Clear(); }

SelectorFilter::~SelectorFilter() = default;

void SelectorFilter::PushElement(const Element& element) {
  PushMark();

  AddIdentifier(element.LocalNameForSelectorMatching(), kTagSalt);
  if (element.HasID()) {
    AddIdentifier(element.IdForStyleResolution(), kIdSalt);
  }
  if (element.HasClass()) {
    for (const auto& class_name : element.ClassNames()) {
      AddIdentifier(class_name, kClassSalt);
    }
  }
  if (element.hasAttributes()) {
    for (const auto& attribute : element.Attributes()) {
      AtomicString local_name = attribute.GetName().LocalName();
      if (!local_name.IsLowerASCII()) {
        local_name = local_name.LowerASCII();
      }
      if (IsExcludedAttribute(local_name)) {
        continue;
      }
      AddIdentifier(local_name, kAttributeSalt);
    }

    // Some attributes (notably those set via DOM APIs like setAttribute) are
    // stored only in the legacy ElementAttributes map and are not reflected in
    // ElementData::Attributes(). Selector matching must still be able to
    // prefilter such attributes without consulting widget binding properties.
    if (ElementAttributes* attrs = element.GetElementAttributesIfExists()) {
      if (attrs->hasAttributes()) {
        for (auto it = attrs->begin(); it != attrs->end(); ++it) {
          AtomicString local_name = it->first;
          if (!local_name.IsLowerASCII()) {
            local_name = local_name.LowerASCII();
          }
          if (IsExcludedAttribute(local_name)) {
            continue;
          }
          AddIdentifier(local_name, kAttributeSalt);
        }
      }
    }
  }
}

void SelectorFilter::PopElement(const Element& element) {
  (void)element;
  PopToLastMark();
}

void SelectorFilter::CollectIdentifierHashes(const CSSSelector& selector, std::vector<uint32_t>& hashes) {
  hashes.clear();

  auto is_excluded_attribute = [](const AtomicString& local_name) -> bool {
    return local_name == g_class_atom || local_name == g_id_atom || local_name == g_style_atom;
  };

  auto canonical_ascii_name = [](const AtomicString& name) -> AtomicString {
    if (name.IsNull() || name.empty()) {
      return name;
    }
    return name.IsLowerASCII() ? name : name.LowerASCII();
  };

  auto collect_descendant_selector_identifier_hashes =
      [&](auto&& self, const CSSSelector& current, std::vector<uint32_t>& out) -> void {
    switch (current.Match()) {
      case CSSSelector::kId:
        if (!current.Value().empty()) {
          out.push_back(current.Value().Hash() * kIdSalt);
        }
        break;
      case CSSSelector::kClass:
        if (!current.Value().empty()) {
          out.push_back(current.Value().Hash() * kClassSalt);
        }
        break;
      case CSSSelector::kTag: {
        AtomicString local = canonical_ascii_name(current.TagQName().LocalName());
        if (!local.IsNull() && !local.empty()) {
          out.push_back(local.Hash() * kTagSalt);
        }
        break;
      }
      case CSSSelector::kAttributeExact:
      case CSSSelector::kAttributeSet:
      case CSSSelector::kAttributeList:
      case CSSSelector::kAttributeContain:
      case CSSSelector::kAttributeBegin:
      case CSSSelector::kAttributeEnd:
      case CSSSelector::kAttributeHyphen: {
        AtomicString local = canonical_ascii_name(current.Attribute().LocalName());
        if (local.IsNull() || local.empty() || is_excluded_attribute(local)) {
          break;
        }
        out.push_back(local.Hash() * kAttributeSalt);
        break;
      }
      case CSSSelector::kPseudoClass: {
        switch (current.GetPseudoType()) {
          case CSSSelector::kPseudoIs:
          case CSSSelector::kPseudoWhere:
          case CSSSelector::kPseudoParent: {
            const CSSSelector* selector_list = current.SelectorListOrParent();
            if (selector_list && CSSSelectorList::Next(*selector_list) == nullptr) {
              // Treat a one-element :is()/:where()/& as if it was written out.
              // Use a descendant relation so we collect identifiers from its compound.
              auto collect_descendant_compound_selector_identifier_hashes =
                  [&](auto&& collect_self, const CSSSelector* sel, CSSSelector::RelationType relation,
                      std::vector<uint32_t>& hashes_out) -> void {
                if (!sel) {
                  return;
                }
                bool skip_over_subselectors = true;
                for (const CSSSelector* cur = sel; cur; cur = cur->NextSimpleSelector()) {
                  switch (relation) {
                    case CSSSelector::kSubSelector:
                      if (!skip_over_subselectors) {
                        self(self, *cur, hashes_out);
                      }
                      break;
                    case CSSSelector::kDirectAdjacent:
                    case CSSSelector::kIndirectAdjacent:
                    case CSSSelector::kRelativeDirectAdjacent:
                    case CSSSelector::kRelativeIndirectAdjacent:
                      skip_over_subselectors = true;
                      break;
                    case CSSSelector::kDescendant:
                    case CSSSelector::kChild:
                    case CSSSelector::kRelativeDescendant:
                    case CSSSelector::kRelativeChild:
                    case CSSSelector::kUAShadow:
                    case CSSSelector::kShadowSlot:
                    case CSSSelector::kShadowPart:
                    case CSSSelector::kScopeActivation:
                      skip_over_subselectors = false;
                      self(self, *cur, hashes_out);
                      break;
                  }
                  relation = cur->Relation();
                }
              };

              collect_descendant_compound_selector_identifier_hashes(
                  collect_descendant_compound_selector_identifier_hashes, selector_list, CSSSelector::kDescendant, out);
            }
            break;
          }
          default:
            break;
        }
        break;
      }
      default:
        break;
    }
  };

  auto collect_descendant_compound_selector_identifier_hashes =
      [&](auto&& self, const CSSSelector* sel, CSSSelector::RelationType relation, std::vector<uint32_t>& out) -> void {
    if (!sel) {
      return;
    }
    // Skip the rightmost compound. It is handled by rule hashes/bucketing.
    bool skip_over_subselectors = true;
    for (const CSSSelector* current = sel; current; current = current->NextSimpleSelector()) {
      switch (relation) {
        case CSSSelector::kSubSelector:
          if (!skip_over_subselectors) {
            collect_descendant_selector_identifier_hashes(collect_descendant_selector_identifier_hashes, *current, out);
          }
          break;
        case CSSSelector::kDirectAdjacent:
        case CSSSelector::kIndirectAdjacent:
        case CSSSelector::kRelativeDirectAdjacent:
        case CSSSelector::kRelativeIndirectAdjacent:
          // Adjacent combinators: the current compound describes siblings, so
          // don't collect identifier requirements from it.
          skip_over_subselectors = true;
          break;
        case CSSSelector::kDescendant:
        case CSSSelector::kChild:
        case CSSSelector::kRelativeDescendant:
        case CSSSelector::kRelativeChild:
        case CSSSelector::kUAShadow:
        case CSSSelector::kShadowSlot:
        case CSSSelector::kShadowPart:
        case CSSSelector::kScopeActivation:
          skip_over_subselectors = false;
          collect_descendant_selector_identifier_hashes(collect_descendant_selector_identifier_hashes, *current, out);
          break;
      }
      relation = current->Relation();
    }
  };

  collect_descendant_compound_selector_identifier_hashes(
      collect_descendant_compound_selector_identifier_hashes, selector.NextSimpleSelector(), selector.Relation(), hashes);
}

bool SelectorFilter::FastRejectSelector(const std::vector<uint32_t>& identifier_hashes) const {
  for (uint32_t hash : identifier_hashes) {
    if (!MayContainHash(hash)) {
      return true;
    }
  }
  return false;
}

bool SelectorFilter::MightMatch(const CSSSelector& selector) const {
  // Fast-path for Tailwind/utility CSS: selectors are often wrapped in a
  // single-element :where(...) or :is(...). Treat those as transparent so we
  // can still collect descendant identifiers and reject early.
  if (selector.Match() == CSSSelector::kPseudoClass) {
    switch (selector.GetPseudoType()) {
      case CSSSelector::kPseudoIs:
      case CSSSelector::kPseudoWhere:
      case CSSSelector::kPseudoParent: {
        const CSSSelector* selector_list = selector.SelectorListOrParent();
        if (selector_list && CSSSelectorList::Next(*selector_list) == nullptr) {
          return MightMatch(*selector_list);
        }
        break;
      }
      default:
        break;
    }
  }

  return !FastRejectDescendantSelectors(selector);
}

void SelectorFilter::Clear() {
  ancestor_filter_.reset();
  set_bits_.clear();
  marks_.clear();
  // Base mark so PopElement is always safe.
  marks_.push_back(0);
}

void SelectorFilter::PushMark() {
  marks_.push_back(set_bits_.size());
}

void SelectorFilter::PopToLastMark() {
  if (marks_.size() <= 1) {
    return;
  }
  size_t mark = marks_.back();
  marks_.pop_back();
  while (set_bits_.size() > mark) {
    uint16_t bit = set_bits_.back();
    set_bits_.pop_back();
    ancestor_filter_.reset(bit);
  }
}

void SelectorFilter::AddHash(unsigned hash) {
  auto add_bit = [&](unsigned bit) {
    bit &= kFilterMask;
    if (!ancestor_filter_.test(bit)) {
      ancestor_filter_.set(bit);
      set_bits_.push_back(static_cast<uint16_t>(bit));
    }
  };
  add_bit(hash);
  add_bit(hash >> 16);
}

bool SelectorFilter::MayContainHash(unsigned hash) const {
  unsigned first = hash & kFilterMask;
  unsigned second = (hash >> 16) & kFilterMask;
  return ancestor_filter_.test(first) && ancestor_filter_.test(second);
}

void SelectorFilter::AddIdentifier(const AtomicString& identifier, unsigned salt) {
  if (identifier.IsNull() || identifier.empty()) {
    return;
  }
  AddHash(identifier.Hash() * salt);
}

bool SelectorFilter::MayContainIdentifier(const AtomicString& identifier, unsigned salt) const {
  if (identifier.IsNull() || identifier.empty()) {
    return true;
  }
  return MayContainHash(identifier.Hash() * salt);
}

bool SelectorFilter::IsExcludedAttribute(const AtomicString& local_name) {
  return local_name == g_class_atom || local_name == g_id_atom || local_name == g_style_atom;
}

bool SelectorFilter::FastRejectDescendantSelectors(const CSSSelector& selector) const {
  // Collect descendant selector identifiers (skip the rightmost compound).
  return FastRejectDescendantCompoundSelectorIdentifierHashes(selector.NextSimpleSelector(), selector.Relation());
}

bool SelectorFilter::FastRejectDescendantCompoundSelectorIdentifierHashes(const CSSSelector* selector,
                                                                         CSSSelector::RelationType relation) const {
  if (!selector) {
    return false;
  }
  // Skip the rightmost compound. It is handled by rule hashes/bucketing.
  bool skip_over_subselectors = true;
  for (const CSSSelector* current = selector; current; current = current->NextSimpleSelector()) {
    switch (relation) {
      case CSSSelector::kSubSelector:
        if (!skip_over_subselectors) {
          if (FastRejectForSimpleSelector(*current)) {
            return true;
          }
        }
        break;
      case CSSSelector::kDirectAdjacent:
      case CSSSelector::kIndirectAdjacent:
      case CSSSelector::kRelativeDirectAdjacent:
      case CSSSelector::kRelativeIndirectAdjacent:
        // Adjacent combinators: the current compound describes siblings, so
        // don't collect identifier requirements from it. Reset subselector
        // collection until we see an ancestor combinator again.
        skip_over_subselectors = true;
        break;
      case CSSSelector::kDescendant:
      case CSSSelector::kChild:
      case CSSSelector::kRelativeDescendant:
      case CSSSelector::kRelativeChild:
      case CSSSelector::kUAShadow:
      case CSSSelector::kShadowSlot:
      case CSSSelector::kShadowPart:
      case CSSSelector::kScopeActivation:
        // Ancestor combinators: subsequent simple selectors correspond to
        // elements on the ancestor chain.
        skip_over_subselectors = false;
        if (FastRejectForSimpleSelector(*current)) {
          return true;
        }
        break;
    }
    relation = current->Relation();
  }
  return false;
}

bool SelectorFilter::FastRejectForSimpleSelector(const CSSSelector& selector) const {
  switch (selector.Match()) {
    case CSSSelector::kId:
      return !MayContainIdentifier(selector.Value(), kIdSalt);
    case CSSSelector::kClass:
      return !MayContainIdentifier(selector.Value(), kClassSalt);
    case CSSSelector::kTag: {
      AtomicString local_name = selector.TagQName().LocalName();
      if (!local_name.IsLowerASCII()) {
        local_name = local_name.LowerASCII();
      }
      return !MayContainIdentifier(local_name, kTagSalt);
    }
    case CSSSelector::kAttributeExact:
    case CSSSelector::kAttributeSet:
    case CSSSelector::kAttributeList:
    case CSSSelector::kAttributeContain:
    case CSSSelector::kAttributeBegin:
    case CSSSelector::kAttributeEnd:
    case CSSSelector::kAttributeHyphen: {
      AtomicString local_name = selector.Attribute().LocalName();
      if (!local_name.IsLowerASCII()) {
        local_name = local_name.LowerASCII();
      }
      if (IsExcludedAttribute(local_name)) {
        return false;
      }
      return !MayContainIdentifier(local_name, kAttributeSalt);
    }
    case CSSSelector::kPseudoClass: {
      switch (selector.GetPseudoType()) {
        case CSSSelector::kPseudoIs:
        case CSSSelector::kPseudoWhere:
        case CSSSelector::kPseudoParent: {
          const CSSSelector* selector_list = selector.SelectorListOrParent();
          if (selector_list && CSSSelectorList::Next(*selector_list) == nullptr) {
            // Treat a one-element :is()/:where()/& as if it was written out.
            if (FastRejectDescendantCompoundSelectorIdentifierHashes(selector_list, CSSSelector::kDescendant)) {
              return true;
            }
          }
          break;
        }
        default:
          break;
      }
      return false;
    }
    default:
      return false;
  }
}

}  // namespace webf
