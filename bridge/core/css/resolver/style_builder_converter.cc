/*
 * Copyright (C) 2013 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "core/css/resolver/style_builder_converter.h"

#include "core/css/css_identifier_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_initial_color_value.h"
#include "core/css/css_to_length_conversion_data.h"
#include "core/css/parser/css_parser.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/style/computed_style.h"
#include "core/platform/geometry/length.h"
#include "core/platform/graphics/color.h"
#include "core/platform/text/writing_mode.h"
#include "core/platform/geometry/length_size.h"
#include "core/platform/geometry/length_box.h"
#include "core/platform/geometry/length_point.h"
#include "core/platform/geometry/layout_unit.h"
#include "core/css/css_identifier_value.h"
#include "core/style/style_stubs.h"
#include <type_traits>
#include <optional>

namespace webf {

Length StyleBuilderConverter::ConvertLength(const StyleResolverState& state,
                                           const CSSValue& value) {
  auto* primitive_value = DynamicTo<CSSPrimitiveValue>(&value);
  if (!primitive_value) {
    return Length(0, Length::kFixed);
  }
  
  // Create conversion data with minimal required parameters
  CSSToLengthConversionData::FontSizes font_sizes;
  CSSToLengthConversionData::LineHeightSize line_height_size;
  CSSToLengthConversionData::ViewportSize viewport_size;
  CSSToLengthConversionData::ContainerSizes container_sizes;
  CSSToLengthConversionData::Flags flags = 0;
  
  CSSToLengthConversionData conversion_data(
    WritingMode::kHorizontalTb,
    font_sizes,
    line_height_size, 
    viewport_size,
    container_sizes,
    1.0f, // zoom
    flags
  );
  return ConvertToLength(state, *primitive_value, conversion_data);
}

Length StyleBuilderConverter::ConvertLengthOrAuto(const StyleResolverState& state,
                                                 const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    if (identifier_value->GetValueID() == CSSValueID::kAuto) {
      return Length(Length::kAuto);
    }
  }
  
  return ConvertLength(state, value);
}

Length StyleBuilderConverter::ConvertLengthSizing(const StyleResolverState& state,
                                                 const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kAuto:
        return Length(Length::kAuto);
      case CSSValueID::kMinContent:
        return Length(Length::kMinContent);
      case CSSValueID::kMaxContent:
        return Length(Length::kMaxContent);
      case CSSValueID::kFitContent:
        return Length(Length::kFitContent);
      default:
        break;
    }
  }
  
  return ConvertLength(state, value);
}

Length StyleBuilderConverter::ConvertLengthMaxSizing(const StyleResolverState& state,
                                                    const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    if (identifier_value->GetValueID() == CSSValueID::kNone) {
      return Length(Length::kNone);  // Use kNone instead of kMaxSizeNone
    }
  }
  
  return ConvertLengthSizing(state, value);
}

float StyleBuilderConverter::ConvertNumber(const StyleResolverState& state,
                                          const CSSValue& value) {
  auto* primitive_value = DynamicTo<CSSPrimitiveValue>(&value);
  if (!primitive_value || !primitive_value->IsNumber()) {
    return 0.0f;
  }
  
  return ConvertToFloat(state, *primitive_value);
}

float StyleBuilderConverter::ConvertAlpha(const StyleResolverState& state,
                                         const CSSValue& value) {
  float alpha = ConvertNumber(state, value);
  // Clamp alpha to [0, 1]
  return std::max(0.0f, std::min(1.0f, alpha));
}

int StyleBuilderConverter::ConvertInteger(const StyleResolverState& state,
                                         const CSSValue& value) {
  auto* primitive_value = DynamicTo<CSSPrimitiveValue>(&value);
  if (!primitive_value || !primitive_value->IsNumber()) {
    return 0;
  }
  
  return ConvertToInt(state, *primitive_value);
}

StyleColor StyleBuilderConverter::ConvertStyleColor(const StyleResolverState& state,
                                                   const CSSValue& value,
                                                   bool /*for_visited_link*/) {
  // currentColor special-cases to StyleColor::CurrentColor
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    if (identifier_value->GetValueID() == CSSValueID::kCurrentcolor) {
      return StyleColor::CurrentColor();
    }
  }
  // Fallback to a numeric StyleColor from ConvertColor.
  return StyleColor(ConvertColor(state, value));
}

