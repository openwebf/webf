// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_STYLE_RULE_COUNTER_STYLE_H_
#define WEBF_CORE_CSS_STYLE_RULE_COUNTER_STYLE_H_

#include "../../foundation/string/atomic_string.h"
#include "core/css/css_custom_ident_value.h"
#include "core/css/css_string_value.h"
#include "core/css/css_value_list.h"
#include "core/css/css_value_pair.h"
#include "core/css/style_rule.h"

namespace webf {

// https://drafts.csswg.org/css-counter-styles-3/#the-counter-style-rule
class StyleRuleCounterStyle final : public StyleRuleBase {
 public:
  StyleRuleCounterStyle(const AtomicString& name, std::shared_ptr<const CSSPropertyValueSet> properties);
  StyleRuleCounterStyle(const StyleRuleCounterStyle&);
  ~StyleRuleCounterStyle();

  StyleRuleCounterStyle& operator=(const StyleRuleCounterStyle&) = delete;

  const AtomicString& GetName() const { return name_; }
  void SetName(const AtomicString& name) { name_ = name; }

  // Descriptor getters
  std::shared_ptr<const CSSValue> GetSystem() const;
  std::shared_ptr<const CSSValue> GetNegative() const;
  std::shared_ptr<const CSSValue> GetPrefix() const;
  std::shared_ptr<const CSSValue> GetSuffix() const;
  std::shared_ptr<const CSSValue> GetRange() const;
  std::shared_ptr<const CSSValue> GetPad() const;
  std::shared_ptr<const CSSValue> GetFallback() const;
  std::shared_ptr<const CSSValue> GetSymbols() const;
  std::shared_ptr<const CSSValue> GetAdditiveSymbols() const;
  std::shared_ptr<const CSSValue> GetSpeakAs() const;

  // Descriptor setters
  void SetSystem(const CSSValue* value);
  void SetNegative(const CSSValue* value);
  void SetPrefix(const CSSValue* value);
  void SetSuffix(const CSSValue* value);
  void SetRange(const CSSValue* value);
  void SetPad(const CSSValue* value);
  void SetFallback(const CSSValue* value);
  void SetSymbols(const CSSValue* value);
  void SetAdditiveSymbols(const CSSValue* value);
  void SetSpeakAs(const CSSValue* value);

  // Check if this counter style has valid symbols for its system
  bool HasValidSymbols() const;

  CSSPropertyValueSet& MutableProperties() const;

  std::shared_ptr<StyleRuleCounterStyle> Copy() const {
    return std::make_shared<StyleRuleCounterStyle>(*this);
  }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSValue> GetDescriptorValue(StringView descriptor_name) const;
  void SetDescriptorValue(StringView descriptor_name, const CSSValue* value);

  AtomicString name_;
  mutable std::shared_ptr<const CSSPropertyValueSet> properties_;
};

template <>
struct DowncastTraits<StyleRuleCounterStyle> {
  static bool AllowFrom(const StyleRuleBase& rule) {
    return rule.IsCounterStyleRule();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_RULE_COUNTER_STYLE_H_
