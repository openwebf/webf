/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_RESOLVER_STYLE_CASCADE_H
#define WEBF_CSS_RESOLVER_STYLE_CASCADE_H

#include <memory>
#include <vector>
#include "code_gen/css_property_names.h"
#include "core/css/css_value.h"
#include "core/css/match_result.h"
#include "foundation/macros.h"

namespace webf {

class CSSValue;
class StyleResolverState;
class CSSPropertyValueSet;

// Manages the CSS cascade - applying properties in the correct order
class StyleCascade {
  WEBF_STACK_ALLOCATED();

 public:
  explicit StyleCascade(StyleResolverState&);
  ~StyleCascade();

  // Apply all matched properties from MatchResult
  void Apply(const MatchResult&);

  // Apply a single property
  void ApplyProperty(CSSPropertyID, const CSSValue&);

  // Apply a set of properties
  void ApplyProperties(const CSSPropertyValueSet&);

  // Reset the cascade
  void Reset();

  // Check if a property has been applied
  bool HasAppliedProperty(CSSPropertyID) const;

  // Get the state
  StyleResolverState& State() { return state_; }
  const StyleResolverState& State() const { return state_; }

 private:
  // Apply properties in cascade order
  void ApplyMatchedProperties(const MatchResult&);
  
  // Apply properties from a single matched properties entry
  void ApplyMatchedPropertiesEntry(const MatchResult::MatchedProperties&);
  
  // Apply important properties
  void ApplyImportantProperties(const MatchResult&);

  // Track which properties have been applied
  void MarkPropertyAsApplied(CSSPropertyID);

  StyleResolverState& state_;
  
  // Vector to track which properties have been applied
  std::vector<bool> applied_properties_;
  
  // Track if we're applying important properties
  bool applying_important_ = false;
};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_STYLE_CASCADE_H