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

#ifndef WEBF_CORE_CSS_CSS_KEYFRAMES_RULE_H_
#define WEBF_CORE_CSS_CSS_KEYFRAMES_RULE_H_

#include "core/css/css_rule.h"
#include "core/css/style_rule.h"
#include "core/css/css_rule_list.h"
#include "core/css/css_keyframe_rule.h"

namespace webf {


class CascadeLayer;
class CSSRuleList;
class CSSKeyframeRule;
class StyleRuleKeyframe;
class CSSParserContext;

class StyleRuleKeyframes final : public StyleRuleBase {
 public:
  StyleRuleKeyframes();
  explicit StyleRuleKeyframes(const StyleRuleKeyframes&);
  ~StyleRuleKeyframes();

  const std::vector<std::shared_ptr<StyleRuleKeyframe>>& Keyframes() const {
    return keyframes_;
  }

  void ParserAppendKeyframe(std::shared_ptr<StyleRuleKeyframe>);
  void WrapperAppendKeyframe(std::shared_ptr<StyleRuleKeyframe>);
  void WrapperRemoveKeyframe(unsigned);

  std::string GetName() const { return name_; }
  void SetName(const std::string& name) { name_ = name; }

  bool IsVendorPrefixed() const { return is_prefixed_; }
  void SetVendorPrefixed(bool is_prefixed) { is_prefixed_ = is_prefixed; }

  int FindKeyframeIndex(std::shared_ptr<CSSParserContext> context, const std::string& key) const;

  std::shared_ptr<StyleRuleKeyframes> Copy() const {
    return std::make_shared<StyleRuleKeyframes>(*this);
  }

  void SetCascadeLayer(std::shared_ptr<const CascadeLayer> layer) { layer_ = layer; }
  const CascadeLayer* GetCascadeLayer() const { return layer_.get(); }

  void TraceAfterDispatch(GCVisitor*) const;

  void StyleChanged() { version_++; }
  unsigned Version() const { return version_; }

 private:
  std::shared_ptr<const CascadeLayer> layer_;
  std::vector<std::shared_ptr<StyleRuleKeyframe>> keyframes_;
  std::string name_;
  unsigned version_ : 31;
  unsigned is_prefixed_ : 1;
};

template <>
struct DowncastTraits<StyleRuleKeyframes> {
  static bool AllowFrom(const StyleRuleBase& rule) {
    return rule.IsKeyframesRule();
  }
};

class CSSKeyframesRule final : public CSSRule {
  DEFINE_WRAPPERTYPEINFO();

 public:
  CSSKeyframesRule(StyleRuleKeyframes*, CSSStyleSheet* parent);
  ~CSSKeyframesRule() override;

  StyleRuleKeyframes* Keyframes() { return keyframes_rule_.get(); }

  AtomicString cssText() const override;
  void Reattach(std::shared_ptr<StyleRuleBase>) override;

  AtomicString name() const { return AtomicString(keyframes_rule_->GetName()); }
  void setName(const AtomicString&);

  CSSRuleList* cssRules() const override;

  void appendRule(const ExecutingContext*, const std::string& rule);
  void deleteRule(const ExecutingContext*, const std::string& key);
  CSSKeyframeRule* findRule(const ExecutingContext*, const std::string& key);

  // For IndexedGetter and CSSRuleList.
  unsigned length() const;
  CSSKeyframeRule* Item(unsigned index, bool trigger_use_counters = true) const;
  CSSKeyframeRule* AnonymousIndexedGetter(unsigned index) const;

  bool IsVendorPrefixed() const { return is_prefixed_; }
  void SetVendorPrefixed(bool is_prefixed) { is_prefixed_ = is_prefixed; }

  void StyleChanged() { keyframes_rule_->StyleChanged(); }

  void Trace(GCVisitor*) const override;

 private:
  CSSRule::Type GetType() const override { return kKeyframesRule; }

  std::shared_ptr<StyleRuleKeyframes> keyframes_rule_;
  mutable std::vector<Member<CSSKeyframeRule>> child_rule_cssom_wrappers_;
  mutable Member<CSSRuleList> rule_list_cssom_wrapper_;
  bool is_prefixed_;
};

template <>
struct DowncastTraits<CSSKeyframesRule> {
  static bool AllowFrom(const CSSRule& rule) {
    return rule.GetType() == CSSRule::kKeyframesRule;
  }
};


}

#endif  // WEBF_CORE_CSS_CSS_KEYFRAMES_RULE_H_
