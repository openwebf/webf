/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_builder.h"

#include "core/css/css_identifier_value.h"
#include "core/css/css_inherit_value.h"
#include "core/css/css_initial_value.h"
#include "core/css/css_unset_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_value_list.h"
#include "core/css/css_color.h"
#include "core/css/properties/css_property.h"
#include "core/css/properties/longhand.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/style/computed_style.h"
#include "core/style/computed_style_constants.h"
#include "foundation/logging.h"

namespace webf {

void StyleBuilder::ApplyProperty(CSSPropertyID property_id,
                               StyleResolverState& state,
                               const CSSValue& value) {
  // Following Blink's pattern, get the property and delegate to it
  const CSSProperty& property = CSSProperty::Get(property_id);
  
  // Check if it's a shorthand property - these need special handling
  if (property.IsShorthand()) {
    // TODO: Implement shorthand expansion
    return;
  }
  
  // Must be a longhand property
  DCHECK(property.IsLonghand());
  const Longhand& longhand = To<Longhand>(property);
  
  // Handle CSS-wide keywords by delegating to the longhand
  if (value.IsInitialValue()) {
    longhand.ApplyInitial(state);
    return;
  }
  
  if (value.IsInheritedValue()) {
    longhand.ApplyInherit(state);
    return;
  }
  
  if (value.IsUnsetValue()) {
    longhand.ApplyUnset(state);
    return;
  }
  
  // Apply the value using the longhand's implementation
  longhand.ApplyValue(state, value, CSSProperty::ValueMode::kNormal);
}

void StyleBuilder::ApplyInitialProperty(CSSPropertyID property_id,
                                      StyleResolverState& state) {
  // Following Blink's pattern, delegate to the longhand property
  const CSSProperty& property = CSSProperty::Get(property_id);
  
  if (property.IsShorthand()) {
    // TODO: Handle shorthand properties by expanding to longhands
    return;
  }
  
  DCHECK(property.IsLonghand());
  const Longhand& longhand = To<Longhand>(property);
  longhand.ApplyInitial(state);
}

void StyleBuilder::ApplyInheritedProperty(CSSPropertyID property_id,
                                        StyleResolverState& state) {
  // Following Blink's pattern, delegate to the longhand property
  const CSSProperty& property = CSSProperty::Get(property_id);
  
  if (property.IsShorthand()) {
    // TODO: Handle shorthand properties by expanding to longhands
    return;
  }
  
  DCHECK(property.IsLonghand());
  const Longhand& longhand = To<Longhand>(property);
  longhand.ApplyInherit(state);
}

void StyleBuilder::ApplyUnsetProperty(CSSPropertyID property_id,
                                    StyleResolverState& state) {
  // Following Blink's pattern, delegate to the longhand property
  const CSSProperty& property = CSSProperty::Get(property_id);
  
  if (property.IsShorthand()) {
    // TODO: Handle shorthand properties by expanding to longhands
    return;
  }
  
  DCHECK(property.IsLonghand());
  const Longhand& longhand = To<Longhand>(property);
  longhand.ApplyUnset(state);
}

void StyleBuilder::ApplyAllProperty(StyleResolverState& state,
                                  const CSSValue& value,
                                  TextDirection direction,
                                  CSSPropertyValueSet::PropertySetFlag flag) {
  // TODO: Implement 'all' property handling following Blink's pattern
  // This would apply the given value to all properties
}

}  // namespace webf