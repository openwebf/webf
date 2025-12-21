// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_LAYER_STATEMENT_RULE_H_
#define WEBF_CORE_CSS_CSS_LAYER_STATEMENT_RULE_H_

#include "core/css/css_rule.h"
#include "foundation/casting.h"

namespace webf {

class StyleRuleLayerStatement;

class CSSLayerStatementRule final : public CSSRule {
 public:
  CSSLayerStatementRule(std::shared_ptr<StyleRuleLayerStatement>, CSSStyleSheet*);
  ~CSSLayerStatementRule() override;

  std::vector<String> nameList() const;

  void Reattach(std::shared_ptr<StyleRuleBase>) override;
  AtomicString cssText() const override;

 private:
  CSSRule::Type GetType() const override { return kLayerStatementRule; }
  
  std::shared_ptr<StyleRuleLayerStatement> rule_;
};

template <>
struct DowncastTraits<CSSLayerStatementRule> {
  static bool AllowFrom(const CSSRule& rule) {
    return rule.GetType() == CSSRule::kLayerStatementRule;
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_LAYER_STATEMENT_RULE_H_
