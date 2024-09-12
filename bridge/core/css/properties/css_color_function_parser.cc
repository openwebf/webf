// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_color_function_parser.h"
#include "core/css/css_color.h"
#include "core/css/css_math_expression_node.h"
#include "core/css/css_math_function_value.h"
#include "core/css/parser/css_parser_save_point.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/css/style_color.h"

namespace webf {

struct ColorFunctionParser::FunctionMetadata {
  // The name/binding for positional color channels 0, 1 and 2.
  std::array<CSSValueID, 3> channel_name;

  // The value (number) that equals 100% for the corresponding positional color
  // channel.
  std::array<double, 3> channel_percentage;
};

namespace {

// https://www.w3.org/TR/css-color-4/#typedef-color-function
bool IsValidColorFunction(CSSValueID id) {
  switch (id) {
    case CSSValueID::kRgb:
    case CSSValueID::kRgba:
    case CSSValueID::kHsl:
    case CSSValueID::kHsla:
    case CSSValueID::kHwb:
    case CSSValueID::kLab:
    case CSSValueID::kLch:
    case CSSValueID::kOklab:
    case CSSValueID::kOklch:
    case CSSValueID::kColor:
      return true;
    default:
      return false;
  }
}

// Unique entries in kFunctionMetadataMap.
enum class FunctionMetadataEntry : uint8_t {
  kLegacyRgb,  // Color::ColorSpace::kSRGBLegacy
  kColorRgb,   // Color::ColorSpace::kSRGB,
               // Color::ColorSpace::kSRGBLinear,
               // Color::ColorSpace::kDisplayP3,
               // Color::ColorSpace::kA98RGB,
               // Color::ColorSpace::kProPhotoRGB,
               // Color::ColorSpace::kRec2020
  kColorXyz,   // Color::ColorSpace::kXYZD50,
               // Color::ColorSpace::kXYZD65
  kLab,        // Color::ColorSpace::kLab
  kOkLab,      // Color::ColorSpace::kOklab
  kLch,        // Color::ColorSpace::kLch
  kOkLch,      // Color::ColorSpace::kOklch
  kHsl,        // Color::ColorSpace::kHSL
  kHwb,        // Color::ColorSpace::kHWB
};

constexpr double kPercentNotApplicable = std::numeric_limits<double>::quiet_NaN();

std::unordered_map<FunctionMetadataEntry, ColorFunctionParser::FunctionMetadata> kFunctionMetadataMap = {
    // rgb(); percentage mapping: r,g,b=255
    {FunctionMetadataEntry::kLegacyRgb, {{CSSValueID::kR, CSSValueID::kG, CSSValueID::kB}, {255, 255, 255}}},

    // color(... <predefined-rgb-params> ...); percentage mapping: r,g,b=1
    {FunctionMetadataEntry::kColorRgb, {{CSSValueID::kR, CSSValueID::kG, CSSValueID::kB}, {1, 1, 1}}},

    // color(... <xyz-params> ...); percentage mapping: x,y,z=1
    {FunctionMetadataEntry::kColorXyz, {{CSSValueID::kX, CSSValueID::kY, CSSValueID::kZ}, {1, 1, 1}}},

    // lab(); percentage mapping: l=100 a,b=125
    {FunctionMetadataEntry::kLab, {{CSSValueID::kL, CSSValueID::kA, CSSValueID::kB}, {100, 125, 125}}},

    // oklab(); percentage mapping: l=1 a,b=0.4
    {FunctionMetadataEntry::kOkLab, {{CSSValueID::kL, CSSValueID::kA, CSSValueID::kB}, {1, 0.4, 0.4}}},

    // lch(); percentage mapping: l=100 c=150 h=n/a
    {FunctionMetadataEntry::kLch,
     {{CSSValueID::kL, CSSValueID::kC, CSSValueID::kH}, {100, 150, kPercentNotApplicable}}},

    // oklch(); percentage mapping: l=1 c=0.4 h=n/a
    {FunctionMetadataEntry::kOkLch,
     {{CSSValueID::kL, CSSValueID::kC, CSSValueID::kH}, {1, 0.4, kPercentNotApplicable}}},

    // hsl(); percentage mapping: h=n/a s,l=100
    {FunctionMetadataEntry::kHsl,
     {{CSSValueID::kH, CSSValueID::kS, CSSValueID::kL}, {kPercentNotApplicable, 100, 100}}},

    // hwb(); percentage mapping: h=n/a w,b=100
    {FunctionMetadataEntry::kHwb,
     {{CSSValueID::kH, CSSValueID::kW, CSSValueID::kB}, {kPercentNotApplicable, 100, 100}}},
};

// If the CSSValue is an absolute color, return the corresponding Color.
std::optional<Color> TryResolveAtParseTime(const CSSValue& value) {
  if (auto* color_value = DynamicTo<cssvalue::CSSColor>(value)) {
    return color_value->Value();
  }
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(value)) {
    // We can resolve <named-color> and 'transparent' at parse-time.
    CSSValueID value_id = identifier_value->GetValueID();
    if ((value_id >= CSSValueID::kAqua && value_id <= CSSValueID::kYellow) ||
        (value_id >= CSSValueID::kAliceblue && value_id <= CSSValueID::kYellowgreen) ||
        value_id == CSSValueID::kTransparent || value_id == CSSValueID::kGrey) {
      // We're passing 'light' as the color-scheme, but nothing above should
      // depend on that value (i.e it's a dummy argument). Ditto for the null
      // color provider.
      return StyleColor::ColorFromKeyword(value_id, ColorScheme::kLight);
    }
    return std::nullopt;
  }

