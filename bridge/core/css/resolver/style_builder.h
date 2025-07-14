/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_RESOLVER_STYLE_BUILDER_H
#define WEBF_CSS_RESOLVER_STYLE_BUILDER_H

#include <memory>
#include "code_gen/css_property_names.h"
#include "core/css/css_value.h"
#include "core/css/css_property_value_set.h"
#include "core/style/computed_style.h"
#include "foundation/macros.h"

namespace webf {

class CSSValue;
class StyleResolverState;

// Responsible for applying CSS property values to a ComputedStyle
class StyleBuilder {
  WEBF_STATIC_ONLY(StyleBuilder);

 public:
  // Apply a single CSS property
  static void ApplyProperty(CSSPropertyID,
                           StyleResolverState&,
                           const CSSValue&);

  // Apply a single CSS property with initial value
  static void ApplyInitialProperty(CSSPropertyID,
                                  StyleResolverState&);

  // Apply a single CSS property with inherited value
  static void ApplyInheritedProperty(CSSPropertyID,
                                    StyleResolverState&);

  // Apply a single CSS property with unset value
  static void ApplyUnsetProperty(CSSPropertyID,
                               StyleResolverState&);

  // Apply all declarations in a StylePropertySet
  static void ApplyAllProperty(StyleResolverState&,
                              const CSSValue&,
                              TextDirection,
                              CSSPropertyValueSet::PropertySetFlag);

};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_STYLE_BUILDER_H