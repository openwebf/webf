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

 private:
  // Apply individual property handlers
  static void ApplyColorProperty(StyleResolverState&, const CSSValue&);
  static void ApplyBackgroundColorProperty(StyleResolverState&, const CSSValue&);
  static void ApplyDisplayProperty(StyleResolverState&, const CSSValue&);
  static void ApplyPositionProperty(StyleResolverState&, const CSSValue&);
  static void ApplyWidthProperty(StyleResolverState&, const CSSValue&);
  static void ApplyHeightProperty(StyleResolverState&, const CSSValue&);
  static void ApplyMarginProperty(CSSPropertyID, StyleResolverState&, const CSSValue&);
  static void ApplyPaddingProperty(CSSPropertyID, StyleResolverState&, const CSSValue&);
  static void ApplyBorderProperty(CSSPropertyID, StyleResolverState&, const CSSValue&);
  static void ApplyFontProperty(CSSPropertyID, StyleResolverState&, const CSSValue&);
  static void ApplyTextProperty(CSSPropertyID, StyleResolverState&, const CSSValue&);
  static void ApplyFlexProperty(CSSPropertyID, StyleResolverState&, const CSSValue&);
  static void ApplyTransformProperty(StyleResolverState&, const CSSValue&);
  static void ApplyOpacityProperty(StyleResolverState&, const CSSValue&);
  static void ApplyOverflowProperty(CSSPropertyID, StyleResolverState&, const CSSValue&);
  static void ApplyZIndexProperty(StyleResolverState&, const CSSValue&);
};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_STYLE_BUILDER_H