  return std::nullopt;
}

// https://www.w3.org/TR/css-color-5/#relative-colors
// e.g. lab(from magenta l a b), consume the "magenta" after the from. The
// result needs to be a blink::Color as we need actual values for the color
// parameters.
bool ConsumeRelativeOriginColor(CSSParserTokenRange& args, const CSSParserContext& context, Color& result) {
  if (auto css_color = css_parsing_utils::ConsumeColor(args, context)) {
    if (auto absolute_color = TryResolveAtParseTime(*css_color)) {
      result = absolute_color.value();
      return true;
    }
    // TODO(crbug.com/325309578): Just like with
    // css_parsing_utils::ResolveColor(), currentcolor is not currently
    // handled.
    // TODO(crbug.com/41492196): Similarly, color-mix() with non-absolute
    // arguments is not supported as an origin color yet.
  }
  return false;
}

std::shared_ptr<const CSSValue> ConsumeRelativeColorChannel(CSSParserTokenRange& input_range,
                                                            const CSSParserContext& context,
                                                            const CSSColorChannelMap& color_channel_map,
                                                            CalculationResultCategorySet expected_categories,
                                                            const double percentage_base = 0) {
  const CSSParserToken& token = input_range.Peek();
  // Relative color channels can be calc() functions with color channel
  // replacements. e.g. In "color(from magenta srgb calc(r / 2) 0 0)", the
  // "calc" should substitute "1" for "r" (magenta has a full red channel).
  if (token.GetType() == kFunctionToken) {
    using enum CSSMathExpressionNode::Flag;
    using Flags = CSSMathExpressionNode::Flags;

    // Don't consume the range if the parsing fails.
    CSSParserTokenRange calc_range = input_range;
    auto calc_value =
        CSSMathFunctionValue::Create(CSSMathExpressionNode::ParseMathFunction(
                                         token.FunctionId(), css_parsing_utils::ConsumeFunction(calc_range), context,
                                         Flags({AllowPercent}), kCSSAnchorQueryTypesNone, color_channel_map),
                                     CSSPrimitiveValue::ValueRange::kAll);
    if (calc_value) {
      const CalculationResultCategory category = calc_value->Category();
      if (!expected_categories.Has(category)) {
        return nullptr;
      }
      // Consume the range, since it has succeeded.
      input_range = calc_range;
      return calc_value;
    }
  }

  // This is for just single variable swaps without calc(). e.g. The "l" in
  // "lab(from cyan l 0.5 0.5)".
  if (color_channel_map.count(token.Id()) > 0) {
    return css_parsing_utils::ConsumeIdent(input_range);
  }

  return nullptr;
}

}  // namespace

