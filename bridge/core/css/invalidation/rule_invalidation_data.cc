// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/invalidation/rule_invalidation_data.h"

#include "core/base/memory/values_equivalent.h"
#include "core/dom/element.h"
#include "core/dom/space_split_string.h"
#include "foundation/string_builder.h"

namespace webf {

namespace {

template <typename KeyType,
          typename MapType = std::unordered_map<KeyType, std::shared_ptr<InvalidationSet>>>
bool InvalidationSetMapsEqual(const MapType& a, const MapType& b) {
  if (a.size() != b.size()) {
    return false;
  }
  for (const auto& entry : a) {
    auto it = b.find(entry.first);
    if (it == b.end()) {
      return false;
    }
    if (!webf::ValuesEquivalent(entry.second, it->second)) {
      return false;
    }
  }
  return true;
}

}  // anonymous namespace

bool RuleInvalidationData::operator==(const RuleInvalidationData& other) const {
  return InvalidationSetMapsEqual<AtomicString>(
             class_invalidation_sets, other.class_invalidation_sets) &&
         webf::ValuesEquivalent(names_with_self_invalidation,
                                other.names_with_self_invalidation) &&
         InvalidationSetMapsEqual<AtomicString>(id_invalidation_sets,
                                                other.id_invalidation_sets) &&
         InvalidationSetMapsEqual<AtomicString>(
             attribute_invalidation_sets, other.attribute_invalidation_sets) &&
         InvalidationSetMapsEqual<CSSSelector::PseudoType>(
             pseudo_invalidation_sets, other.pseudo_invalidation_sets) &&
         webf::ValuesEquivalent(universal_sibling_invalidation_set,
                                other.universal_sibling_invalidation_set) &&
         webf::ValuesEquivalent(nth_invalidation_set,
                                other.nth_invalidation_set) &&
         webf::ValuesEquivalent(universal_sibling_invalidation_set,
                                other.universal_sibling_invalidation_set) &&
         classes_in_has_argument == other.classes_in_has_argument &&
         attributes_in_has_argument == other.attributes_in_has_argument &&
         ids_in_has_argument == other.ids_in_has_argument &&
         tag_names_in_has_argument == other.tag_names_in_has_argument &&
         max_direct_adjacent_selectors == other.max_direct_adjacent_selectors &&
         uses_first_line_rules == other.uses_first_line_rules &&
         uses_window_inactive_selector == other.uses_window_inactive_selector &&
         universal_in_has_argument == other.universal_in_has_argument &&
         not_pseudo_in_has_argument == other.not_pseudo_in_has_argument &&
         pseudos_in_has_argument == other.pseudos_in_has_argument &&
         invalidates_parts == other.invalidates_parts &&
         uses_has_inside_nth == other.uses_has_inside_nth;
}

void RuleInvalidationData::Clear() {
  class_invalidation_sets.clear();
  names_with_self_invalidation.reset();
  attribute_invalidation_sets.clear();
  id_invalidation_sets.clear();
  pseudo_invalidation_sets.clear();
  universal_sibling_invalidation_set = nullptr;
  nth_invalidation_set = nullptr;
  classes_in_has_argument.clear();
  attributes_in_has_argument.clear();
  ids_in_has_argument.clear();
  tag_names_in_has_argument.clear();
  pseudos_in_has_argument.clear();
  max_direct_adjacent_selectors = 0;
  uses_first_line_rules = false;
  uses_window_inactive_selector = false;
  universal_in_has_argument = false;
  not_pseudo_in_has_argument = false;
  invalidates_parts = false;
  uses_has_inside_nth = false;
}

void RuleInvalidationData::CollectInvalidationSetsForClass(
    InvalidationLists& invalidation_lists,
    Element& element,
    const std::string& class_name) const {
  // Implicit self-invalidation sets for all classes (with Bloom filter
  // rejection); see comment on class_invalidation_sets_.
  if (names_with_self_invalidation && names_with_self_invalidation->MayContain(
                                          std::hash<std::string>{}(class_name) * kClassSalt)) {
    invalidation_lists.descendants.push_back(
        InvalidationSet::SelfInvalidationSet());
  }

  RuleInvalidationData::InvalidationSetMap::const_iterator it =
      class_invalidation_sets.find(class_name);
  if (it == class_invalidation_sets.end()) {
    return;
  }

  DescendantInvalidationSet* descendants;
  SiblingInvalidationSet* siblings;
  ExtractInvalidationSets(it->second.get(), descendants, siblings);

  if (descendants) {
    //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *descendants, ClassChange,
    //                                  class_name);
    invalidation_lists.descendants.push_back(std::shared_ptr<DescendantInvalidationSet>(descendants));
  }

  if (siblings) {
    //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *siblings, ClassChange,
    //                                  class_name);
    invalidation_lists.siblings.push_back(std::shared_ptr<SiblingInvalidationSet>(siblings));
  }
}

void RuleInvalidationData::CollectSiblingInvalidationSetForClass(
    InvalidationLists& invalidation_lists,
    Element& element,
    const std::string& class_name,
    unsigned min_direct_adjacent) const {
  RuleInvalidationData::InvalidationSetMap::const_iterator it =
      class_invalidation_sets.find(class_name);
  if (it == class_invalidation_sets.end()) {
    return;
  }

  auto* sibling_set = DynamicTo<SiblingInvalidationSet>(it->second.get());
  if (!sibling_set) {
    return;
  }

  if (sibling_set->MaxDirectAdjacentSelectors() < min_direct_adjacent) {
    return;
  }

  //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *sibling_set, ClassChange,
  //                                  class_name);
  invalidation_lists.siblings.push_back(std::shared_ptr<SiblingInvalidationSet>(sibling_set));
}

void RuleInvalidationData::CollectInvalidationSetsForId(
    InvalidationLists& invalidation_lists,
    Element& element,
    const std::string& id) const {
  if (names_with_self_invalidation &&
      names_with_self_invalidation->MayContain(std::hash<std::string>{}(id) * kIdSalt)) {
    invalidation_lists.descendants.push_back(
        InvalidationSet::SelfInvalidationSet());
  }

  RuleInvalidationData::InvalidationSetMap::const_iterator it =
      id_invalidation_sets.find(id);
  if (it == id_invalidation_sets.end()) {
    return;
  }

  DescendantInvalidationSet* descendants;
  SiblingInvalidationSet* siblings;
  ExtractInvalidationSets(it->second.get(), descendants, siblings);

  if (descendants) {
    //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *descendants, IdChange, id);
    invalidation_lists.descendants.push_back(std::shared_ptr<DescendantInvalidationSet>(descendants));
  }

  if (siblings) {
    //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *siblings, IdChange, id);
    invalidation_lists.siblings.push_back(std::shared_ptr<SiblingInvalidationSet>(siblings));
  }
}

void RuleInvalidationData::CollectSiblingInvalidationSetForId(
    InvalidationLists& invalidation_lists,
    Element& element,
    const std::string& id,
    unsigned min_direct_adjacent) const {
  RuleInvalidationData::InvalidationSetMap::const_iterator it =
      id_invalidation_sets.find(id);
  if (it == id_invalidation_sets.end()) {
    return;
  }

  auto* sibling_set = DynamicTo<SiblingInvalidationSet>(it->second.get());
  if (!sibling_set) {
    return;
  }

  if (sibling_set->MaxDirectAdjacentSelectors() < min_direct_adjacent) {
    return;
  }

  //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *sibling_set, IdChange, id);
  invalidation_lists.siblings.push_back(std::shared_ptr<SiblingInvalidationSet>(sibling_set));
}

void RuleInvalidationData::CollectInvalidationSetsForAttribute(
    InvalidationLists& invalidation_lists,
    Element& element,
    const QualifiedName& attribute_name) const {
  RuleInvalidationData::InvalidationSetMap::const_iterator it =
      attribute_invalidation_sets.find(attribute_name.LocalName().ToStdString(element.ctx()));
  if (it == attribute_invalidation_sets.end()) {
    return;
  }

  DescendantInvalidationSet* descendants;
  SiblingInvalidationSet* siblings;
  ExtractInvalidationSets(it->second.get(), descendants, siblings);

  if (descendants) {
    //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *descendants, AttributeChange,
    //                                  attribute_name);
    invalidation_lists.descendants.push_back(std::shared_ptr<DescendantInvalidationSet>(descendants));
  }

  if (siblings) {
    //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *siblings, AttributeChange,
    //                                  attribute_name);
    invalidation_lists.siblings.push_back(std::shared_ptr<SiblingInvalidationSet>(siblings));
  }
}

void RuleInvalidationData::CollectSiblingInvalidationSetForAttribute(
    InvalidationLists& invalidation_lists,
    Element& element,
    const QualifiedName& attribute_name,
    unsigned min_direct_adjacent) const {
  RuleInvalidationData::InvalidationSetMap::const_iterator it =
      attribute_invalidation_sets.find(attribute_name.LocalName().ToStdString(element.ctx()));
  if (it == attribute_invalidation_sets.end()) {
    return;
  }

  auto* sibling_set = DynamicTo<SiblingInvalidationSet>(it->second.get());
  if (!sibling_set) {
    return;
  }

  if (sibling_set->MaxDirectAdjacentSelectors() < min_direct_adjacent) {
    return;
  }

  //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *sibling_set, AttributeChange,
  //                                  attribute_name);
  invalidation_lists.siblings.push_back(std::shared_ptr<SiblingInvalidationSet>(sibling_set));
}

void RuleInvalidationData::CollectInvalidationSetsForPseudoClass(
    InvalidationLists& invalidation_lists,
    Element& element,
    CSSSelector::PseudoType pseudo) const {
  RuleInvalidationData::PseudoTypeInvalidationSetMap::const_iterator it =
      pseudo_invalidation_sets.find(pseudo);
  if (it == pseudo_invalidation_sets.end()) {
    return;
  }

  DescendantInvalidationSet* descendants;
  SiblingInvalidationSet* siblings;
  ExtractInvalidationSets(it->second.get(), descendants, siblings);

  if (descendants) {
    //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *descendants, PseudoChange,
    //                                  pseudo);
    invalidation_lists.descendants.push_back(std::shared_ptr<DescendantInvalidationSet>(descendants));
  }

  if (siblings) {
    //TRACE_SCHEDULE_STYLE_INVALIDATION(element, *siblings, PseudoChange, pseudo);
    invalidation_lists.siblings.push_back(std::shared_ptr<SiblingInvalidationSet>(siblings));
  }
}

void RuleInvalidationData::CollectUniversalSiblingInvalidationSet(
    InvalidationLists& invalidation_lists,
    unsigned min_direct_adjacent) const {
  if (universal_sibling_invalidation_set &&
      universal_sibling_invalidation_set->MaxDirectAdjacentSelectors() >=
          min_direct_adjacent) {
    invalidation_lists.siblings.push_back(universal_sibling_invalidation_set);
  }
}

void RuleInvalidationData::CollectNthInvalidationSet(
    InvalidationLists& invalidation_lists) const {
  if (nth_invalidation_set) {
    invalidation_lists.siblings.push_back(nth_invalidation_set);
  }
}

void RuleInvalidationData::CollectPartInvalidationSet(
    InvalidationLists& invalidation_lists) const {
  if (invalidates_parts) {
    invalidation_lists.descendants.push_back(
        InvalidationSet::PartInvalidationSet());
  }
}

bool RuleInvalidationData::NeedsHasInvalidationForClass(
    const AtomicString& class_name) const {
  return classes_in_has_argument.find(class_name) != classes_in_has_argument.end();
}

bool RuleInvalidationData::NeedsHasInvalidationForAttribute(
    const QualifiedName& attribute_name) const {
  return attributes_in_has_argument.find(attribute_name.LocalName()) != attributes_in_has_argument.end();
}

bool RuleInvalidationData::NeedsHasInvalidationForId(
    const AtomicString& id) const {
  return ids_in_has_argument.find(id) != ids_in_has_argument.end();
}

bool RuleInvalidationData::NeedsHasInvalidationForTagName(
    const AtomicString& tag_name) const {
  return universal_in_has_argument ||
         tag_names_in_has_argument.find(tag_name) != tag_names_in_has_argument.end();
}

bool RuleInvalidationData::NeedsHasInvalidationForInsertedOrRemovedElement(
    Element& element) const {
  if (not_pseudo_in_has_argument) {
    return true;
  }

  if (element.HasID()) {
    if (NeedsHasInvalidationForId(element.IdForStyleResolution())) {
      return true;
    }
  }

  if (element.HasClass()) {
    const SpaceSplitString& class_names = element.ClassNames();
    for (const AtomicString& class_name : class_names) {
      if (NeedsHasInvalidationForClass(class_name)) {
        return true;
      }
    }
  }

  return !attributes_in_has_argument.empty() ||
         NeedsHasInvalidationForTagName(element.LocalNameForSelectorMatching());
}

bool RuleInvalidationData::NeedsHasInvalidationForPseudoClass(
    CSSSelector::PseudoType pseudo_type) const {
  return pseudos_in_has_argument.find(pseudo_type) != pseudos_in_has_argument.end();

}

std::string RuleInvalidationData::ToString() const {
  StringBuilder builder;

  enum TypeFlags {
    kId = 1 << 0,
    kClass = 1 << 1,
    kAttribute = 1 << 2,
    kPseudo = 1 << 3,
    kDescendant = 1 << 4,
    kSibling = 1 << 5,
    kUniversal = 1 << 6,
    kNth = 1 << 7,
  };

  struct Entry {
    std::string name;
    const InvalidationSet* set;
    unsigned flags;
  };

  std::vector<Entry> entries;

  auto add_invalidation_sets = [&entries](const std::string& base,
                                          InvalidationSet* set, unsigned flags,
                                          const char* prefix = "",
                                          const char* suffix = "") {
    if (!set) {
      return;
    }
    DescendantInvalidationSet* descendants;
    SiblingInvalidationSet* siblings;
    RuleInvalidationData::ExtractInvalidationSets(set, descendants, siblings);

    if (descendants) {
      entries.push_back(Entry{base, descendants, flags | kDescendant});
    }
    if (siblings) {
      entries.push_back(Entry{base, siblings, flags | kSibling});
    }
    if (siblings && siblings->SiblingDescendants()) {
      entries.push_back(Entry{base, siblings->SiblingDescendants(),
                              flags | kSibling | kDescendant});
    }
  };

  auto format_name = [](const std::string& base, unsigned flags) {
    StringBuilder builder;
    // Prefix:

    builder.Append((flags & kId) ? "#" : "");
    builder.Append((flags & kClass) ? "." : "");
    builder.Append((flags & kAttribute) ? "[" : "");

    builder.Append(base);

    // Suffix:
    builder.Append((flags & kAttribute) ? "]" : "");

    builder.Append("[");
    if (flags & kSibling) {
      builder.Append("+");
    }
    if (flags & kDescendant) {
      builder.Append(">");
    }
    builder.Append("]");

    return builder.ReleaseString();
  };

  auto format_max_direct_adjancent = [](unsigned max) -> std::string {
    if (max == SiblingInvalidationSet::kDirectAdjacentMax) {
      return "~";
    }
    if (max) {
      return std::to_string(max);
    }
    return "";
  };

  for (auto& i : id_invalidation_sets) {
    add_invalidation_sets(i.first, i.second.get(), kId, "#");
  }
  for (auto& i : class_invalidation_sets) {
    add_invalidation_sets(i.first, i.second.get(), kClass, ".");
  }
  for (auto& i : attribute_invalidation_sets) {
    add_invalidation_sets(i.first, i.second.get(), kAttribute, "[", "]");
  }
  for (auto& i : pseudo_invalidation_sets) {
    std::string name = CSSSelector::FormatPseudoTypeForDebugging(
        static_cast<CSSSelector::PseudoType>(i.first));
    add_invalidation_sets(name, i.second.get(), kPseudo, ":", "");
  }

  add_invalidation_sets("*", universal_sibling_invalidation_set.get(),
                        kUniversal);
  add_invalidation_sets("nth", nth_invalidation_set.get(), kNth);

  std::sort(entries.begin(), entries.end(), [](const auto& a, const auto& b) {
    if (a.flags != b.flags) {
      return a.flags < b.flags;
    }
    //return WTF::CodeUnitCompareLessThan(a.name, b.name);
    return a.name < b.name;
  });

  for (const Entry& entry : entries) {
    builder.Append(format_name(entry.name, entry.flags));
    builder.Append(entry.set->ToString());
    builder.Append(" ");
  }

  StringBuilder metadata;
  metadata.Append(uses_first_line_rules ? "F" : "");
  metadata.Append(uses_window_inactive_selector ? "W" : "");
  metadata.Append(invalidates_parts ? "P" : "");
  metadata.Append(format_max_direct_adjancent(max_direct_adjacent_selectors));

  if (!metadata.empty()) {
    builder.Append("META:");
    builder.Append(metadata.ReleaseString());
  }

  return builder.ReleaseString();
}

// static
void RuleInvalidationData::ExtractInvalidationSets(
    InvalidationSet* invalidation_set,
    DescendantInvalidationSet*& descendants,
    SiblingInvalidationSet*& siblings) {
  CHECK(invalidation_set->IsAlive());
  if (auto* descendant =
          DynamicTo<DescendantInvalidationSet>(invalidation_set)) {
    descendants = descendant;
    siblings = nullptr;
    return;
  }

  siblings = To<SiblingInvalidationSet>(invalidation_set);
  descendants = siblings->Descendants();
}

}  // namespace webf