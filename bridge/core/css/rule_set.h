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

#ifndef WEBF_CSS_RULE_SET_H
#define WEBF_CSS_RULE_SET_H

#include <memory>
#include <unordered_map>
#include <vector>
#include "core/css/css_selector.h"
#include "core/css/rule_feature_set.h"
#include "core/css/style_rule.h"
#include "core/dom/qualified_name.h"
#include "foundation/macros.h"

namespace webf {

// Flags for rule processing
enum AddRuleFlags {
  kRuleHasNoSpecialState = 0,
  kRuleHasDocumentSecurityOrigin = 1 << 0,
  kRuleIsChildRule = 1 << 1,
};

class CSSSelector;
class MediaQueryEvaluator;
class StyleSheetContents;

// Rule data contains a style rule and metadata for efficient matching
class RuleData {
  WEBF_DISALLOW_NEW();

 public:
  RuleData(std::shared_ptr<StyleRule>, unsigned selector_index, unsigned position);
  ~RuleData() = default;

  const CSSSelector& Selector() const { 
    return rule_->SelectorAt(selector_index_); 
  }
  
  std::shared_ptr<StyleRule> Rule() const { return rule_; }
  unsigned SelectorIndex() const { return selector_index_; }
  unsigned Position() const { return position_; }
  unsigned SelectorSpecificity() const { return specificity_; }

  // Prefilter metadata for rightmost compound's type selector.
  bool HasRightmostType() const { return has_rightmost_type_; }
  const AtomicString& RightmostTag() const { return rightmost_tag_; }

 private:
  std::shared_ptr<StyleRule> rule_;
  unsigned selector_index_;
  unsigned position_;  // Position in the original stylesheet
  unsigned specificity_;

  // Whether the rightmost compound has a type selector and its localName.
  bool has_rightmost_type_ = false;
  AtomicString rightmost_tag_;
};

// Container for rules organized by selector characteristics
class RuleSet {
  WEBF_DISALLOW_NEW();

 public:
  RuleSet();
  ~RuleSet();

  // Add rules from a stylesheet
  void AddRulesFromSheet(std::shared_ptr<StyleSheetContents>,
                        const MediaQueryEvaluator&,
                        AddRuleFlags = kRuleHasNoSpecialState);

  // Add a single rule
  void AddRule(std::shared_ptr<StyleRule>, 
              unsigned selector_index,
              AddRuleFlags = kRuleHasNoSpecialState);

  // Add style rule
  void AddStyleRule(std::shared_ptr<StyleRule>, AddRuleFlags);

  // Get rules by category
  const std::vector<std::shared_ptr<RuleData>>& UniversalRules() const { 
    return universal_rules_; 
  }
  
  const std::vector<std::shared_ptr<RuleData>>& IdRules(
      const AtomicString& id) const;
  
  const std::vector<std::shared_ptr<RuleData>>& ClassRules(
      const AtomicString& class_name) const;
  
  const std::vector<std::shared_ptr<RuleData>>& TagRules(
      const AtomicString& tag_name) const;
  
  const std::vector<std::shared_ptr<RuleData>>& ShadowPseudoElementRules(
      const AtomicString& pseudo) const;

  // Get features
  const RuleFeatureSet& Features() const { return features_; }

  // Statistics
  unsigned RuleCount() const { return rule_count_; }
  
  void CompactRulesIfNeeded();

 private:
  using RuleDataVector = std::vector<std::shared_ptr<RuleData>>;
  
  // Find the appropriate list for a selector
  RuleDataVector* FindBestRuleSetForSelector(const CSSSelector&);
  
  void AddToRuleSet(const AtomicString& key,
                   std::unordered_map<AtomicString, std::unique_ptr<RuleDataVector>, AtomicString::KeyHasher>&,
                   std::shared_ptr<RuleData>);

  // Rules organized by selector type for efficient matching
  RuleDataVector universal_rules_;
  std::unordered_map<AtomicString, std::unique_ptr<RuleDataVector>, AtomicString::KeyHasher> id_rules_;
  std::unordered_map<AtomicString, std::unique_ptr<RuleDataVector>, AtomicString::KeyHasher> class_rules_;
  std::unordered_map<AtomicString, std::unique_ptr<RuleDataVector>, AtomicString::KeyHasher> tag_rules_;
  std::unordered_map<AtomicString, std::unique_ptr<RuleDataVector>, AtomicString::KeyHasher> shadow_pseudo_element_rules_;
  
  // Link pseudo class rules
  RuleDataVector link_pseudo_class_rules_;
  
  // Focus pseudo class rules
  RuleDataVector focus_pseudo_class_rules_;
  
  // Selector features for optimization
  RuleFeatureSet features_;
  
  // Statistics
  unsigned rule_count_ = 0;
  
  // Empty rule data vector for returning when no rules match
  static const RuleDataVector empty_rule_data_vector_;
};

}  // namespace webf

#endif  // WEBF_CSS_RULE_SET_H
