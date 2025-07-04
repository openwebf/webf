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
                                                   const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    if (identifier_value->GetValueID() == CSSValueID::kCurrentcolor) {
      return StyleColor::CurrentColor();
    }
  }
  
  return StyleColor(ConvertColor(state, value));
}

Color StyleBuilderConverter::ConvertColor(const StyleResolverState& state,
                                         const CSSValue& value) {
  if (auto* color_value = DynamicTo<CSSInitialColorValue>(&value)) {
    // CSSInitialColorValue doesn't have a Value() method in WebF
    // Return a default color for initial color value
    return Color::kBlack;
  }
  
  // TODO: Handle more color types when available (rgb(), rgba(), hsl(), etc.)
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

FontSelectionValue StyleBuilderConverter::ConvertFontWeight(const StyleResolverState& state,
                                                          const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kNormal:
        return FontSelectionValue(400);
      case CSSValueID::kBold:
        return FontSelectionValue(700);
      case CSSValueID::kBolder:
        // TODO: Calculate based on parent weight
        return FontSelectionValue(700);
      case CSSValueID::kLighter:
        // TODO: Calculate based on parent weight
        return FontSelectionValue(300);
      default:
        break;
    }
  }
  
  if (auto* numeric_value = DynamicTo<CSSNumericLiteralValue>(&value)) {
    return FontSelectionValue(numeric_value->GetFloatValue());
  }
  
  return FontSelectionValue(400); // Normal weight
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

}  // namespace webf