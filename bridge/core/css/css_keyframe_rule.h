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

#ifndef WEBF_CORE_CSS_CSS_KEYFRAME_RULE_H_
#define WEBF_CORE_CSS_CSS_KEYFRAME_RULE_H_

#include "core/css/css_rule.h"
#include "core/css/style_rule_keyframe.h"

namespace webf {

class CSSKeyframesRule;
class CSSStyleDeclaration;
class ExceptionState;
class KeyframeStyleRuleCSSStyleDeclaration;

class CSSKeyframeRule final : public CSSRule {
  DEFINE_WRAPPERTYPEINFO();

 public:
  CSSKeyframeRule(std::shared_ptr<StyleRuleKeyframe>, CSSKeyframesRule* parent);
  ~CSSKeyframeRule() override;

  AtomicString cssText() const override { return AtomicString(keyframe_->CssText()); }
  void Reattach(std::shared_ptr<StyleRuleBase>) override;

  AtomicString keyText() const { return AtomicString(keyframe_->KeyText()); }
  void setKeyText(const ExecutingContext*, const AtomicString&, ExceptionState&);

  CSSStyleDeclaration* style() const;

  void Trace(GCVisitor*) const override;

 private:
  CSSRule::Type GetType() const override { return kKeyframeRule; }

  std::shared_ptr<StyleRuleKeyframe> keyframe_;
  mutable Member<KeyframeStyleRuleCSSStyleDeclaration> properties_cssom_wrapper_;

  friend class CSSKeyframesRule;
};

template <>
struct DowncastTraits<CSSKeyframeRule> {
  static bool AllowFrom(const CSSRule& rule) { return rule.GetType() == CSSRule::kKeyframeRule; }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_KEYFRAME_RULE_H_