bool ColorFunctionParser::ConsumeChannel(CSSParserTokenRange& args, const CSSParserContext& context, int i) {
  if (css_parsing_utils::ConsumeIdent<CSSValueID::kNone>(args)) {
    channel_types_[i] = ChannelType::kNone;
    has_none_ = true;
    return true;
  }

  if ((unresolved_channels_[i] =
           css_parsing_utils::ConsumeNumber(args, context, CSSPrimitiveValue::ValueRange::kAll))) {
    channel_types_[i] = ChannelType::kNumber;
    return true;
  }

  if ((unresolved_channels_[i] =
           css_parsing_utils::ConsumePercent(args, context, CSSPrimitiveValue::ValueRange::kAll))) {
    channel_types_[i] = ChannelType::kPercentage;
    return true;
  }

  // Missing components should not parse.
  return false;
}

bool ColorFunctionParser::ConsumeAlpha(CSSParserTokenRange& args, const CSSParserContext& context) {
  if ((unresolved_alpha_ = css_parsing_utils::ConsumeNumber(args, context, CSSPrimitiveValue::ValueRange::kAll))) {
    alpha_channel_type_ = ChannelType::kNumber;
    return true;
  }

  if ((unresolved_alpha_ = css_parsing_utils::ConsumePercent(args, context, CSSPrimitiveValue::ValueRange::kAll))) {
    alpha_channel_type_ = ChannelType::kPercentage;
    return true;
  }

  if (css_parsing_utils::ConsumeIdent<CSSValueID::kNone>(args)) {
    has_none_ = true;
    alpha_channel_type_ = ChannelType::kNone;
    return true;
  }

  if (is_relative_color_ && (unresolved_alpha_ = ConsumeRelativeColorChannel(args, context, color_channel_map_,
                                                                             {kCalcNumber, kCalcPercent}, 1.0))) {
    alpha_channel_type_ = ChannelType::kRelative;
    return true;
  }

  return false;
}

std::optional<double> ColorFunctionParser::TryResolveColorChannel(const std::shared_ptr<const CSSValue>& value,
                                                                  ChannelType channel_type,
                                                                  double percentage_base,
                                                                  const CSSColorChannelMap& color_channel_map) {
  if (const auto* primitive_value = DynamicTo<CSSPrimitiveValue>(value.get())) {
    switch (channel_type) {
      case ChannelType::kNumber:
        if (primitive_value->IsAngle()) {
          return primitive_value->ComputeDegrees();
        } else {
          return primitive_value->GetDoubleValueWithoutClamping();
        }
      case ChannelType::kPercentage:
        return (primitive_value->GetDoubleValue() / 100.0) * percentage_base;
      case ChannelType::kRelative:
        // Proceed to relative channel value resolution below.
        break;
      default:
        assert(false);
    }
  }

  return TryResolveRelativeChannelValue(value, channel_type, percentage_base, color_channel_map);
}

std::optional<double> ColorFunctionParser::TryResolveAlpha(const std::shared_ptr<const CSSValue>& value,
                                                           ChannelType channel_type,
                                                           const CSSColorChannelMap& color_channel_map) {
  if (const CSSPrimitiveValue* primitive_value = DynamicTo<CSSPrimitiveValue>(value.get())) {
    switch (channel_type) {
      case ChannelType::kNumber:
        return ClampTo<double>(primitive_value->GetDoubleValue(), 0.0, 1.0);
      case ChannelType::kPercentage:
        return ClampTo<double>(primitive_value->GetDoubleValue() / 100.0, 0.0, 1.0);
      case ChannelType::kRelative:
        // Proceed to relative channel value resolution below.
        break;
      default:
        assert(false);
    }
  }

  return TryResolveRelativeChannelValue(value, channel_type, /*percentage_base=*/1.0, color_channel_map);
}

