/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc.
 * All rights reserved.
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
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_ELEMENT_RULE_COLLECTOR_H
#define WEBF_CSS_ELEMENT_RULE_COLLECTOR_H

#include <memory>
#include <vector>
#include "core/css/css_rule_list.h"
#include "core/css/match_result.h"
#include "core/css/resolver/match_request.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/selector_checker.h"
#include "core/css/style_rule.h"
#include "foundation/macros.h"

namespace webf {

// Enum for property allowed modes
enum class PropertyAllowedInMode {
  kAll,
  kAnimationOnly,
  kTransitionOnly,
  kHighPriorityOnly,
};

class CSSRuleList;
class CSSSelector;
class Element;
class RuleData;
class RuleSet;
class SelectorFilter;

// Request for pseudo-element style
struct PseudoElementStyleRequest {
  PseudoId pseudo_id;
  const AtomicString& pseudo_argument;
  
  PseudoElementStyleRequest(PseudoId id, const AtomicString& arg = g_null_atom)
      : pseudo_id(id), pseudo_argument(arg) {}
};

// Manages the process of collecting rules that match an element
class ElementRuleCollector {
  WEBF_STACK_ALLOCATED();

 public:
  explicit ElementRuleCollector(StyleResolverState&, SelectorChecker::Mode mode = SelectorChecker::kResolvingStyle);
  ~ElementRuleCollector();

  // Collect matching rules from a RuleSet
  void CollectMatchingRules(const MatchRequest&);
  
  // Collect rules from a specific RuleSet with cascading information
  void CollectRuleSetMatchingRules(const MatchRequest&, 
                                  std::shared_ptr<RuleSet>,
                                  CascadeOrigin,
                                  CascadeLayerLevel);

  // Collect matching rules from shadow hosts
  void CollectMatchingRulesFromShadowHosts();

  // Collect matching rules from slotted rules
  void CollectMatchingSlottedRules();

  // Collect matching rules from part rules
  void CollectMatchingPartRules();

  // Sort and transfer matched rules to MatchResult
  void SortAndTransferMatchedRules();

  // Clear matched rules
  void ClearMatchedRules();

  // Add element style properties
  void AddElementStyleProperties(std::shared_ptr<const StylePropertySet>, 
                                PropertyAllowedInMode);

  // Check if we have any matched rules
  bool HasMatchedRules() const { return !matched_rules_.empty(); }

  // Get the match result
  const MatchResult& GetMatchResult() const { return result_; }

  // Pseudo element matching
  void SetPseudoElementStyleRequest(const PseudoElementStyleRequest&);
  void SetMatchingFromScope(bool matching_from_scope) { 
    matching_from_scope_ = matching_from_scope; 
  }

  // Include or exclude rules based on their properties
  void SetIncludeEmptyRules(bool include) { include_empty_rules_ = include; }
  
  // Set whether we're matching UA rules
  void SetIsUARule(bool is_ua_rule) { is_ua_rule_ = is_ua_rule; }

  StyleResolverState& State() { return state_; }
  const StyleResolverState& State() const { return state_; }

 private:
  struct MatchedRule {
    std::shared_ptr<const RuleData> rule_data;
    unsigned specificity;
    CascadeOrigin cascade_origin;
    CascadeLayerLevel cascade_layer;
    unsigned style_sheet_index;
    uint16_t cascade_order;
  };

  template <typename RuleDataListType>
  void CollectMatchingRulesForList(
      const RuleDataListType& rules,
      CascadeOrigin,
      CascadeLayerLevel,
      const MatchRequest&);

  void DidMatchRule(std::shared_ptr<const RuleData>,
                   CascadeOrigin,
                   CascadeLayerLevel,
                   const MatchRequest&);

  template <class CSSRuleCollection>
  std::shared_ptr<CSSRule> FindStyleRule(CSSRuleCollection*, std::shared_ptr<StyleRule>);

  void AppendCSSOMWrapperForRule(std::shared_ptr<CSSRule>);

  void SortMatchedRules();
  void TransferMatchedRules();

  void AddMatchedRule(std::shared_ptr<const RuleData>,
                     unsigned specificity,
                     CascadeOrigin,
                     CascadeLayerLevel,
                     unsigned style_sheet_index,
                     const MatchRequest&);

  StyleResolverState& state_;
  Element* element_;
  PseudoId pseudo_element_id_;
  SelectorChecker selector_checker_;
  SelectorFilter* selector_filter_;
  
  std::vector<MatchedRule> matched_rules_;
  MatchResult result_;
  
  bool matching_from_scope_ = false;
  bool include_empty_rules_ = false;
  bool in_rightmost_compound_ = true;
  bool is_collecting_for_pseudo_element_ = false;
  bool is_ua_rule_ = false;
  uint16_t current_cascade_order_ = 0;
};

}  // namespace webf

#endif  // WEBF_CSS_ELEMENT_RULE_COLLECTOR_H