Color StyleBuilderConverter::ConvertColor(const StyleResolverState& /*state*/,
                                         const CSSValue& value) {
  // Numeric color (e.g., from named colors mapped by the parser or rgba())
  if (auto* color_value = DynamicTo<cssvalue::CSSColor>(&value)) {
    return color_value->Value();
  }

  // Keyword colors (e.g., white, yellow, transparent, etc.)
  if (auto* ident = DynamicTo<CSSIdentifierValue>(&value)) {
    CSSValueID id = ident->GetValueID();
    if (StyleColor::IsColorKeyword(id)) {
      // Resolve via named color table using default color scheme.
      return StyleColor::ColorFromKeyword(id, ColorScheme::kDefault);
    }
  }

  // Initial color
  if (DynamicTo<CSSInitialColorValue>(&value)) {
    return Color::kBlack;
  }

  // Fallback: transparent
  return Color::kTransparent;
}

EDisplay StyleBuilderConverter::ConvertDisplay(const StyleResolverState& state,
                                              const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kNone:
        return EDisplay::kNone;
      case CSSValueID::kBlock:
        return EDisplay::kBlock;
      case CSSValueID::kInline:
        return EDisplay::kInline;
      case CSSValueID::kInlineBlock:
        return EDisplay::kInlineBlock;
      case CSSValueID::kFlex:
        return EDisplay::kFlex;
      case CSSValueID::kInlineFlex:
        return EDisplay::kInlineFlex;
      case CSSValueID::kGrid:
        return EDisplay::kGrid;
      case CSSValueID::kInlineGrid:
        return EDisplay::kInlineGrid;
      case CSSValueID::kTable:
        return EDisplay::kTable;
      case CSSValueID::kInlineTable:
        return EDisplay::kInlineTable;
      case CSSValueID::kContents:
        return EDisplay::kContents;
      case CSSValueID::kListItem:
        return EDisplay::kListItem;
      default:
        break;
    }
  }
  
  return EDisplay::kBlock;
}

EPosition StyleBuilderConverter::ConvertPosition(const StyleResolverState& state,
                                                const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kStatic:
        return EPosition::kStatic;
      case CSSValueID::kRelative:
        return EPosition::kRelative;
      case CSSValueID::kAbsolute:
        return EPosition::kAbsolute;
      case CSSValueID::kFixed:
        return EPosition::kFixed;
      case CSSValueID::kSticky:
        return EPosition::kSticky;
      default:
        break;
    }
  }
  
  return EPosition::kStatic;
}

EFloat StyleBuilderConverter::ConvertFloat(const StyleResolverState& state,
                                          const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kNone:
        return EFloat::kNone;
      case CSSValueID::kLeft:
        return EFloat::kLeft;
      case CSSValueID::kRight:
        return EFloat::kRight;
      default:
        break;
    }
  }
  
  return EFloat::kNone;
}

// TODO: Implement EClear converter when EClear enum is available

EOverflow StyleBuilderConverter::ConvertOverflow(const StyleResolverState& state,
                                                const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kVisible:
        return EOverflow::kVisible;
      case CSSValueID::kHidden:
        return EOverflow::kHidden;
      case CSSValueID::kScroll:
        return EOverflow::kScroll;
      case CSSValueID::kAuto:
        return EOverflow::kAuto;
      case CSSValueID::kClip:
        return EOverflow::kClip;
      default:
        break;
    }
  }
  
  return EOverflow::kVisible;
}

// TODO: Implement these converters when the enum types are available in WebF:
// - EVisibility ConvertVisibility()
// - ETextAlign ConvertTextAlign()
// - ETextDecoration ConvertTextDecoration()
// - EWhiteSpace ConvertWhiteSpace()
// - EBoxSizing ConvertBoxSizing()

