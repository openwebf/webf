/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_counter_style_rule.h"

#include "../../foundation/string/string_builder.h"
#include "bindings/qjs/exception_state.h"
#include "core/css/css_style_sheet.h"
#include "core/css/css_value.h"
#include "core/css/style_rule.h"
#include "core/css/style_rule_counter_style.h"

namespace webf {

CSSCounterStyleRule::CSSCounterStyleRule(
    std::shared_ptr<StyleRuleCounterStyle> counter_style_rule,
    CSSStyleSheet* parent)
    : CSSRule(parent),
      counter_style_rule_(std::move(counter_style_rule)) {}

CSSCounterStyleRule::~CSSCounterStyleRule() = default;

AtomicString CSSCounterStyleRule::name() const {
  if (!counter_style_rule_)
    return AtomicString();
  return AtomicString(counter_style_rule_->GetName());
}

void CSSCounterStyleRule::setName(const AtomicString& name) {
  if (counter_style_rule_) {
    counter_style_rule_->SetName(name.GetString());
  }
}

AtomicString CSSCounterStyleRule::system() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetSystem();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setSystem(const AtomicString& system) {
  // TODO: Parse and set system value
}

AtomicString CSSCounterStyleRule::symbols() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetSymbols();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setSymbols(const AtomicString& symbols) {
  // TODO: Parse and set symbols value
}

AtomicString CSSCounterStyleRule::additiveSymbols() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetAdditiveSymbols();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setAdditiveSymbols(const AtomicString& additive_symbols) {
  // TODO: Parse and set additive symbols value
}

AtomicString CSSCounterStyleRule::range() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetRange();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setRange(const AtomicString& range) {
  // TODO: Parse and set range value
}

AtomicString CSSCounterStyleRule::prefix() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetPrefix();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setPrefix(const AtomicString& prefix) {
  // TODO: Parse and set prefix value
}

AtomicString CSSCounterStyleRule::suffix() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetSuffix();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setSuffix(const AtomicString& suffix) {
  // TODO: Parse and set suffix value
}

AtomicString CSSCounterStyleRule::pad() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetPad();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setPad(const AtomicString& pad) {
  // TODO: Parse and set pad value
}

AtomicString CSSCounterStyleRule::speakAs() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetSpeakAs();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setSpeakAs(const AtomicString& speak_as) {
  // TODO: Parse and set speak-as value
}

AtomicString CSSCounterStyleRule::fallback() const {
  if (!counter_style_rule_)
    return AtomicString();
  auto value = counter_style_rule_->GetFallback();
  return value ? AtomicString(value->CssText()) : AtomicString();
}

void CSSCounterStyleRule::setFallback(const AtomicString& fallback) {
  // TODO: Parse and set fallback value
}

AtomicString CSSCounterStyleRule::cssText() const {
  if (!counter_style_rule_)
    return AtomicString();

  StringBuilder result;
  result.Append("@counter-style ");
  result.Append(name().GetString());
  result.Append(" { ");
  
  // Add each descriptor if present
  if (!system().IsEmpty()) {
    result.Append("system: ");
    result.Append(system().GetString());
    result.Append("; ");
  }
  
  if (!symbols().IsEmpty()) {
    result.Append("symbols: ");
    result.Append(symbols().GetString());
    result.Append("; ");
  }
  
  if (!additiveSymbols().IsEmpty()) {
    result.Append("additive-symbols: ");
    result.Append(additiveSymbols().GetString());
    result.Append("; ");
  }
  
  if (!range().IsEmpty()) {
    result.Append("range: ");
    result.Append(range().GetString());
    result.Append("; ");
  }
  
  if (!prefix().IsEmpty()) {
    result.Append("prefix: ");
    result.Append(prefix().GetString());
    result.Append("; ");
  }
  
  if (!suffix().IsEmpty()) {
    result.Append("suffix: ");
    result.Append(suffix().GetString());
    result.Append("; ");
  }
  
  if (!pad().IsEmpty()) {
    result.Append("pad: ");
    result.Append(pad().GetString());
    result.Append("; ");
  }
  
  if (!speakAs().IsEmpty()) {
    result.Append("speak-as: ");
    result.Append(speakAs().GetString());
    result.Append("; ");
  }
  
  if (!fallback().IsEmpty()) {
    result.Append("fallback: ");
    result.Append(fallback().GetString());
    result.Append("; ");
  }
  
  result.Append("}");
  return AtomicString(result.ReleaseString());
}

void CSSCounterStyleRule::setCSSText(const AtomicString& css_text,
                                     ExceptionState& exception_state) {
  // TODO: Implement setCSSText
}

void CSSCounterStyleRule::Reattach(std::shared_ptr<StyleRuleBase> rule) {
  if (!rule || !rule->IsCounterStyleRule())
    return;
    
  counter_style_rule_ = std::static_pointer_cast<StyleRuleCounterStyle>(rule);
}

void CSSCounterStyleRule::TraceAfterDispatch(GCVisitor* visitor) const {
  // In WebF, we use shared_ptr, so no tracing needed
}

}  // namespace webf