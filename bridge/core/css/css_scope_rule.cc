// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_scope_rule.h"
#include "core/css/style_rule.h"
#include "core/css/css_style_sheet.h"
#include "foundation/native_string.h"

namespace webf {

CSSScopeRule::CSSScopeRule(std::shared_ptr<StyleRuleScope> scope_rule, CSSStyleSheet* parent_sheet)
    : CSSGroupingRule(std::static_pointer_cast<StyleRuleGroup>(scope_rule), parent_sheet) {}

CSSScopeRule::~CSSScopeRule() = default;

String CSSScopeRule::PreludeText() const {
  const StyleRuleScope& scope_rule = GetStyleRuleScope();
  const StyleScope& style_scope = scope_rule.GetStyleScope();
  StringBuilder prelude;
  
  if (style_scope.From()) {
    // TODO: Convert selector to string
    prelude.Append("("_s);
    // Need proper selector serialization here
    prelude.Append(")"_s);
  }
  
  if (style_scope.To()) {
    if (!prelude.IsEmpty()) {
      prelude.Append(" to "_s);
    } else {
      prelude.Append("to "_s);
    }
    prelude.Append("("_s);
    // Need proper selector serialization here  
    prelude.Append(")"_s);
  }
  
  return prelude.ReleaseString();
}

AtomicString CSSScopeRule::cssText() const {
  StringBuilder result;
  result.Append("@scope"_s);
  String prelude = PreludeText();
  
  if (!prelude.IsEmpty()) {
    result.Append(" "_s);
    result.Append(prelude);
  }
  
  AppendCSSTextForItems(result);
  
  return AtomicString(result.ReleaseString());
}

String CSSScopeRule::start() const {
  const StyleScope& style_scope = GetStyleRuleScope().GetStyleScope();
  if (style_scope.From()) {
    // TODO: Implement proper selector serialization
    return "()"_s;
  }
  return String::EmptyString();
}

String CSSScopeRule::end() const {
  const StyleScope& style_scope = GetStyleRuleScope().GetStyleScope();
  if (style_scope.To()) {
    // TODO: Implement proper selector serialization
    return "()"_s;
  }
  return String::EmptyString();
}

void CSSScopeRule::SetPreludeText(const ExecutingContext* context, const String& text) {
  // TODO: Implement prelude text parsing and setting
  // This would require parsing the scope prelude text and updating the underlying StyleRuleScope
}

StyleRuleScope& CSSScopeRule::GetStyleRuleScope() {
  return static_cast<StyleRuleScope&>(*group_rule_);
}

const StyleRuleScope& CSSScopeRule::GetStyleRuleScope() const {
  return static_cast<const StyleRuleScope&>(*group_rule_);
}

}  // namespace webf