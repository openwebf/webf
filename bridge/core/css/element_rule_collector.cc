/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 2004-2005 Allan Sandfeld Jensen (kde@carewolf.com)
 * Copyright (C) 2006, 2007 Nicholas Shanks (webkit@nickshanks.com)
 * Copyright (C) 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013 Apple Inc.
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

#include "element_rule_collector.h"

#include <algorithm>
#include <limits>
#include "core/css/css_property_value_set.h"
#include "core/css/css_rule_list.h"
#include "core/css/css_selector.h"
#include "core/css/css_style_rule.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/rule_set.h"
#include "core/css/selector_filter.h"
#include "core/css/style_rule.h"
#include "core/dom/element.h"

namespace webf {

ElementRuleCollector::ElementRuleCollector(StyleResolverState& state, SelectorChecker::Mode mode)
    : state_(state),
      element_(&state.GetElement()),
      pseudo_element_id_(state.GetPseudoElementId()),
      selector_checker_(mode),
      selector_filter_(nullptr) {
}

ElementRuleCollector::~ElementRuleCollector() = default;

void ElementRuleCollector::CollectMatchingRules(const MatchRequest& match_request) {
  assert(element_);
  
  // Collect rules from the match request
  for (const auto& rule_set : match_request.GetRuleSets()) {
    if (rule_set) {
      CollectRuleSetMatchingRules(match_request, 
                                 rule_set,
                                 match_request.GetOrigin(),
                                 0);
    }
  }
}

void ElementRuleCollector::CollectRuleSetMatchingRules(
    const MatchRequest& match_request,
    std::shared_ptr<RuleSet> rule_set,
    CascadeOrigin cascade_origin,
    CascadeLayerLevel cascade_layer) {
  
  if (!rule_set) {
    return;
  }
  
  // The hang might be in accessing rules from RuleSet - let's be more careful
  
  // Collect tag rules first (most likely to match for simple selectors like "div")
  const auto& tag_rules = rule_set->TagRules(element_->localName());
  if (!tag_rules.empty()) {
    CollectMatchingRulesForList(tag_rules,
                               cascade_origin,
                               cascade_layer, 
                               match_request);
  }
  
  // Collect universal rules
  const auto& universal_rules = rule_set->UniversalRules();
  if (!universal_rules.empty()) {
    CollectMatchingRulesForList(universal_rules, 
                               cascade_origin, 
                               cascade_layer,
                               match_request);
  }
  
  // Collect ID rules
  if (element_->HasID()) {
    const auto& id_rules = rule_set->IdRules(element_->id());
    if (!id_rules.empty()) {
      CollectMatchingRulesForList(id_rules,
                                 cascade_origin,
                                 cascade_layer,
                                 match_request);
    }
  }
  
  // Collect class rules
  if (element_->HasClass()) {
    for (const auto& class_name : element_->ClassNames()) {
      const auto& class_rules = rule_set->ClassRules(class_name);
      if (!class_rules.empty()) {
        CollectMatchingRulesForList(class_rules,
                                   cascade_origin,
                                   cascade_layer,
                                   match_request);
      }
    }
  }
}

template <typename RuleDataListType>
void ElementRuleCollector::CollectMatchingRulesForList(
    const RuleDataListType& rules,
    CascadeOrigin cascade_origin,
    CascadeLayerLevel cascade_layer,
    const MatchRequest& match_request) {
  
  // Safety check - don't process too many rules to prevent hangs
  size_t processed_count = 0;
  const size_t MAX_RULES_TO_PROCESS = 1000;
  
  for (const auto& rule_data : rules) {
    if (!rule_data) {
      continue;
    }
    
    // Prevent processing too many rules
    if (++processed_count > MAX_RULES_TO_PROCESS) {
      break;
    }
    
    // Check if selector matches element
    SelectorChecker::SelectorCheckingContext context(element_);
    context.selector = &rule_data->Selector();
    
    // Safety check: skip malformed selectors
    if (!context.selector) {
      continue;
    }
    
  // UA stylesheet matching must respect full selectors (combinators, pseudos).
  // Previously we short-circuited on tag-only which caused rules like
  // "td > p:first-child" to (incorrectly) match all <p>, zeroing margins.
  if (cascade_origin == CascadeOrigin::kUserAgent) {
    SelectorChecker::MatchResult ua_match_result;
    // Ensure UA rule matching respects requested pseudo-element (e.g., ::before/::after)
    context.pseudo_id = pseudo_element_id_;
    bool ua_matched = selector_checker_.Match(context, ua_match_result);
    if (ua_matched) {
      DidMatchRule(rule_data, cascade_origin, cascade_layer, match_request);
    }
    continue;  // Handled UA case.
  }
    
    SelectorChecker::MatchResult match_result;
    // Avoid calling TagQName() unless the selector is a tag selector.
    // Non-tag selectors (class, id, attribute, pseudo, etc.) would hit
    // a DCHECK in CSSSelector::TagQName(). Logging is omitted here to
    // keep this path safe across all selector types.
    // Propagate pseudo-element matching request (if any) into the context
    // so pseudo-element selectors like ::before / ::after can be evaluated
    // when the checker runs in non-querying modes.
    context.pseudo_id = pseudo_element_id_;
    bool matched = selector_checker_.Match(context, match_result);
    if (matched) {
      WEBF_COND_LOG(COLLECTOR, VERBOSE) << "Author rule matched!";
      const std::shared_ptr<StyleRule>& rule = rule_data->Rule();

      String selector = rule->SelectorsText();
      WEBF_COND_LOG(COLLECTOR, VERBOSE) << "SELECTOR: " << selector.Characters8();

      String s = rule->Properties().AsText();
      WEBF_COND_LOG(COLLECTOR, VERBOSE) << "RULE: " << s.Characters8();
      DidMatchRule(rule_data, cascade_origin, cascade_layer, match_request);
    }
  }
}

void ElementRuleCollector::DidMatchRule(
    std::shared_ptr<const RuleData> rule_data,
    CascadeOrigin cascade_origin,
    CascadeLayerLevel cascade_layer,
    const MatchRequest& match_request) {
  
  if (!rule_data || !rule_data->Rule()) {
    return;
  }
  
  // Check if we should include empty rules
  if (!include_empty_rules_ && 
      rule_data->Rule()->Properties().PropertyCount() == 0) {
    return;
  }
  
  // Add the matched rule
  AddMatchedRule(rule_data,
                rule_data->SelectorSpecificity(),
                cascade_origin,
                cascade_layer,
                match_request.GetStyleSheetIndex(),
                match_request);
}

void ElementRuleCollector::AddMatchedRule(
    std::shared_ptr<const RuleData> rule_data,
    unsigned specificity,
    CascadeOrigin cascade_origin,
    CascadeLayerLevel cascade_layer,
    unsigned style_sheet_index,
    const MatchRequest& match_request) {
  
  MatchedRule matched_rule;
  matched_rule.rule_data = rule_data;
  matched_rule.specificity = specificity;
  matched_rule.cascade_origin = cascade_origin;
  matched_rule.cascade_layer = cascade_layer;
  matched_rule.style_sheet_index = style_sheet_index;
  matched_rule.cascade_order = current_cascade_order_++;
  
  matched_rules_.push_back(matched_rule);
}

void ElementRuleCollector::CollectMatchingRulesFromShadowHosts() {
  // TODO: Implement shadow host rule collection
}

void ElementRuleCollector::CollectMatchingSlottedRules() {
  // TODO: Implement slotted rule collection
}

void ElementRuleCollector::CollectMatchingPartRules() {
  // TODO: Implement part rule collection
}

void ElementRuleCollector::SortAndTransferMatchedRules() {
  if (matched_rules_.empty()) {
    return;
  }
  
  SortMatchedRules();
  TransferMatchedRules();
}

void ElementRuleCollector::SortMatchedRules() {
  // Sort by cascade order
  std::stable_sort(matched_rules_.begin(), matched_rules_.end(),
      [](const MatchedRule& a, const MatchedRule& b) {
        // CSS Cascade order (aligned with CascadePriority::ForLayerComparison):
        // 1) Origin (UA < User < Author < Animation < Transition)
        if (a.cascade_origin != b.cascade_origin) {
          return static_cast<int>(a.cascade_origin) < static_cast<int>(b.cascade_origin);
        }

        // 2) Inline style vs. stylesheet rules: non-inline first, inline last.
        //    This ensures ForLayerComparison is non-decreasing when adding
        //    to CascadeMap, preventing assertion failures.
        if (a.is_inline_style != b.is_inline_style) {
          return b.is_inline_style; // false < true
        }

        // 3) Cascade layer (lower layer order first)
        if (a.cascade_layer != b.cascade_layer) {
          return a.cascade_layer < b.cascade_layer;
        }

        // 4) Specificity (sort ascending so higher specificity appears later and wins)
        if (a.specificity != b.specificity) {
          return a.specificity < b.specificity;
        }

        // 5) Source order tie-breaker: stylesheet index, then rule position
        if (a.style_sheet_index != b.style_sheet_index) {
          return a.style_sheet_index < b.style_sheet_index;
        }
        if (a.rule_data && b.rule_data && a.rule_data->Position() != b.rule_data->Position()) {
          return a.rule_data->Position() < b.rule_data->Position();
        }

        // 6) Fallback to collection order (stable)
        return a.cascade_order < b.cascade_order;
      });
}

void ElementRuleCollector::TransferMatchedRules() {
  for (const auto& matched_rule : matched_rules_) {
    if (matched_rule.is_inline_style) {
      if (matched_rule.inline_properties) {
        result_.AddInlineStyleProperties(matched_rule.inline_properties);
      }
      continue;
    }
    if (matched_rule.rule_data && matched_rule.rule_data->Rule()) {
      result_.AddMatchedProperties(
          &matched_rule.rule_data->Rule()->Properties(),
          matched_rule.cascade_origin,
          matched_rule.cascade_layer);
    }
  }
  
  matched_rules_.clear();
}

void ElementRuleCollector::ClearMatchedRules() {
  matched_rules_.clear();
  result_.Clear();
  current_cascade_order_ = 0;
}

void ElementRuleCollector::AddElementStyleProperties(
    std::shared_ptr<const StylePropertySet> property_set,
    PropertyAllowedInMode property_mode) {
  // Align with Blink: Do not add the originating element's inline style when
  // collecting rules for a pseudo-element. Pseudo elements cannot have inline
  // styles; they inherit inheritable properties via the computed style
  // pipeline instead. Including inline here would incorrectly elevate
  // non-inherited properties (e.g., border) into the pseudo cascade.
  if (is_collecting_for_pseudo_element_) {
    return;
  }

  if (!property_set || property_set->PropertyCount() == 0) {
    return;
  }
  
  // Queue inline style into matched list so it participates in sorting.
  MatchedRule matched_rule;
  matched_rule.rule_data = nullptr;
  matched_rule.specificity = 0;
  matched_rule.cascade_origin = CascadeOrigin::kAuthor;
  matched_rule.cascade_layer = 0;
  matched_rule.style_sheet_index = std::numeric_limits<unsigned>::max();
  matched_rule.cascade_order = current_cascade_order_++;
  matched_rule.is_inline_style = true;
  matched_rule.inline_properties = property_set.get();
  // Keep a strong reference to ensure lifetime if needed in later phases
  // (TransferMatchedRules reads from inline_properties pointer).
  // Note: We avoid changing interfaces; this ownership is implicit.
  matched_rules_.push_back(matched_rule);
}

void ElementRuleCollector::SetPseudoElementStyleRequest(
    const PseudoElementStyleRequest& request) {
  
  pseudo_element_id_ = request.pseudo_id;
  is_collecting_for_pseudo_element_ = true;
}

template <class CSSRuleCollection>
std::shared_ptr<CSSRule> ElementRuleCollector::FindStyleRule(
    CSSRuleCollection* css_rules,
    std::shared_ptr<StyleRule> style_rule) {
  
  if (!css_rules || !style_rule) {
    return nullptr;
  }
  
  // TODO: Implement finding CSS rule wrapper
  return nullptr;
}

void ElementRuleCollector::AppendCSSOMWrapperForRule(std::shared_ptr<CSSRule> css_rule) {
  // TODO: Implement CSSOM wrapper appending
}

}  // namespace webf
