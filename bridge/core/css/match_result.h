/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_MATCH_RESULT_H
#define WEBF_CSS_MATCH_RESULT_H

#include <memory>
#include <vector>
#include "core/css/css_property_value_set.h"
#include "core/css/style_rule.h"
#include "foundation/macros.h"

namespace webf {

// Type alias for property set used in style matching
using StylePropertySet = CSSPropertyValueSet;

// Represents the origin of cascade rules
enum class CascadeOrigin {
  kUserAgent = 0,
  kUser = 1,
  kAuthor = 2,
  kAnimation = 3,
  kTransition = 4,
  kMaxOrigin = kTransition,
};

// Represents cascade layer level
using CascadeLayerLevel = unsigned;

// Represents matched properties from CSS rules
class MatchResult {
  WEBF_STACK_ALLOCATED();

 public:
  struct MatchedProperties {
    const StylePropertySet* properties;
    CascadeOrigin origin;
    CascadeLayerLevel layer_level;
    bool is_inline_style = false;
  };

  MatchResult() = default;
  ~MatchResult() = default;

  void AddMatchedProperties(const StylePropertySet* properties,
                           CascadeOrigin origin,
                           CascadeLayerLevel layer_level) {
    if (!properties) return;
    
    MatchedProperties matched;
    matched.properties = properties;
    matched.origin = origin;
    matched.layer_level = layer_level;
    matched.is_inline_style = false;
    matched_properties_.push_back(matched);
  }
  
  void AddInlineStyleProperties(const StylePropertySet* properties) {
    if (!properties) return;
    
    MatchedProperties matched;
    matched.properties = properties;
    matched.origin = CascadeOrigin::kAuthor;
    matched.layer_level = 0;
    matched.is_inline_style = true;
    matched_properties_.push_back(matched);
  }

  const std::vector<MatchedProperties>& GetMatchedProperties() const {
    return matched_properties_;
  }

  bool IsEmpty() const { return matched_properties_.empty(); }
  
  void Clear() { matched_properties_.clear(); }

 private:
  std::vector<MatchedProperties> matched_properties_;
};

}  // namespace webf

#endif  // WEBF_CSS_MATCH_RESULT_H