std::optional<double> ColorFunctionParser::TryResolveRelativeChannelValue(const std::shared_ptr<const CSSValue>& value,
                                                                          ChannelType channel_type,
                                                                          double percentage_base,
                                                                          const CSSColorChannelMap& color_channel_map) {
  if (const auto* identifier_value = DynamicTo<CSSIdentifierValue>(value.get())) {
    // This is for just single variable swaps without calc(). e.g. The "l" in
    // "lab(from cyan l 0.5 0.5)".
    if (auto it = color_channel_map.find(identifier_value->GetValueID()); it != color_channel_map.end()) {
      return it->second;
    }
  }

  if (const CSSMathFunctionValue* calc_value = DynamicTo<CSSMathFunctionValue>(value.get())) {
    switch (calc_value->Category()) {
      case kCalcNumber:
        return calc_value->GetDoubleValueWithoutClamping();
      case kCalcPercent:
        return (calc_value->GetDoubleValue() / 100) * percentage_base;
      case kCalcAngle:
        return calc_value->ComputeDegrees();
      default:
        assert(false);
        return std::nullopt;
    }
  }

  return std::nullopt;
}

std::shared_ptr<const CSSValue> ColorFunctionParser::ConsumeFunctionalSyntaxColor(CSSParserTokenRange& input_range,
                                                                                  const CSSParserContext& context) {
  return ConsumeFunctionalSyntaxColorInternal(input_range, context);
}

std::shared_ptr<const CSSValue> ColorFunctionParser::ConsumeFunctionalSyntaxColor(CSSParserTokenStream& input_stream,
                                                                                  const CSSParserContext& context) {
  return ConsumeFunctionalSyntaxColorInternal(input_stream, context);
}

template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ColorFunctionParser::ConsumeFunctionalSyntaxColorInternal(T& range, const CSSParserContext& context) {
  CSSParserSavePoint savepoint(range);

  CSSValueID function_id = range.Peek().FunctionId();
  if (!IsValidColorFunction(function_id)) {
    return nullptr;
  }

  CSSParserTokenRange args = css_parsing_utils::ConsumeFunction(range);

  // Parse the three color channel params.
  for (int i = 0; i < 3; i++) {
    if (!ConsumeChannel(args, context, i)) {
      return nullptr;
    }
    // Potentially expect a separator after the first and second channel. The
    // separator for a potential alpha channel is handled below.
    if (i < 2) {
      const bool matched_comma = css_parsing_utils::ConsumeCommaIncludingWhitespace(args);
      if (is_legacy_syntax_) {
        // We've parsed one separating comma token, so we expect the second
        // separator to match.
        if (!matched_comma) {
          return nullptr;
        }
      } else if (matched_comma) {
        if (is_relative_color_) {
          return nullptr;
        }
        is_legacy_syntax_ = true;
      }
    }
  }

  // Parse alpha.
  bool expect_alpha = false;
  if (is_legacy_syntax_) {
    // , <alpha-value>?
    if (css_parsing_utils::ConsumeCommaIncludingWhitespace(args)) {
      expect_alpha = true;
    }
  } else {
    // / <alpha-value>?
    if (css_parsing_utils::ConsumeSlashIncludingWhitespace(args)) {
      expect_alpha = true;
    }
  }
  if (expect_alpha) {
    if (!ConsumeAlpha(args, context)) {
      return nullptr;
    }
  }

  // "None" is not a part of the legacy syntax.
  if (!args.AtEnd() || (is_legacy_syntax_ && has_none_)) {
    return nullptr;
  }

  if (expect_alpha) {
    if (alpha_channel_type_ != ChannelType::kNone) {
      alpha_ = TryResolveAlpha(unresolved_alpha_, alpha_channel_type_, color_channel_map_);
    } else {
      alpha_.reset();
    }
  } else if (is_relative_color_) {
    alpha_ = color_channel_map_.at(CSSValueID::kAlpha);
  }

  Color result = Color::FromColor(channels_[0], channels_[1], channels_[2], alpha_);
  // The parsing was successful, so we need to consume the input.
  savepoint.Release();

  return cssvalue::CSSColor::Create(result);
}

}  // namespace webf