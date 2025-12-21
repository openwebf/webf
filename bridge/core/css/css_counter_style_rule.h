/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_COUNTER_STYLE_RULE_H_
#define WEBF_CORE_CSS_CSS_COUNTER_STYLE_RULE_H_

#include "core/css/css_rule.h"
#include <memory>

namespace webf {

class CSSStyleDeclaration;
class StyleRuleCounterStyle;
class StyleRuleCSSStyleDeclaration;

class CSSCounterStyleRule : public CSSRule {
 public:
  CSSCounterStyleRule(std::shared_ptr<StyleRuleCounterStyle> counter_style_rule,
                      CSSStyleSheet* parent);
  ~CSSCounterStyleRule() override;

  AtomicString cssText() const override;
  void setCSSText(const AtomicString&, ExceptionState&);
  
  CSSRule::Type GetType() const override { return CSSRule::Type::kCounterStyleRule; }

  AtomicString name() const;
  void setName(const AtomicString& name);

  AtomicString system() const;
  void setSystem(const AtomicString& system);

  AtomicString symbols() const;
  void setSymbols(const AtomicString& symbols);

  AtomicString additiveSymbols() const;
  void setAdditiveSymbols(const AtomicString& additive_symbols);

  AtomicString range() const;
  void setRange(const AtomicString& range);

  AtomicString prefix() const;
  void setPrefix(const AtomicString& prefix);

  AtomicString suffix() const;
  void setSuffix(const AtomicString& suffix);

  AtomicString pad() const;
  void setPad(const AtomicString& pad);

  AtomicString speakAs() const;
  void setSpeakAs(const AtomicString& speak_as);

  AtomicString fallback() const;
  void setFallback(const AtomicString& fallback);

  void Reattach(std::shared_ptr<StyleRuleBase>) override;

 private:
  std::shared_ptr<StyleRuleCounterStyle> counter_style_rule_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_COUNTER_STYLE_RULE_H_