FontDescription::FontSelectionValue StyleBuilderConverter::ConvertFontWeight(const StyleResolverState& state,
                                                                          const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kNormal:
        return FontDescription::FontSelectionValue(400);
      case CSSValueID::kBold:
        return FontDescription::FontSelectionValue(700);
      case CSSValueID::kBolder:
        // TODO: Calculate based on parent weight
        return FontDescription::FontSelectionValue(700);
      case CSSValueID::kLighter:
        // TODO: Calculate based on parent weight
        return FontDescription::FontSelectionValue(300);
      default:
        break;
    }
  }
  
  if (auto* numeric_value = DynamicTo<CSSNumericLiteralValue>(&value)) {
    return FontDescription::FontSelectionValue(numeric_value->GetFloatValue());
  }
  
  return FontDescription::FontSelectionValue(400); // Normal weight
}

// TODO: Implement FontStyle converter when FontStyle class is available

float StyleBuilderConverter::ConvertFontSize(const StyleResolverState& state,
                                           const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    // Handle keyword font sizes
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kXxSmall:
        return 9.0f;
      case CSSValueID::kXSmall:
        return 10.0f;
      case CSSValueID::kSmall:
        return 13.0f;
      case CSSValueID::kMedium:
        return 16.0f;
      case CSSValueID::kLarge:
        return 18.0f;
      case CSSValueID::kXLarge:
        return 24.0f;
      case CSSValueID::kXxLarge:
        return 32.0f;
      case CSSValueID::kXxxLarge:
        return 48.0f;
      case CSSValueID::kLarger:
        // TODO: Calculate based on parent
        return 18.0f;
      case CSSValueID::kSmaller:
        // TODO: Calculate based on parent
        return 13.0f;
      default:
        break;
    }
  }
  
  Length length = ConvertLength(state, value);
  if (length.IsFixed()) {
    return length.GetFloatValue();
  }
  
  // TODO: Handle percentage and other units
  return 16.0f;  // Default medium size
}

Length StyleBuilderConverter::ConvertLineHeight(const StyleResolverState& state,
                                               const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    if (identifier_value->GetValueID() == CSSValueID::kNormal) {
      return Length(-100, Length::kPercent);  // Special value for normal
    }
  }
  
  if (auto* primitive_value = DynamicTo<CSSPrimitiveValue>(&value)) {
    if (primitive_value->IsNumber()) {
      // Line height as multiplier
      float multiplier = ConvertToFloat(state, *primitive_value);
      return Length(multiplier * 100, Length::kPercent);
    }
  }
  
  return ConvertLength(state, value);
}

// TODO: Implement EBorderStyle converter when EBorderStyle enum is available

// Helper methods

Length StyleBuilderConverter::ConvertToLength(const StyleResolverState& state,
                                             const CSSPrimitiveValue& value,
                                             const CSSToLengthConversionData& conversion_data) {
  return value.ConvertToLength(conversion_data);
}

float StyleBuilderConverter::ConvertToFloat(const StyleResolverState& state,
                                           const CSSPrimitiveValue& value) {
  if (auto* numeric_value = DynamicTo<CSSNumericLiteralValue>(&value)) {
    return numeric_value->GetFloatValue();
  }
  return 0.0f;
}

int StyleBuilderConverter::ConvertToInt(const StyleResolverState& state,
                                       const CSSPrimitiveValue& value) {
  if (auto* numeric_value = DynamicTo<CSSNumericLiteralValue>(&value)) {
    return static_cast<int>(numeric_value->GetFloatValue());
  }
  return 0;
}

// Font converters

FontFamily StyleBuilderConverter::ConvertFontFamily(StyleResolverState& state, const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    switch (ident.GetValueID()) {
      case CSSValueID::kSerif:
        return FontFamily(AtomicString::CreateFromUTF8("serif"), FontFamily::Type::kGenericFamily);
      case CSSValueID::kSansSerif:
        return FontFamily(AtomicString::CreateFromUTF8("sans-serif"), FontFamily::Type::kGenericFamily);
      case CSSValueID::kMonospace:
        return FontFamily(AtomicString::CreateFromUTF8("monospace"), FontFamily::Type::kGenericFamily);
      case CSSValueID::kCursive:
        return FontFamily(AtomicString::CreateFromUTF8("cursive"), FontFamily::Type::kGenericFamily);
      case CSSValueID::kFantasy:
        return FontFamily(AtomicString::CreateFromUTF8("fantasy"), FontFamily::Type::kGenericFamily);
      default:
        break;
    }
  }
  return FontFamily();
}

