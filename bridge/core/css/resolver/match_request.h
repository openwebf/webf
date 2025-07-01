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
        style_sheet_index_(style_sheet_index) {
    if (rule_set) {
      rule_sets_.push_back(rule_set);
    }
  }
  
  void AddRuleSet(std::shared_ptr<RuleSet> rule_set) {
    if (rule_set) {
      rule_sets_.push_back(rule_set);
    }
  }

  const std::vector<std::shared_ptr<RuleSet>>& GetRuleSets() const {
    return rule_sets_;
  }

  CascadeOrigin GetOrigin() const { return origin_; }
  unsigned GetStyleSheetIndex() const { return style_sheet_index_; }

 private:
  std::vector<std::shared_ptr<RuleSet>> rule_sets_;
  CascadeOrigin origin_ = CascadeOrigin::kAuthor;
  unsigned style_sheet_index_ = 0;
};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_MATCH_REQUEST_H