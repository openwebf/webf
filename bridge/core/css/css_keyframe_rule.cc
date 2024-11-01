/*
 * Copyright (C) 2007, 2008, 2012 Apple Inc. All rights reserved.
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

#include "css_keyframe_rule.h"
#include "core/css/css_keyframes_rule.h"
#include "core/css/css_rule.h"
#include "core/css/css_style_sheet.h"
#include "core/css/keyframe_style_rule_css_style_declaration.h"
#include "core/css/style_sheet_contents.h"

namespace webf {

CSSKeyframeRule::CSSKeyframeRule(std::shared_ptr<StyleRuleKeyframe> keyframe, CSSKeyframesRule* parent)
    : CSSRule(nullptr), keyframe_(keyframe) {
  SetParentRule(parent);
}

CSSKeyframeRule::~CSSKeyframeRule() = default;

void CSSKeyframeRule::setKeyText(const ExecutingContext* execution_context,
                                 const AtomicString& key_text,
                                 ExceptionState& exception_state) {
  CSSStyleSheet::RuleMutationScope rule_mutation_scope(this);

  if (!keyframe_->SetKeyText(execution_context, key_text.ToStdString(ctx()))) {
    exception_state.ThrowException(ctx(), ErrorType::SyntaxError,
                                   "The key '" + key_text.ToStdString(ctx()) + "' is invalid and cannot be parsed");
    return;
  }

  if (auto* parent = To<CSSKeyframesRule>(parentRule())) {
    if (parentRule()->parentStyleSheet()) {
      parentRule()->parentStyleSheet()->Contents()->NotifyDiffUnrepresentable();
    }
    parent->StyleChanged();
  }
}

CSSStyleDeclaration* CSSKeyframeRule::style() const {
  if (!properties_cssom_wrapper_) {
    properties_cssom_wrapper_ = MakeGarbageCollected<KeyframeStyleRuleCSSStyleDeclaration>(
        std::const_pointer_cast<MutableCSSPropertyValueSet>(keyframe_->MutableProperties()),
        const_cast<CSSKeyframeRule*>(this));
  }
  return properties_cssom_wrapper_.Get();
}

void CSSKeyframeRule::Reattach(std::shared_ptr<StyleRuleBase>) {
  // No need to reattach, the underlying data is shareable on mutation.
  NOTREACHED_IN_MIGRATION();
}

void CSSKeyframeRule::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(properties_cssom_wrapper_);
  CSSRule::Trace(visitor);
}

}  // namespace webf
