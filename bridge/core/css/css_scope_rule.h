// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_SCOPE_RULE_H_
#define WEBF_CORE_CSS_CSS_SCOPE_RULE_H_

#include "core/css/css_grouping_rule.h"
#include "core/executing_context.h"
#include "foundation/casting.h"
#include "foundation/string/wtf_string.h"

namespace webf {

class StyleRuleScope;

class CSSScopeRule final : public CSSGroupingRule {
 public:
  CSSScopeRule(std::shared_ptr<StyleRuleScope>, CSSStyleSheet*);
  ~CSSScopeRule() override;

  String PreludeText() const;
  AtomicString cssText() const override;
  String start() const;
  String end() const;

  void SetPreludeText(const ExecutingContext*, const String&);
  StyleRuleScope& GetStyleRuleScope();
  const StyleRuleScope& GetStyleRuleScope() const;

 private:
  CSSRule::Type GetType() const override { return kScopeRule; }
};

template <>
struct DowncastTraits<CSSScopeRule> {
  static bool AllowFrom(const CSSRule& rule) {
    return rule.GetType() == CSSRule::kScopeRule;
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_SCOPE_RULE_H_