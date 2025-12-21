/*
 * Copyright (C) 2011 Adobe Systems Incorporated. All rights reserved.
 * Copyright (C) 2012 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer.
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_grouping_rule.h"

#include "../../foundation/string/string_builder.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/exception_state.h"
#include "core/css/css_rule_list.h"
#include "core/css/css_style_sheet.h"
#include "core/executing_context.h"

namespace webf {

CSSGroupingRule::CSSGroupingRule(std::shared_ptr<StyleRuleGroup> group_rule,
                                 CSSStyleSheet* parent)
    : CSSRule(parent), group_rule_(group_rule) {}

CSSGroupingRule::~CSSGroupingRule() = default;

void CSSGroupingRule::Reattach(std::shared_ptr<StyleRuleBase> rule) {
  group_rule_ = std::static_pointer_cast<StyleRuleGroup>(rule);
  
  // Clear CSSOM wrappers
  child_rule_cssom_wrappers_.clear();
  rule_list_cssom_wrapper_ = nullptr;
}

CSSRuleList* CSSGroupingRule::cssRules() const {
  // For now, always create a new rule list to avoid Member<> issues
  return MakeGarbageCollected<LiveCSSRuleList<CSSGroupingRule>>(
      const_cast<CSSGroupingRule*>(this));
}

unsigned CSSGroupingRule::insertRule(const ExecutingContext* context,
                                     const String& rule,
                                     unsigned index,
                                     ExceptionState& exception_state) {
  // TODO: Implement insertRule for dynamic rule insertion
  // This would involve parsing the rule string and inserting it into group_rule_
  return 0;
}

void CSSGroupingRule::deleteRule(unsigned index, ExceptionState& exception_state) {
  // TODO: Implement deleteRule for dynamic rule deletion
}

unsigned CSSGroupingRule::length() const {
  return group_rule_ ? group_rule_->ChildRules().size() : 0;
}

CSSRule* CSSGroupingRule::Item(unsigned index, bool trigger_use_counters) const {
  if (index >= length())
    return nullptr;

  // Ensure we have CSSOM wrappers for all child rules
  if (child_rule_cssom_wrappers_.size() != length()) {
    child_rule_cssom_wrappers_.resize(length());
  }

  if (!child_rule_cssom_wrappers_[index]) {
    CSSRule* wrapper = group_rule_->ChildRules()[index]->CreateCSSOMWrapper(index, parentStyleSheet());
    if (wrapper) {
      child_rule_cssom_wrappers_[index] = wrapper;
    }
  }

  return child_rule_cssom_wrappers_[index].Get();
}

void CSSGroupingRule::AppendCSSTextForItems(StringBuilder& result) const {
  result.Append(" {\n"_s);
  for (unsigned i = 0; i < length(); ++i) {
    result.Append("  "_s);
    CSSRule* item = Item(i, false);
    if (item) {
      result.Append(item->cssText().GetString());
    }
    result.Append("\n"_s);
  }
  result.Append("}"_s);
}

void CSSGroupingRule::Trace(GCVisitor* visitor) const {
  for (auto& child_rule : child_rule_cssom_wrappers_) {
    visitor->TraceMember(child_rule);
  }
  visitor->TraceMember(rule_list_cssom_wrapper_);
  CSSRule::Trace(visitor);
}

}  // namespace webf
