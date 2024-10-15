/*
 * Copyright (C) 2012 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "style_rule_css_style_declaration.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/css/css_style_sheet.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/style_rule.h"

namespace webf {

StyleRuleCSSStyleDeclaration::StyleRuleCSSStyleDeclaration(std::shared_ptr<const MutableCSSPropertyValueSet> property_set_arg,
                                                           CSSRule* parent_rule)
    : PropertySetCSSStyleDeclaration(
          const_cast<Document*>(CSSStyleSheet::SingleOwnerDocument(parent_rule->parentStyleSheet()))
              ? const_cast<Document*>(CSSStyleSheet::SingleOwnerDocument(parent_rule->parentStyleSheet()))
                    ->GetExecutingContext()
              : nullptr,
          std::move(property_set_arg)),
      parent_rule_(parent_rule) {}

StyleRuleCSSStyleDeclaration::~StyleRuleCSSStyleDeclaration() = default;

void StyleRuleCSSStyleDeclaration::WillMutate() {
  if (parent_rule_ && parent_rule_->parentStyleSheet()) {
    parent_rule_->parentStyleSheet()->WillMutateRules();
  }
}

void StyleRuleCSSStyleDeclaration::DidMutate(MutationType type) {
  // Style sheet mutation needs to be signaled even if the change failed.
  // willMutateRules/didMutateRules must pair.
  if (parent_rule_ && parent_rule_->parentStyleSheet()) {
    parent_rule_->parentStyleSheet()->DidMutate(CSSStyleSheet::Mutation::kRules);
    std::shared_ptr<StyleSheetContents> parent_contents = parent_rule_->parentStyleSheet()->Contents();
    if (parent_rule_->GetType() == CSSRule::kStyleRule) {
      assert(false);
//      parent_contents->NotifyRuleChanged(static_cast<CSSStyleRule*>(parent_rule_.Get())->GetStyleRule());
    } else {
      parent_contents->NotifyDiffUnrepresentable();
    }
  }
}

CSSStyleSheet* StyleRuleCSSStyleDeclaration::ParentStyleSheet() const {
  return parent_rule_ ? parent_rule_->parentStyleSheet() : nullptr;
}

void StyleRuleCSSStyleDeclaration::Reattach(std::shared_ptr<MutableCSSPropertyValueSet> property_set) {
  property_set_ = property_set;
}

void StyleRuleCSSStyleDeclaration::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(parent_rule_);
  PropertySetCSSStyleDeclaration::Trace(visitor);
}

}  // namespace webf
