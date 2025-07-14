/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_PROPERTIES_STYLE_BUILDER_CONVERTER_H_
#define WEBF_CORE_CSS_PROPERTIES_STYLE_BUILDER_CONVERTER_H_

#include "core/css/css_value.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/platform/fonts/font_family.h"
#include "core/platform/fonts/font_description.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_value_list.h"

namespace webf {

class StyleBuilderConverter {
 public:
  // Font family converter
  static FontFamily ConvertFontFamily(StyleResolverState& state, const CSSValue& value) {
    // Simple implementation - just use the generic family for now
    if (value.IsIdentifierValue()) {
      const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
      switch (ident.GetValueID()) {
        case CSSValueID::kSerif:
          return FontFamily(AtomicString("serif"), FontFamily::Type::kGenericFamily);
        case CSSValueID::kSansSerif:
          return FontFamily(AtomicString("sans-serif"), FontFamily::Type::kGenericFamily);
        case CSSValueID::kMonospace:
          return FontFamily(AtomicString("monospace"), FontFamily::Type::kGenericFamily);
        case CSSValueID::kCursive:
          return FontFamily(AtomicString("cursive"), FontFamily::Type::kGenericFamily);
        case CSSValueID::kFantasy:
          return FontFamily(AtomicString("fantasy"), FontFamily::Type::kGenericFamily);
        default:
          break;
      }
    }
    // TODO: Handle string values, value lists
    return FontFamily();
  }
  
  // Font feature settings converter (stub)
  static int ConvertFontFeatureSettings(StyleResolverState& state, const CSSValue& value) {
    // TODO: Implement proper conversion
    return 0;
  }
  
  // Font kerning converter
  static ::webf::FontDescription::Kerning ConvertFontKerning(StyleResolverState& state, const CSSValue& value) {
    if (value.IsIdentifierValue()) {
      const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
      switch (ident.GetValueID()) {
        case CSSValueID::kAuto:
          return ::webf::FontDescription::Kerning::kAuto;
        case CSSValueID::kNormal:
          return ::webf::FontDescription::Kerning::kNormal;
        case CSSValueID::kNone:
          return ::webf::FontDescription::Kerning::kNone;
        default:
          break;
      }
    }
    return ::webf::FontDescription::Kerning::kAuto;
  }
  
  // Font optical sizing converter
  static int ConvertFontOpticalSizing(StyleResolverState& state, const CSSValue& value) {
    // TODO: Implement
    return 0;
  }
  
  // Font palette converter
  static int ConvertFontPalette(StyleResolverState& state, const CSSValue& value) {
    // TODO: Implement
    return 0;
  }
  
  // Font size converter
  static float ConvertFontSize(StyleResolverState& state, const CSSValue& value) {
    // TODO: Implement - for now just return default
    return 16.0f;
  }
  
  // Font size adjust converter
  static float ConvertFontSizeAdjust(StyleResolverState& state, const CSSValue& value) {
    // TODO: Implement
    return 1.0f;
  }
  
  // Font stretch converter
  static ::webf::FontDescription::FontSelectionValue ConvertFontStretch(StyleResolverState& state, const CSSValue& value) {
    // TODO: Implement properly
    return ::webf::FontDescription::FontSelectionValue(100);  // Normal stretch
  }
  
  // Font style converter
  static ::webf::FontDescription::FontSelectionValue ConvertFontStyle(StyleResolverState& state, const CSSValue& value) {
    // TODO: Implement properly
    return ::webf::FontDescription::FontSelectionValue(0);  // Normal style
  }
  
  // Font synthesis converters - using fully qualified names to avoid conflicts
  static ::webf::FontDescription::FontSynthesisSmallCaps ConvertFontSynthesisSmallCaps(StyleResolverState& state, const CSSValue& value) {
    return ::webf::FontDescription::FontSynthesisSmallCaps::kAuto;
  }
  static ::webf::FontDescription::FontSynthesisStyle ConvertFontSynthesisStyle(StyleResolverState& state, const CSSValue& value) {
    return ::webf::FontDescription::FontSynthesisStyle::kAuto;
  }
  static ::webf::FontDescription::FontSynthesisWeight ConvertFontSynthesisWeight(StyleResolverState& state, const CSSValue& value) {
    return ::webf::FontDescription::FontSynthesisWeight::kAuto;
  }
  
  // Font variant converters
  static int ConvertFontVariantAlternates(StyleResolverState& state, const CSSValue& value) {
    return 0;
  }
  static int ConvertFontVariantCaps(StyleResolverState& state, const CSSValue& value) {
    return 0;
  }
  static int ConvertFontVariantEastAsian(StyleResolverState& state, const CSSValue& value) {
    return 0;
  }
  static int ConvertFontVariantLigatures(StyleResolverState& state, const CSSValue& value) {
    return 0;
  }
  static int ConvertFontVariantNumeric(StyleResolverState& state, const CSSValue& value) {
    return 0;
  }
  static int ConvertFontVariantPosition(StyleResolverState& state, const CSSValue& value) {
    return 0;
  }
  static int ConvertFontVariationSettings(StyleResolverState& state, const CSSValue& value) {
    return 0;
  }
  static int ConvertFontVariantEmoji(StyleResolverState& state, const CSSValue& value) {
    return 0;
  }
  
  // Font weight converter
  static ::webf::FontDescription::FontSelectionValue ConvertFontWeight(StyleResolverState& state, const CSSValue& value) {
    // TODO: Implement properly
    return ::webf::FontDescription::FontSelectionValue(400);  // Normal weight
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_PROPERTIES_STYLE_BUILDER_CONVERTER_H_