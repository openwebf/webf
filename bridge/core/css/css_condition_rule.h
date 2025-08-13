// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_CONDITION_RULE_H_
#define WEBF_CORE_CSS_CSS_CONDITION_RULE_H_

#include "core/css/css_grouping_rule.h"
#include "foundation/string/wtf_string.h"

namespace webf {

class StyleRuleCondition;

class CSSConditionRule : public CSSGroupingRule {
 public:
  ~CSSConditionRule() override;

  // Prefer ConditionTextInternal for internal use.
  virtual String conditionText() const;
  virtual String ConditionTextInternal() const;

 protected:
  CSSConditionRule(std::shared_ptr<StyleRuleCondition> condition_rule, CSSStyleSheet* parent);
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_CONDITION_RULE_H_