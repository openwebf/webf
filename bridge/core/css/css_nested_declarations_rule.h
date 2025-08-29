// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_NESTED_DECLARATIONS_RULE_H_
#define WEBF_CORE_CSS_CSS_NESTED_DECLARATIONS_RULE_H_

#include "core/css/css_rule.h"
#include "foundation/casting.h"
#include <memory>

namespace webf {

class StyleRuleNestedDeclarations;
class StyleRuleCSSStyleDeclaration;
class CSSStyleDeclaration;

// https://drafts.csswg.org/css-nesting-1/#the-cssnestrule
class CSSNestedDeclarationsRule final : public CSSRule {
 public:
  CSSNestedDeclarationsRule(std::shared_ptr<StyleRuleNestedDeclarations>, CSSStyleSheet* parent);

  // Note that a CSSNestedDeclarationsRule serializes without any prelude
  // (i.e. selector list), and also without any brackets surrounding the body.
  AtomicString cssText() const override;
  void Reattach(std::shared_ptr<StyleRuleBase>) override;

  CSSStyleDeclaration* style() const;

  StyleRuleNestedDeclarations* NestedDeclarationsRule() const {
    return nested_declarations_rule_.get();
  }

  CSSRule* InnerCSSStyleRule() const;

  CSSRule::Type GetType() const override { return kNestedDeclarationsRule; }

 private:

  std::shared_ptr<StyleRuleNestedDeclarations> nested_declarations_rule_;
  mutable std::shared_ptr<StyleRuleCSSStyleDeclaration> properties_cssom_wrapper_;
  mutable std::shared_ptr<CSSRule> style_rule_cssom_wrapper_;
};

template <>
struct DowncastTraits<CSSNestedDeclarationsRule> {
  static bool AllowFrom(const CSSRule& rule) {
    return rule.GetType() == CSSRule::kNestedDeclarationsRule;
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_NESTED_DECLARATIONS_RULE_H_