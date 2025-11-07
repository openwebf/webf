/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 2004-2005 Allan Sandfeld Jensen (kde@carewolf.com)
 * Copyright (C) 2006, 2007 Nicholas Shanks (webkit@nickshanks.com)
 * Copyright (C) 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012 Apple Inc.
 * All rights reserved.
 * Copyright (C) 2007 Alexey Proskuryakov <ap@webkit.org>
 * Copyright (C) 2007, 2008 Eric Seidel <eric@webkit.org>
 * Copyright (C) 2008, 2009 Torch Mobile Inc. All rights reserved.
 * (http://www.torchmobile.com/)
 * Copyright (c) 2011, Code Aurora Forum. All rights reserved.
 * Copyright (C) Research In Motion Limited 2011. All rights reserved.
 * Copyright (C) 2012 Google Inc. All rights reserved.
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
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "rule_set.h"

#include "core/css/css_selector.h"
#include "core/css/css_style_rule.h"
#include "core/css/media_query_evaluator.h"
#include "core/css/style_rule.h"
#include "foundation/string/string_view.h"
#include "core/css/style_sheet_contents.h"
#include "foundation/casting.h"
#include "foundation/logging.h"

namespace webf {

const std::vector<std::shared_ptr<RuleData>> RuleSet::empty_rule_data_vector_;

RuleData::RuleData(std::shared_ptr<StyleRule> rule, 
                   unsigned selector_index, 
                   unsigned position)
    : rule_(rule),
      selector_index_(selector_index),
      position_(position),
      specificity_(0) {
  
  if (rule_) {
    const CSSSelector& selector = rule_->SelectorAt(selector_index_);
    specificity_ = selector.Specificity();

    // Compute rightmost compound's type selector, if any.
    const CSSSelector* simple = &selector;
    while (simple) {
      if (simple->Match() == CSSSelector::kTag) {
        has_rightmost_type_ = true;
        rightmost_tag_ = simple->TagQName().LocalName();
        break;
      }
      simple = simple->NextSimpleSelector();
    }
  }
}

RuleSet::RuleSet() = default;

RuleSet::~RuleSet() = default;

void RuleSet::AddRulesFromSheet(
    std::shared_ptr<StyleSheetContents> sheet,
    const MediaQueryEvaluator& medium,
    AddRuleFlags add_rule_flags) {
  
  if (!sheet) {
    return;
  }
  
  // Process child rules
  const auto& child_rules = sheet->ChildRules();
  for (const auto& rule : child_rules) {
    if (auto style_rule = DynamicTo<StyleRule>(rule.get())) {
      // For style rules, add them to the RuleSet
      AddStyleRule(std::static_pointer_cast<StyleRule>(rule), add_rule_flags);
    }
    // TODO: Handle other rule types (@media, @supports, etc) when implemented
  }
}

void RuleSet::AddRule(std::shared_ptr<StyleRule> rule,
                     unsigned selector_index,
                     AddRuleFlags add_rule_flags) {
  
  if (!rule) {
    return;
  }
  
  auto rule_data = std::make_shared<RuleData>(rule, selector_index, rule_count_++);
  
  // Update features
  // TODO: Add feature tracking
  // features_.Add(rule_data->Selector());
  
  // Find the best rule set for this selector
  RuleDataVector* rules = FindBestRuleSetForSelector(rule_data->Selector());
  if (rules) {
    rules->push_back(rule_data);
  }
}

void RuleSet::AddStyleRule(std::shared_ptr<StyleRule> rule,
                          AddRuleFlags add_rule_flags) {
  
  if (!rule) {
    return;
  }
  
  // Add rules for all selectors
  // StyleRule has a linked list of selectors, count them
  unsigned selector_count = 0;
  const CSSSelector* first_selector = rule->FirstSelector();
  for (const CSSSelector* selector = first_selector; selector; 
       selector = CSSSelectorList::Next(*selector)) {
    selector_count++;
  }
  
  // WEBF_LOG(VERBOSE) << "Adding style rule with " << selector_count << " selectors";
  
  // Add a rule for each selector in the style rule
  for (unsigned i = 0; i < selector_count; ++i) {
    AddRule(rule, i, add_rule_flags);
  }
}

const std::vector<std::shared_ptr<RuleData>>& RuleSet::IdRules(
    const AtomicString& id) const {
  
  auto it = id_rules_.find(id);
  if (it != id_rules_.end() && it->second) {
    return *it->second;
  }
  return empty_rule_data_vector_;
}

const std::vector<std::shared_ptr<RuleData>>& RuleSet::ClassRules(
    const AtomicString& class_name) const {
  
  auto it = class_rules_.find(class_name);
  if (it != class_rules_.end() && it->second) {
    return *it->second;
  }
  return empty_rule_data_vector_;
}

const std::vector<std::shared_ptr<RuleData>>& RuleSet::TagRules(
    const AtomicString& tag_name) const {
  if (!tag_name.IsNull()) {
    auto it = tag_rules_.find(tag_name);
    if (it != tag_rules_.end() && it->second) {
      return *it->second;
    }

    // HTML tag selectors are ASCII case-insensitive. Retry lookup using
    // lower/upper ASCII folds before falling back.
    AtomicString lower = tag_name.LowerASCII();
    if (lower != tag_name) {
      it = tag_rules_.find(lower);
      if (it != tag_rules_.end() && it->second) {
        return *it->second;
      }
    }

    AtomicString upper = tag_name.UpperASCII();
    if (upper != tag_name) {
      it = tag_rules_.find(upper);
      if (it != tag_rules_.end() && it->second) {
        return *it->second;
      }
    }

    // As a last resort, perform a linear scan with ASCII case-insensitive
    // comparison. This only runs when lookups above miss (e.g. author wrote
    // “BoDy”).
    StringView needle(tag_name);
    for (const auto& entry : tag_rules_) {
      if (!entry.second || entry.second->empty()) {
        continue;
      }
      const AtomicString& key = entry.first;
      if (EqualIgnoringASCIICase(StringView(key), needle)) {
        return *entry.second;
      }
    }
  }
  return empty_rule_data_vector_;
}

const std::vector<std::shared_ptr<RuleData>>& RuleSet::ShadowPseudoElementRules(
    const AtomicString& pseudo) const {
  
  auto it = shadow_pseudo_element_rules_.find(pseudo);
  if (it != shadow_pseudo_element_rules_.end() && it->second) {
    return *it->second;
  }
  return empty_rule_data_vector_;
}

void RuleSet::CompactRulesIfNeeded() {
  // TODO: Implement rule compaction for memory efficiency
}

RuleSet::RuleDataVector* RuleSet::FindBestRuleSetForSelector(
    const CSSSelector& selector) {
  // Bucket by the rightmost compound, prioritizing ID > class > tag.
  // This mirrors Blink’s approach so compound selectors like "P#three"
  // are indexed by ID and still require the type to match during checking.

  // Start at the rightmost compound's first simple selector.
  const CSSSelector* simple = &selector;

  // Skip over leading pseudo-elements (they don't bucket well on their own).
  for (; simple && simple->Match() == CSSSelector::kPseudoElement; simple = simple->NextSimpleSelector()) {
    if (!simple->NextSimpleSelector()) {
      // Only a pseudo-element: bucket into universal; relation context will handle.
      return &universal_rules_;
    }
  }

  // Scan the entire rightmost compound for ID/class/tag.
  const CSSSelector* found_id = nullptr;
  const CSSSelector* found_class = nullptr;
  const CSSSelector* found_tag = nullptr;

  for (const CSSSelector* s = simple; s; s = s->NextSimpleSelector()) {
    switch (s->Match()) {
      case CSSSelector::kId:
        // Prefer the first ID we see in the rightmost compound.
        if (!found_id) found_id = s;
        break;
      case CSSSelector::kClass:
        if (!found_class) found_class = s;
        break;
      case CSSSelector::kTag:
        if (!found_tag) found_tag = s;
        break;
      default:
        break;
    }
  }

  if (found_id) {
    const AtomicString& id = found_id->Value();
    if (id_rules_.find(id) == id_rules_.end()) {
      id_rules_[id] = std::make_unique<RuleDataVector>();
    }
    return id_rules_[id].get();
  }

  if (found_class) {
    const AtomicString& class_name = found_class->Value();
    if (class_rules_.find(class_name) == class_rules_.end()) {
      class_rules_[class_name] = std::make_unique<RuleDataVector>();
    }
    return class_rules_[class_name].get();
  }

  if (found_tag) {
    const AtomicString& tag_name = found_tag->TagQName().LocalName();
    if (!tag_name.IsNull() && tag_name != "*") {
      AtomicString bucket = tag_name;
      if (bucket.Is8Bit()) {
        bucket = tag_name.LowerASCII();
      }
      if (tag_rules_.find(bucket) == tag_rules_.end()) {
        tag_rules_[bucket] = std::make_unique<RuleDataVector>();
      }
      return tag_rules_[bucket].get();
    }
  }

  // Fall back to known pseudo-class buckets if applicable.
  if (simple && simple->Match() == CSSSelector::kPseudoClass) {
    switch (simple->GetPseudoType()) {
      case CSSSelector::kPseudoLink:
      case CSSSelector::kPseudoVisited:
      case CSSSelector::kPseudoAnyLink:
        return &link_pseudo_class_rules_;
      case CSSSelector::kPseudoFocus:
      case CSSSelector::kPseudoFocusVisible:
      case CSSSelector::kPseudoFocusWithin:
        return &focus_pseudo_class_rules_;
      default:
        break;
    }
  }

  // Default to universal rules when no better bucket applies.
  return &universal_rules_;
}

void RuleSet::AddToRuleSet(
    const AtomicString& key,
    std::unordered_map<AtomicString, std::unique_ptr<RuleDataVector>, AtomicString::KeyHasher>& rules,
    std::shared_ptr<RuleData> rule_data) {
  
  if (rules.find(key) == rules.end()) {
    rules[key] = std::make_unique<RuleDataVector>();
  }
  rules[key]->push_back(rule_data);
}

}  // namespace webf
