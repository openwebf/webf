// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_nested_declarations_rule.h"

#include "core/css/css_property_value_set.h"
#include "core/css/style_rule.h"
#include "core/css/style_rule_css_style_declaration.h"
#include "core/css/style_rule_nested_declarations.h"
#include "foundation/native_string.h"
#include <cassert>

namespace webf {

CSSNestedDeclarationsRule::CSSNestedDeclarationsRule(
    std::shared_ptr<StyleRuleNestedDeclarations> nested_declarations_rule,
    CSSStyleSheet* parent)
    : CSSRule(parent), nested_declarations_rule_(std::move(nested_declarations_rule)) {}

// TODO: find out why this was LegacyCssStyleDeclaration
CSSStyleDeclaration* CSSNestedDeclarationsRule::style() const {
  if (!properties_cssom_wrapper_) {
    // TODO: StyleRuleCSSStyleDeclaration needs proper shared_ptr handling for properties
    // For now, return nullptr as the CSSOM wrapper would need architectural changes
    return nullptr;
  }
  return properties_cssom_wrapper_.get();
}

AtomicString CSSNestedDeclarationsRule::cssText() const {
  // "The CSSNestedDeclarations rule serializes as if its declaration block
  //  had been serialized directly".
  // https://drafts.csswg.org/css-nesting-1/#the-cssnestrule
  return AtomicString(nested_declarations_rule_->Properties().AsText());
}

void CSSNestedDeclarationsRule::Reattach(std::shared_ptr<StyleRuleBase> rule) {
  assert(rule);
  nested_declarations_rule_ = std::static_pointer_cast<StyleRuleNestedDeclarations>(rule);
  if (properties_cssom_wrapper_) {
    // TODO: properties_cssom_wrapper_->Reattach needs to be updated to work with the new architecture
  }
  if (style_rule_cssom_wrapper_) {
    style_rule_cssom_wrapper_->Reattach(
        std::shared_ptr<StyleRuleBase>(nested_declarations_rule_->InnerStyleRule()));
  }
}

CSSRule* CSSNestedDeclarationsRule::InnerCSSStyleRule() const {
  if (!style_rule_cssom_wrapper_) {
    // Create a CSSStyleRule for the inner style rule
    // Note: WebF may need a different approach here depending on CreateCSSOMWrapper implementation
    // style_rule_cssom_wrapper_ = nested_declarations_rule_->InnerStyleRule()->CreateCSSOMWrapper(...);
    // For now, return nullptr as this would need more infrastructure
  }
  return style_rule_cssom_wrapper_.get();
}

}  // namespace webf