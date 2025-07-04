/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_cascade.h"

#include "code_gen/css_property_names.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_value.h"
#include "core/css/properties/css_property.h"
#include "core/css/resolver/style_builder.h"
#include "core/css/resolver/style_resolver_state.h"

namespace webf {

StyleCascade::StyleCascade(StyleResolverState& state)
    : state_(state),
      applied_properties_(kNumCSSProperties, false) {
}

StyleCascade::~StyleCascade() = default;

void StyleCascade::Apply(const MatchResult& match_result) {
  // First apply normal properties
  applying_important_ = false;
  ApplyMatchedProperties(match_result);
  
  // Then apply important properties
  applying_important_ = true;
  ApplyImportantProperties(match_result);
}

void StyleCascade::ApplyMatchedProperties(const MatchResult& match_result) {
  const auto& matched_properties = match_result.GetMatchedProperties();
  
  // Apply in cascade order (UA -> User -> Author)
  for (const auto& entry : matched_properties) {
    if (!applying_important_) {
      ApplyMatchedPropertiesEntry(entry);
    }
  }
}

void StyleCascade::ApplyImportantProperties(const MatchResult& match_result) {
  const auto& matched_properties = match_result.GetMatchedProperties();
  
  // Apply important properties in reverse cascade order
  // (Author !important -> User !important -> UA !important)
  for (auto it = matched_properties.rbegin(); it != matched_properties.rend(); ++it) {
    ApplyMatchedPropertiesEntry(*it);
  }
}

void StyleCascade::ApplyMatchedPropertiesEntry(
    const MatchResult::MatchedProperties& entry) {
  
  if (!entry.properties) {
    return;
  }
  
  const StylePropertySet& properties = *entry.properties;
  
  for (unsigned i = 0; i < properties.PropertyCount(); ++i) {
    const StylePropertySet::PropertyReference property = properties.PropertyAt(i);
    
    // Skip if we're looking for important properties and this isn't important,
    // or vice versa
    if (applying_important_ != property.IsImportant()) {
      continue;
    }
    
    // Skip if property has already been applied by a higher priority rule
    if (HasAppliedProperty(property.Id())) {
      continue;
    }
    
    // Apply the property
    if (property.Value() && *property.Value()) {
      ApplyProperty(property.Id(), **property.Value());
    }
  }
}

void StyleCascade::ApplyProperty(CSSPropertyID property_id, const CSSValue& value) {
  // Mark property as applied
  MarkPropertyAsApplied(property_id);
  
  // Apply via StyleBuilder
  StyleBuilder::ApplyProperty(property_id, state_, value);
}

void StyleCascade::ApplyProperties(const CSSPropertyValueSet& properties) {
  for (unsigned i = 0; i < properties.PropertyCount(); ++i) {
    const CSSPropertyValueSet::PropertyReference property = properties.PropertyAt(i);
    if (property.Value() && *property.Value()) {
      ApplyProperty(property.Id(), **property.Value());
    }
  }
}

void StyleCascade::Reset() {
  std::fill(applied_properties_.begin(), applied_properties_.end(), false);
  applying_important_ = false;
}

bool StyleCascade::HasAppliedProperty(CSSPropertyID property_id) const {
  if (property_id == CSSPropertyID::kInvalid || 
      static_cast<int>(property_id) >= kNumCSSProperties) {
    return false;
  }
  
  return applied_properties_[static_cast<int>(property_id)];
}

void StyleCascade::MarkPropertyAsApplied(CSSPropertyID property_id) {
  if (property_id != CSSPropertyID::kInvalid && 
      static_cast<int>(property_id) < kNumCSSProperties) {
    applied_properties_[static_cast<int>(property_id)] = true;
  }
}

}  // namespace webf