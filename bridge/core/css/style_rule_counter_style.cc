// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/style_rule_counter_style.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_identifier_value.h"

namespace webf {

StyleRuleCounterStyle::StyleRuleCounterStyle(const AtomicString& name,
                                             std::shared_ptr<const CSSPropertyValueSet> properties)
    : StyleRuleBase(kCounterStyle),
      name_(name),
      properties_(properties) {}

StyleRuleCounterStyle::StyleRuleCounterStyle(const StyleRuleCounterStyle& other)
    : StyleRuleBase(other),
      name_(other.name_),
      properties_(other.properties_->MutableCopy()) {}

StyleRuleCounterStyle::~StyleRuleCounterStyle() = default;

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetSystem() const {
  return GetDescriptorValue("system"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetNegative() const {
  return GetDescriptorValue("negative"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetPrefix() const {
  return GetDescriptorValue("prefix"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetSuffix() const {
  return GetDescriptorValue("suffix"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetRange() const {
  return GetDescriptorValue("range"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetPad() const {
  return GetDescriptorValue("pad"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetFallback() const {
  return GetDescriptorValue("fallback"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetSymbols() const {
  return GetDescriptorValue("symbols"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetAdditiveSymbols() const {
  return GetDescriptorValue("additive-symbols"_sv);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetSpeakAs() const {
  return GetDescriptorValue("speak-as"_sv);
}

void StyleRuleCounterStyle::SetSystem(const CSSValue* value) {
  SetDescriptorValue("system"_sv, value);
}

void StyleRuleCounterStyle::SetNegative(const CSSValue* value) {
  SetDescriptorValue("negative"_sv, value);
}

void StyleRuleCounterStyle::SetPrefix(const CSSValue* value) {
  SetDescriptorValue("prefix"_sv, value);
}

void StyleRuleCounterStyle::SetSuffix(const CSSValue* value) {
  SetDescriptorValue("suffix"_sv, value);
}

void StyleRuleCounterStyle::SetRange(const CSSValue* value) {
  SetDescriptorValue("range"_sv, value);
}

void StyleRuleCounterStyle::SetPad(const CSSValue* value) {
  SetDescriptorValue("pad"_sv, value);
}

void StyleRuleCounterStyle::SetFallback(const CSSValue* value) {
  SetDescriptorValue("fallback"_sv, value);
}

void StyleRuleCounterStyle::SetSymbols(const CSSValue* value) {
  SetDescriptorValue("symbols"_sv, value);
}

void StyleRuleCounterStyle::SetAdditiveSymbols(const CSSValue* value) {
  SetDescriptorValue("additive-symbols"_sv, value);
}

void StyleRuleCounterStyle::SetSpeakAs(const CSSValue* value) {
  SetDescriptorValue("speak-as"_sv, value);
}

bool StyleRuleCounterStyle::HasValidSymbols() const {
  auto system = GetSystem();
  if (!system) {
    // Default system is 'symbolic'
    auto symbols = GetSymbols();
    return symbols && symbols->IsValueList() && 
           DynamicTo<CSSValueList>(*symbols)->length() > 0;
  }

  auto* ident = DynamicTo<CSSIdentifierValue>(*system);
  if (!ident) {
    return true; // extends case
  }

  switch (ident->GetValueID()) {
    case CSSValueID::kCyclic:
    case CSSValueID::kFixed:
    case CSSValueID::kSymbolic:
    case CSSValueID::kAlphabetic:
    case CSSValueID::kNumeric: {
      auto symbols = GetSymbols();
      return symbols && symbols->IsValueList() && 
             DynamicTo<CSSValueList>(*symbols)->length() > 0;
    }
    case CSSValueID::kAdditive: {
      auto additive_symbols = GetAdditiveSymbols();
      return additive_symbols && additive_symbols->IsValueList() && 
             DynamicTo<CSSValueList>(*additive_symbols)->length() > 0;
    }
    default:
      return true;
  }
}

CSSPropertyValueSet& StyleRuleCounterStyle::MutableProperties() const {
  if (!properties_) {
    properties_ = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  }
  // Use const_cast to return non-const reference from const member
  return const_cast<CSSPropertyValueSet&>(*properties_);
}

std::shared_ptr<const CSSValue> StyleRuleCounterStyle::GetDescriptorValue(
    StringView descriptor_name) const {
  if (!properties_) {
    return nullptr;
  }
  
  // WebF doesn't have at-rule descriptor infrastructure yet,
  // so we'll use a simple string-based approach for now
  // TODO: Implement proper at-rule descriptor support
  return nullptr;
}

void StyleRuleCounterStyle::SetDescriptorValue(StringView descriptor_name,
                                               const CSSValue* value) {
  if (!properties_) {
    properties_ = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  }
  
  // WebF doesn't have at-rule descriptor infrastructure yet,
  // so we'll use a simple string-based approach for now
  // TODO: Implement proper at-rule descriptor support
}

void StyleRuleCounterStyle::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
  // TODO: Trace properties when WebF supports it
}

}  // namespace webf
