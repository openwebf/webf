/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_RESOLVER_MATCH_REQUEST_H
#define WEBF_CSS_RESOLVER_MATCH_REQUEST_H

#include <memory>
#include <vector>
#include "core/css/match_result.h"
#include "core/css/rule_set.h"
#include "foundation/macros.h"

namespace webf {

// Encapsulates a request to match CSS rules against an element
class MatchRequest {
  WEBF_STACK_ALLOCATED();

 public:
  MatchRequest() = default;
  
  explicit MatchRequest(std::shared_ptr<RuleSet> rule_set,
                       CascadeOrigin origin = CascadeOrigin::kAuthor,
                       unsigned style_sheet_index = 0)
      : origin_(origin), 
        style_sheet_index_(style_sheet_index),
        primary_rule_set_(std::move(rule_set)) {}
  
  void AddRuleSet(std::shared_ptr<RuleSet> rule_set) {
    if (!rule_set) {
      return;
    }
    if (!primary_rule_set_) {
      primary_rule_set_ = std::move(rule_set);
      return;
    }
    additional_rule_sets_.push_back(std::move(rule_set));
  }

  template <typename Callback>
  void ForEachRuleSet(Callback&& callback) const {
    if (primary_rule_set_) {
      callback(primary_rule_set_);
    }
    for (const auto& rule_set : additional_rule_sets_) {
      if (rule_set) {
        callback(rule_set);
      }
    }
  }

  CascadeOrigin GetOrigin() const { return origin_; }
  unsigned GetStyleSheetIndex() const { return style_sheet_index_; }

 private:
  // Most callers match against a single RuleSet. Keep that in an inline slot
  // to avoid per-request heap allocation (std::vector would allocate even for
  // a single entry). Additional RuleSets are stored in a side vector.
  std::shared_ptr<RuleSet> primary_rule_set_;
  std::vector<std::shared_ptr<RuleSet>> additional_rule_sets_;
  CascadeOrigin origin_ = CascadeOrigin::kAuthor;
  unsigned style_sheet_index_ = 0;
};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_MATCH_REQUEST_H