int StyleBuilderConverter::ConvertFontFeatureSettings(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

FontDescription::Kerning StyleBuilderConverter::ConvertFontKerning(StyleResolverState& state, const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    switch (ident.GetValueID()) {
      case CSSValueID::kAuto:
        return FontDescription::Kerning::kAuto;
      case CSSValueID::kNormal:
        return FontDescription::Kerning::kNormal;
      case CSSValueID::kNone:
        return FontDescription::Kerning::kNone;
      default:
        break;
    }
  }
  return FontDescription::Kerning::kAuto;
}

int StyleBuilderConverter::ConvertFontOpticalSizing(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

int StyleBuilderConverter::ConvertFontPalette(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

float StyleBuilderConverter::ConvertFontSizeAdjust(StyleResolverState& state, const CSSValue& value) {
  return 1.0f;
}

FontDescription::FontSelectionValue StyleBuilderConverter::ConvertFontStretch(StyleResolverState& state, const CSSValue& value) {
  return FontDescription::FontSelectionValue(100);
}

FontDescription::FontSelectionValue StyleBuilderConverter::ConvertFontStyle(StyleResolverState& state, const CSSValue& value) {
  return FontDescription::FontSelectionValue(0);
}

int StyleBuilderConverter::ConvertFontVariantAlternates(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

int StyleBuilderConverter::ConvertFontVariantCaps(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

int StyleBuilderConverter::ConvertFontVariantEastAsian(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

int StyleBuilderConverter::ConvertFontVariantEmoji(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

int StyleBuilderConverter::ConvertFontVariantLigatures(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

int StyleBuilderConverter::ConvertFontVariantNumeric(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

int StyleBuilderConverter::ConvertFontVariantPosition(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

int StyleBuilderConverter::ConvertFontVariationSettings(StyleResolverState& state, const CSSValue& value) {
  return 0;
}

// Color converters

StyleAutoColor StyleBuilderConverter::ConvertStyleAutoColor(StyleResolverState& state, const CSSValue& value, bool for_visited_link) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    if (ident.GetValueID() == CSSValueID::kAuto) {
      return StyleAutoColor::AutoColor();
    }
  }
  return StyleAutoColor::AutoColor();
}

// Alignment converters

StyleContentAlignmentData StyleBuilderConverter::ConvertContentAlignmentData(StyleResolverState& state, const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    switch (ident.GetValueID()) {
      case CSSValueID::kNormal:
        return StyleContentAlignmentData(ContentPosition::kNormal, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
      case CSSValueID::kStart:
        return StyleContentAlignmentData(ContentPosition::kStart, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
      case CSSValueID::kEnd:
        return StyleContentAlignmentData(ContentPosition::kEnd, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
      case CSSValueID::kCenter:
        return StyleContentAlignmentData(ContentPosition::kCenter, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
      case CSSValueID::kStretch:
        return StyleContentAlignmentData(ContentPosition::kCenter, ContentDistributionType::kStretch, OverflowAlignment::kDefault);
      case CSSValueID::kFlexStart:
        return StyleContentAlignmentData(ContentPosition::kFlexStart, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
      case CSSValueID::kFlexEnd:
        return StyleContentAlignmentData(ContentPosition::kFlexEnd, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
      case CSSValueID::kSpaceBetween:
        return StyleContentAlignmentData(ContentPosition::kCenter, ContentDistributionType::kSpaceBetween, OverflowAlignment::kDefault);
      case CSSValueID::kSpaceAround:
        return StyleContentAlignmentData(ContentPosition::kCenter, ContentDistributionType::kSpaceAround, OverflowAlignment::kDefault);
      case CSSValueID::kSpaceEvenly:
        return StyleContentAlignmentData(ContentPosition::kCenter, ContentDistributionType::kSpaceEvenly, OverflowAlignment::kDefault);
      case CSSValueID::kBaseline:
        return StyleContentAlignmentData(ContentPosition::kBaseline, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
      default:
        break;
    }
  }
  return StyleContentAlignmentData(ContentPosition::kNormal, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
}

// Self alignment data converter
StyleSelfAlignmentData StyleBuilderConverter::ConvertSelfOrDefaultAlignmentData(StyleResolverState& state, const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    switch (ident.GetValueID()) {
      case CSSValueID::kAuto:
        return StyleSelfAlignmentData(ItemPosition::kAuto, OverflowAlignment::kDefault);
      case CSSValueID::kNormal:
        return StyleSelfAlignmentData(ItemPosition::kNormal, OverflowAlignment::kDefault);
      case CSSValueID::kStart:
        return StyleSelfAlignmentData(ItemPosition::kStart, OverflowAlignment::kDefault);
      case CSSValueID::kEnd:
        return StyleSelfAlignmentData(ItemPosition::kEnd, OverflowAlignment::kDefault);
      case CSSValueID::kCenter:
        return StyleSelfAlignmentData(ItemPosition::kCenter, OverflowAlignment::kDefault);
      case CSSValueID::kStretch:
        return StyleSelfAlignmentData(ItemPosition::kStretch, OverflowAlignment::kDefault);
      case CSSValueID::kFlexStart:
        return StyleSelfAlignmentData(ItemPosition::kFlexStart, OverflowAlignment::kDefault);
      case CSSValueID::kFlexEnd:
        return StyleSelfAlignmentData(ItemPosition::kFlexEnd, OverflowAlignment::kDefault);
      case CSSValueID::kBaseline:
        return StyleSelfAlignmentData(ItemPosition::kBaseline, OverflowAlignment::kDefault);
      default:
        break;
    }
  }
  return StyleSelfAlignmentData(ItemPosition::kAuto, OverflowAlignment::kDefault);
}

// Additional converters
ScopedCSSNameList* StyleBuilderConverter::ConvertAnchorName(StyleResolverState& state, const CSSValue& value) {
  return nullptr;
}

ScopedCSSNameList* StyleBuilderConverter::ConvertAnchorScope(StyleResolverState& state, const CSSValue& value) {
  return nullptr;
}

StyleAspectRatio StyleBuilderConverter::ConvertAspectRatio(StyleResolverState& state, const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    if (ident.GetValueID() == CSSValueID::kAuto) {
      return StyleAspectRatio(EAspectRatioType::kAuto, gfx::SizeF());
    }
  }
  return StyleAspectRatio(EAspectRatioType::kAuto, gfx::SizeF());
}

int StyleBuilderConverter::ConvertBorderWidth(StyleResolverState& state, const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    switch (ident.GetValueID()) {
      case CSSValueID::kThin:
        return 1;
      case CSSValueID::kMedium:
        return 3;
      case CSSValueID::kThick:
        return 5;
      default:
        return 3;
    }
  }
  return 3;
}

// Radius converter
LengthSize StyleBuilderConverter::ConvertRadius(StyleResolverState& state, const CSSValue& value) {
  return LengthSize(Length::Fixed(0), Length::Fixed(0));
}

// Shadow list converter
ShadowList* StyleBuilderConverter::ConvertShadowList(StyleResolverState& state, const CSSValue& value) {
  return nullptr;
}

// Clip converter
LengthBox StyleBuilderConverter::ConvertClip(StyleResolverState& state, const CSSValue& value) {
  return LengthBox();
}

// Clip path converter
ClipPathOperation* StyleBuilderConverter::ConvertClipPath(StyleResolverState& state, const CSSValue& value) {
  return nullptr;
}

// Gap length converter
Length StyleBuilderConverter::ConvertGapLength(StyleResolverState& state, const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    if (ident.GetValueID() == CSSValueID::kNormal) {
      return Length::Normal();
    }
  }
  return Length::Fixed(0);
}

// Column rule width converter
uint16_t StyleBuilderConverter::ConvertColumnRuleWidth(StyleResolverState& state, const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const CSSIdentifierValue& ident = To<CSSIdentifierValue>(value);
    switch (ident.GetValueID()) {
      case CSSValueID::kThin:
        return 1;
      case CSSValueID::kMedium:
        return 3;
      case CSSValueID::kThick:
        return 5;
      default:
        return 3;
    }
  }
  return 3;
}

// Computed length converter template
template<typename T>
T StyleBuilderConverter::ConvertComputedLength(StyleResolverState& state, const CSSValue& value) {
  return T(0);
}

// Explicit template instantiation for float
template float StyleBuilderConverter::ConvertComputedLength<float>(StyleResolverState& state, const CSSValue& value);

// Flags converter template
template<typename T>
T StyleBuilderConverter::ConvertFlags(StyleResolverState& state, const CSSValue& value) {
  if constexpr (std::is_same_v<T, unsigned>) {
    return 0;
  } else {
    return static_cast<T>(0);
  }
}

// Flags converter template with default value
template<typename T, CSSValueID DefaultValue>
T StyleBuilderConverter::ConvertFlags(StyleResolverState& state, const CSSValue& value) {
  if constexpr (std::is_same_v<T, unsigned>) {
    return 0;
  } else {
    return static_cast<T>(0);
  }
}

// Explicit template instantiations for known types
template unsigned StyleBuilderConverter::ConvertFlags<unsigned>(StyleResolverState& state, const CSSValue& value);
template EContainerType StyleBuilderConverter::ConvertFlags<EContainerType, CSSValueID::kNormal>(StyleResolverState& state, const CSSValue& value);
template Containment StyleBuilderConverter::ConvertFlags<Containment>(StyleResolverState& state, const CSSValue& value);
template TouchAction StyleBuilderConverter::ConvertFlags<TouchAction>(StyleResolverState& state, const CSSValue& value);
template TextDecorationLine StyleBuilderConverter::ConvertFlags<TextDecorationLine>(StyleResolverState& state, const CSSValue& value);

// Intrinsic dimension converter
StyleIntrinsicLength StyleBuilderConverter::ConvertIntrinsicDimension(StyleResolverState& state, const CSSValue& value) {
  return StyleIntrinsicLength::None();
}

// Container name converter
ScopedCSSNameList* StyleBuilderConverter::ConvertContainerName(StyleResolverState& state, const CSSValue& value) {
  return nullptr;
}

// Grid converters
ComputedGridTrackList StyleBuilderConverter::ConvertGridTrackSizeList(StyleResolverState& state, const CSSValue& value) {
  return ComputedGridTrackList::CreateDefault();
}

GridAutoFlow StyleBuilderConverter::ConvertGridAutoFlow(StyleResolverState& state, const CSSValue& value) {
  return GridAutoFlow::kAutoFlowRow;
}

GridPosition StyleBuilderConverter::ConvertGridPosition(StyleResolverState& state, const CSSValue& value) {
  return GridPosition::CreateAuto();
}

ComputedGridTemplateAreas* StyleBuilderConverter::ConvertGridTemplateAreas(StyleResolverState& state, const CSSValue& value) {
  return ComputedGridTemplateAreas::CreateDefault();
}

void StyleBuilderConverter::ConvertGridTrackList(const CSSValue& value, ComputedGridTrackList& computed_grid_track_list, StyleResolverState& state) {
  computed_grid_track_list = ComputedGridTrackList::CreateDefault();
}

// Additional missing converters
RespectImageOrientationEnum StyleBuilderConverter::ConvertImageOrientation(StyleResolverState& state, const CSSValue& value) {
  return RespectImageOrientationEnum::kNone;
}

StyleInitialLetter StyleBuilderConverter::ConvertInitialLetter(StyleResolverState& state, const CSSValue& value) {
  return StyleInitialLetter::None();
}

float StyleBuilderConverter::ConvertSpacing(StyleResolverState& state, const CSSValue& value) {
  return 0.0f;
}

template<int DefaultValue>
int StyleBuilderConverter::ConvertIntegerOrNone(StyleResolverState& state, const CSSValue& value) {
  return DefaultValue;
}

// Explicit template instantiation
template int StyleBuilderConverter::ConvertIntegerOrNone<0>(StyleResolverState& state, const CSSValue& value);

Length StyleBuilderConverter::ConvertQuirkyLength(StyleResolverState& state, const CSSValue& value) {
  return Length::Fixed(0);
}

StyleSVGResource* StyleBuilderConverter::ConvertElementReference(StyleResolverState& state, const CSSValue& value) {
  return StyleSVGResource::CreateDefault();
}

LengthPoint StyleBuilderConverter::ConvertPosition(StyleResolverState& state, const CSSValue& value) {
  return LengthPoint(Length::Percent(50.0), Length::Percent(50.0));
}

BasicShape* StyleBuilderConverter::ConvertObjectViewBox(StyleResolverState& state, const CSSValue& value) {
  return BasicShape::CreateDefault();
}

OffsetPathOperation* StyleBuilderConverter::ConvertOffsetPath(StyleResolverState& state, const CSSValue& value) {
  return OffsetPathOperation::CreateDefault();
}

LengthPoint StyleBuilderConverter::ConvertOffsetPosition(StyleResolverState& state, const CSSValue& value) {
  return LengthPoint(Length::None(), Length::None());
}

StyleOffsetRotation StyleBuilderConverter::ConvertOffsetRotate(StyleResolverState& state, const CSSValue& value) {
  return StyleOffsetRotation::Auto();
}

LengthPoint StyleBuilderConverter::ConvertPositionOrAuto(StyleResolverState& state, const CSSValue& value) {
  return LengthPoint(Length::Auto(), Length::Auto());
}

QuotesData* StyleBuilderConverter::ConvertQuotes(StyleResolverState& state, const CSSValue& value) {
  return QuotesData::CreateDefault();
}

LayoutUnit StyleBuilderConverter::ConvertLayoutUnit(StyleResolverState& state, const CSSValue& value) {
  return LayoutUnit();
}

std::optional<StyleOverflowClipMargin> StyleBuilderConverter::ConvertOverflowClipMargin(StyleResolverState& state, const CSSValue& value) {
  return StyleOverflowClipMargin::CreateContent();
}

AtomicString StyleBuilderConverter::ConvertPage(StyleResolverState& state, const CSSValue& value) {
  return AtomicString();
}

float StyleBuilderConverter::ConvertPerspective(StyleResolverState& state, const CSSValue& value) {
  return -1.0f;
}

float StyleBuilderConverter::ConvertTimeValue(StyleResolverState& state, const CSSValue& value) {
  return 0.0f;
}

RotateTransformOperation* StyleBuilderConverter::ConvertRotate(StyleResolverState& state, const CSSValue& value) {
  return nullptr;
}

ScaleTransformOperation* StyleBuilderConverter::ConvertScale(StyleResolverState& state, const CSSValue& value) {
  return nullptr;
}

TabSize StyleBuilderConverter::ConvertLengthOrTabSpaces(StyleResolverState& state, const CSSValue& value) {
  return TabSize(8);
}

TextBoxEdge StyleBuilderConverter::ConvertTextBoxEdge(StyleResolverState& state, const CSSValue& value) {
  return TextBoxEdge();
}

TextDecorationThickness StyleBuilderConverter::ConvertTextDecorationThickness(StyleResolverState& state, const CSSValue& value) {
  return TextDecorationThickness();
}

TextEmphasisPosition StyleBuilderConverter::ConvertTextTextEmphasisPosition(StyleResolverState& state, const CSSValue& value) {
  return TextEmphasisPosition::kOverRight;
}

Length StyleBuilderConverter::ConvertTextUnderlineOffset(StyleResolverState& state, const CSSValue& value) {
  return Length();
}

TextUnderlinePosition StyleBuilderConverter::ConvertTextUnderlinePosition(StyleResolverState& state, const CSSValue& value) {
  return TextUnderlinePosition::kAuto;
}

ScopedCSSNameList* StyleBuilderConverter::ConvertTimelineScope(StyleResolverState& state, const CSSValue& value) {
  return nullptr;
}

TransformOperations StyleBuilderConverter::ConvertTransformOperations(StyleResolverState& state, const CSSValue& value) {
  return TransformOperations();
}

TransformOrigin StyleBuilderConverter::ConvertTransformOrigin(StyleResolverState& state, const CSSValue& value) {
  return TransformOrigin(Length::Percent(50.0), Length::Percent(50.0), 0.0);
}

}  // namespace webf
