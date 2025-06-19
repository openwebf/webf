// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_STYLE_RULE_NESTED_DECLARATIONS_H_
#define WEBF_CORE_CSS_STYLE_RULE_NESTED_DECLARATIONS_H_

#include "core/css/parser/css_nesting_type.h"
#include "core/css/style_rule.h"
#include "foundation/casting.h"

namespace webf {

class CSSPropertyValueSet;
class MutableCSSPropertyValueSet;
class StyleRule;

// A "nested declarations rule" represents a "bare" list of declarations
// that appears in a nesting context. This rule exists to make it possible
// to mix nested rules and bare declarations without reordering things.
//
// StyleRuleNestedDeclarations has an inner, non-observable StyleRule
// which is added to the RuleSet during RuleSet::AddChildRules.
// This inner StyleRule contains the "bare" list of declarations,
// and its selector list is a *copy* of the parent rule's selector list
// (for regular nesting), or a :where(:scope) selector (for @scope).
//
// https://drafts.csswg.org/css-nesting-1/#nested-declarations-rule
class StyleRuleNestedDeclarations : public StyleRuleBase {
 public:
  StyleRuleNestedDeclarations(CSSNestingType nesting_type, std::shared_ptr<StyleRule> style_rule)
      : StyleRuleBase(kNestedDeclarations),
        nesting_type_(nesting_type),
        style_rule_(std::move(style_rule)) {}

  StyleRuleNestedDeclarations(const StyleRuleNestedDeclarations& o)
      : StyleRuleBase(o),
        nesting_type_(o.nesting_type_),
        style_rule_(o.style_rule_->Copy()) {}

  CSSNestingType NestingType() const { return nesting_type_; }
  StyleRule* InnerStyleRule() const { return style_rule_.get(); }

  // Properties of the inner StyleRule.
  const CSSPropertyValueSet& Properties() const {
    return style_rule_->Properties();
  }

  MutableCSSPropertyValueSet& MutableProperties() const {
    return style_rule_->MutableProperties();
  }

  std::shared_ptr<StyleRuleNestedDeclarations> Copy() const {
    return std::make_shared<StyleRuleNestedDeclarations>(*this);
  }

 private:
  // Whether this StyleRuleNestedDeclarations rule is a child of
  // a regular style rule (kNesting) or an @scope rule (kScope).
  // In the kNesting case the selector list held by `style_rule_` is a deep
  // copy of the outer selector list, but in the kScope case, it's simply
  // the :where(:scope) selector. We need to differentiate between these two
  // cases during re-nesting; see StyleRuleBase::Renest.
  CSSNestingType nesting_type_;
  std::shared_ptr<StyleRule> style_rule_;
};

template <>
struct DowncastTraits<StyleRuleNestedDeclarations> {
  static bool AllowFrom(const StyleRuleBase& rule) {
    return rule.IsNestedDeclarationsRule();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_RULE_NESTED_DECLARATIONS_H_