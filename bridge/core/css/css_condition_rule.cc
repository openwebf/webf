// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_condition_rule.h"

#include "core/css/style_rule.h"

namespace webf {

CSSConditionRule::CSSConditionRule(std::shared_ptr<StyleRuleCondition> condition_rule,
                                   CSSStyleSheet* parent)
    : CSSGroupingRule(std::static_pointer_cast<StyleRuleGroup>(condition_rule), parent) {}

CSSConditionRule::~CSSConditionRule() = default;

String CSSConditionRule::conditionText() const {
  return ConditionTextInternal();
}

String CSSConditionRule::ConditionTextInternal() const {
  return To<StyleRuleCondition>(group_rule_.get())->ConditionText();
}

}  // namespace webf