// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/properties/css_parsing_utils.h"
#include "core/base/containers/span.h"
#include "core/css/css_appearance_auto_base_select_value_pair.h"
#include "core/css/css_axis_value.h"
#include "core/css/css_basic_shape_value.h"
#include "core/css/css_border_image.h"
#include "core/css/css_border_image_slice_value.h"
#include "core/css/css_bracketed_value_list.h"
#include "core/css/css_color_channel_map.h"
#include "core/css/css_content_distribution_value.h"
#include "core/css/css_crossfade_value.h"
#include "core/css/css_font_family_value.h"
#include "core/css/css_font_feature_value.h"
#include "core/css/css_font_style_range_value.h"
#include "core/css/css_function_value.h"
#include "core/css/css_gradient_value.h"
#include "core/css/css_grid_auto_repeat_value.h"
#include "core/css/css_grid_integer_repeat_value.h"
#include "core/css/css_grid_template_areas_value.h"
#include "core/css/css_image_set_option_value.h"
#include "core/css/css_image_set_type_value.h"
#include "core/css/css_image_set_value.h"
#include "core/css/css_image_value.h"
#include "core/css/css_inherit_value.h"
#include "core/css/css_initial_value.h"
#include "core/css/css_light_dart_value_pair.h"
#include "core/css/css_math_expression_node.h"
#include "core/css/css_math_function_value.h"
#include "core/css/css_quad_value.h"
#include "core/css/css_ratio_value.h"
#include "core/css/css_ray_value.h"
#include "core/css/css_revert_layer_value.h"
#include "core/css/css_revert_value.h"
#include "core/css/css_scroll_value.h"
#include "core/css/css_shadow_value.h"
#include "core/css/css_timing_function_value.h"
#include "core/css/css_unset_value.h"
#include "core/css/css_uri_value.h"
#include "core/css/parser/css_parser_fast_path.h"
#include "core/css/parser/css_parser_idioms.h"
#include "core/css/parser/css_parser_save_point.h"
#include "core/css/properties/css_color_function_parser.h"
#include "core/css/properties/longhand.h"
#include "core/css/style_color.h"
#include "core/platform/graphics/color.h"
#include "core/style/grid_area.h"
#include "foundation/macros.h"
#include "style_property_shorthand.h"

#include <cmath>
#include <memory>
#include <utility>

namespace webf {
namespace css_parsing_utils {

// https://drafts.csswg.org/css-syntax/#typedef-any-value
bool IsTokenAllowedForAnyValue(const CSSParserToken& token) {
  switch (token.GetType()) {
    case kBadStringToken:
    case kEOFToken:
    case kBadUrlToken:
      return false;
    case kRightParenthesisToken:
    case kRightBracketToken:
    case kRightBraceToken:
      return token.GetBlockType() == CSSParserToken::kBlockEnd;
    default:
      return true;
  }
}

void Complete4Sides(std::shared_ptr<const CSSValue> side[4]) {
  if (side[3]) {
    return;
  }
  if (!side[2]) {
    if (!side[1]) {
      side[1] = side[0];
    }
    side[2] = side[0];
  }
  side[3] = side[1];
}

bool ConsumeCommaIncludingWhitespace(CSSParserTokenRange& range) {
  CSSParserToken value = range.Peek();
  if (value.GetType() != kCommaToken) {
    return false;
  }
  range.ConsumeIncludingWhitespace();
  return true;
}

bool ConsumeCommaIncludingWhitespace(CSSParserTokenStream& stream) {
  CSSParserToken value = stream.Peek();
  if (value.GetType() != kCommaToken) {
    return false;
  }
  stream.ConsumeIncludingWhitespace();
  return true;
}

bool ConsumeSlashIncludingWhitespace(CSSParserTokenRange& range) {
  CSSParserToken value = range.Peek();
  if (value.GetType() != kDelimiterToken || value.Delimiter() != '/') {
    return false;
  }
  range.ConsumeIncludingWhitespace();
  return true;
}

bool ConsumeSlashIncludingWhitespace(CSSParserTokenStream& stream) {
  CSSParserToken value = stream.Peek();
  if (value.GetType() != kDelimiterToken || value.Delimiter() != '/') {
    return false;
  }
  stream.ConsumeIncludingWhitespace();
  return true;
}

CSSParserTokenRange ConsumeFunction(CSSParserTokenRange& range) {
  assert(range.Peek().GetType() == kFunctionToken);
  CSSParserTokenRange contents = range.ConsumeBlock();
  range.ConsumeWhitespace();
  contents.ConsumeWhitespace();
  return contents;
}

CSSParserTokenRange ConsumeFunction(CSSParserTokenStream& stream) {
  assert(stream.Peek().GetType() == kFunctionToken);
  CSSParserTokenRange contents((std::vector<CSSParserToken>()));
  {
    CSSParserTokenStream::BlockGuard guard(stream);
    contents = stream.ConsumeUntilPeekedTypeIs<>();
  }
  stream.ConsumeWhitespace();
  contents.ConsumeWhitespace();
  return contents;
}

bool ConsumeAnyValue(CSSParserTokenRange& range) {
  bool result = IsTokenAllowedForAnyValue(range.Peek());
  unsigned nesting_level = 0;

  while (nesting_level || result) {
    const CSSParserToken& token = range.Consume();
    if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      nesting_level++;
    } else if (token.GetBlockType() == CSSParserToken::kBlockEnd) {
      nesting_level--;
    }
    if (range.AtEnd()) {
      return result;
    }
    result = result && IsTokenAllowedForAnyValue(range.Peek());
  }

  return result;
}

// MathFunctionParser is a helper for parsing something that _might_ be a
// function. In particular, it helps rewinding the parser to the point where it
// started if what was to be parsed was not a function (or an invalid function).
// This rewinding happens in the destructor, unless Consume*() was called _and_
// returned success. In effect, this gives us a multi-token peek for functions.
//
// TODO(rwlbuis): consider pulling in the parsing logic from
// css_math_expression_node.cc.
template <class T = CSSParserTokenRange>
class MathFunctionParser {
  static_assert(std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                "T must be either CSSParserTokenStream or CSSParserTokenRange");
  WEBF_STACK_ALLOCATED();

 public:
  using Flag = CSSMathExpressionNode::Flag;
  using Flags = CSSMathExpressionNode::Flags;

  MathFunctionParser(T& stream,
                     std::shared_ptr<const CSSParserContext> context,
                     CSSPrimitiveValue::ValueRange value_range,
                     const Flags parsing_flags = Flags({Flag::AllowPercent}),
                     CSSAnchorQueryTypes allowed_anchor_queries = kCSSAnchorQueryTypesNone,
                     const CSSColorChannelMap& color_channel_map = {})
      : stream_(&stream), savepoint_(Save(stream)) {
    const CSSParserToken token = stream.Peek();
    if (token.GetType() == kFunctionToken) {
      auto math_function = CSSMathExpressionNode::ParseMathFunction(token.FunctionId(), ConsumeFunction(*stream_),
                                                                    context, parsing_flags, allowed_anchor_queries);
      calc_value_ = CSSMathFunctionValue::Create(math_function, value_range);
    }
  }

  ~MathFunctionParser() {
    if (!has_consumed_) {
      // Rewind the parser.
      if constexpr (std::is_same_v<T, CSSParserTokenRange>) {
        *stream_ = savepoint_;
      } else {
        stream_->Restore(savepoint_);
      }
    }
  }

  const std::shared_ptr<const CSSMathFunctionValue>* Value() const { return &calc_value_; }
  const std::shared_ptr<const CSSMathFunctionValue> ConsumeValue() {
    if (!calc_value_) {
      return nullptr;
    }
    assert(!has_consumed_);  // Cannot consume twice.
    has_consumed_ = true;
    const std::shared_ptr<const CSSMathFunctionValue> result = calc_value_;
    calc_value_ = nullptr;
    return result;
  }

  bool ConsumeNumberRaw(double& result) {
    if (!calc_value_ || calc_value_->Category() != kCalcNumber) {
      return false;
    }
    assert(!has_consumed_);  // Cannot consume twice.
    has_consumed_ = true;
    result = calc_value_->GetDoubleValue();
    return true;
  }

 private:
  bool has_consumed_ = false;
  T* stream_;
  // For rewinding.
  std::conditional_t<std::is_same_v<T, CSSParserTokenStream>, CSSParserTokenStream::State, CSSParserTokenRange>
      savepoint_;
  std::shared_ptr<const CSSMathFunctionValue> calc_value_ = nullptr;

  decltype(savepoint_) Save(T& stream) {
    if constexpr (std::is_same_v<T, CSSParserTokenRange>) {
      return stream;
    } else {
      return stream.Save();
    }
  }
};

template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeIntegerInternal(T& range,
                       std::shared_ptr<const CSSParserContext> context,
                       double minimum_value,
                       const bool is_percentage_allowed) {
  const CSSParserToken token = range.Peek();
  if (token.GetType() == kNumberToken) {
    if (token.GetNumericValueType() == kNumberValueType || token.NumericValue() < minimum_value) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(),
                                          CSSPrimitiveValue::UnitType::kInteger);
  }

  assert(minimum_value == -std::numeric_limits<double>::max() || minimum_value == 0 || minimum_value == 1);

  CSSPrimitiveValue::ValueRange value_range = CSSPrimitiveValue::ValueRange::kInteger;
  if (minimum_value == 0) {
    value_range = CSSPrimitiveValue::ValueRange::kNonNegativeInteger;
  } else if (minimum_value == 1) {
    value_range = CSSPrimitiveValue::ValueRange::kPositiveInteger;
  }

  using Flags = CSSMathExpressionNode::Flags;

  Flags parsing_flags;
  if (is_percentage_allowed) {
    parsing_flags.Put(CSSMathExpressionNode::Flag::AllowPercent);
  }

  MathFunctionParser<T> math_parser(range, context, value_range, parsing_flags);
  if (const std::shared_ptr<const CSSMathFunctionValue> math_value = *math_parser.Value()) {
    if (math_value->Category() != kCalcNumber) {
      return nullptr;
    }
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeInteger(CSSParserTokenRange& range,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        double minimum_value,
                                                        const bool is_percentage_allowed) {
  return ConsumeIntegerInternal(range, context, minimum_value, is_percentage_allowed);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeInteger(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        double minimum_value,
                                                        const bool is_percentage_allowed) {
  return ConsumeIntegerInternal(stream, context, minimum_value, is_percentage_allowed);
}

// This implements the behavior defined in [1], where calc() expressions
// are valid when <integer> is expected, even if the calc()-expression does
// not result in an integral value.
//
// TODO(andruud): Eventually this behavior should just be part of
// ConsumeInteger, and this function can be removed. For now, having a separate
// function with this behavior allows us to implement [1] gradually.
//
// [1] https://drafts.csswg.org/css-values-4/#calc-type-checking
template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeIntegerOrNumberCalc(T& range,
                           std::shared_ptr<const CSSParserContext> context,
                           CSSPrimitiveValue::ValueRange value_range) {
  double minimum_value = -std::numeric_limits<double>::max();
  switch (value_range) {
    case CSSPrimitiveValue::ValueRange::kAll:
      assert_m(false, "unexpected value range for integer parsing");
      [[fallthrough]];
    case CSSPrimitiveValue::ValueRange::kInteger:
      minimum_value = -std::numeric_limits<double>::max();
      break;
    case CSSPrimitiveValue::ValueRange::kNonNegative:
      assert_m(false, "unexpected value range for integer parsing");
      [[fallthrough]];
    case CSSPrimitiveValue::ValueRange::kNonNegativeInteger:
      minimum_value = 0.0;
      break;
    case CSSPrimitiveValue::ValueRange::kPositiveInteger:
      minimum_value = 1.0;
      break;
  }
  if (auto value = ConsumeInteger(range, context, minimum_value)) {
    return value;
  }

  MathFunctionParser math_parser(range, context, value_range);
  if (auto calculation = *math_parser.Value()) {
    if (calculation->Category() != kCalcNumber) {
      return nullptr;
    }
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

template std::shared_ptr<const CSSPrimitiveValue> ConsumeIntegerOrNumberCalc(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context,
    CSSPrimitiveValue::ValueRange value_range);
template std::shared_ptr<const CSSPrimitiveValue> ConsumeIntegerOrNumberCalc(
    CSSParserTokenRange& range,
    std::shared_ptr<const CSSParserContext> context,
    CSSPrimitiveValue::ValueRange value_range);

std::shared_ptr<const CSSPrimitiveValue> ConsumePositiveInteger(CSSParserTokenRange& range,
                                                                std::shared_ptr<const CSSParserContext> context) {
  return ConsumeInteger(range, context, 1);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumePositiveInteger(CSSParserTokenStream& stream,
                                                                std::shared_ptr<const CSSParserContext> context) {
  return ConsumeInteger(stream, context, 1);
}

bool ConsumeNumberRaw(CSSParserTokenRange& range, std::shared_ptr<const CSSParserContext> context, double& result) {
  if (range.Peek().GetType() == kNumberToken) {
    result = range.ConsumeIncludingWhitespace().NumericValue();
    return true;
  }
  MathFunctionParser math_parser(range, context, CSSPrimitiveValue::ValueRange::kAll);
  return math_parser.ConsumeNumberRaw(result);
}

bool ConsumeNumberRaw(CSSParserTokenStream& stream, std::shared_ptr<const CSSParserContext> context, double& result) {
  if (stream.Peek().GetType() == kNumberToken) {
    result = stream.ConsumeIncludingWhitespace().NumericValue();
    return true;
  }
  MathFunctionParser math_parser(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  return math_parser.ConsumeNumberRaw(result);
}

// TODO(timloh): Work out if this can just call consumeNumberRaw
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumber(CSSParserTokenRange& range,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       CSSPrimitiveValue::ValueRange value_range) {
  const CSSParserToken& token = range.Peek();
  if (token.GetType() == kNumberToken) {
    if (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(), token.GetUnitType());
  }
  MathFunctionParser math_parser(range, context, value_range);
  if (auto calculation = *math_parser.Value()) {
    if (calculation->Category() != kCalcNumber) {
      return nullptr;
    }
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeNumber(CSSParserTokenStream& stream,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       CSSPrimitiveValue::ValueRange value_range) {
  const CSSParserToken token = stream.Peek();
  if (token.GetType() == kNumberToken) {
    if (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(stream.ConsumeIncludingWhitespace().NumericValue(), token.GetUnitType());
  }
  MathFunctionParser math_parser(stream, context, value_range);
  if (auto calculation = *math_parser.Value()) {
    if (calculation->Category() != kCalcNumber) {
      return nullptr;
    }
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

inline bool ShouldAcceptUnitlessLength(double value, CSSParserMode css_parser_mode, UnitlessQuirk unitless) {
  return value == 0 || css_parser_mode == kSVGAttributeMode ||
         (css_parser_mode == kHTMLQuirksMode && unitless == UnitlessQuirk::kAllow);
}

template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeLengthInternal(T& range,
                      std::shared_ptr<const CSSParserContext> context,
                      CSSPrimitiveValue::ValueRange value_range,
                      UnitlessQuirk unitless) {
  const CSSParserToken token = range.Peek();
  if (token.GetType() == kDimensionToken) {
    switch (token.GetUnitType()) {
      case CSSPrimitiveValue::UnitType::kQuirkyEms:
        if (context->Mode() != kUASheetMode) {
          return nullptr;
        }
        [[fallthrough]];
      case CSSPrimitiveValue::UnitType::kEms:
      case CSSPrimitiveValue::UnitType::kRems:
      case CSSPrimitiveValue::UnitType::kChs:
      case CSSPrimitiveValue::UnitType::kExs:
      case CSSPrimitiveValue::UnitType::kPixels:
      case CSSPrimitiveValue::UnitType::kCentimeters:
      case CSSPrimitiveValue::UnitType::kMillimeters:
      case CSSPrimitiveValue::UnitType::kQuarterMillimeters:
      case CSSPrimitiveValue::UnitType::kInches:
      case CSSPrimitiveValue::UnitType::kPoints:
      case CSSPrimitiveValue::UnitType::kPicas:
      case CSSPrimitiveValue::UnitType::kUserUnits:
      case CSSPrimitiveValue::UnitType::kViewportWidth:
      case CSSPrimitiveValue::UnitType::kViewportHeight:
      case CSSPrimitiveValue::UnitType::kViewportMin:
      case CSSPrimitiveValue::UnitType::kViewportMax:
      case CSSPrimitiveValue::UnitType::kIcs:
      case CSSPrimitiveValue::UnitType::kLhs:
      case CSSPrimitiveValue::UnitType::kRexs:
      case CSSPrimitiveValue::UnitType::kRchs:
      case CSSPrimitiveValue::UnitType::kRics:
      case CSSPrimitiveValue::UnitType::kRlhs:
      case CSSPrimitiveValue::UnitType::kCaps:
      case CSSPrimitiveValue::UnitType::kRcaps:
      case CSSPrimitiveValue::UnitType::kViewportInlineSize:
      case CSSPrimitiveValue::UnitType::kViewportBlockSize:
      case CSSPrimitiveValue::UnitType::kSmallViewportWidth:
      case CSSPrimitiveValue::UnitType::kSmallViewportHeight:
      case CSSPrimitiveValue::UnitType::kSmallViewportInlineSize:
      case CSSPrimitiveValue::UnitType::kSmallViewportBlockSize:
      case CSSPrimitiveValue::UnitType::kSmallViewportMin:
      case CSSPrimitiveValue::UnitType::kSmallViewportMax:
      case CSSPrimitiveValue::UnitType::kLargeViewportWidth:
      case CSSPrimitiveValue::UnitType::kLargeViewportHeight:
      case CSSPrimitiveValue::UnitType::kLargeViewportInlineSize:
      case CSSPrimitiveValue::UnitType::kLargeViewportBlockSize:
      case CSSPrimitiveValue::UnitType::kLargeViewportMin:
      case CSSPrimitiveValue::UnitType::kLargeViewportMax:
      case CSSPrimitiveValue::UnitType::kDynamicViewportWidth:
      case CSSPrimitiveValue::UnitType::kDynamicViewportHeight:
      case CSSPrimitiveValue::UnitType::kDynamicViewportInlineSize:
      case CSSPrimitiveValue::UnitType::kDynamicViewportBlockSize:
      case CSSPrimitiveValue::UnitType::kDynamicViewportMin:
      case CSSPrimitiveValue::UnitType::kDynamicViewportMax:
      case CSSPrimitiveValue::UnitType::kContainerWidth:
      case CSSPrimitiveValue::UnitType::kContainerHeight:
      case CSSPrimitiveValue::UnitType::kContainerInlineSize:
      case CSSPrimitiveValue::UnitType::kContainerBlockSize:
      case CSSPrimitiveValue::UnitType::kContainerMin:
      case CSSPrimitiveValue::UnitType::kContainerMax:
        break;
      default:
        return nullptr;
    }
    if (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(), token.GetUnitType());
  }
  if (token.GetType() == kNumberToken) {
    if (!ShouldAcceptUnitlessLength(token.NumericValue(), context->Mode(), unitless) ||
        (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0)) {
      return nullptr;
    }
    CSSPrimitiveValue::UnitType unit_type = CSSPrimitiveValue::UnitType::kPixels;
    if (context->Mode() == kSVGAttributeMode) {
      unit_type = CSSPrimitiveValue::UnitType::kUserUnits;
    }
    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(), unit_type);
  }
  if (context->Mode() == kSVGAttributeMode) {
    return nullptr;
  }
  MathFunctionParser math_parser(range, context, value_range);
  if (math_parser.Value()->get() && math_parser.Value()->get()->Category() == kCalcLength) {
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLength(CSSParserTokenRange& range,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       CSSPrimitiveValue::ValueRange value_range,
                                                       UnitlessQuirk unitless) {
  return ConsumeLengthInternal(range, context, value_range, unitless);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLength(CSSParserTokenStream& stream,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       CSSPrimitiveValue::ValueRange value_range,
                                                       UnitlessQuirk unitless) {
  return ConsumeLengthInternal(stream, context, value_range, unitless);
}

template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumePercentInternal(T& range,
                       std::shared_ptr<const CSSParserContext> context,
                       CSSPrimitiveValue::ValueRange value_range) {
  const CSSParserToken token = range.Peek();
  if (token.GetType() == kPercentageToken) {
    if (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(),
                                          CSSPrimitiveValue::UnitType::kPercentage);
  }
  MathFunctionParser math_parser(range, context, value_range);
  if (auto calculation = *math_parser.Value()) {
    if (calculation->Category() == kCalcPercent) {
      return math_parser.ConsumeValue();
    }
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumePercent(CSSParserTokenRange& range,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        CSSPrimitiveValue::ValueRange value_range) {
  return ConsumePercentInternal(range, context, value_range);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumePercent(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        CSSPrimitiveValue::ValueRange value_range) {
  return ConsumePercentInternal(stream, context, value_range);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeNumberOrPercent(CSSParserTokenRange& range,
                                                                std::shared_ptr<const CSSParserContext> context,
                                                                CSSPrimitiveValue::ValueRange value_range) {
  if (auto value = ConsumeNumber(range, context, value_range)) {
    return value;
  }
  if (auto value = ConsumePercent(range, context, value_range)) {
    return CSSNumericLiteralValue::Create(value->GetDoubleValue() / 100.0, CSSPrimitiveValue::UnitType::kNumber);
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeNumberOrPercent(CSSParserTokenStream& stream,
                                                                std::shared_ptr<const CSSParserContext> context,
                                                                CSSPrimitiveValue::ValueRange value_stream) {
  if (auto value = ConsumeNumber(stream, context, value_stream)) {
    return value;
  }
  if (auto value = ConsumePercent(stream, context, value_stream)) {
    return CSSNumericLiteralValue::Create(value->GetDoubleValue() / 100.0, CSSPrimitiveValue::UnitType::kNumber);
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeAlphaValue(CSSParserTokenStream& stream,
                                                           std::shared_ptr<const CSSParserContext> context) {
  return ConsumeNumberOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

bool CanConsumeCalcValue(CalculationResultCategory category, CSSParserMode css_parser_mode) {
  return category == kCalcLength || category == kCalcPercent || category == kCalcLengthFunction ||
         category == kCalcIntrinsicSize || (css_parser_mode == kSVGAttributeMode && category == kCalcNumber);
}

template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeLengthOrPercentInternal(T& range,
                               std::shared_ptr<const CSSParserContext> context,
                               CSSPrimitiveValue::ValueRange value_range,
                               UnitlessQuirk unitless,
                               CSSAnchorQueryTypes allowed_anchor_queries,
                               AllowCalcSize allow_calc_size) {
  using Flags = CSSMathExpressionNode::Flags;

  const CSSParserToken& token = range.Peek();
  if (token.GetType() == kDimensionToken || token.GetType() == kNumberToken) {
    return ConsumeLength(range, context, value_range, unitless);
  }
  if (token.GetType() == kPercentageToken) {
    return ConsumePercent(range, context, value_range);
  }
  Flags parsing_flags({CSSMathExpressionNode::Flag::AllowPercent});
  switch (allow_calc_size) {
    case AllowCalcSize::kAllowWithAutoAndContent:
      parsing_flags.Put(CSSMathExpressionNode::Flag::AllowContentInCalcSize);
      [[fallthrough]];
    case AllowCalcSize::kAllowWithAuto:
      parsing_flags.Put(CSSMathExpressionNode::Flag::AllowAutoInCalcSize);
      [[fallthrough]];
    case AllowCalcSize::kAllowWithoutAuto:
      parsing_flags.Put(CSSMathExpressionNode::Flag::AllowCalcSize);
      [[fallthrough]];
    case AllowCalcSize::kForbid:
      break;
  }
  MathFunctionParser math_parser(range, context, value_range, parsing_flags, allowed_anchor_queries);
  if (auto calculation = *math_parser.Value()) {
    if (CanConsumeCalcValue(calculation->Category(), context->Mode())) {
      return math_parser.ConsumeValue();
    }
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercent(CSSParserTokenRange& range,
                                                                std::shared_ptr<const CSSParserContext> context,
                                                                CSSPrimitiveValue::ValueRange value_range,
                                                                UnitlessQuirk unitless,
                                                                CSSAnchorQueryTypes allowed_anchor_queries,
                                                                AllowCalcSize allow_calc_size) {
  return ConsumeLengthOrPercentInternal(range, context, value_range, unitless, allowed_anchor_queries, allow_calc_size);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercent(CSSParserTokenStream& stream,
                                                                std::shared_ptr<const CSSParserContext> context,
                                                                CSSPrimitiveValue::ValueRange value_range,
                                                                UnitlessQuirk unitless,
                                                                CSSAnchorQueryTypes allowed_anchor_queries,
                                                                AllowCalcSize allow_calc_size) {
  return ConsumeLengthOrPercentInternal(stream, context, value_range, unitless, allowed_anchor_queries,
                                        allow_calc_size);
}

template <class T>
static
    typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                            std::shared_ptr<const CSSPrimitiveValue>>::type
    ConsumeNumericLiteralAngle(T& range, std::shared_ptr<const CSSParserContext> context) {
  const CSSParserToken token = range.Peek();
  if (token.GetType() == kDimensionToken) {
    switch (token.GetUnitType()) {
      case CSSPrimitiveValue::UnitType::kDegrees:
      case CSSPrimitiveValue::UnitType::kRadians:
      case CSSPrimitiveValue::UnitType::kGradians:
      case CSSPrimitiveValue::UnitType::kTurns:
        return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(), token.GetUnitType());
      default:
        return nullptr;
    }
  }
  if (token.GetType() == kNumberToken && token.NumericValue() == 0) {
    range.ConsumeIncludingWhitespace();
    return CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kDegrees);
  }
  return nullptr;
}

template <class T>
static
    typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                            std::shared_ptr<const CSSPrimitiveValue>>::type
    ConsumeMathFunctionAngle(T& range, std::shared_ptr<const CSSParserContext> context) {
  MathFunctionParser<T> math_parser(range, context, CSSPrimitiveValue::ValueRange::kAll);
  if (auto calculation = *math_parser.Value()) {
    if (calculation->Category() != kCalcAngle) {
      return nullptr;
    }
  }
  return math_parser.ConsumeValue();
}

template <class T>
static
    typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                            std::shared_ptr<const CSSPrimitiveValue>>::type
    ConsumeMathFunctionAngle(T& range,
                             std::shared_ptr<const CSSParserContext> context,
                             double minimum_value,
                             double maximum_value) {
  MathFunctionParser math_parser(range, context, CSSPrimitiveValue::ValueRange::kAll);
  if (auto calculation = *math_parser.Value()) {
    if (calculation->Category() != kCalcAngle) {
      return nullptr;
    }
  }
  if (auto result = math_parser.ConsumeValue()) {
    if (result->ComputeDegrees() < minimum_value) {
      return CSSNumericLiteralValue::Create(minimum_value, CSSPrimitiveValue::UnitType::kDegrees);
    }
    if (result->ComputeDegrees() > maximum_value) {
      return CSSNumericLiteralValue::Create(maximum_value, CSSPrimitiveValue::UnitType::kDegrees);
    }
    return result;
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      double minimum_value,
                                                      double maximum_value) {
  if (auto result = ConsumeNumericLiteralAngle(stream, context)) {
    return result;
  }

  return ConsumeMathFunctionAngle(stream, context, minimum_value, maximum_value);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenRange& range,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      double minimum_value,
                                                      double maximum_value) {
  if (auto result = ConsumeNumericLiteralAngle(range, context)) {
    return result;
  }

  return ConsumeMathFunctionAngle(range, context, minimum_value, maximum_value);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenRange& range,
                                                      std::shared_ptr<const CSSParserContext> context) {
  if (auto result = ConsumeNumericLiteralAngle(range, context)) {
    return result;
  }

  return ConsumeMathFunctionAngle(range, context);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context) {
  if (auto result = ConsumeNumericLiteralAngle(stream, context)) {
    return result;
  }

  return ConsumeMathFunctionAngle(stream, context);
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeTime(T& stream, std::shared_ptr<const CSSParserContext> context, CSSPrimitiveValue::ValueRange value_range) {
  const CSSParserToken token = stream.Peek();
  if (token.GetType() == kDimensionToken) {
    if (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0) {
      return nullptr;
    }
    CSSPrimitiveValue::UnitType unit = token.GetUnitType();
    if (unit == CSSPrimitiveValue::UnitType::kMilliseconds || unit == CSSPrimitiveValue::UnitType::kSeconds) {
      return CSSNumericLiteralValue::Create(stream.ConsumeIncludingWhitespace().NumericValue(), token.GetUnitType());
    }
    return nullptr;
  }
  MathFunctionParser math_parser(stream, context, value_range);
  if (auto calculation = *math_parser.Value()) {
    if (calculation->Category() == kCalcTime) {
      return math_parser.ConsumeValue();
    }
  }
  return nullptr;
}

template std::shared_ptr<const CSSPrimitiveValue> ConsumeTime(CSSParserTokenRange& stream,
                                                              std::shared_ptr<const CSSParserContext> context,
                                                              CSSPrimitiveValue::ValueRange value_range);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeResolution(T& range, std::shared_ptr<const CSSParserContext> context) {
  if (const CSSParserToken& token = range.Peek(); token.GetType() == kDimensionToken) {
    CSSPrimitiveValue::UnitType unit = token.GetUnitType();
    if (!CSSPrimitiveValue::IsResolution(unit) || token.NumericValue() < 0.0) {
      // "The allowed range of <resolution> values always excludes negative
      // values"
      // https://www.w3.org/TR/css-values-4/#resolution-value

      return nullptr;
    }

    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(), unit);
  }

  MathFunctionParser math_parser(range, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  auto math_value = *math_parser.Value();
  if (math_value && math_value->IsResolution()) {
    return math_parser.ConsumeValue();
  }

  return nullptr;
}

template std::shared_ptr<const CSSPrimitiveValue> ConsumeResolution(CSSParserTokenRange& range,
                                                                    std::shared_ptr<const CSSParserContext> context);
template std::shared_ptr<const CSSPrimitiveValue> ConsumeResolution(CSSParserTokenStream& range,
                                                                    std::shared_ptr<const CSSParserContext> context);

// https://drafts.csswg.org/css-values-4/#ratio-value
//
// <ratio> = <number [0,+inf]> [ / <number [0,+inf]> ]?
std::shared_ptr<const CSSValue> ConsumeRatio(CSSParserTokenStream& stream,
                                             std::shared_ptr<const CSSParserContext> context) {
  CSSParserSavePoint savepoint(stream);

  auto&& first = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!first) {
    return nullptr;
  }

  std::shared_ptr<const CSSPrimitiveValue> second = nullptr;

  if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
    second = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!second) {
      return nullptr;
    }
  } else {
    second = CSSNumericLiteralValue::Create(1, CSSPrimitiveValue::UnitType::kInteger);
  }

  savepoint.Release();
  return std::make_shared<cssvalue::CSSRatioValue>(*first, *second);
}

std::shared_ptr<const CSSIdentifierValue> ConsumeIdent(CSSParserTokenRange& range) {
  if (range.Peek().GetType() != kIdentToken) {
    return nullptr;
  }
  return CSSIdentifierValue::Create(range.ConsumeIncludingWhitespace().Id());
}

std::shared_ptr<const CSSIdentifierValue> ConsumeIdent(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() != kIdentToken) {
    return nullptr;
  }
  return CSSIdentifierValue::Create(stream.ConsumeIncludingWhitespace().Id());
}

std::shared_ptr<const CSSIdentifierValue> ConsumeIdentRange(CSSParserTokenRange& range,
                                                            CSSValueID lower,
                                                            CSSValueID upper) {
  if (range.Peek().Id() < lower || range.Peek().Id() > upper) {
    return nullptr;
  }
  return ConsumeIdent(range);
}

std::shared_ptr<const CSSIdentifierValue> ConsumeIdentRange(CSSParserTokenStream& stream,
                                                            CSSValueID lower,
                                                            CSSValueID upper) {
  if (stream.Peek().Id() < lower || stream.Peek().Id() > upper) {
    return nullptr;
  }
  return ConsumeIdent(stream);
}

// https://drafts.csswg.org/css-values-4/#css-wide-keywords
bool IsCSSWideKeyword(CSSValueID id) {
  return id == CSSValueID::kInherit || id == CSSValueID::kInitial || id == CSSValueID::kUnset ||
         id == CSSValueID::kRevert || id == CSSValueID::kRevertLayer;
  // This function should match the overload after it.
}

std::shared_ptr<const CSSCustomIdentValue> ConsumeCustomIdent(CSSParserTokenRange& range,
                                                              std::shared_ptr<const CSSParserContext> context) {
  if (range.Peek().GetType() != kIdentToken || IsCSSWideKeyword(range.Peek().Id()) ||
      range.Peek().Id() == CSSValueID::kDefault) {
    return nullptr;
  }
  return std::make_shared<CSSCustomIdentValue>(std::string(range.ConsumeIncludingWhitespace().Value()));
}

std::shared_ptr<const CSSCustomIdentValue> ConsumeCustomIdent(CSSParserTokenStream& stream,
                                                              std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().GetType() != kIdentToken || IsCSSWideKeyword(stream.Peek().Id()) ||
      stream.Peek().Id() == CSSValueID::kDefault) {
    return nullptr;
  }
  return std::make_shared<CSSCustomIdentValue>(std::string(stream.ConsumeIncludingWhitespace().Value()));
}

template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeColorInternal(T& range,
                     std::shared_ptr<const CSSParserContext> context,
                     bool accept_quirky_colors,
                     AllowedColors allowed_colors);

template <class T, typename Func>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSLightDarkValuePair>>::type
ConsumeLightDark(Func consume_value, T& range, std::shared_ptr<const CSSParserContext> context) {
  if (range.Peek().FunctionId() != CSSValueID::kLightDark) {
    return nullptr;
  }
  CSSParserSavePoint savepoint(range);
  CSSParserTokenRange arg_range = ConsumeFunction(range);
  auto light_value = consume_value(arg_range, context);
  if (!light_value || !ConsumeCommaIncludingWhitespace(arg_range)) {
    return nullptr;
  }
  auto dark_value = consume_value(arg_range, context);
  if (!dark_value || !arg_range.AtEnd()) {
    return nullptr;
  }
  savepoint.Release();
  return std::make_shared<CSSLightDarkValuePair>(light_value, dark_value);
}

template <class T>
static
    typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                            bool>::type
    ParseHexColor(T& range, Color& result, bool accept_quirky_colors) {
  const CSSParserToken& token = range.Peek();
  if (token.GetType() == kHashToken) {
    if (!Color::ParseHexColor(token.Value(), result)) {
      return false;
    }
  } else if (accept_quirky_colors) {
    std::string color;
    if (token.GetType() == kNumberToken || token.GetType() == kDimensionToken) {
      if (token.GetNumericValueType() != kIntegerValueType || token.NumericValue() < 0. ||
          token.NumericValue() >= 1000000.) {
        return false;
      }
      if (token.GetType() == kNumberToken) {  // e.g. 112233
        char buffer[5];
        snprintf(buffer, 5, "%d", static_cast<int>(token.NumericValue()));
        color = buffer;
      } else {  // e.g. 0001FF
        color = std::to_string(static_cast<int>(token.NumericValue())) + std::string(token.Value());
      }
      while (color.length() < 6) {
        color = "0" + color;
      }
    } else if (token.GetType() == kIdentToken) {  // e.g. FF0000
      color = token.Value();
    }
    unsigned length = color.length();
    if (length != 3 && length != 6) {
      return false;
    }
    if (!Color::ParseHexColor(color, result)) {
      return false;
    }
  } else {
    return false;
  }
  range.ConsumeIncludingWhitespace();
  return true;
}

std::shared_ptr<const CSSValue> ConsumeColorMaybeQuirky(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context) {
  return ConsumeColorInternal(stream, context, IsQuirksModeBehavior(context->Mode()), AllowedColors::kAll);
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeColor(T& range, std::shared_ptr<const CSSParserContext> context) {
  return ConsumeColorInternal(range, context, false /* accept_quirky_colors */, AllowedColors::kAll);
}

template std::shared_ptr<const CSSValue> ConsumeColor(CSSParserTokenRange& range,
                                                      std::shared_ptr<const CSSParserContext> context);
template std::shared_ptr<const CSSValue> ConsumeColor(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context);

template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeColorInternal(T& range,
                     std::shared_ptr<const CSSParserContext> context,
                     bool accept_quirky_colors,
                     AllowedColors allowed_colors) {
  CSSValueID id = range.Peek().Id();
  if ((id == CSSValueID::kAccentcolor || id == CSSValueID::kAccentcolortext)) {
    return nullptr;
  }
  if (StyleColor::IsColorKeyword(id)) {
    if (!isValueAllowedInMode(id, context->Mode())) {
      return nullptr;
    }
    if (allowed_colors == AllowedColors::kAbsolute &&
        (id == CSSValueID::kCurrentcolor || StyleColor::IsSystemColorIncludingDeprecated(id) ||
         StyleColor::IsSystemColor(id))) {
      return nullptr;
    }
    auto color = ConsumeIdent(range);
    return color;
  }

  Color color = Color::kTransparent;
  if (ParseHexColor(range, color, accept_quirky_colors)) {
    return cssvalue::CSSColor::Create(color);
  }

  // Parses the color inputs rgb(), rgba(), hsl(), hsla(), hwb(), lab(),
  // oklab(), lch(), oklch() and color(). https://www.w3.org/TR/css-color-4/
  ColorFunctionParser parser;
  if (auto functional_syntax_color = parser.ConsumeFunctionalSyntaxColor(range, context)) {
    return functional_syntax_color;
  }

  if (allowed_colors == AllowedColors::kAll) {
    return ConsumeLightDark(ConsumeColor<CSSParserTokenRange>, range, context);
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeAbsoluteColor(CSSParserTokenRange& range,
                                                     std::shared_ptr<const CSSParserContext> context) {
  return ConsumeColorInternal(range, std::move(context), false /* accept_quirky_colors */, AllowedColors::kAbsolute);
}

std::shared_ptr<const CSSValue> ConsumeLineWidth(CSSParserTokenRange& range,
                                                 std::shared_ptr<const CSSParserContext> context,
                                                 UnitlessQuirk unitless) {
  CSSValueID id = range.Peek().Id();
  if (id == CSSValueID::kThin || id == CSSValueID::kMedium || id == CSSValueID::kThick) {
    return ConsumeIdent(range);
  }
  return ConsumeLength(range, context, CSSPrimitiveValue::ValueRange::kNonNegative, unitless);
}

std::shared_ptr<const CSSValue> ConsumeLineWidth(CSSParserTokenStream& stream,
                                                 std::shared_ptr<const CSSParserContext> context,
                                                 UnitlessQuirk unitless) {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kThin || id == CSSValueID::kMedium || id == CSSValueID::kThick) {
    return ConsumeIdent(stream);
  }
  return ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, unitless);
}

static bool IsVerticalPositionKeywordOnly(const CSSValue& value) {
  auto* identifier_value = DynamicTo<CSSIdentifierValue>(value);
  if (!identifier_value) {
    return false;
  }
  CSSValueID value_id = identifier_value->GetValueID();
  return value_id == CSSValueID::kTop || value_id == CSSValueID::kBottom;
}

static bool IsHorizontalPositionKeywordOnly(const CSSValue& value) {
  auto* identifier_value = DynamicTo<CSSIdentifierValue>(value);
  if (!identifier_value) {
    return false;
  }
  CSSValueID value_id = identifier_value->GetValueID();
  return value_id == CSSValueID::kLeft || value_id == CSSValueID::kRight;
}

static void PositionFromOneValue(const std::shared_ptr<const CSSValue>& value,
                                 std::shared_ptr<const CSSValue>& result_x,
                                 std::shared_ptr<const CSSValue>& result_y) {
  bool value_applies_to_y_axis_only = IsVerticalPositionKeywordOnly(*value);
  result_x = value;
  result_y = CSSIdentifierValue::Create(CSSValueID::kCenter);
  if (value_applies_to_y_axis_only) {
    std::swap(result_x, result_y);
  }
}

static void PositionFromTwoValues(const std::shared_ptr<const CSSValue>& value1,
                                  const std::shared_ptr<const CSSValue>& value2,
                                  std::shared_ptr<const CSSValue>& result_x,
                                  std::shared_ptr<const CSSValue>& result_y) {
  bool must_order_as_xy = IsHorizontalPositionKeywordOnly(*value1) || IsVerticalPositionKeywordOnly(*value2) ||
                          !value1->IsIdentifierValue() || !value2->IsIdentifierValue();
  bool must_order_as_yx = IsVerticalPositionKeywordOnly(*value1) || IsHorizontalPositionKeywordOnly(*value2);
  assert(!must_order_as_xy || !must_order_as_yx);
  result_x = value1;
  result_y = value2;
  if (must_order_as_yx) {
    std::swap(result_x, result_y);
  }
}

static void PositionFromThreeOrFourValues(const std::shared_ptr<const CSSValue>* values,
                                          std::shared_ptr<const CSSValue>& result_x,
                                          std::shared_ptr<const CSSValue>& result_y) {
  std::shared_ptr<const CSSIdentifierValue> center = nullptr;
  for (int i = 0; values[i]; i++) {
    auto current_value = reinterpret_pointer_cast<const CSSIdentifierValue>(values[i]);
    CSSValueID id = current_value->GetValueID();

    if (id == CSSValueID::kCenter) {
      assert(!center);
      center = current_value;
      continue;
    }

    std::shared_ptr<const CSSValue> result = nullptr;
    if (values[i + 1] && !values[i + 1]->IsIdentifierValue()) {
      result = std::make_shared<CSSValuePair>(current_value, values[++i], CSSValuePair::kKeepIdenticalValues);
    } else {
      result = current_value;
    }

    if (id == CSSValueID::kLeft || id == CSSValueID::kRight) {
      assert(!result_x);
      result_x = result;
    } else {
      assert(id == CSSValueID::kTop || id == CSSValueID::kBottom);
      assert(!result_y);
      result_y = result;
    }
  }

  if (center) {
    assert(!!result_x != !!result_y);
    if (!result_x) {
      result_x = center;
    } else {
      result_y = center;
    }
  }

  assert(result_x && result_y);
}

template <typename T>
static
    typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                            std::shared_ptr<const CSSValue>>::type
    ConsumePositionComponent(T& stream,
                             std::shared_ptr<const CSSParserContext> context,
                             UnitlessQuirk unitless,
                             bool& horizontal_edge,
                             bool& vertical_edge) {
  if (stream.Peek().GetType() != kIdentToken) {
    return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll, unitless);
  }

  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kLeft || id == CSSValueID::kRight) {
    if (horizontal_edge) {
      return nullptr;
    }
    horizontal_edge = true;
  } else if (id == CSSValueID::kTop || id == CSSValueID::kBottom) {
    if (vertical_edge) {
      return nullptr;
    }
    vertical_edge = true;
  } else if (id != CSSValueID::kCenter) {
    return nullptr;
  }
  return ConsumeIdent(stream);
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValuePair>>::type
ConsumePosition(T& range, std::shared_ptr<const CSSParserContext> context, UnitlessQuirk unitless) {
  std::shared_ptr<const CSSValue> result_x = nullptr;
  std::shared_ptr<const CSSValue> result_y = nullptr;
  if (ConsumePosition(range, context, unitless, result_x, result_y)) {
    return std::make_shared<CSSValuePair>(result_x, result_y, CSSValuePair::kKeepIdenticalValues);
  }
  return nullptr;
}

template std::shared_ptr<const CSSValuePair> ConsumePosition(CSSParserTokenStream& stream,
                                                             std::shared_ptr<const CSSParserContext> context,
                                                             UnitlessQuirk unitless);
template std::shared_ptr<const CSSValuePair> ConsumePosition(CSSParserTokenRange& range,
                                                             std::shared_ptr<const CSSParserContext> context,
                                                             UnitlessQuirk unitless);

bool ConsumePosition(CSSParserTokenRange& range,
                     std::shared_ptr<const CSSParserContext> context,
                     UnitlessQuirk unitless,
                     std::shared_ptr<const CSSValue>& result_x,
                     std::shared_ptr<const CSSValue>& result_y) {
  bool horizontal_edge = false;
  bool vertical_edge = false;
  std::shared_ptr<const CSSValue> value1 =
      ConsumePositionComponent(range, context, unitless, horizontal_edge, vertical_edge);
  if (!value1) {
    return false;
  }
  if (!value1->IsIdentifierValue()) {
    horizontal_edge = true;
  }

  CSSParserTokenRange range_after_first_consume = range;
  std::shared_ptr<const CSSValue> value2 =
      ConsumePositionComponent(range, context, unitless, horizontal_edge, vertical_edge);
  if (!value2) {
    PositionFromOneValue(value1, result_x, result_y);
    return true;
  }

  CSSParserTokenRange range_after_second_consume = range;
  std::shared_ptr<const CSSValue> value3 = nullptr;
  auto* identifier_value1 = DynamicTo<CSSIdentifierValue>(value1.get());
  auto* identifier_value2 = DynamicTo<CSSIdentifierValue>(value2.get());
  // TODO(crbug.com/940442): Fix the strange comparison of a
  // CSSIdentifierValue instance against a specific "range peek" type check.
  if (identifier_value1 && !!identifier_value2 != (range.Peek().GetType() == kIdentToken) &&
      (identifier_value2 ? identifier_value2->GetValueID() : identifier_value1->GetValueID()) != CSSValueID::kCenter) {
    value3 = ConsumePositionComponent(range, context, unitless, horizontal_edge, vertical_edge);
  }
  if (!value3) {
    if (vertical_edge && !value2->IsIdentifierValue()) {
      range = range_after_first_consume;
      PositionFromOneValue(value1, result_x, result_y);
      return true;
    }
    PositionFromTwoValues(value1, value2, result_x, result_y);
    return true;
  }

  std::shared_ptr<const CSSValue> value4 = nullptr;
  auto* identifier_value3 = DynamicTo<CSSIdentifierValue>(value3.get());
  if (identifier_value3 && identifier_value3->GetValueID() != CSSValueID::kCenter &&
      range.Peek().GetType() != kIdentToken) {
    value4 = ConsumePositionComponent(range, context, unitless, horizontal_edge, vertical_edge);
  }

  if (!value4) {
    // [top | bottom] <length-percentage> is not permitted
    if (vertical_edge && !value2->IsIdentifierValue()) {
      range = range_after_first_consume;
      PositionFromOneValue(value1, result_x, result_y);
      return true;
    }
    range = range_after_second_consume;
    PositionFromTwoValues(value1, value2, result_x, result_y);
    return true;
  }

  std::shared_ptr<const CSSValue> values[5];
  values[0] = value1;
  values[1] = value2;
  values[2] = value3;
  values[3] = value4;
  values[4] = nullptr;
  PositionFromThreeOrFourValues(values, result_x, result_y);
  return true;
}

bool ConsumePosition(CSSParserTokenStream& stream,
                     std::shared_ptr<const CSSParserContext> context,
                     UnitlessQuirk unitless,
                     std::shared_ptr<const CSSValue>& result_x,
                     std::shared_ptr<const CSSValue>& result_y) {
  bool horizontal_edge = false;
  bool vertical_edge = false;
  std::shared_ptr<const CSSValue> value1 =
      ConsumePositionComponent(stream, context, unitless, horizontal_edge, vertical_edge);
  if (!value1) {
    return false;
  }
  if (!value1->IsIdentifierValue()) {
    horizontal_edge = true;
  }

  CSSParserTokenStream::State savepoint_after_first_consume = stream.Save();
  std::shared_ptr<const CSSValue> value2 =
      ConsumePositionComponent(stream, context, unitless, horizontal_edge, vertical_edge);
  if (!value2) {
    PositionFromOneValue(value1, result_x, result_y);
    return true;
  }

  CSSParserTokenStream::State savepoint_after_second_consume = stream.Save();
  std::shared_ptr<const CSSValue> value3 = nullptr;
  auto* identifier_value1 = DynamicTo<CSSIdentifierValue>(value1.get());
  auto* identifier_value2 = DynamicTo<CSSIdentifierValue>(value2.get());
  // TODO(crbug.com/940442): Fix the strange comparison of a
  // CSSIdentifierValue instance against a specific "stream peek" type check.
  if (identifier_value1 && !!identifier_value2 != (stream.Peek().GetType() == kIdentToken) &&
      (identifier_value2 ? identifier_value2->GetValueID() : identifier_value1->GetValueID()) != CSSValueID::kCenter) {
    value3 = ConsumePositionComponent(stream, context, unitless, horizontal_edge, vertical_edge);
  }
  if (!value3) {
    if (vertical_edge && !value2->IsIdentifierValue()) {
      stream.Restore(savepoint_after_first_consume);
      PositionFromOneValue(value1, result_x, result_y);
      return true;
    }
    PositionFromTwoValues(value1, value2, result_x, result_y);
    return true;
  }

  std::shared_ptr<const CSSValue> value4 = nullptr;
  auto* identifier_value3 = DynamicTo<CSSIdentifierValue>(value3.get());
  if (identifier_value3 && identifier_value3->GetValueID() != CSSValueID::kCenter &&
      stream.Peek().GetType() != kIdentToken) {
    value4 = ConsumePositionComponent(stream, context, unitless, horizontal_edge, vertical_edge);
  }

  if (!value4) {
    // [top | bottom] <length-percentage> is not permitted
    if (vertical_edge && !value2->IsIdentifierValue()) {
      stream.Restore(savepoint_after_first_consume);
      PositionFromOneValue(value1, result_x, result_y);
      return true;
    }
    stream.Restore(savepoint_after_second_consume);
    PositionFromTwoValues(value1, value2, result_x, result_y);
    return true;
  }

  std::shared_ptr<const CSSValue> values[5];
  values[0] = value1;
  values[1] = value2;
  values[2] = value3;
  values[3] = value4;
  values[4] = nullptr;
  PositionFromThreeOrFourValues(values, result_x, result_y);
  return true;
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        bool>::type
ConsumeOneOrTwoValuedPosition(T& range,
                              std::shared_ptr<const CSSParserContext> context,
                              UnitlessQuirk unitless,
                              std::shared_ptr<const CSSValue>& result_x,
                              std::shared_ptr<const CSSValue>& result_y) {
  bool horizontal_edge = false;
  bool vertical_edge = false;
  std::shared_ptr<const CSSValue> value1 =
      ConsumePositionComponent(range, context, unitless, horizontal_edge, vertical_edge);
  if (!value1) {
    return false;
  }
  if (!value1->IsIdentifierValue()) {
    horizontal_edge = true;
  }

  if (vertical_edge && ConsumeLengthOrPercent(range, context, CSSPrimitiveValue::ValueRange::kAll, unitless)) {
    // <length-percentage> is not permitted after top | bottom.
    return false;
  }
  std::shared_ptr<const CSSValue> value2 =
      ConsumePositionComponent(range, context, unitless, horizontal_edge, vertical_edge);
  if (!value2) {
    PositionFromOneValue(value1, result_x, result_y);
    return true;
  }
  PositionFromTwoValues(value1, value2, result_x, result_y);
  return true;
}

bool ConsumeBorderShorthand(CSSParserTokenStream& stream,
                            std::shared_ptr<const CSSParserContext> context,
                            const CSSParserLocalContext& local_context,
                            std::shared_ptr<const CSSValue>& result_width,
                            std::shared_ptr<const CSSValue>& result_style,
                            std::shared_ptr<const CSSValue>& result_color) {
  while (!result_width || !result_style || !result_color) {
    if (!result_width) {
      result_width = ParseBorderWidthSide(stream, context, local_context);
      if (result_width) {
        ConsumeCommaIncludingWhitespace(stream);
        continue;
      }
    }
    if (!result_style) {
      result_style = ParseBorderStyleSide(stream, context);
      if (result_style) {
        ConsumeCommaIncludingWhitespace(stream);
        continue;
      }
    }
    if (!result_color) {
      result_color = ConsumeBorderColorSide(stream, context, local_context);
      if (result_color) {
        ConsumeCommaIncludingWhitespace(stream);
        continue;
      }
    }
    break;
  }

  if (!result_width && !result_style && !result_color) {
    return false;
  }

  if (!result_width) {
    result_width = CSSInitialValue::Create();
  }
  if (!result_style) {
    result_style = CSSInitialValue::Create();
  }
  if (!result_color) {
    result_color = CSSInitialValue::Create();
  }
  return true;
}

std::shared_ptr<const CSSValue> ConsumeBorderWidth(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context,
                                                   UnitlessQuirk unitless) {
  if (stream.Peek().FunctionId() == CSSValueID::kInternalAppearanceAutoBaseSelect) {
    CSSParserSavePoint savepoint(stream);
    CSSParserTokenRange arg_range = ConsumeFunction(stream);
    auto auto_value = ConsumeLineWidth(arg_range, context, unitless);
    if (!auto_value || !ConsumeCommaIncludingWhitespace(arg_range)) {
      return nullptr;
    }
    auto base_select_value = ConsumeLineWidth(arg_range, context, unitless);
    if (!base_select_value || !arg_range.AtEnd()) {
      return nullptr;
    }
    savepoint.Release();
    return std::make_shared<CSSAppearanceAutoBaseSelectValuePair>(auto_value, base_select_value);
  }
  return ConsumeLineWidth(stream, context, unitless);
}

std::shared_ptr<const CSSValue> ParseBorderWidthSide(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     const CSSParserLocalContext& local_context) {
  CSSPropertyID shorthand = local_context.CurrentShorthand();
  bool allow_quirky_lengths = IsQuirksModeBehavior(context->Mode()) &&
                              (shorthand == CSSPropertyID::kInvalid || shorthand == CSSPropertyID::kBorderWidth);
  UnitlessQuirk unitless = allow_quirky_lengths ? UnitlessQuirk::kAllow : UnitlessQuirk::kForbid;
  return ConsumeBorderWidth(stream, context, unitless);
}

std::shared_ptr<const CSSValue> ParseBorderStyleSide(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().FunctionId() == CSSValueID::kInternalAppearanceAutoBaseSelect) {
    CSSParserSavePoint savepoint(stream);
    CSSParserTokenRange arg_range = ConsumeFunction(stream);
    auto auto_value = ConsumeIdent(arg_range);
    if (!auto_value || !ConsumeCommaIncludingWhitespace(arg_range)) {
      return nullptr;
    }
    auto base_select_value = ConsumeIdent(arg_range);
    if (!base_select_value || !arg_range.AtEnd()) {
      return nullptr;
    }
    savepoint.Release();
    return std::make_shared<CSSAppearanceAutoBaseSelectValuePair>(auto_value, base_select_value);
  }
  return ParseLonghand(CSSPropertyID::kBorderLeftStyle, CSSPropertyID::kBorder, context, stream);
}

template <class T = CSSParserTokenRange>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSAppearanceAutoBaseSelectValuePair>>::type
ConsumeAppearanceAutoBaseSelectColor(T& range, std::shared_ptr<const CSSParserContext> context) {
  if (range.Peek().FunctionId() != CSSValueID::kInternalAppearanceAutoBaseSelect) {
    return nullptr;
  }
  CSSParserSavePoint savepoint(range);
  CSSParserTokenRange arg_range = ConsumeFunction(range);
  auto auto_value = ConsumeColor(arg_range, context);
  if (!auto_value || !ConsumeCommaIncludingWhitespace(arg_range)) {
    return nullptr;
  }
  auto base_select_value = ConsumeColor(arg_range, context);
  if (!base_select_value || !arg_range.AtEnd()) {
    return nullptr;
  }
  savepoint.Release();
  return std::make_shared<CSSAppearanceAutoBaseSelectValuePair>(auto_value, base_select_value);
}

std::shared_ptr<const CSSValue> ConsumeBorderColorSide(CSSParserTokenStream& stream,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       const CSSParserLocalContext& local_context) {
  CSSPropertyID shorthand = local_context.CurrentShorthand();
  bool allow_quirky_colors = IsQuirksModeBehavior(context->Mode()) &&
                             (shorthand == CSSPropertyID::kInvalid || shorthand == CSSPropertyID::kBorderColor);
  if (stream.Peek().FunctionId() == CSSValueID::kInternalAppearanceAutoBaseSelect &&
      IsUASheetBehavior(context->Mode())) {
    return ConsumeAppearanceAutoBaseSelectColor(stream, context);
  }
  return ConsumeColorInternal(stream, context, allow_quirky_colors, AllowedColors::kAll);
}

std::shared_ptr<const CSSValue> ParseLonghand(CSSPropertyID unresolved_property,
                                              CSSPropertyID current_shorthand,
                                              std::shared_ptr<const CSSParserContext> context,
                                              CSSParserTokenStream& stream) {
  CSSPropertyID property_id = ResolveCSSPropertyID(unresolved_property);
  CSSValueID value_id = stream.Peek().Id();
  assert(!CSSProperty::Get(property_id).IsShorthand());
  if (CSSParserFastPaths::IsHandledByKeywordFastPath(property_id)) {
    if (CSSParserFastPaths::IsValidKeywordPropertyAndValue(property_id, stream.Peek().Id(), context->Mode())) {
      return ConsumeIdent(stream);
    }
    WarnInvalidKeywordPropertyUsage(property_id, context, value_id);
    return nullptr;
  }

  const auto local_context = CSSParserLocalContext()
                                 .WithAliasParsing(IsPropertyAlias(unresolved_property))
                                 .WithCurrentShorthand(current_shorthand);

  std::shared_ptr<const CSSValue> result =
      To<Longhand>(CSSProperty::Get(property_id)).ParseSingleValue(stream, context, local_context);
  return result;
}

void WarnInvalidKeywordPropertyUsage(CSSPropertyID property,
                                     std::shared_ptr<const CSSParserContext> context,
                                     CSSValueID value_id) {}

bool ValidWidthOrHeightKeyword(CSSValueID id, std::shared_ptr<const CSSParserContext> context) {
  // The keywords supported here should be kept in sync with
  // CalculationExpressionSizingKeywordNode::Keyword and the things that use
  // it.
  // TODO(https://crbug.com/353538495): This should also be kept in sync with
  // FlexBasis::ParseSingleValue, although we should eventually make it use
  // this function instead.
  if (id == CSSValueID::kWebkitMinContent || id == CSSValueID::kWebkitMaxContent ||
      id == CSSValueID::kWebkitFillAvailable || id == CSSValueID::kWebkitFitContent || id == CSSValueID::kMinContent ||
      id == CSSValueID::kMaxContent || id == CSSValueID::kFitContent) {
    return true;
  }
  return false;
}

std::shared_ptr<const CSSValue> ConsumeMaxWidthOrHeight(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        UnitlessQuirk unitless) {
  if (stream.Peek().Id() == CSSValueID::kNone || ValidWidthOrHeightKeyword(stream.Peek().Id(), context)) {
    return ConsumeIdent(stream);
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, unitless,
                                static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchorSize),
                                AllowCalcSize::kAllowWithoutAuto);
}

std::shared_ptr<const CSSValue> ConsumeWidthOrHeight(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     UnitlessQuirk unitless) {
  if (stream.Peek().Id() == CSSValueID::kAuto || ValidWidthOrHeightKeyword(stream.Peek().Id(), context)) {
    return ConsumeIdent(stream);
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, unitless,
                                static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchorSize),
                                AllowCalcSize::kAllowWithAuto);
}

std::shared_ptr<const CSSValue> ConsumeMarginOrOffset(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      UnitlessQuirk unitless,
                                                      CSSAnchorQueryTypes allowed_anchor_queries) {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return ConsumeIdent(stream);
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll, unitless, allowed_anchor_queries);
}

std::shared_ptr<const CSSValue> ConsumeScrollPadding(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return ConsumeIdent(stream);
  }
  CSSParserContext::ParserModeOverridingScope scope(*context, kHTMLStandardMode);
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> ConsumeScrollStart(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context) {
  if (std::shared_ptr<const CSSIdentifierValue> ident =
          ConsumeIdent<CSSValueID::kAuto, CSSValueID::kStart, CSSValueID::kCenter, CSSValueID::kEnd, CSSValueID::kTop,
                       CSSValueID::kBottom, CSSValueID::kLeft, CSSValueID::kRight>(stream)) {
    return ident;
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> ConsumeScrollStartTarget(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kAuto, CSSValueID::kNone>(stream);
}

// https://drafts.csswg.org/css-box-4/#typedef-coord-box
template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeCoordBoxInternal(T& range) {
  return ConsumeIdent<CSSValueID::kContentBox, CSSValueID::kPaddingBox, CSSValueID::kBorderBox, CSSValueID::kFillBox,
                      CSSValueID::kStrokeBox, CSSValueID::kViewBox>(range);
}

std::shared_ptr<const CSSIdentifierValue> ConsumeCoordBox(CSSParserTokenRange& range) {
  return ConsumeCoordBoxInternal(range);
}

std::shared_ptr<const CSSIdentifierValue> ConsumeCoordBox(CSSParserTokenStream& stream) {
  return ConsumeCoordBoxInternal(stream);
}

std::shared_ptr<const CSSValue> ConsumeRay(CSSParserTokenStream& stream,
                                           std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().FunctionId() != CSSValueID::kRay) {
    return nullptr;
  }

  std::shared_ptr<const CSSValue> value;
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();

    std::shared_ptr<const CSSPrimitiveValue> angle = nullptr;
    std::shared_ptr<const CSSIdentifierValue> size = nullptr;
    std::shared_ptr<const CSSIdentifierValue> contain = nullptr;
    bool position = false;
    std::shared_ptr<const CSSValue> x = nullptr;
    std::shared_ptr<const CSSValue> y = nullptr;
    while (!stream.AtEnd()) {
      if (!angle) {
        angle = ConsumeAngle(stream, context);
        if (angle) {
          continue;
        }
      }
      if (!size) {
        size = ConsumeIdent<CSSValueID::kClosestSide, CSSValueID::kClosestCorner, CSSValueID::kFarthestSide,
                            CSSValueID::kFarthestCorner, CSSValueID::kSides>(stream);
        if (size) {
          continue;
        }
      }
      if (!contain) {
        contain = ConsumeIdent<CSSValueID::kContain>(stream);
        if (contain) {
          continue;
        }
      }
      if (!position && ConsumeIdent<CSSValueID::kAt>(stream)) {
        position = ConsumePosition(stream, context, UnitlessQuirk::kForbid, x, y);
        if (position) {
          continue;
        }
      }
      return nullptr;
    }
    if (!angle) {
      return nullptr;
    }
    guard.Release();
    if (!size) {
      size = CSSIdentifierValue::Create(CSSValueID::kClosestSide);
    }
    value = std::make_shared<const cssvalue::CSSRayValue>(angle, size, contain, x, y);
  }
  stream.ConsumeWhitespace();
  return value;
}

std::shared_ptr<const CSSValue> ConsumeShapeRadius(CSSParserTokenStream& args,
                                                   std::shared_ptr<const CSSParserContext> context) {
  if (IdentMatches<CSSValueID::kClosestSide, CSSValueID::kFarthestSide>(args.Peek().Id())) {
    return ConsumeIdent(args);
  }
  return ConsumeLengthOrPercent(args, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const cssvalue::CSSBasicShapeCircleValue> ConsumeBasicShapeCircle(
    CSSParserTokenStream& args,
    std::shared_ptr<const CSSParserContext> context) {
  // spec: https://drafts.csswg.org/css-shapes/#supported-basic-shapes
  // circle( [<shape-radius>]? [at <position>]? )
  auto shape = std::make_shared<cssvalue::CSSBasicShapeCircleValue>();
  if (auto radius = ConsumeShapeRadius(args, context)) {
    shape->SetRadius(radius);
  }
  if (ConsumeIdent<CSSValueID::kAt>(args)) {
    std::shared_ptr<const CSSValue> center_x = nullptr;
    std::shared_ptr<const CSSValue> center_y = nullptr;
    if (!ConsumePosition(args, context, UnitlessQuirk::kForbid, center_x, center_y)) {
      return nullptr;
    }
    shape->SetCenterX(center_x);
    shape->SetCenterY(center_y);
  }
  return shape;
}

std::shared_ptr<const CSSValue> ConsumeOffsetPath(CSSParserTokenStream& stream,
                                                  std::shared_ptr<const CSSParserContext> context) {
  if (std::shared_ptr<const CSSValue> none = ConsumeIdent<CSSValueID::kNone>(stream)) {
    return none;
  }
  std::shared_ptr<const CSSValue> coord_box = ConsumeCoordBox(stream);

  std::shared_ptr<const CSSValue> offset_path = ConsumeRay(stream, context);
  if (!offset_path) {
    offset_path = ConsumeBasicShape(stream, context, AllowPathValue::kForbid);
  }
  if (!offset_path) {
    offset_path = ConsumeUrl(stream, context);
  }
  //  if (!offset_path) {
  //    offset_path = ConsumePathFunction(stream, EmptyPathStringHandling::kFailure);
  //  }

  if (!coord_box) {
    coord_box = ConsumeCoordBox(stream);
  }

  if (!offset_path && !coord_box) {
    return nullptr;
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (offset_path) {
    list->Append(offset_path);
  }
  if (!offset_path || (coord_box && To<CSSIdentifierValue>(coord_box.get())->GetValueID() != CSSValueID::kBorderBox)) {
    list->Append(coord_box);
  }

  return list;
}

std::shared_ptr<const CSSValue> ConsumeOffsetRotate(CSSParserTokenStream& stream,
                                                    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> angle = ConsumeAngle(stream, context);
  std::shared_ptr<const CSSValue> keyword = ConsumeIdent<CSSValueID::kAuto, CSSValueID::kReverse>(stream);
  if (!angle && !keyword) {
    return nullptr;
  }

  if (!angle) {
    angle = ConsumeAngle(stream, context);
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (keyword) {
    list->Append(keyword);
  }
  if (angle) {
    list->Append(angle);
  }
  return list;
}

std::shared_ptr<const CSSValue> ConsumeInitialLetter(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context) {
  if (ConsumeIdent<CSSValueID::kNormal>(stream)) {
    return CSSIdentifierValue::Create(CSSValueID::kNormal);
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  // ["drop" | "raise"] number[1,Inf]
  if (auto sink_type = ConsumeIdent<CSSValueID::kDrop, CSSValueID::kRaise>(stream)) {
    if (auto size = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative)) {
      if (size->GetFloatValue() < 1) {
        return nullptr;
      }
      list->Append(size);
      list->Append(sink_type);
      return list;
    }
    return nullptr;
  }

  // number[1, Inf]
  // number[1, Inf] ["drop" | "raise"]
  // number[1, Inf] integer[1, Inf]
  if (auto size = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative)) {
    if (size->GetFloatValue() < 1) {
      return nullptr;
    }
    list->Append(size);
    if (auto sink_type = ConsumeIdent<CSSValueID::kDrop, CSSValueID::kRaise>(stream)) {
      list->Append(sink_type);
      return list;
    }
    if (auto sink = ConsumeIntegerOrNumberCalc(stream, context, CSSPrimitiveValue::ValueRange::kPositiveInteger)) {
      list->Append(sink);
      return list;
    }
    return list;
  }

  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeAnimationIterationCount(CSSParserTokenStream& stream,
                                                               std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kInfinite) {
    return ConsumeIdent(stream);
  }
  return ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> ConsumeTimelineRangeName(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kContain, CSSValueID::kCover, CSSValueID::kEntry, CSSValueID::kEntryCrossing,
                      CSSValueID::kExit, CSSValueID::kExitCrossing>(stream);
}

std::shared_ptr<const CSSValue> ConsumeTimelineRangeName(CSSParserTokenRange& range) {
  return ConsumeIdent<CSSValueID::kContain, CSSValueID::kCover, CSSValueID::kEntry, CSSValueID::kEntryCrossing,
                      CSSValueID::kExit, CSSValueID::kExitCrossing>(range);
}

std::shared_ptr<const CSSValue> ConsumeAnimationName(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     bool allow_quoted_name) {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return ConsumeIdent(stream);
  }

  if (allow_quoted_name && stream.Peek().GetType() == kStringToken) {
    const CSSParserToken& token = stream.ConsumeIncludingWhitespace();
    if (EqualIgnoringASCIICase(token.Value(), "none")) {
      return CSSIdentifierValue::Create(CSSValueID::kNone);
    }
    return std::make_shared<CSSCustomIdentValue>(std::string(token.Value()));
  }

  return ConsumeCustomIdent(stream, context);
}

std::shared_ptr<const CSSValue> ConsumeAnimationRange(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      double default_offset_percent) {
  if (std::shared_ptr<const CSSValue> ident = ConsumeIdent<CSSValueID::kNormal>(stream)) {
    return ident;
  }
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  std::shared_ptr<const CSSValue> range_name = ConsumeTimelineRangeName(stream);
  if (range_name) {
    list->Append(range_name);
  }
  std::shared_ptr<const CSSPrimitiveValue> percentage =
      ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  if (percentage &&
      !(range_name && percentage->IsPercentage() && percentage->GetValue<double>() == default_offset_percent)) {
    list->Append(percentage);
  } else if (!range_name) {
    return nullptr;
  }
  return list;
}

namespace {

std::shared_ptr<const CSSValue> ConsumeSingleTimelineInsetSide(CSSParserTokenStream& stream,
                                                               std::shared_ptr<const CSSParserContext> context) {
  if (std::shared_ptr<const CSSValue> ident = ConsumeIdent<CSSValueID::kAuto>(stream)) {
    return ident;
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

}  // namespace

bool IsIdent(const CSSValue& value, CSSValueID id) {
  const auto* ident = DynamicTo<CSSIdentifierValue>(value);
  return ident && ident->GetValueID() == id;
}

std::shared_ptr<const CSSValue> ConsumeSingleTimelineInset(CSSParserTokenStream& stream,
                                                           std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> start = ConsumeSingleTimelineInsetSide(stream, context);
  if (!start) {
    return nullptr;
  }
  std::shared_ptr<const CSSValue> end = ConsumeSingleTimelineInsetSide(stream, context);
  if (!end) {
    end = start;
  }
  return std::make_shared<CSSValuePair>(start, end, CSSValuePair::kDropIdenticalValues);
}

std::shared_ptr<const CSSValue> ConsumeTransitionProperty(CSSParserTokenStream& stream,
                                                          std::shared_ptr<const CSSParserContext> context) {
  const CSSParserToken& token = stream.Peek();
  if (token.GetType() != kIdentToken) {
    return nullptr;
  }
  if (token.Id() == CSSValueID::kNone) {
    return ConsumeIdent(stream);
  }
  const auto* execution_context = context->GetExecutingContext();
  CSSPropertyID unresolved_property = token.ParseAsUnresolvedCSSPropertyID(execution_context);
  if (unresolved_property != CSSPropertyID::kInvalid && unresolved_property != CSSPropertyID::kVariable) {
#if DCHECK_IS_ON()
    DCHECK(CSSProperty::Get(ResolveCSSPropertyID(unresolved_property)).IsWebExposed(execution_context));
#endif
    stream.ConsumeIncludingWhitespace();
    return std::make_shared<CSSCustomIdentValue>(unresolved_property);
  }
  return ConsumeCustomIdent(stream, context);
}

std::shared_ptr<const CSSValue> ConsumeScrollFunction(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().FunctionId() != CSSValueID::kScroll) {
    return nullptr;
  }

  std::shared_ptr<const CSSValue> scroller = nullptr;
  std::shared_ptr<const CSSIdentifierValue> axis = nullptr;

  {
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();
    while (!scroller || !axis) {
      if (stream.AtEnd()) {
        break;
      }
      if (!scroller) {
        if ((scroller = ConsumeIdent<CSSValueID::kRoot, CSSValueID::kNearest, CSSValueID::kSelf>(stream))) {
          continue;
        }
      }
      if (!axis) {
        if ((axis = ConsumeIdent<CSSValueID::kBlock, CSSValueID::kInline, CSSValueID::kX, CSSValueID::kY>(stream))) {
          continue;
        }
      }
      return nullptr;
    }
    if (!stream.AtEnd()) {
      return nullptr;
    }
    // Nullify default values.
    // https://drafts.csswg.org/scroll-animations-1/#valdef-scroll-nearest
    if (scroller && IsIdent(*scroller, CSSValueID::kNearest)) {
      scroller = nullptr;
    }
    // https://drafts.csswg.org/scroll-animations-1/#valdef-scroll-block
    if (axis && IsIdent(*axis, CSSValueID::kBlock)) {
      axis = nullptr;
    }
  }
  stream.ConsumeWhitespace();
  return std::make_shared<cssvalue::CSSScrollValue>(scroller, axis);
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSCustomIdentValue>>::type
ConsumeDashedIdent(T& stream, std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeAnimationTimeline(CSSParserTokenStream& stream,
                                                         std::shared_ptr<const CSSParserContext> context) {
  if (auto value = ConsumeIdent<CSSValueID::kNone, CSSValueID::kAuto>(stream)) {
    return value;
  }
  if (auto value = ConsumeDashedIdent(stream, context)) {
    return value;
  }
  return ConsumeScrollFunction(stream, context);
}

std::optional<cssvalue::CSSLinearStop> ConsumeLinearStop(CSSParserTokenStream& stream,
                                                         std::shared_ptr<const CSSParserContext> context) {
  std::optional<double> number;
  std::optional<double> length_a;
  std::optional<double> length_b;
  while (!stream.AtEnd()) {
    if (stream.Peek().GetType() == kCommaToken) {
      break;
    }
    std::shared_ptr<const CSSPrimitiveValue> value =
        ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    if (!number.has_value() && value && value->IsNumber()) {
      number = value->GetDoubleValue();
      continue;
    }
    value = ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    if (!length_a.has_value() && value && value->IsPercentage()) {
      length_a = value->GetDoubleValue();
      value = ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
      if (value && value->IsPercentage()) {
        length_b = value->GetDoubleValue();
      }
      continue;
    }
    return {};
  }
  if (!number.has_value()) {
    return {};
  }
  return {{number.value(), length_a, length_b}};
}

std::shared_ptr<const CSSValue> ConsumeLinear(CSSParserTokenStream& stream,
                                              std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> result;

  // https://w3c.github.io/csswg-drafts/css-easing/#linear-easing-function-parsing
  DCHECK_EQ(stream.Peek().FunctionId(), CSSValueID::kLinear);
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    std::vector<cssvalue::CSSLinearStop> stop_list{};
    std::optional<cssvalue::CSSLinearStop> linear_stop;
    do {
      linear_stop = ConsumeLinearStop(stream, context);
      if (!linear_stop.has_value()) {
        return nullptr;
      }
      stop_list.emplace_back(linear_stop.value());
    } while (ConsumeCommaIncludingWhitespace(stream));
    if (!stream.AtEnd()) {
      return nullptr;
    }
    // 1. Let function be a new linear easing function.
    // 2. Let largestInput be negative infinity.
    // 3. If there are less than two items in stopList, then return failure.
    if (stop_list.size() < 2) {
      return nullptr;
    }
    // 4. For each stop in stopList:
    double largest_input = std::numeric_limits<double>::lowest();
    std::vector<gfx::LinearEasingPoint> points{};
    for (size_t i = 0; i < stop_list.size(); ++i) {
      const auto& stop = stop_list[i];
      // 4.1. Let point be a new linear easing point with its output set
      // to stop’s <number> as a number.
      gfx::LinearEasingPoint point{std::numeric_limits<double>::quiet_NaN(), stop.number};
      // 4.2. Append point to function’s points.
      points.emplace_back(point);
      // 4.3. If stop has a <linear-stop-length>, then:
      if (stop.length_a.has_value()) {
        // 4.3.1. Set point’s input to whichever is greater:
        // stop’s <linear-stop-length>'s first <percentage> as a number,
        // or largestInput.
        points.back().input = std::max(largest_input, stop.length_a.value());
        // 4.3.2. Set largestInput to point’s input.
        largest_input = points.back().input;
        // 4.3.3. If stop’s <linear-stop-length> has a second <percentage>,
        // then:
        if (stop.length_b.has_value()) {
          // 4.3.3.1. Let extraPoint be a new linear easing point with its
          // output set to stop’s <number> as a number.
          gfx::LinearEasingPoint extra_point{// 4.3.3.3. Set extraPoint’s input to whichever is greater:
                                             // stop’s <linear-stop-length>'s second <percentage>
                                             // as a number, or largestInput.
                                             std::max(largest_input, stop.length_b.value()), stop.number};
          // 4.3.3.2. Append extraPoint to function’s points.
          points.emplace_back(extra_point);
          // 4.3.3.4. Set largestInput to extraPoint’s input.
          largest_input = extra_point.input;
        }
        // 4.4. Otherwise, if stop is the first item in stopList, then:
      } else if (i == 0) {
        // 4.4.1. Set point’s input to 0.
        points.back().input = 0;
        // 4.4.2. Set largestInput to 0.
        largest_input = 0;
        // 4.5. Otherwise, if stop is the last item in stopList,
        // then set point’s input to whichever is greater: 1 or largestInput.
      } else if (i == stop_list.size() - 1) {
        points.back().input = std::max(100., largest_input);
      }
    }
    // 5. For runs of items in function’s points that have a null input, assign
    // a number to the input by linearly interpolating between the closest
    // previous and next points that have a non-null input.
    size_t upper_index = 0;
    for (size_t i = 1; i < points.size(); ++i) {
      if (std::isnan(points[i].input)) {
        if (i > upper_index) {
          const auto it = std::find_if(std::next(points.begin(), i + 1), points.end(),
                                       [](const auto& point) { return !std::isnan(point.input); });
          upper_index = static_cast<size_t>(it - points.begin());
        }
        points[i].input =
            points[i - 1].input + (points[upper_index].input - points[i - 1].input) / (upper_index - (i - 1));
      }
    }
    guard.Release();
    result = std::make_shared<cssvalue::CSSLinearTimingFunctionValue>(std::move(points));
  }
  stream.ConsumeWhitespace();

  // 6. Return function.
  return result;
}

std::shared_ptr<const CSSValue> ConsumeSteps(CSSParserTokenStream& stream,
                                             std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> result;

  DCHECK_EQ(stream.Peek().FunctionId(), CSSValueID::kSteps);
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);

    std::shared_ptr<const CSSPrimitiveValue> steps = ConsumePositiveInteger(stream, context);
    if (!steps) {
      return nullptr;
    }

    StepsTimingFunction::StepPosition position = StepsTimingFunction::StepPosition::END;
    if (ConsumeCommaIncludingWhitespace(stream)) {
      switch (stream.ConsumeIncludingWhitespace().Id()) {
        case CSSValueID::kStart:
          position = StepsTimingFunction::StepPosition::START;
          break;

        case CSSValueID::kEnd:
          position = StepsTimingFunction::StepPosition::END;
          break;

        case CSSValueID::kJumpBoth:
          position = StepsTimingFunction::StepPosition::JUMP_BOTH;
          break;

        case CSSValueID::kJumpEnd:
          position = StepsTimingFunction::StepPosition::JUMP_END;
          break;

        case CSSValueID::kJumpNone:
          position = StepsTimingFunction::StepPosition::JUMP_NONE;
          break;

        case CSSValueID::kJumpStart:
          position = StepsTimingFunction::StepPosition::JUMP_START;
          break;

        default:
          return nullptr;
      }
    }

    if (!stream.AtEnd()) {
      return nullptr;
    }

    // Steps(n, jump-none) requires n >= 2.
    if (position == StepsTimingFunction::StepPosition::JUMP_NONE && steps->GetIntValue() < 2) {
      return nullptr;
    }

    guard.Release();
    result = std::make_shared<cssvalue::CSSStepsTimingFunctionValue>(steps->GetIntValue(), position);
  }
  stream.ConsumeWhitespace();
  return result;
}

std::shared_ptr<const CSSValue> ConsumeCubicBezier(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context) {
  DCHECK_EQ(stream.Peek().FunctionId(), CSSValueID::kCubicBezier);
  std::shared_ptr<const CSSValue> result = nullptr;
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);

    double x1, y1, x2, y2;
    if (ConsumeNumberRaw(stream, context, x1) && x1 >= 0 && x1 <= 1 && ConsumeCommaIncludingWhitespace(stream) &&
        ConsumeNumberRaw(stream, context, y1) && ConsumeCommaIncludingWhitespace(stream) &&
        ConsumeNumberRaw(stream, context, x2) && x2 >= 0 && x2 <= 1 && ConsumeCommaIncludingWhitespace(stream) &&
        ConsumeNumberRaw(stream, context, y2) && stream.AtEnd()) {
      guard.Release();
      result = std::make_shared<cssvalue::CSSCubicBezierTimingFunctionValue>(x1, y1, x2, y2);
    }
  }
  if (result) {
    stream.ConsumeWhitespace();
  }

  return result;
}

std::shared_ptr<const CSSValue> ConsumeAnimationTimingFunction(CSSParserTokenStream& stream,
                                                               std::shared_ptr<const CSSParserContext> context) {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kEase || id == CSSValueID::kLinear || id == CSSValueID::kEaseIn || id == CSSValueID::kEaseOut ||
      id == CSSValueID::kEaseInOut || id == CSSValueID::kStepStart || id == CSSValueID::kStepEnd) {
    return ConsumeIdent(stream);
  }

  CSSValueID function = stream.Peek().FunctionId();
  if (function == CSSValueID::kLinear) {
    return ConsumeLinear(stream, context);
  }
  if (function == CSSValueID::kSteps) {
    return ConsumeSteps(stream, context);
  }
  if (function == CSSValueID::kCubicBezier) {
    return ConsumeCubicBezier(stream, context);
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeAnimationDuration(CSSParserTokenStream& stream,
                                                         std::shared_ptr<const CSSParserContext> context) {
  if (auto ident = ConsumeIdent<CSSValueID::kAuto>(stream)) {
    return ident;
  }
  return ConsumeTime(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

template <typename T>
typename std::enable_if<std::is_same_v<T, CSSParserTokenStream> || std::is_same_v<T, CSSParserTokenRange>,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeFontTechIdent(T& stream) {
  return ConsumeIdent<CSSValueID::kFeaturesOpentype, CSSValueID::kFeaturesAat, CSSValueID::kFeaturesGraphite,
                      CSSValueID::kColorSbix, CSSValueID::kVariations, CSSValueID::kPalettes, CSSValueID::kIncremental>(
      stream);
}

template std::shared_ptr<const CSSIdentifierValue> ConsumeFontTechIdent(CSSParserTokenStream&);
template std::shared_ptr<const CSSIdentifierValue> ConsumeFontTechIdent(CSSParserTokenRange&);

bool ConsumeAnimationShorthand(const StylePropertyShorthand& shorthand,
                               std::vector<std::shared_ptr<CSSValueList>>& longhands,
                               ConsumeAnimationItemValue consumeLonghandItem,
                               IsResetOnlyFunction is_reset_only,
                               CSSParserTokenStream& stream,
                               std::shared_ptr<const CSSParserContext> context,
                               bool use_legacy_parsing) {
  DCHECK(consumeLonghandItem);
  const unsigned longhand_count = shorthand.length();
  DCHECK_LE(longhand_count, kMaxNumAnimationLonghands);

  for (unsigned i = 0; i < longhand_count; ++i) {
    longhands[i] = CSSValueList::CreateCommaSeparated();
  }

  do {
    bool parsed_longhand[kMaxNumAnimationLonghands] = {false};
    bool found_any = false;
    do {
      bool found_property = false;
      for (unsigned i = 0; i < longhand_count; ++i) {
        if (parsed_longhand[i]) {
          continue;
        }

        std::shared_ptr<const CSSValue> value =
            consumeLonghandItem(shorthand.properties()[i]->PropertyID(), stream, context, use_legacy_parsing);
        if (value) {
          parsed_longhand[i] = true;
          found_property = true;
          found_any = true;
          longhands[i]->Append(value);
          break;
        }
      }
      if (!found_property) {
        break;
      }
    } while (!stream.AtEnd() && stream.Peek().GetType() != kCommaToken);

    if (!found_any) {
      return false;
    }

    for (unsigned i = 0; i < longhand_count; ++i) {
      const Longhand& longhand = *To<Longhand>(shorthand.properties()[i]);
      if (!parsed_longhand[i]) {
        // For each longhand that doesn't parse, add the initial (list-item)
        // value instead. However, we only do this *once* for reset-only
        // properties to end up with the initial value for the property as
        // a whole.
        //
        // Example:
        //
        //  animation: anim1, anim2;
        //
        // Should expand to (ignoring longhands other than name and timeline):
        //
        //   animation-name: anim1, anim2;
        //   animation-timeline: auto;
        //
        // It should *not* expand to:
        //
        //   animation-name: anim1, anim2;
        //   animation-timeline: auto, auto;
        //
        if (!is_reset_only(longhand.PropertyID()) || !longhands[i]->length()) {
          longhands[i]->Append(longhand.InitialValue());
        }
      }
      parsed_longhand[i] = false;
    }
  } while (ConsumeCommaIncludingWhitespace(stream));

  return true;
}

std::shared_ptr<const CSSValue> ConsumeColumnWidth(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return ConsumeIdent(stream);
  }
  // Always parse lengths in strict mode here, since it would be ambiguous
  // otherwise when used in the 'columns' shorthand property.
  CSSParserContext::ParserModeOverridingScope scope(*context, kHTMLStandardMode);
  std::shared_ptr<const CSSPrimitiveValue> column_width =
      ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!column_width) {
    return nullptr;
  }
  return column_width;
}

std::shared_ptr<const CSSValue> ConsumeColumnCount(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return ConsumeIdent(stream);
  }
  return ConsumePositiveInteger(stream, context);
}

bool ConsumeColumnWidthOrCount(CSSParserTokenStream& stream,
                               std::shared_ptr<const CSSParserContext> context,
                               std::shared_ptr<const CSSValue>& column_width,
                               std::shared_ptr<const CSSValue>& column_count) {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    ConsumeIdent(stream);
    return true;
  }
  if (!column_width) {
    column_width = ConsumeColumnWidth(stream, context);
    if (column_width) {
      return true;
    }
  }
  if (!column_count) {
    column_count = ConsumeColumnCount(stream, context);
  }
  return column_count != nullptr;
}

void AddProperty(CSSPropertyID resolved_property,
                 CSSPropertyID current_shorthand,
                 std::shared_ptr<const CSSValue> value,
                 bool important,
                 IsImplicitProperty implicit,
                 std::vector<CSSPropertyValue>& properties) {
  DCHECK(!IsPropertyAlias(resolved_property));
  DCHECK(implicit == IsImplicitProperty::kNotImplicit || implicit == IsImplicitProperty::kImplicit);

  int shorthand_index = 0;
  bool set_from_shorthand = false;

  if (IsValidCSSPropertyID(current_shorthand)) {
    std::vector<StylePropertyShorthand> shorthands;
    shorthands.reserve(4);
    getMatchingShorthandsForLonghand(resolved_property, &shorthands);
    set_from_shorthand = true;
    if (shorthands.size() > 1) {
      shorthand_index = indexOfShorthandForLonghand(current_shorthand, shorthands);
    }
  }

  properties.emplace_back(CSSPropertyValue(CSSPropertyName(resolved_property), value, important, set_from_shorthand,
                                           shorthand_index, implicit == IsImplicitProperty::kImplicit));
}

static void SetAllowsNegativePercentageReference(CSSValue* value) {
  if (auto* math_value = DynamicTo<CSSMathFunctionValue>(value)) {
    math_value->SetAllowsNegativePercentageReference();
  }
}

std::shared_ptr<const CSSValue> GetSingleValueOrMakeList(CSSValue::ValueListSeparator list_separator,
                                                         std::vector<std::shared_ptr<const CSSValue>> values) {
  if (values.size() == 1u) {
    return values.front();
  }
  return std::make_shared<CSSValueList>(list_separator, std::move(values));
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercentCountNegative(
    CSSParserTokenRange& range,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSPrimitiveValue> result =
      ConsumeLengthOrPercent(range, context, CSSPrimitiveValue::ValueRange::kNonNegative, UnitlessQuirk::kForbid);
  return result;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercentCountNegative(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSPrimitiveValue> result =
      ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, UnitlessQuirk::kForbid);
  return result;
}

bool ConsumeBackgroundPosition(CSSParserTokenStream& stream,
                               std::shared_ptr<const CSSParserContext> context,
                               UnitlessQuirk unitless,
                               std::shared_ptr<const CSSValue>& result_x,
                               std::shared_ptr<const CSSValue>& result_y) {
  std::vector<std::shared_ptr<const CSSValue>> values_x;
  std::vector<std::shared_ptr<const CSSValue>> values_y;

  do {
    std::shared_ptr<const CSSValue> position_x = nullptr;
    std::shared_ptr<const CSSValue> position_y = nullptr;
    if (!ConsumePosition(stream, context, unitless, position_x, position_y)) {
      return false;
    }
    // TODO(crbug.com/825895): So far, 'background-position' is the only
    // property that allows resolving a percentage against a negative value. If
    // we have more of such properties, we should instead pass an additional
    // argument to ask the parser to set this flag.
    SetAllowsNegativePercentageReference(const_cast<CSSValue*>(position_x.get()));
    SetAllowsNegativePercentageReference(const_cast<CSSValue*>(position_y.get()));
    values_x.push_back(position_x);
    values_y.push_back(position_y);
  } while (ConsumeCommaIncludingWhitespace(stream));

  // To conserve memory we don't wrap single values in lists.
  result_x = GetSingleValueOrMakeList(CSSValue::kCommaSeparator, std::move(values_x));
  result_y = GetSingleValueOrMakeList(CSSValue::kCommaSeparator, std::move(values_y));

  return true;
}

std::shared_ptr<const CSSValue> ConsumeBackgroundSize(CSSParserTokenRange& range,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      ParsingStyle parsing_style) {
  if (IdentMatches<CSSValueID::kContain, CSSValueID::kCover>(range.Peek().Id())) {
    return ConsumeIdent(range);
  }

  std::shared_ptr<const CSSValue> horizontal = ConsumeIdent<CSSValueID::kAuto>(range);
  if (!horizontal) {
    horizontal = ConsumeLengthOrPercentCountNegative(range, context);
  }
  if (!horizontal) {
    return nullptr;
  }

  std::shared_ptr<const CSSValue> vertical = nullptr;
  if (!range.AtEnd()) {
    if (range.Peek().Id() == CSSValueID::kAuto) {  // `auto' is the default
      range.ConsumeIncludingWhitespace();
    } else {
      vertical = ConsumeLengthOrPercentCountNegative(range, context);
    }
  } else if (parsing_style == ParsingStyle::kLegacy) {
    // Legacy syntax: "-webkit-background-size: 10px" is equivalent to
    // "background-size: 10px 10px".
    vertical = horizontal;
  }
  if (!vertical) {
    return horizontal;
  }
  return std::make_shared<CSSValuePair>(horizontal, vertical, CSSValuePair::kKeepIdenticalValues);
}

std::shared_ptr<const CSSValue> ConsumeBackgroundSize(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      ParsingStyle parsing_style) {
  if (IdentMatches<CSSValueID::kContain, CSSValueID::kCover>(stream.Peek().Id())) {
    return ConsumeIdent(stream);
  }

  std::shared_ptr<const CSSValue> horizontal = ConsumeIdent<CSSValueID::kAuto>(stream);
  if (!horizontal) {
    horizontal = ConsumeLengthOrPercentCountNegative(stream, context);
  }
  if (!horizontal) {
    return nullptr;
  }

  std::shared_ptr<const CSSValue> vertical = nullptr;
  if (!stream.AtEnd()) {
    if (stream.Peek().Id() == CSSValueID::kAuto) {  // `auto' is the default
      stream.ConsumeIncludingWhitespace();
    } else {
      vertical = ConsumeLengthOrPercentCountNegative(stream, context);
    }
  } else if (parsing_style == ParsingStyle::kLegacy) {
    // Legacy syntax: "-webkit-background-size: 10px" is equivalent to
    // "background-size: 10px 10px".
    vertical = horizontal;
  }
  if (!vertical) {
    return horizontal;
  }
  return std::make_shared<CSSValuePair>(horizontal, vertical, CSSValuePair::kKeepIdenticalValues);
}

std::shared_ptr<const CSSValue> ConsumeBackgroundBoxOrText(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kBorderBox, CSSValueID::kPaddingBox, CSSValueID::kContentBox, CSSValueID::kText>(
      stream);
}

std::shared_ptr<const CSSValue> ConsumeBackgroundAttachment(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kScroll, CSSValueID::kFixed, CSSValueID::kLocal>(stream);
}

// Returns a token whose token.Value() will contain the URL,
// or the empty string if there are fetch restrictions,
// or an EOF token if we failed to parse.
//
// NOTE: We are careful not to return a reference, since for
// the streaming parser, the token will be overwritten on once we
// move to the next one.
//
// NOTE: Keep in sync with the other ConsumeUrlAsToken.
CSSParserToken ConsumeUrlAsToken(CSSParserTokenRange& range, std::shared_ptr<const CSSParserContext> context) {
  const CSSParserToken* token = &range.Peek();
  if (token->GetType() == kUrlToken) {
    range.ConsumeIncludingWhitespace();
  } else if (token->FunctionId() == CSSValueID::kUrl) {
    CSSParserTokenRange url_range = range;
    CSSParserTokenRange url_args = url_range.ConsumeBlock();
    const CSSParserToken& next = url_args.ConsumeIncludingWhitespace();
    if (next.GetType() == kBadStringToken || !url_args.AtEnd()) {
      return CSSParserToken(kEOFToken);
    }
    DCHECK_EQ(next.GetType(), kStringToken);
    range = url_range;
    range.ConsumeWhitespace();
    token = &next;
  } else {
    return CSSParserToken(kEOFToken);
  }
  return *token;
}

CSSParserToken ConsumeUrlAsToken(CSSParserTokenStream& stream, std::shared_ptr<const CSSParserContext> context) {
  CSSParserToken token = stream.Peek();
  if (token.GetType() == kUrlToken) {
    stream.ConsumeIncludingWhitespace();
  } else if (token.FunctionId() == CSSValueID::kUrl) {
    {
      CSSParserTokenStream::RestoringBlockGuard guard(stream);
      stream.ConsumeWhitespace();
      // If the block doesn't start with a quote, then the tokenizer
      // would return a kUrlToken or kBadUrlToken instead of a
      // kFunctionToken. Note also that this Peek() placates the
      // DCHECK that we Peek() before Consume().
      DCHECK(stream.Peek().GetType() == kStringToken || stream.Peek().GetType() == kBadStringToken);
      token = stream.ConsumeIncludingWhitespace();
      if (token.GetType() == kBadStringToken || !stream.AtEnd()) {
        return CSSParserToken(kEOFToken);
      }
      guard.Release();
    }
    DCHECK_EQ(token.GetType(), kStringToken);
    stream.ConsumeWhitespace();
  } else {
    return CSSParserToken(kEOFToken);
  }
  return token;
}

CSSUrlData CollectUrlData(const std::string& url, std::shared_ptr<const CSSParserContext> context) {
  return CSSUrlData(url, context->CompleteNonEmptyURL(url));
}

static std::shared_ptr<const CSSImageValue> CreateCSSImageValueWithReferrer(
    std::string uri,
    std::shared_ptr<const CSSParserContext> context) {
  auto image_value = std::make_shared<CSSImageValue>(CollectUrlData(uri, context));
  return image_value;
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSCustomIdentValue>>::type
ConsumeDashedIdent(T& stream, std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().GetType() != kIdentToken) {
    return nullptr;
  }

  if (stream.Peek().Value().rfind("--", 0) != 0) {
    return nullptr;
  }

  return ConsumeCustomIdent(stream, context);
}

template std::shared_ptr<const CSSCustomIdentValue> ConsumeDashedIdent(CSSParserTokenStream&,
                                                                       std::shared_ptr<const CSSParserContext> context);
template std::shared_ptr<const CSSCustomIdentValue> ConsumeDashedIdent(CSSParserTokenRange&,
                                                                       std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSStringValue> ConsumeString(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() != kStringToken) {
    return nullptr;
  }
  return std::make_shared<CSSStringValue>(std::string(stream.ConsumeIncludingWhitespace().Value()));
}

std::shared_ptr<const CSSStringValue> ConsumeString(CSSParserTokenRange& range) {
  if (range.Peek().GetType() != kStringToken) {
    return nullptr;
  }
  return std::make_shared<CSSStringValue>(std::string(range.ConsumeIncludingWhitespace().Value()));
}

// With the streaming parser, we cannot return a StringView, since the token
// will go out of scope when we exit the function and the StringView might
// point into the token.
std::string ConsumeStringAsString(CSSParserTokenStream& stream, bool* is_string_null) {
  if (stream.Peek().GetType() != CSSParserTokenType::kStringToken) {
    *is_string_null = true;
    return "";
  }

  CSSParserToken token = stream.ConsumeIncludingWhitespace();
  std::string_view view = token.Value();
  *is_string_null = view.data() == nullptr;
  return std::string(view);
}

bool IsImageSet(const CSSValueID id) {
  return id == CSSValueID::kWebkitImageSet || id == CSSValueID::kImageSet;
}

bool IsGeneratedImage(const CSSValueID id) {
  switch (id) {
    case CSSValueID::kLinearGradient:
    case CSSValueID::kRadialGradient:
    case CSSValueID::kConicGradient:
    case CSSValueID::kRepeatingLinearGradient:
    case CSSValueID::kRepeatingRadialGradient:
    case CSSValueID::kRepeatingConicGradient:
    case CSSValueID::kWebkitLinearGradient:
    case CSSValueID::kWebkitRadialGradient:
    case CSSValueID::kWebkitRepeatingLinearGradient:
    case CSSValueID::kWebkitRepeatingRadialGradient:
    case CSSValueID::kWebkitGradient:
    case CSSValueID::kWebkitCrossFade:
    case CSSValueID::kPaint:
    case CSSValueID::kCrossFade:
      return true;

    default:
      return false;
  }
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeGradientLengthOrPercent(CSSParserTokenStream& stream,
                                                                        std::shared_ptr<const CSSParserContext> context,
                                                                        CSSPrimitiveValue::ValueRange value_range,
                                                                        UnitlessQuirk unitless) {
  return ConsumeLengthOrPercent(stream, context, value_range, unitless);
}

using PositionFunctor = std::shared_ptr<const CSSPrimitiveValue> (*)(CSSParserTokenStream&,
                                                                     std::shared_ptr<const CSSParserContext> context,
                                                                     CSSPrimitiveValue::ValueRange,
                                                                     UnitlessQuirk);

static bool ConsumeGradientColorStops(CSSParserTokenStream& stream,
                                      std::shared_ptr<const CSSParserContext> context,
                                      std::shared_ptr<cssvalue::CSSGradientValue> gradient,
                                      PositionFunctor consume_position_func) {
  bool supports_color_hints = gradient->GradientType() == cssvalue::kCSSLinearGradient ||
                              gradient->GradientType() == cssvalue::kCSSRadialGradient ||
                              gradient->GradientType() == cssvalue::kCSSConicGradient;

  // The first color stop cannot be a color hint.
  bool previous_stop_was_color_hint = true;
  do {
    cssvalue::CSSGradientColorStop stop;
    stop.color_ = ConsumeColor(stream, context);
    // Two hints in a row are not allowed.
    if (!stop.color_ && (!supports_color_hints || previous_stop_was_color_hint)) {
      return false;
    }
    previous_stop_was_color_hint = !stop.color_;
    stop.offset_ = consume_position_func(stream, context, CSSPrimitiveValue::ValueRange::kAll, UnitlessQuirk::kForbid);
    if (!stop.color_ && !stop.offset_) {
      return false;
    }
    gradient->AddStop(stop);

    if (!stop.color_ || !stop.offset_) {
      continue;
    }

    // Optional second position.
    stop.offset_ = consume_position_func(stream, context, CSSPrimitiveValue::ValueRange::kAll, UnitlessQuirk::kForbid);
    if (stop.offset_) {
      gradient->AddStop(stop);
    }
  } while (ConsumeCommaIncludingWhitespace(stream));

  // The last color stop cannot be a color hint.
  if (previous_stop_was_color_hint) {
    return false;
  }

  // Must have 2 or more stops to be valid.
  return gradient->StopCount() >= 2;
}

static std::shared_ptr<const CSSValue> ConsumeRadialGradient(CSSParserTokenStream& stream,
                                                             std::shared_ptr<const CSSParserContext> context,
                                                             cssvalue::CSSGradientRepeat repeating) {
  std::shared_ptr<const CSSIdentifierValue> shape = nullptr;
  std::shared_ptr<const CSSIdentifierValue> size_keyword = nullptr;
  std::shared_ptr<const CSSPrimitiveValue> horizontal_size = nullptr;
  std::shared_ptr<const CSSPrimitiveValue> vertical_size = nullptr;

  // First part of grammar, the size/shape/color space clause:
  // [ in <color-space>? &&
  // [[ circle || <length> ] |
  // [ ellipse || [ <length> | <percentage> ]{2} ] |
  // [ [ circle | ellipse] || <size-keyword> ]] ]

  bool has_color_space = false;

  for (int i = 0; i < 3; ++i) {
    if (stream.Peek().GetType() == kIdentToken) {
      CSSValueID id = stream.Peek().Id();
      if (id == CSSValueID::kCircle || id == CSSValueID::kEllipse) {
        if (shape) {
          return nullptr;
        }
        shape = ConsumeIdent(stream);
      } else if (id == CSSValueID::kClosestSide || id == CSSValueID::kClosestCorner ||
                 id == CSSValueID::kFarthestSide || id == CSSValueID::kFarthestCorner) {
        if (size_keyword) {
          return nullptr;
        }
        size_keyword = ConsumeIdent(stream);
      } else {
        break;
      }
    } else {
      std::shared_ptr<const CSSPrimitiveValue> center =
          ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
      if (!center) {
        break;
      }
      if (horizontal_size) {
        return nullptr;
      }
      horizontal_size = center;
      center = ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
      if (center) {
        vertical_size = center;
        ++i;
      }
    }
  }

  // You can specify size as a keyword or a length/percentage, not both.
  if (size_keyword && horizontal_size) {
    return nullptr;
  }
  // Circles must have 0 or 1 lengths.
  if (shape && shape->GetValueID() == CSSValueID::kCircle && vertical_size) {
    return nullptr;
  }
  // Ellipses must have 0 or 2 length/percentages.
  if (shape && shape->GetValueID() == CSSValueID::kEllipse && horizontal_size && !vertical_size) {
    return nullptr;
  }
  // If there's only one size, it must be a length.
  if (!vertical_size && horizontal_size && horizontal_size->IsPercentage()) {
    return nullptr;
  }
  if ((horizontal_size && horizontal_size->IsCalculatedPercentageWithLength()) ||
      (vertical_size && vertical_size->IsCalculatedPercentageWithLength())) {
    return nullptr;
  }

  std::shared_ptr<const CSSValue> center_x = nullptr;
  std::shared_ptr<const CSSValue> center_y = nullptr;
  if (stream.Peek().Id() == CSSValueID::kAt) {
    stream.ConsumeIncludingWhitespace();
    ConsumePosition(stream, context, UnitlessQuirk::kForbid, center_x, center_y);
    if (!(center_x && center_y)) {
      return nullptr;
    }
    // Right now, CSS radial gradients have the same start and end centers.
  }

  if ((shape || size_keyword || horizontal_size || center_x || center_y || has_color_space) &&
      !ConsumeCommaIncludingWhitespace(stream)) {
    return nullptr;
  }

  std::shared_ptr<cssvalue::CSSGradientValue> result = std::make_shared<cssvalue::CSSRadialGradientValue>(
      center_x, center_y, shape, size_keyword, horizontal_size, vertical_size, repeating, cssvalue::kCSSRadialGradient);

  return ConsumeGradientColorStops(stream, context, result, ConsumeGradientLengthOrPercent) ? result : nullptr;
}

static std::shared_ptr<const CSSValue> ConsumeLinearGradient(CSSParserTokenStream& stream,
                                                             std::shared_ptr<const CSSParserContext> context,
                                                             cssvalue::CSSGradientRepeat repeating,
                                                             cssvalue::CSSGradientType gradient_type) {
  // First part of grammar, the size/shape/color space clause:
  // [ in <color-space>? || [ <angle> | to <side-or-corner> ]?]
  bool expect_comma = true;
  bool has_color_space = false;

  std::shared_ptr<const CSSPrimitiveValue> angle = ConsumeAngle(stream, context);
  std::shared_ptr<const CSSIdentifierValue> end_x = nullptr;
  std::shared_ptr<const CSSIdentifierValue> end_y = nullptr;
  if (!angle) {
    // <side-or-corner> parsing
    if (gradient_type == cssvalue::kCSSPrefixedLinearGradient || ConsumeIdent<CSSValueID::kTo>(stream)) {
      end_x = ConsumeIdent<CSSValueID::kLeft, CSSValueID::kRight>(stream);
      end_y = ConsumeIdent<CSSValueID::kBottom, CSSValueID::kTop>(stream);
      if (!end_x && !end_y) {
        if (gradient_type == cssvalue::kCSSLinearGradient) {
          return nullptr;
        }
        end_y = CSSIdentifierValue::Create(CSSValueID::kTop);
        expect_comma = false;
      } else if (!end_x) {
        end_x = ConsumeIdent<CSSValueID::kLeft, CSSValueID::kRight>(stream);
      }
    } else {
      // No <angle> or <side-to-corner>
      expect_comma = false;
    }
  }

  if (has_color_space) {
    expect_comma = true;
  }

  if (expect_comma && !ConsumeCommaIncludingWhitespace(stream)) {
    return nullptr;
  }

  std::shared_ptr<cssvalue::CSSGradientValue> result = std::make_shared<cssvalue::CSSLinearGradientValue>(
      end_x, end_y, nullptr, nullptr, angle, repeating, gradient_type);

  return ConsumeGradientColorStops(stream, context, result, ConsumeGradientLengthOrPercent) ? result : nullptr;
}

// This should go away once we drop support for -webkit-gradient
static std::shared_ptr<const CSSPrimitiveValue> ConsumeDeprecatedGradientPoint(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context,
    bool horizontal) {
  if (stream.Peek().GetType() == kIdentToken) {
    if ((horizontal && ConsumeIdent<CSSValueID::kLeft>(stream)) ||
        (!horizontal && ConsumeIdent<CSSValueID::kTop>(stream))) {
      return CSSNumericLiteralValue::Create(0., CSSPrimitiveValue::UnitType::kPercentage);
    }
    if ((horizontal && ConsumeIdent<CSSValueID::kRight>(stream)) ||
        (!horizontal && ConsumeIdent<CSSValueID::kBottom>(stream))) {
      return CSSNumericLiteralValue::Create(100., CSSPrimitiveValue::UnitType::kPercentage);
    }
    if (ConsumeIdent<CSSValueID::kCenter>(stream)) {
      return CSSNumericLiteralValue::Create(50., CSSPrimitiveValue::UnitType::kPercentage);
    }
    return nullptr;
  }
  std::shared_ptr<const CSSPrimitiveValue> result =
      ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  if (!result) {
    result = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  }
  return result;
}

// Used to parse colors for -webkit-gradient(...).
static std::shared_ptr<const CSSValue> ConsumeDeprecatedGradientStopColor(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kCurrentcolor) {
    return nullptr;
  }
  return ConsumeColor(stream, context);
}

static bool ConsumeDeprecatedGradientColorStop(CSSParserTokenStream& stream,
                                               cssvalue::CSSGradientColorStop& stop,
                                               std::shared_ptr<const CSSParserContext> context) {
  CSSValueID id = stream.Peek().FunctionId();
  if (id != CSSValueID::kFrom && id != CSSValueID::kTo && id != CSSValueID::kColorStop) {
    return false;
  }

  {
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();
    double position;
    if (id == CSSValueID::kFrom || id == CSSValueID::kTo) {
      position = (id == CSSValueID::kFrom) ? 0 : 1;
    } else {
      DCHECK(id == CSSValueID::kColorStop);
      if (std::shared_ptr<const CSSPrimitiveValue> percent_value =
              ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kAll)) {
        position = percent_value->GetDoubleValue() / 100.0;
      } else if (!ConsumeNumberRaw(stream, context, position)) {
        return false;
      }

      if (!ConsumeCommaIncludingWhitespace(stream)) {
        return false;
      }
    }

    stop.offset_ = CSSNumericLiteralValue::Create(position, CSSPrimitiveValue::UnitType::kNumber);
    stop.color_ = ConsumeDeprecatedGradientStopColor(stream, context);
    if (!stream.AtEnd()) {
      return false;
    }
  }
  stream.ConsumeWhitespace();
  return stop.color_.get();
}

static std::shared_ptr<const CSSValue> ConsumeDeprecatedGradient(CSSParserTokenStream& stream,
                                                                 std::shared_ptr<const CSSParserContext> context) {
  CSSValueID id = stream.ConsumeIncludingWhitespace().Id();
  if (id != CSSValueID::kRadial && id != CSSValueID::kLinear) {
    return nullptr;
  }

  if (!ConsumeCommaIncludingWhitespace(stream)) {
    return nullptr;
  }

  std::shared_ptr<const CSSPrimitiveValue> first_x = ConsumeDeprecatedGradientPoint(stream, context, true);
  if (!first_x) {
    return nullptr;
  }
  std::shared_ptr<const CSSPrimitiveValue> first_y = ConsumeDeprecatedGradientPoint(stream, context, false);
  if (!first_y) {
    return nullptr;
  }
  if (!ConsumeCommaIncludingWhitespace(stream)) {
    return nullptr;
  }

  // For radial gradients only, we now expect a numeric radius.
  std::shared_ptr<const CSSPrimitiveValue> first_radius = nullptr;
  if (id == CSSValueID::kRadial) {
    first_radius = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!first_radius || !ConsumeCommaIncludingWhitespace(stream)) {
      return nullptr;
    }
  }

  std::shared_ptr<const CSSPrimitiveValue> second_x = ConsumeDeprecatedGradientPoint(stream, context, true);
  if (!second_x) {
    return nullptr;
  }
  std::shared_ptr<const CSSPrimitiveValue> second_y = ConsumeDeprecatedGradientPoint(stream, context, false);
  if (!second_y) {
    return nullptr;
  }

  // For radial gradients only, we now expect the second radius.
  std::shared_ptr<const CSSPrimitiveValue> second_radius = nullptr;
  if (id == CSSValueID::kRadial) {
    if (!ConsumeCommaIncludingWhitespace(stream)) {
      return nullptr;
    }
    second_radius = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!second_radius) {
      return nullptr;
    }
  }

  std::shared_ptr<cssvalue::CSSGradientValue> result;
  if (id == CSSValueID::kRadial) {
    result = std::make_shared<cssvalue::CSSRadialGradientValue>(first_x, first_y, first_radius, second_x, second_y,
                                                                second_radius, cssvalue::kNonRepeating,
                                                                cssvalue::kCSSDeprecatedRadialGradient);
  } else {
    result = std::make_shared<cssvalue::CSSLinearGradientValue>(
        first_x, first_y, second_x, second_y, nullptr, cssvalue::kNonRepeating, cssvalue::kCSSDeprecatedLinearGradient);
  }
  cssvalue::CSSGradientColorStop stop;
  while (ConsumeCommaIncludingWhitespace(stream)) {
    if (!ConsumeDeprecatedGradientColorStop(stream, stop, context)) {
      return nullptr;
    }
    result->AddStop(stop);
  }

  return result;
}

static std::shared_ptr<const CSSValue> ConsumeDeprecatedRadialGradient(CSSParserTokenStream& stream,
                                                                       std::shared_ptr<const CSSParserContext> context,
                                                                       cssvalue::CSSGradientRepeat repeating) {
  std::shared_ptr<const CSSValue> center_x = nullptr;
  std::shared_ptr<const CSSValue> center_y = nullptr;
  ConsumeOneOrTwoValuedPosition(stream, context, UnitlessQuirk::kForbid, center_x, center_y);
  if ((center_x || center_y) && !ConsumeCommaIncludingWhitespace(stream)) {
    return nullptr;
  }

  std::shared_ptr<const CSSIdentifierValue> shape = ConsumeIdent<CSSValueID::kCircle, CSSValueID::kEllipse>(stream);
  std::shared_ptr<const CSSIdentifierValue> size_keyword =
      ConsumeIdent<CSSValueID::kClosestSide, CSSValueID::kClosestCorner, CSSValueID::kFarthestSide,
                   CSSValueID::kFarthestCorner, CSSValueID::kContain, CSSValueID::kCover>(stream);
  if (!shape) {
    shape = ConsumeIdent<CSSValueID::kCircle, CSSValueID::kEllipse>(stream);
  }

  // Or, two lengths or percentages
  std::shared_ptr<const CSSPrimitiveValue> horizontal_size = nullptr;
  std::shared_ptr<const CSSPrimitiveValue> vertical_size = nullptr;
  if (!shape && !size_keyword) {
    horizontal_size = ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (horizontal_size) {
      vertical_size = ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
      if (!vertical_size) {
        return nullptr;
      }
      ConsumeCommaIncludingWhitespace(stream);
    }
  } else {
    ConsumeCommaIncludingWhitespace(stream);
  }

  std::shared_ptr<cssvalue::CSSGradientValue> result = std::make_shared<cssvalue::CSSRadialGradientValue>(
      center_x, center_y, shape, size_keyword, horizontal_size, vertical_size, repeating,
      cssvalue::kCSSPrefixedRadialGradient);
  return ConsumeGradientColorStops(stream, context, result, ConsumeGradientLengthOrPercent) ? result : nullptr;
}

static std::shared_ptr<const CSSPrimitiveValue> ConsumeGradientAngleOrPercent(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context,
    CSSPrimitiveValue::ValueRange value_range,
    UnitlessQuirk) {
  const CSSParserToken& token = stream.Peek();
  if (token.GetType() == kDimensionToken || token.GetType() == kNumberToken) {
    return ConsumeAngle(stream, context);
  }
  if (token.GetType() == kPercentageToken) {
    return ConsumePercent(stream, context, value_range);
  }
  MathFunctionParser math_parser(stream, context, value_range);
  if (auto calculation = *math_parser.Value()) {
    CalculationResultCategory category = calculation->Category();
    // TODO(fs): Add and support kCalcPercentAngle?
    if (category == kCalcAngle || category == kCalcPercent) {
      return math_parser.ConsumeValue();
    }
  }
  return nullptr;
}

static std::shared_ptr<const CSSValue> ConsumeConicGradient(CSSParserTokenStream& stream,
                                                            std::shared_ptr<const CSSParserContext> context,
                                                            cssvalue::CSSGradientRepeat repeating) {
  bool has_color_space = false;

  std::shared_ptr<const CSSPrimitiveValue> from_angle = nullptr;
  if (ConsumeIdent<CSSValueID::kFrom>(stream)) {
    if (!(from_angle = ConsumeAngle(stream, context))) {
      return nullptr;
    }
  }

  std::shared_ptr<const CSSValue> center_x = nullptr;
  std::shared_ptr<const CSSValue> center_y = nullptr;
  if (ConsumeIdent<CSSValueID::kAt>(stream)) {
    if (!ConsumePosition(stream, context, UnitlessQuirk::kForbid, center_x, center_y)) {
      return nullptr;
    }
  }

  // Comma separator required when fromAngle, position or color_space is
  // present.
  if ((from_angle || center_x || center_y || has_color_space) && !ConsumeCommaIncludingWhitespace(stream)) {
    return nullptr;
  }

  auto result = std::make_shared<cssvalue::CSSConicGradientValue>(center_x, center_y, from_angle, repeating);

  return ConsumeGradientColorStops(stream, context, result, ConsumeGradientAngleOrPercent) ? result : nullptr;
}

static std::shared_ptr<const CSSValue> ConsumeDeprecatedWebkitCrossFade(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> from_image_value = ConsumeImageOrNone(stream, context);
  if (!from_image_value || !ConsumeCommaIncludingWhitespace(stream)) {
    return nullptr;
  }
  std::shared_ptr<const CSSValue> to_image_value = ConsumeImageOrNone(stream, context);
  if (!to_image_value || !ConsumeCommaIncludingWhitespace(stream)) {
    return nullptr;
  }

  std::shared_ptr<const CSSPrimitiveValue> percentage = nullptr;
  if (std::shared_ptr<const CSSPrimitiveValue> percent_value =
          ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kAll)) {
    percentage = CSSNumericLiteralValue::Create(ClampTo<double>(percent_value->GetDoubleValue() / 100.0, 0, 1),
                                                CSSPrimitiveValue::UnitType::kNumber);
  } else if (std::shared_ptr<const CSSPrimitiveValue> number_value =
                 ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kAll)) {
    percentage = CSSNumericLiteralValue::Create(ClampTo<double>(number_value->GetDoubleValue(), 0, 1),
                                                CSSPrimitiveValue::UnitType::kNumber);
  }

  if (!percentage) {
    return nullptr;
  }
  return std::make_shared<cssvalue::CSSCrossfadeValue>(
      /*is_legacy_variant=*/true,
      std::vector<std::pair<std::shared_ptr<const CSSValue>, std::shared_ptr<const CSSPrimitiveValue>>>{
          {from_image_value, nullptr}, {to_image_value, percentage}});
}

static std::shared_ptr<const CSSValue> ConsumeImageSet(CSSParserTokenStream& stream,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       ConsumeGeneratedImagePolicy generated_image_policy);

static std::shared_ptr<const CSSValue> ConsumeGeneratedImage(CSSParserTokenStream& stream,
                                                             std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeImage(CSSParserTokenStream& stream,
                                             std::shared_ptr<const CSSParserContext> context,
                                             const ConsumeGeneratedImagePolicy generated_image_policy,
                                             const ConsumeStringUrlImagePolicy string_url_image_policy,
                                             const ConsumeImageSetImagePolicy image_set_image_policy) {
  CSSParserToken uri = ConsumeUrlAsToken(stream, context);
  if (uri.GetType() != kEOFToken) {
    return CreateCSSImageValueWithReferrer(std::string(uri.Value()), context);
  }
  if (string_url_image_policy == ConsumeStringUrlImagePolicy::kAllow) {
    bool is_uri_null = false;
    std::string uri_string = ConsumeStringAsString(stream, &is_uri_null);
    if (!is_uri_null) {
      return CreateCSSImageValueWithReferrer(uri_string, context);
    }
  }
  if (stream.Peek().GetType() == kFunctionToken) {
    CSSValueID id = stream.Peek().FunctionId();
    if (image_set_image_policy == ConsumeImageSetImagePolicy::kAllow && IsImageSet(id)) {
      return ConsumeImageSet(stream, context, generated_image_policy);
    }
    if (generated_image_policy == ConsumeGeneratedImagePolicy::kAllow && IsGeneratedImage(id)) {
      return ConsumeGeneratedImage(stream, context);
    }
  }
  return nullptr;
}

static std::shared_ptr<const CSSImageSetTypeValue> ConsumeImageSetType(CSSParserTokenStream& stream) {
  if (stream.Peek().FunctionId() != CSSValueID::kType) {
    return nullptr;
  }

  std::string type;
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();

    bool is_type_null = false;
    type = ConsumeStringAsString(stream, &is_type_null);
    if (is_type_null || !stream.AtEnd()) {
      return nullptr;
    }

    guard.Release();
  }
  stream.ConsumeWhitespace();
  return std::make_shared<CSSImageSetTypeValue>(type);
}

static std::shared_ptr<const CSSImageSetOptionValue> ConsumeImageSetOption(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context,
    ConsumeGeneratedImagePolicy generated_image_policy) {
  std::shared_ptr<const CSSValue> image =
      ConsumeImage(stream, context, generated_image_policy, ConsumeStringUrlImagePolicy::kAllow,
                   ConsumeImageSetImagePolicy::kForbid);
  if (!image) {
    return nullptr;
  }

  // Type could appear before or after resolution
  std::shared_ptr<const CSSImageSetTypeValue> type = ConsumeImageSetType(stream);
  std::shared_ptr<const CSSPrimitiveValue> resolution = ConsumeResolution(stream, context);
  if (!type) {
    type = ConsumeImageSetType(stream);
  }

  return std::make_shared<CSSImageSetOptionValue>(image, resolution, type);
}

static std::shared_ptr<const CSSValue> ConsumeImageSet(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context,
    ConsumeGeneratedImagePolicy generated_image_policy = ConsumeGeneratedImagePolicy::kAllow) {
  auto image_set = std::make_shared<CSSImageSetValue>();
  CSSValueID function_id = stream.Peek().FunctionId();
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();

    do {
      auto image_set_option = ConsumeImageSetOption(stream, context, generated_image_policy);
      if (!image_set_option) {
        return nullptr;
      }

      image_set->Append(image_set_option);
    } while (ConsumeCommaIncludingWhitespace(stream));

    if (!stream.AtEnd()) {
      return nullptr;
    }

    switch (function_id) {
      case CSSValueID::kWebkitImageSet:
        break;

      case CSSValueID::kImageSet:
        break;

      default:
        NOTREACHED_IN_MIGRATION();
        break;
    }

    guard.Release();
  }
  stream.ConsumeWhitespace();

  return image_set;
}

// https://drafts.csswg.org/css-images-4/#cross-fade-function
static std::shared_ptr<const CSSValue> ConsumeCrossFade(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context) {
  // Parse an arbitrary comma-separated image|color values,
  // where each image may have a percentage before or after it.
  std::vector<std::pair<std::shared_ptr<const CSSValue>, std::shared_ptr<const CSSPrimitiveValue>>>
      image_and_percentages;
  std::shared_ptr<const CSSValue> image = nullptr;
  std::shared_ptr<const CSSPrimitiveValue> percentage = nullptr;
  for (;;) {
    if (std::shared_ptr<const CSSPrimitiveValue> percent_value =
            ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kAll)) {
      if (percentage) {
        return nullptr;
      }
      if (percent_value->IsNumericLiteralValue()) {
        double val = percent_value->GetDoubleValue();
        if (!(val >= 0.0 && val <= 100.0)) {  // Includes checks for NaN and infinities.
          return nullptr;
        }
      }
      percentage = percent_value;
      continue;
    } else if (std::shared_ptr<const CSSValue> image_value = ConsumeImage(stream, context)) {
      if (image) {
        return nullptr;
      }
      image = image_value;
    } else if (std::shared_ptr<const CSSValue> color_value = ConsumeColor(stream, context)) {
      if (image) {
        return nullptr;
      }

      // Wrap the color in a constant gradient, so that we can treat it as a
      // gradient in nearly all the remaining code.
      image = std::make_shared<cssvalue::CSSConstantGradientValue>(color_value);
    } else {
      if (!image) {
        return nullptr;
      }
      image_and_percentages.emplace_back(image, percentage);
      image = nullptr;
      percentage = nullptr;
      if (!ConsumeCommaIncludingWhitespace(stream)) {
        break;
      }
    }
  }
  if (image_and_percentages.empty()) {
    return nullptr;
  }

  return std::make_shared<cssvalue::CSSCrossfadeValue>(
      /*is_legacy_variant=*/false, image_and_percentages);
}

static std::shared_ptr<const CSSValue> ConsumeGeneratedImage(CSSParserTokenStream& stream,
                                                             std::shared_ptr<const CSSParserContext> context) {
  CSSValueID id = stream.Peek().FunctionId();
  if (!IsGeneratedImage(id)) {
    return nullptr;
  }

  std::shared_ptr<const CSSValue> result = nullptr;
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();
    if (id == CSSValueID::kRadialGradient) {
      result = ConsumeRadialGradient(stream, context, cssvalue::kNonRepeating);
    } else if (id == CSSValueID::kRepeatingRadialGradient) {
      result = ConsumeRadialGradient(stream, context, cssvalue::kRepeating);
    } else if (id == CSSValueID::kWebkitLinearGradient) {
      result = ConsumeLinearGradient(stream, context, cssvalue::kNonRepeating, cssvalue::kCSSPrefixedLinearGradient);
    } else if (id == CSSValueID::kWebkitRepeatingLinearGradient) {
      result = ConsumeLinearGradient(stream, context, cssvalue::kRepeating, cssvalue::kCSSPrefixedLinearGradient);
    } else if (id == CSSValueID::kRepeatingLinearGradient) {
      result = ConsumeLinearGradient(stream, context, cssvalue::kRepeating, cssvalue::kCSSLinearGradient);
    } else if (id == CSSValueID::kLinearGradient) {
      result = ConsumeLinearGradient(stream, context, cssvalue::kNonRepeating, cssvalue::kCSSLinearGradient);
    } else if (id == CSSValueID::kWebkitGradient) {
      result = ConsumeDeprecatedGradient(stream, context);
    } else if (id == CSSValueID::kWebkitRadialGradient) {
      result = ConsumeDeprecatedRadialGradient(stream, context, cssvalue::kNonRepeating);
    } else if (id == CSSValueID::kWebkitRepeatingRadialGradient) {
      result = ConsumeDeprecatedRadialGradient(stream, context, cssvalue::kRepeating);
    } else if (id == CSSValueID::kConicGradient) {
      result = ConsumeConicGradient(stream, context, cssvalue::kNonRepeating);
    } else if (id == CSSValueID::kRepeatingConicGradient) {
      result = ConsumeConicGradient(stream, context, cssvalue::kRepeating);
    } else if (id == CSSValueID::kWebkitCrossFade) {
      result = ConsumeDeprecatedWebkitCrossFade(stream, context);
    } else if (id == CSSValueID::kCrossFade) {
      result = ConsumeCrossFade(stream, context);
    } else if (id == CSSValueID::kPaint) {
      result = nullptr;
    }
    if (!result || !stream.AtEnd()) {
      return nullptr;
    }
    guard.Release();
  }
  stream.ConsumeWhitespace();

  return result;
}

std::shared_ptr<const CSSValue> ConsumeImageOrNone(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return ConsumeIdent(stream);
  }
  return ConsumeImage(stream, context);
}

std::shared_ptr<const CSSValue> ConsumePrefixedBackgroundBox(CSSParserTokenStream& stream,
                                                             AllowTextValue allow_text_value) {
  // The values 'border', 'padding' and 'content' are deprecated and do not
  // apply to the version of the property that has the -webkit- prefix removed.
  if (std::shared_ptr<const CSSValue> value = ConsumeIdentRange(stream, CSSValueID::kBorder, CSSValueID::kPaddingBox)) {
    return value;
  }
  if (allow_text_value == AllowTextValue::kAllow && stream.Peek().Id() == CSSValueID::kText) {
    return ConsumeIdent(stream);
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeCoordBoxOrNoClip(CSSParserTokenStream& stream) {
  if (stream.Peek().Id() == CSSValueID::kNoClip) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeCoordBox(stream);
}

std::shared_ptr<const CSSIdentifierValue> ConsumeRepeatStyleIdent(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kRepeat, CSSValueID::kNoRepeat, CSSValueID::kRound, CSSValueID::kSpace>(stream);
}

std::shared_ptr<CSSRepeatStyleValue> ConsumeRepeatStyleValue(CSSParserTokenStream& range) {
  if (auto id = ConsumeIdent<CSSValueID::kRepeatX>(range)) {
    return std::make_shared<CSSRepeatStyleValue>(id);
  }

  if (auto id = ConsumeIdent<CSSValueID::kRepeatY>(range)) {
    return std::make_shared<CSSRepeatStyleValue>(id);
  }

  if (auto id1 = ConsumeRepeatStyleIdent(range)) {
    if (auto id2 = ConsumeRepeatStyleIdent(range)) {
      return std::make_shared<CSSRepeatStyleValue>(id1, id2);
    }

    return std::make_shared<CSSRepeatStyleValue>(id1);
  }

  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeMaskMode(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kAlpha, CSSValueID::kLuminance, CSSValueID::kMatchSource>(stream);
}

std::shared_ptr<const CSSValue> ConsumeMaskComposite(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kAdd, CSSValueID::kSubtract, CSSValueID::kIntersect, CSSValueID::kExclude>(stream);
}

std::shared_ptr<const CSSValue> ConsumePrefixedMaskComposite(CSSParserTokenStream& stream) {
  return ConsumeIdentRange(stream, CSSValueID::kClear, CSSValueID::kPlusLighter);
}

namespace {

std::shared_ptr<const CSSValue> ConsumeBackgroundComponent(CSSPropertyID resolved_property,
                                                           CSSParserTokenStream& stream,
                                                           std::shared_ptr<const CSSParserContext> context,
                                                           bool use_alias_parsing) {
  switch (resolved_property) {
    case CSSPropertyID::kBackgroundClip:
      return ConsumeBackgroundBoxOrText(stream);
    case CSSPropertyID::kBackgroundAttachment:
      return ConsumeBackgroundAttachment(stream);
    case CSSPropertyID::kBackgroundOrigin:
      return ConsumeBackgroundBox(stream);
    case CSSPropertyID::kBackgroundImage:
    case CSSPropertyID::kBackgroundPositionX:
      return ConsumeImageOrNone(stream, context);
    case CSSPropertyID::kBackgroundPositionY:
      return ConsumePositionLonghand<CSSValueID::kTop, CSSValueID::kBottom>(stream, context);
    case CSSPropertyID::kBackgroundSize:
      return ConsumeBackgroundSize(stream, context, ParsingStyle::kNotLegacy);
    case CSSPropertyID::kBackgroundColor:
      return ConsumeColor(stream, context);
    case CSSPropertyID::kBackgroundRepeat:
      return ConsumeRepeatStyleValue(stream);
    default:
      return nullptr;
  };
}

}  // namespace

std::shared_ptr<const CSSValue> ConsumeBackgroundBox(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kBorderBox, CSSValueID::kPaddingBox, CSSValueID::kContentBox>(stream);
}

// Note: this assumes y properties (e.g. background-position-y) follow the x
// properties in the shorthand array.
// TODO(jiameng): this is used by background and -webkit-mask, hence we
// need local_context as an input that contains shorthand id. We will consider
// remove local_context as an input after
//   (i). StylePropertyShorthand is refactored and
//   (ii). we split parsing logic of background and -webkit-mask into
//   different property classes.
bool ParseBackgroundOrMask(bool important,
                           CSSParserTokenStream& stream,
                           std::shared_ptr<const CSSParserContext> context,
                           const CSSParserLocalContext& local_context,
                           std::vector<CSSPropertyValue>& properties) {
  CSSPropertyID shorthand_id = local_context.CurrentShorthand();
  DCHECK(shorthand_id == CSSPropertyID::kBackground);
  const StylePropertyShorthand& shorthand = backgroundShorthand();

  const unsigned longhand_count = shorthand.length();
  std::vector<std::shared_ptr<const CSSValue>> longhands[10];
  CHECK_LE(longhand_count, 10u);

  bool implicit = false;
  bool previous_layer_had_background_color = false;
  do {
    bool parsed_longhand[10] = {false};
    std::shared_ptr<const CSSValue> origin_value = nullptr;
    bool found_property;
    bool found_any = false;
    do {
      found_property = false;
      bool bg_position_parsed_in_current_layer = false;
      for (unsigned i = 0; i < longhand_count; ++i) {
        if (parsed_longhand[i]) {
          continue;
        }

        std::shared_ptr<const CSSValue> value = nullptr;
        std::shared_ptr<const CSSValue> value_y = nullptr;
        const CSSProperty& property = *shorthand.properties()[i];
        if (property.IDEquals(CSSPropertyID::kBackgroundPositionX)) {
          if (!ConsumePosition(stream, context, UnitlessQuirk::kForbid, value, value_y)) {
            continue;
          }
          if (value) {
            bg_position_parsed_in_current_layer = true;
          }
        } else if (property.IDEquals(CSSPropertyID::kBackgroundSize)) {
          if (!ConsumeSlashIncludingWhitespace(stream)) {
            continue;
          }
          value = ConsumeBackgroundSize(stream, context, ParsingStyle::kNotLegacy);
          if (!value || !bg_position_parsed_in_current_layer) {
            return false;
          }
        } else if (property.IDEquals(CSSPropertyID::kBackgroundPositionY)) {
          continue;
        } else {
          value = ConsumeBackgroundComponent(property.PropertyID(), stream, context, local_context.UseAliasParsing());
        }
        if (value) {
          if (property.IDEquals(CSSPropertyID::kBackgroundOrigin)) {
            origin_value = value;
          }
          parsed_longhand[i] = true;
          found_property = true;
          found_any = true;
          longhands[i].push_back(value);
          if (value_y) {
            parsed_longhand[i + 1] = true;
            longhands[i + 1].push_back(value_y);
          }
        }
      }
    } while (found_property && !stream.AtEnd() && stream.Peek().GetType() != kCommaToken);

    if (!found_any) {
      return false;
    }
    if (previous_layer_had_background_color) {
      // Colors are only allowed in the last layer; previous layer had
      // a background color and we now know for sure it was not the last one,
      // so return parse failure.
      return false;
    }

    // TODO(timloh): This will make invalid longhands, see crbug.com/386459
    for (unsigned i = 0; i < longhand_count; ++i) {
      const CSSProperty& property = *shorthand.properties()[i];

      if (property.IDEquals(CSSPropertyID::kBackgroundColor)) {
        if (parsed_longhand[i]) {
          previous_layer_had_background_color = true;
        }
      }
      if (!parsed_longhand[i]) {
        if ((property.IDEquals(CSSPropertyID::kBackgroundClip)) && origin_value) {
          longhands[i].push_back(origin_value);
          continue;
        }

        longhands[i].push_back(CSSInitialValue::Create());
      }
    }
  } while (ConsumeCommaIncludingWhitespace(stream));

  for (unsigned i = 0; i < longhand_count; ++i) {
    const CSSProperty& property = *shorthand.properties()[i];

    std::shared_ptr<const CSSValue> longhand;
    if (property.IDEquals(CSSPropertyID::kBackgroundColor)) {
      // There can only be one background-color (we've verified this earlier,
      // by means of previous_layer_had_background_color), so pick out only
      // the last one (any others will just be “initial” over and over again).
      longhand = longhands[i].back();
    } else {
      // To conserve memory we don't wrap a single value in a list.
      longhand = GetSingleValueOrMakeList(CSSValue::kCommaSeparator, std::move(longhands[i]));
    }

    AddProperty(property.PropertyID(), shorthand.id(), longhand, important,
                implicit ? IsImplicitProperty::kImplicit : IsImplicitProperty::kNotImplicit, properties);
  }
  return true;
}

bool ConsumeShorthandVia2Longhands(const StylePropertyShorthand& shorthand,
                                   bool important,
                                   std::shared_ptr<const CSSParserContext> context,
                                   CSSParserTokenStream& stream,
                                   std::vector<CSSPropertyValue>& properties) {
  const StylePropertyShorthand::Properties& longhands = shorthand.properties();
  DCHECK_EQ(shorthand.length(), 2u);

  std::shared_ptr<const CSSValue> start = ParseLonghand(longhands[0]->PropertyID(), shorthand.id(), context, stream);

  if (!start) {
    return false;
  }

  std::shared_ptr<const CSSValue> end = ParseLonghand(longhands[1]->PropertyID(), shorthand.id(), context, stream);

  if (!end) {
    end = start;
  }
  AddProperty(longhands[0]->PropertyID(), shorthand.id(), start, important, IsImplicitProperty::kNotImplicit,
              properties);
  AddProperty(longhands[1]->PropertyID(), shorthand.id(), end, important, IsImplicitProperty::kNotImplicit, properties);

  return true;
}

bool ConsumeShorthandVia4Longhands(const StylePropertyShorthand& shorthand,
                                   bool important,
                                   std::shared_ptr<const CSSParserContext> context,
                                   CSSParserTokenStream& stream,
                                   std::vector<CSSPropertyValue>& properties) {
  const StylePropertyShorthand::Properties& longhands = shorthand.properties();
  DCHECK_EQ(shorthand.length(), 4u);
  std::shared_ptr<const CSSValue> top = ParseLonghand(longhands[0]->PropertyID(), shorthand.id(), context, stream);

  if (!top) {
    return false;
  }

  std::shared_ptr<const CSSValue> right = ParseLonghand(longhands[1]->PropertyID(), shorthand.id(), context, stream);

  std::shared_ptr<const CSSValue> bottom = nullptr;
  std::shared_ptr<const CSSValue> left = nullptr;
  if (right) {
    bottom = ParseLonghand(longhands[2]->PropertyID(), shorthand.id(), context, stream);
    if (bottom) {
      left = ParseLonghand(longhands[3]->PropertyID(), shorthand.id(), context, stream);
    }
  }

  if (!right) {
    right = top;
  }
  if (!bottom) {
    bottom = top;
  }
  if (!left) {
    left = right;
  }

  AddProperty(longhands[0]->PropertyID(), shorthand.id(), top, important, IsImplicitProperty::kNotImplicit, properties);
  AddProperty(longhands[1]->PropertyID(), shorthand.id(), right, important, IsImplicitProperty::kNotImplicit,
              properties);
  AddProperty(longhands[2]->PropertyID(), shorthand.id(), bottom, important, IsImplicitProperty::kNotImplicit,
              properties);
  AddProperty(longhands[3]->PropertyID(), shorthand.id(), left, important, IsImplicitProperty::kNotImplicit,
              properties);

  return true;
}

bool ConsumeShorthandGreedilyViaLonghands(const StylePropertyShorthand& shorthand,
                                          bool important,
                                          std::shared_ptr<const CSSParserContext> context,
                                          CSSParserTokenStream& stream,
                                          std::vector<CSSPropertyValue>& properties,
                                          bool use_initial_value_function) {
  // Existing shorthands have at most 6 longhands.
  DCHECK_LE(shorthand.length(), 6u);
  std::shared_ptr<const CSSValue> longhands[6] = {nullptr, nullptr, nullptr, nullptr, nullptr, nullptr};
  const StylePropertyShorthand::Properties& shorthand_properties = shorthand.properties();
  bool found_any = false;
  bool found_longhand;
  do {
    found_longhand = false;
    for (size_t i = 0; i < shorthand.length(); ++i) {
      if (longhands[i]) {
        continue;
      }
      longhands[i] = ParseLonghand(shorthand_properties[i]->PropertyID(), shorthand.id(), context, stream);

      if (longhands[i]) {
        found_longhand = true;
        found_any = true;
        break;
      }
    }
  } while (found_longhand && !stream.AtEnd());

  if (!found_any) {
    return false;
  }

  for (size_t i = 0; i < shorthand.length(); ++i) {
    if (longhands[i]) {
      AddProperty(shorthand_properties[i]->PropertyID(), shorthand.id(), longhands[i], important,
                  IsImplicitProperty::kNotImplicit, properties);
    } else {
      std::shared_ptr<const CSSValue> value = use_initial_value_function
                                                  ? To<Longhand>(shorthand_properties[i])->InitialValue()
                                                  : CSSInitialValue::Create();
      AddProperty(shorthand_properties[i]->PropertyID(), shorthand.id(), value, important,
                  IsImplicitProperty::kNotImplicit, properties);
    }
  }
  return true;
}

void AddExpandedPropertyForValue(CSSPropertyID property,
                                 const std::shared_ptr<const CSSValue>& value,
                                 bool important,
                                 std::vector<CSSPropertyValue>& properties) {
  const StylePropertyShorthand& shorthand = shorthandForProperty(property);
  const StylePropertyShorthand::Properties& longhands = shorthand.properties();
  DCHECK(shorthand.length());
  for (int i = 0; i < shorthand.length(); i++) {
    AddProperty(shorthand.properties()[i]->PropertyID(), property, value, important, IsImplicitProperty::kNotImplicit,
                properties);
  }
}

std::shared_ptr<const CSSIdentifierValue> ConsumeBorderImageRepeatKeyword(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kStretch, CSSValueID::kRepeat, CSSValueID::kSpace, CSSValueID::kRound>(stream);
}

bool ConsumeCSSValueId(CSSParserTokenStream& stream, CSSValueID& value) {
  std::shared_ptr<const CSSIdentifierValue> keyword = ConsumeIdent(stream);
  if (!keyword) {
    return false;
  }
  value = keyword->GetValueID();
  return true;
}

std::shared_ptr<const CSSValue> ConsumeBorderImageRepeat(CSSParserTokenStream& stream) {
  std::shared_ptr<const CSSIdentifierValue> horizontal = ConsumeBorderImageRepeatKeyword(stream);
  if (!horizontal) {
    return nullptr;
  }
  std::shared_ptr<const CSSIdentifierValue> vertical = ConsumeBorderImageRepeatKeyword(stream);
  if (!vertical) {
    vertical = horizontal;
  }
  return std::make_shared<CSSValuePair>(horizontal, vertical, CSSValuePair::kDropIdenticalValues);
}

std::shared_ptr<const CSSValue> ConsumeBorderImageSlice(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        DefaultFill default_fill) {
  bool fill = ConsumeIdent<CSSValueID::kFill>(stream) != nullptr;
  std::shared_ptr<const CSSValue> slices[4] = {nullptr};

  for (size_t index = 0; index < 4; ++index) {
    std::shared_ptr<const CSSPrimitiveValue> value =
        ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!value) {
      value = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    }
    if (!value) {
      break;
    }
    slices[index] = value;
  }
  if (!slices[0]) {
    return nullptr;
  }
  if (ConsumeIdent<CSSValueID::kFill>(stream)) {
    if (fill) {
      return nullptr;
    }
    fill = true;
  }
  Complete4Sides(slices);
  if (default_fill == DefaultFill::kFill) {
    fill = true;
  }

  return std::make_shared<cssvalue::CSSBorderImageSliceValue>(
      std::make_shared<CSSQuadValue>(slices[0], slices[1], slices[2], slices[3], CSSQuadValue::kSerializeAsQuad), fill);
}

bool ConsumeBorderImageComponents(CSSParserTokenStream& stream,
                                  std::shared_ptr<const CSSParserContext> context,
                                  std::shared_ptr<const CSSValue>& source,
                                  std::shared_ptr<const CSSValue>& slice,
                                  std::shared_ptr<const CSSValue>& width,
                                  std::shared_ptr<const CSSValue>& outset,
                                  std::shared_ptr<const CSSValue>& repeat,
                                  DefaultFill default_fill) {
  do {
    if (!source) {
      source = ConsumeImageOrNone(stream, context);
      if (source) {
        continue;
      }
    }
    if (!repeat) {
      repeat = ConsumeBorderImageRepeat(stream);
      if (repeat) {
        continue;
      }
    }
    if (!slice) {
      CSSParserSavePoint savepoint(stream);
      slice = ConsumeBorderImageSlice(stream, context, default_fill);
      if (slice) {
        DCHECK(!width);
        DCHECK(!outset);
        if (ConsumeSlashIncludingWhitespace(stream)) {
          width = ConsumeBorderImageWidth(stream, context);
          if (ConsumeSlashIncludingWhitespace(stream)) {
            outset = ConsumeBorderImageOutset(stream, context);
            if (!outset) {
              break;
            }
          } else if (!width) {
            break;
          }
        }
      } else {
        break;
      }
      savepoint.Release();
    } else {
      break;
    }
  } while (!stream.AtEnd());
  if (!source && !repeat && !slice) {
    return false;
  }
  return true;
}

std::shared_ptr<const CSSValue> ConsumeBorderImageWidth(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> widths[4] = {nullptr};

  std::shared_ptr<const CSSValue> value = nullptr;
  for (size_t index = 0; index < 4; ++index) {
    value = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!value) {
      CSSParserContext::ParserModeOverridingScope scope(*context, kHTMLStandardMode);
      value =
          ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, UnitlessQuirk::kForbid);
    }
    if (!value) {
      value = ConsumeIdent<CSSValueID::kAuto>(stream);
    }
    if (!value) {
      break;
    }
    widths[index] = value;
  }
  if (!widths[0]) {
    return nullptr;
  }
  Complete4Sides(widths);
  return std::make_shared<CSSQuadValue>(widths[0], widths[1], widths[2], widths[3], CSSQuadValue::kSerializeAsQuad);
}

std::shared_ptr<const CSSValue> ConsumeBorderImageOutset(CSSParserTokenStream& stream,
                                                         std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> outsets[4] = {nullptr};

  std::shared_ptr<const CSSValue> value = nullptr;
  for (size_t index = 0; index < 4; ++index) {
    value = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!value) {
      CSSParserContext::ParserModeOverridingScope scope(*context, kHTMLStandardMode);
      value = ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    }
    if (!value) {
      break;
    }
    outsets[index] = value;
  }
  if (!outsets[0]) {
    return nullptr;
  }
  Complete4Sides(outsets);
  return std::make_shared<CSSQuadValue>(outsets[0], outsets[1], outsets[2], outsets[3], CSSQuadValue::kSerializeAsQuad);
}

bool ConsumeRadii(std::shared_ptr<const CSSValue> horizontal_radii[4],
                  std::shared_ptr<const CSSValue> vertical_radii[4],
                  CSSParserTokenStream& stream,
                  std::shared_ptr<const CSSParserContext> context,
                  bool use_legacy_parsing) {
  unsigned horizontal_value_count = 0;
  for (; horizontal_value_count < 4 && stream.Peek().GetType() != kDelimiterToken; ++horizontal_value_count) {
    horizontal_radii[horizontal_value_count] =
        ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!horizontal_radii[horizontal_value_count]) {
      break;
    }
  }
  if (!horizontal_radii[0]) {
    return false;
  }
  if (ConsumeSlashIncludingWhitespace(stream)) {
    for (unsigned i = 0; i < 4; ++i) {
      vertical_radii[i] = ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
      if (!vertical_radii[i]) {
        break;
      }
    }
    if (!vertical_radii[0]) {
      return false;
    }
  } else {
    // Legacy syntax: -webkit-border-radius: l1 l2; is equivalent to
    // border-radius: l1 / l2;
    if (use_legacy_parsing && horizontal_value_count == 2) {
      vertical_radii[0] = horizontal_radii[1];
      horizontal_radii[1] = nullptr;
    } else {
      Complete4Sides(horizontal_radii);
      for (unsigned i = 0; i < 4; ++i) {
        vertical_radii[i] = horizontal_radii[i];
      }
      return true;
    }
  }
  Complete4Sides(horizontal_radii);
  Complete4Sides(vertical_radii);
  return true;
}

std::shared_ptr<const CSSValue> ParseBorderRadiusCorner(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value1 =
      ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!parsed_value1) {
    return nullptr;
  }
  std::shared_ptr<const CSSValue> parsed_value2 =
      ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!parsed_value2) {
    parsed_value2 = parsed_value1;
  }
  return std::make_shared<CSSValuePair>(parsed_value1, parsed_value2, CSSValuePair::kDropIdenticalValues);
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeSingleContainerName(T& stream, std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().GetType() != kIdentToken) {
    return nullptr;
  }
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return nullptr;
  }
  if (EqualIgnoringASCIICase(stream.Peek().Value(), "not")) {
    return nullptr;
  }
  if (EqualIgnoringASCIICase(stream.Peek().Value(), "and")) {
    return nullptr;
  }
  if (EqualIgnoringASCIICase(stream.Peek().Value(), "or")) {
    return nullptr;
  }
  return ConsumeCustomIdent(stream, context);
}

std::shared_ptr<const CSSValue> ConsumeContainerName(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context) {
  if (std::shared_ptr<const CSSValue> value = ConsumeIdent<CSSValueID::kNone>(stream)) {
    return value;
  }

  std::shared_ptr<CSSValueList> list = std::const_pointer_cast<CSSValueList>(CSSValueList::CreateSpaceSeparated());

  while (std::shared_ptr<const CSSValue> value = ConsumeSingleContainerName(stream, context)) {
    list->Append(value);
  }

  return list->length() ? list : nullptr;
}

std::shared_ptr<const CSSValue> ConsumeContainerType(CSSParserTokenStream& stream) {
  // container-type: normal | [ [ size | inline-size ] || scroll-state ]
  if (std::shared_ptr<const CSSValue> value = ConsumeIdent<CSSValueID::kNormal>(stream)) {
    return value;
  }

  std::shared_ptr<const CSSValue> size_value = nullptr;
  std::shared_ptr<const CSSValue> scroll_state_value = nullptr;

  do {
    if (!size_value) {
      size_value = ConsumeIdent<CSSValueID::kSize, CSSValueID::kInlineSize>(stream);
      if (size_value) {
        continue;
      }
    }
    if (!scroll_state_value) {
      scroll_state_value = ConsumeIdent<CSSValueID::kScrollState>(stream);
      if (scroll_state_value) {
        continue;
      }
    }
    break;
  } while (!stream.AtEnd());

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (size_value) {
    list->Append(size_value);
  }
  if (scroll_state_value) {
    list->Append(scroll_state_value);
  }
  if (list->length() == 0) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSShadowValue> ParseSingleShadow(CSSParserTokenStream& range,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        AllowInsetAndSpread inset_and_spread) {
  std::shared_ptr<const CSSIdentifierValue> style = nullptr;
  std::shared_ptr<const CSSValue> color = nullptr;

  if (range.AtEnd()) {
    return nullptr;
  }

  color = ConsumeColor(range, context);
  if (range.Peek().Id() == CSSValueID::kInset) {
    if (inset_and_spread != AllowInsetAndSpread::kAllow) {
      return nullptr;
    }
    style = ConsumeIdent(range);
    if (!color) {
      color = ConsumeColor(range, context);
    }
  }

  std::shared_ptr<const CSSPrimitiveValue> horizontal_offset =
      ConsumeLength(range, context, CSSPrimitiveValue::ValueRange::kAll);
  if (!horizontal_offset) {
    return nullptr;
  }

  std::shared_ptr<const CSSPrimitiveValue> vertical_offset =
      ConsumeLength(range, context, CSSPrimitiveValue::ValueRange::kAll);
  if (!vertical_offset) {
    return nullptr;
  }

  std::shared_ptr<const CSSPrimitiveValue> blur_radius =
      ConsumeLength(range, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  std::shared_ptr<const CSSPrimitiveValue> spread_distance = nullptr;
  if (blur_radius) {
    if (inset_and_spread == AllowInsetAndSpread::kAllow) {
      spread_distance = ConsumeLength(range, context, CSSPrimitiveValue::ValueRange::kAll);
    }
  }

  if (!range.AtEnd()) {
    if (!color) {
      color = ConsumeColor(range, context);
    }
    if (range.Peek().Id() == CSSValueID::kInset) {
      if (inset_and_spread != AllowInsetAndSpread::kAllow || style) {
        return nullptr;
      }
      style = ConsumeIdent(range);
      if (!color) {
        color = ConsumeColor(range, context);
      }
    }
  }
  return std::make_shared<CSSShadowValue>(horizontal_offset, vertical_offset, blur_radius, spread_distance, style,
                                          color);
}

std::shared_ptr<const CSSValue> ConsumeGapLength(CSSParserTokenStream& stream,
                                                 std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return ConsumeIdent(stream);
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> ConsumeCounter(CSSParserTokenStream& stream,
                                               std::shared_ptr<const CSSParserContext> context,
                                               int default_value) {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return ConsumeIdent(stream);
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  do {
    std::shared_ptr<const CSSCustomIdentValue> counter_name = ConsumeCustomIdent(stream, context);
    if (!counter_name) {
      break;
    }
    int value = default_value;
    if (std::shared_ptr<const CSSPrimitiveValue> counter_value = ConsumeInteger(stream, context)) {
      value = ClampTo<int>(counter_value->GetDoubleValue());
    }
    list->Append(std::make_shared<CSSValuePair>(
        counter_name, CSSNumericLiteralValue::Create(value, CSSPrimitiveValue::UnitType::kInteger),
        CSSValuePair::kDropIdenticalValues));
  } while (!stream.AtEnd());
  if (list->length() == 0) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSValue> ConsumeShadow(CSSParserTokenStream& stream,
                                              std::shared_ptr<const CSSParserContext> context,
                                              AllowInsetAndSpread inset_and_spread) {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return ConsumeIdent(stream);
  }
  return ConsumeCommaSeparatedList(ParseSingleShadow, stream, context, inset_and_spread);
}

std::shared_ptr<const CSSValue> ConsumeFontSize(CSSParserTokenStream& stream,
                                                std::shared_ptr<const CSSParserContext> context,
                                                UnitlessQuirk unitless) {
  if ((stream.Peek().Id() >= CSSValueID::kXxSmall && stream.Peek().Id() <= CSSValueID::kWebkitXxxLarge) ||
      stream.Peek().Id() == CSSValueID::kMath) {
    return ConsumeIdent(stream);
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, unitless);
}

std::shared_ptr<const CSSValue> ConsumeLineHeight(CSSParserTokenStream& stream,
                                                  std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return ConsumeIdent(stream);
  }

  std::shared_ptr<const CSSPrimitiveValue> line_height =
      ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (line_height) {
    return line_height;
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> ConsumeMathDepth(CSSParserTokenStream& stream,
                                                 std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kAutoAdd) {
    return ConsumeIdent(stream);
  }

  if (std::shared_ptr<const CSSPrimitiveValue> integer_value = ConsumeInteger(stream, context)) {
    return integer_value;
  }

  CSSValueID function_id = stream.Peek().FunctionId();
  if (function_id == CSSValueID::kAdd) {
    std::shared_ptr<const CSSValue> value;
    bool at_end;
    {
      CSSParserTokenStream::BlockGuard guard(stream);
      stream.ConsumeWhitespace();
      value = ConsumeInteger(stream, context);
      at_end = stream.AtEnd();
    }
    stream.ConsumeWhitespace();
    if (value && at_end) {
      auto add_value = std::make_shared<CSSFunctionValue>(function_id);
      add_value->Append(value);
      return add_value;
    }
  }

  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeFontPalette(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNormal || stream.Peek().Id() == CSSValueID::kLight ||
      stream.Peek().Id() == CSSValueID::kDark) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  return ConsumeDashedIdent(stream, context);
}

std::shared_ptr<const CSSValueList> ConsumeFontFamily(CSSParserTokenRange& range) {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateCommaSeparated();
  do {
    std::shared_ptr<const CSSValue> parsed_value = ConsumeGenericFamily(range);
    if (parsed_value) {
      list->Append(parsed_value);
    } else {
      parsed_value = ConsumeFamilyName(range);
      if (parsed_value) {
        list->Append(parsed_value);
      } else {
        return nullptr;
      }
    }
  } while (ConsumeCommaIncludingWhitespace(range));
  return list;
}

std::shared_ptr<const CSSValueList> ConsumeFontFamily(CSSParserTokenStream& stream) {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateCommaSeparated();
  do {
    std::shared_ptr<const CSSValue> parsed_value = ConsumeGenericFamily(stream);
    if (parsed_value) {
      list->Append(parsed_value);
    } else {
      parsed_value = ConsumeFamilyName(stream);
      if (parsed_value) {
        list->Append(parsed_value);
      } else {
        return nullptr;
      }
    }
  } while (ConsumeCommaIncludingWhitespace(stream));
  return list;
}

std::shared_ptr<const CSSValueList> ConsumeNonGenericFamilyNameList(CSSParserTokenRange& range) {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateCommaSeparated();
  do {
    std::shared_ptr<const CSSValue> parsed_value = ConsumeGenericFamily(range);
    // Consume only if all families in the list are regular family names and
    // none of them are generic ones.
    if (parsed_value) {
      return nullptr;
    }
    parsed_value = ConsumeFamilyName(range);
    if (parsed_value) {
      list->Append(parsed_value);
    } else {
      return nullptr;
    }
  } while (ConsumeCommaIncludingWhitespace(range));
  return list;
}

std::shared_ptr<const CSSValue> ConsumeGenericFamily(CSSParserTokenRange& range) {
  return ConsumeIdentRange(range, CSSValueID::kSerif, CSSValueID::kMath);
}

std::shared_ptr<const CSSValue> ConsumeGenericFamily(CSSParserTokenStream& stream) {
  return ConsumeIdentRange(stream, CSSValueID::kSerif, CSSValueID::kMath);
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFamilyName(T& range) {
  if (range.Peek().GetType() == kStringToken) {
    return CSSFontFamilyValue::Create(std::string(range.ConsumeIncludingWhitespace().Value()));
  }
  if (range.Peek().GetType() != kIdentToken) {
    return nullptr;
  }
  std::string family_name = ConcatenateFamilyName(range);
  if (family_name.empty()) {
    return nullptr;
  }
  return CSSFontFamilyValue::Create(family_name);
}

// https://drafts.csswg.org/css-values-4/#css-wide-keywords
bool IsCSSWideKeyword(const std::string_view& keyword) {
  return EqualIgnoringASCIICase(keyword, "initial") || EqualIgnoringASCIICase(keyword, "inherit") ||
         EqualIgnoringASCIICase(keyword, "unset") || EqualIgnoringASCIICase(keyword, "revert") ||
         EqualIgnoringASCIICase(keyword, "revert-layer");
  // This function should match the overload before it.
}

// https://drafts.csswg.org/css-cascade/#default
bool IsRevertKeyword(const std::string_view& keyword) {
  return EqualIgnoringASCIICase(keyword, "revert");
}

// https://drafts.csswg.org/css-values-4/#identifier-value
bool IsDefaultKeyword(const std::string_view& keyword) {
  return EqualIgnoringASCIICase(keyword, "default");
}

// https://drafts.csswg.org/css-syntax/#typedef-hash-token
bool IsHashIdentifier(const CSSParserToken& token) {
  return token.GetType() == kHashToken && token.GetHashTokenType() == kHashTokenId;
}

bool IsDashedIdent(const CSSParserToken& token) {
  if (token.GetType() != kIdentToken) {
    return false;
  }
  DCHECK(!IsCSSWideKeyword(token.Value()));
  return token.Value().size() >= 2 && token.Value().substr(0, 2) == "--";
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::string>::type
ConcatenateFamilyName(T& range) {
  StringBuilder builder;
  bool added_space = false;
  const CSSParserToken first_token = range.Peek();
  while (range.Peek().GetType() == kIdentToken) {
    if (!builder.empty()) {
      builder.Append(' ');
      added_space = true;
    }
    builder.Append(range.ConsumeIncludingWhitespace().Value());
  }
  if (!added_space && (IsCSSWideKeyword(first_token.Value()) || IsDefaultKeyword(first_token.Value()))) {
    return "";
  }
  return builder.ReleaseString();
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeFontStretchKeywordOnly(T& stream, std::shared_ptr<const CSSParserContext> context) {
  const CSSParserToken& token = stream.Peek();
  if (token.Id() == CSSValueID::kNormal ||
      (token.Id() >= CSSValueID::kUltraCondensed && token.Id() <= CSSValueID::kUltraExpanded)) {
    return ConsumeIdent(stream);
  }
  if (token.Id() == CSSValueID::kAuto && context->Mode() == kCSSFontFaceRuleMode) {
    return ConsumeIdent(stream);
  }
  return nullptr;
}

bool IsAngleWithinLimits(const CSSPrimitiveValue* angle) {
  constexpr float kMaxAngle = 90.0f;
  return angle->GetFloatValue() >= -kMaxAngle && angle->GetFloatValue() <= kMaxAngle;
}

std::shared_ptr<const CSSValueList> CombineToRangeList(const std::shared_ptr<const CSSPrimitiveValue>& range_start,
                                                       const std::shared_ptr<const CSSPrimitiveValue>& range_end) {
  DCHECK(range_start);
  DCHECK(range_end);
  // Reversed ranges are valid, let them pass through here and swap them in
  // FontFace to keep serialisation of the value as specified.
  // https://drafts.csswg.org/css-fonts/#font-prop-desc
  std::shared_ptr<CSSValueList> value_list = CSSValueList::CreateSpaceSeparated();
  value_list->Append(range_start);
  value_list->Append(range_end);
  return value_list;
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFontStyle(T& stream, std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNormal || stream.Peek().Id() == CSSValueID::kItalic) {
    return ConsumeIdent(stream);
  }

  if (stream.Peek().Id() == CSSValueID::kAuto && context->Mode() == kCSSFontFaceRuleMode) {
    return ConsumeIdent(stream);
  }

  if (stream.Peek().Id() != CSSValueID::kOblique) {
    return nullptr;
  }

  std::shared_ptr<const CSSIdentifierValue> oblique_identifier = ConsumeIdent<CSSValueID::kOblique>(stream);

  std::shared_ptr<const CSSPrimitiveValue> start_angle = ConsumeAngle(stream, context);
  if (!start_angle) {
    return oblique_identifier;
  }
  if (!IsAngleWithinLimits(start_angle.get())) {
    return nullptr;
  }

  if (context->Mode() != kCSSFontFaceRuleMode || stream.AtEnd()) {
    std::shared_ptr<CSSValueList> value_list = CSSValueList::CreateSpaceSeparated();
    value_list->Append(start_angle);
    return std::make_shared<cssvalue::CSSFontStyleRangeValue>(oblique_identifier, value_list);
  }

  std::shared_ptr<const CSSPrimitiveValue> end_angle = ConsumeAngle(stream, context);
  if (!end_angle || !IsAngleWithinLimits(end_angle.get())) {
    return nullptr;
  }

  std::shared_ptr<const CSSValueList> range_list = CombineToRangeList(start_angle, end_angle);
  if (!range_list) {
    return nullptr;
  }
  return std::make_shared<cssvalue::CSSFontStyleRangeValue>(oblique_identifier, range_list);
}

template std::shared_ptr<const CSSValue> ConsumeFontStyle(CSSParserTokenStream& stream,
                                                          std::shared_ptr<const CSSParserContext> context);
template std::shared_ptr<const CSSValue> ConsumeFontStyle(CSSParserTokenRange& stream,
                                                          std::shared_ptr<const CSSParserContext> context);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFontWeight(T& stream, std::shared_ptr<const CSSParserContext> context) {
  const CSSParserToken& token = stream.Peek();
  if (context->Mode() != kCSSFontFaceRuleMode) {
    if (token.Id() >= CSSValueID::kNormal && token.Id() <= CSSValueID::kLighter) {
      return ConsumeIdent(stream);
    }
  } else {
    if (token.Id() == CSSValueID::kNormal || token.Id() == CSSValueID::kBold || token.Id() == CSSValueID::kAuto) {
      return ConsumeIdent(stream);
    }
  }

  // Avoid consuming the first zero of font: 0/0; e.g. in the Acid3 test.  In
  // font:0/0; the first zero is the font size, the second is the line height.
  // In font: 100 0/0; we should parse the first 100 as font-weight, the 0
  // before the slash as font size. We need to peek and check the token in order
  // to avoid parsing a 0 font size as a font-weight. If we call ConsumeNumber
  // straight away without Peek, then the parsing cursor advances too far and we
  // parsed font-size as font-weight incorrectly.
  if (token.GetType() == kNumberToken && (token.NumericValue() < 1 || token.NumericValue() > 1000)) {
    return nullptr;
  }

  std::shared_ptr<const CSSPrimitiveValue> start_weight =
      ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!start_weight || start_weight->GetFloatValue() < 1 || start_weight->GetFloatValue() > 1000) {
    return nullptr;
  }

  // In a non-font-face context, more than one number is not allowed. Return
  // what we have. If there is trailing garbage, the AtEnd() check in
  // CSSPropertyParser::ParseValueStart will catch that.
  if (context->Mode() != kCSSFontFaceRuleMode || stream.AtEnd()) {
    return start_weight;
  }

  std::shared_ptr<const CSSPrimitiveValue> end_weight =
      ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!end_weight || end_weight->GetFloatValue() < 1 || end_weight->GetFloatValue() > 1000) {
    return nullptr;
  }

  return CombineToRangeList(start_weight, end_weight);
}

template std::shared_ptr<const CSSValue> ConsumeFontWeight(CSSParserTokenStream& stream,
                                                           std::shared_ptr<const CSSParserContext> context);
template std::shared_ptr<const CSSValue> ConsumeFontWeight(CSSParserTokenRange& stream,
                                                           std::shared_ptr<const CSSParserContext> context);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFontFeatureSettings(T& stream, std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return ConsumeIdent(stream);
  }
  std::shared_ptr<CSSValueList> settings = CSSValueList::CreateCommaSeparated();
  do {
    std::shared_ptr<const cssvalue::CSSFontFeatureValue> font_feature_value = ConsumeFontFeatureTag(stream, context);
    if (!font_feature_value) {
      return nullptr;
    }
    settings->Append(font_feature_value);
  } while (ConsumeCommaIncludingWhitespace(stream));
  return settings;
}

template std::shared_ptr<const CSSValue> ConsumeFontFeatureSettings(CSSParserTokenRange& stream,
                                                                    std::shared_ptr<const CSSParserContext> context);
template std::shared_ptr<const CSSValue> ConsumeFontFeatureSettings(CSSParserTokenStream& stream,
                                                                    std::shared_ptr<const CSSParserContext> context);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFontStretch(T& stream, std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSIdentifierValue> parsed_keyword = ConsumeFontStretchKeywordOnly(stream, context);
  if (parsed_keyword) {
    return parsed_keyword;
  }

  std::shared_ptr<const CSSPrimitiveValue> start_percent =
      ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!start_percent) {
    return nullptr;
  }

  // In a non-font-face context, more than one percentage is not allowed.
  if (context->Mode() != kCSSFontFaceRuleMode || stream.AtEnd()) {
    return start_percent;
  }

  std::shared_ptr<const CSSPrimitiveValue> end_percent =
      ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!end_percent) {
    return nullptr;
  }

  return CombineToRangeList(start_percent, end_percent);
}

template std::shared_ptr<const CSSValue> ConsumeFontStretch(CSSParserTokenRange& stream,
                                                            std::shared_ptr<const CSSParserContext> context);
template std::shared_ptr<const CSSValue> ConsumeFontStretch(CSSParserTokenStream& stream,
                                                            std::shared_ptr<const CSSParserContext> context);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const cssvalue::CSSFontFeatureValue>>::type
ConsumeFontFeatureTag(T& stream, std::shared_ptr<const CSSParserContext> context) {
  // Feature tag name consists of 4-letter characters.
  const unsigned kTagNameLength = 4;

  const CSSParserToken& token = stream.Peek();
  // Feature tag name comes first
  if (token.GetType() != kStringToken) {
    return nullptr;
  }
  if (token.Value().length() != kTagNameLength) {
    return nullptr;
  }
  std::string tag = std::string(token.Value());
  stream.ConsumeIncludingWhitespace();
  for (unsigned i = 0; i < kTagNameLength; ++i) {
    // Limits the stream of characters to 0x20-0x7E, following the tag name
    // rules defined in the OpenType specification.
    uint8_t character = tag[i];
    if (character < 0x20 || character > 0x7E) {
      return nullptr;
    }
  }

  int tag_value = 1;
  // Feature tag values could follow: <integer> | on | off
  if (std::shared_ptr<const CSSPrimitiveValue> value = ConsumeInteger(stream, context, 0)) {
    tag_value = ClampTo<int>(value->GetDoubleValue());
  } else if (stream.Peek().Id() == CSSValueID::kOn || stream.Peek().Id() == CSSValueID::kOff) {
    tag_value = stream.ConsumeIncludingWhitespace().Id() == CSSValueID::kOn;
  }
  return std::make_shared<cssvalue::CSSFontFeatureValue>(tag, tag_value);
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeFontVariantCSS21(T& stream) {
  return ConsumeIdent<CSSValueID::kNormal, CSSValueID::kSmallCaps>(stream);
}

template std::shared_ptr<const CSSIdentifierValue> ConsumeFontVariantCSS21(CSSParserTokenRange& stream);
template std::shared_ptr<const CSSIdentifierValue> ConsumeFontVariantCSS21(CSSParserTokenStream& stream);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeFontFormatIdent(T& stream) {
  return ConsumeIdent<CSSValueID::kCollection, CSSValueID::kEmbeddedOpentype, CSSValueID::kOpentype,
                      CSSValueID::kTruetype, CSSValueID::kSvg, CSSValueID::kWoff, CSSValueID::kWoff2>(stream);
}

template std::shared_ptr<const CSSIdentifierValue> ConsumeFontFormatIdent(CSSParserTokenRange& stream);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSCustomIdentValue>>::type
ConsumeCustomIdentForGridLine(T& stream, std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kAuto || stream.Peek().Id() == CSSValueID::kSpan) {
    return nullptr;
  }
  return ConsumeCustomIdent(stream, context);
}

std::shared_ptr<const CSSValue> ConsumeGridLine(CSSParserTokenStream& stream,
                                                std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return ConsumeIdent(stream);
  }

  std::shared_ptr<const CSSIdentifierValue> span_value = nullptr;
  std::shared_ptr<const CSSCustomIdentValue> grid_line_name = nullptr;
  std::shared_ptr<const CSSPrimitiveValue> numeric_value = ConsumeInteger(stream, context);
  if (numeric_value) {
    grid_line_name = ConsumeCustomIdentForGridLine(stream, context);
    span_value = ConsumeIdent<CSSValueID::kSpan>(stream);
  } else {
    span_value = ConsumeIdent<CSSValueID::kSpan>(stream);
    if (span_value) {
      numeric_value = ConsumeInteger(stream, context);
      grid_line_name = ConsumeCustomIdentForGridLine(stream, context);
      if (!numeric_value) {
        numeric_value = ConsumeInteger(stream, context);
      }
    } else {
      grid_line_name = ConsumeCustomIdentForGridLine(stream, context);
      if (grid_line_name) {
        numeric_value = ConsumeInteger(stream, context);
        span_value = ConsumeIdent<CSSValueID::kSpan>(stream);
        if (!span_value && !numeric_value) {
          return grid_line_name;
        }
      } else {
        return nullptr;
      }
    }
  }

  if (span_value && !numeric_value && !grid_line_name) {
    return nullptr;  // "span" keyword alone is invalid.
  }
  if (span_value && numeric_value && numeric_value->GetIntValue() < 0) {
    return nullptr;  // Negative numbers are not allowed for span.
  }
  if (numeric_value && numeric_value->GetIntValue() == 0) {
    return nullptr;  // An <integer> value of zero makes the declaration
                     // invalid.
  }

  if (numeric_value) {
    numeric_value = CSSNumericLiteralValue::Create(
        ClampTo(numeric_value->GetIntValue(), -kGridMaxTracks, kGridMaxTracks), CSSPrimitiveValue::UnitType::kInteger);
  }

  std::shared_ptr<CSSValueList> values = CSSValueList::CreateSpaceSeparated();
  if (span_value) {
    values->Append(span_value);
  }
  // If span is present, omit `1` if there's a trailing identifier.
  if (numeric_value && (!span_value || !grid_line_name || numeric_value->GetIntValue() != 1)) {
    values->Append(numeric_value);
  }
  if (grid_line_name) {
    values->Append(grid_line_name);
  }
  DCHECK(values->length());
  return values;
}

bool ConsumeGridItemPositionShorthand(bool important,
                                      CSSParserTokenStream& stream,
                                      std::shared_ptr<const CSSParserContext> context,
                                      std::shared_ptr<const CSSValue>& start_value,
                                      std::shared_ptr<const CSSValue>& end_value) {
  // Input should be nullptrs.
  DCHECK(!start_value);
  DCHECK(!end_value);

  start_value = ConsumeGridLine(stream, context);
  if (!start_value) {
    return false;
  }

  if (ConsumeSlashIncludingWhitespace(stream)) {
    end_value = ConsumeGridLine(stream, context);
    if (!end_value) {
      return false;
    }
  } else {
    end_value = start_value->IsCustomIdentValue() ? start_value : CSSIdentifierValue::Create(CSSValueID::kAuto);
  }

  return true;
}

// Appends to the passed in CSSBracketedValueList if any, otherwise creates a
// new one. Returns nullptr if an empty list is consumed.
std::shared_ptr<CSSBracketedValueList> ConsumeGridLineNames(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context,
    bool is_subgrid_track_list,
    std::shared_ptr<CSSBracketedValueList> line_names = nullptr) {
  if (stream.Peek().GetType() != kLeftBracketToken) {
    return nullptr;
  }
  {
    CSSParserTokenStream::RestoringBlockGuard savepoint(stream);
    stream.ConsumeWhitespace();

    if (!line_names) {
      line_names = std::make_shared<CSSBracketedValueList>();
    }

    while (std::shared_ptr<const CSSCustomIdentValue> line_name = ConsumeCustomIdentForGridLine(stream, context)) {
      line_names->Append(line_name);
    }

    if (!savepoint.Release()) {
      return nullptr;
    }
  }
  stream.ConsumeWhitespace();

  if (!is_subgrid_track_list && line_names->length() == 0U) {
    return nullptr;
  }

  return line_names;
}

bool AppendLineNames(CSSParserTokenStream& stream,
                     std::shared_ptr<const CSSParserContext> context,
                     bool is_subgrid_track_list,
                     std::shared_ptr<CSSValueList> values) {
  if (std::shared_ptr<const CSSBracketedValueList> line_names =
          ConsumeGridLineNames(stream, context, is_subgrid_track_list)) {
    values->Append(line_names);
    return true;
  }
  return false;
}

std::shared_ptr<const CSSValue> ConsumeGridBreadth(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context) {
  const CSSParserToken& token = stream.Peek();
  if (IdentMatches<CSSValueID::kAuto, CSSValueID::kMinContent, CSSValueID::kMaxContent>(token.Id())) {
    return ConsumeIdent(stream);
  }
  if (token.GetType() == kDimensionToken && token.GetUnitType() == CSSPrimitiveValue::UnitType::kFlex) {
    if (token.NumericValue() < 0) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(stream.ConsumeIncludingWhitespace().NumericValue(),
                                          CSSPrimitiveValue::UnitType::kFlex);
  }
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> ConsumeFitContent(CSSParserTokenStream& stream,
                                                  std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<CSSFunctionValue> result;
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();
    std::shared_ptr<const CSSPrimitiveValue> length =
        ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, UnitlessQuirk::kAllow);
    if (!length || !stream.AtEnd()) {
      return nullptr;
    }
    guard.Release();
    result = std::make_shared<CSSFunctionValue>(CSSValueID::kFitContent);
    result->Append(length);
  }
  stream.ConsumeWhitespace();
  return result;
}

std::shared_ptr<const CSSValue> ConsumeGridTrackSize(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context) {
  const auto& token_id = stream.Peek().FunctionId();

  if (token_id == CSSValueID::kMinmax) {
    std::shared_ptr<CSSFunctionValue> result;
    DCHECK_EQ(stream.Peek().GetType(), kFunctionToken);
    {
      CSSParserTokenStream::RestoringBlockGuard guard(stream);
      stream.ConsumeWhitespace();
      std::shared_ptr<const CSSValue> min_track_breadth = ConsumeGridBreadth(stream, context);
      auto* min_track_breadth_primitive_value = DynamicTo<CSSPrimitiveValue>(min_track_breadth.get());
      if (!min_track_breadth || (min_track_breadth_primitive_value && min_track_breadth_primitive_value->IsFlex()) ||
          !ConsumeCommaIncludingWhitespace(stream)) {
        return nullptr;
      }
      std::shared_ptr<const CSSValue> max_track_breadth = ConsumeGridBreadth(stream, context);
      if (!max_track_breadth || !stream.AtEnd()) {
        return nullptr;
      }
      guard.Release();
      result = std::make_shared<CSSFunctionValue>(CSSValueID::kMinmax);
      result->Append(min_track_breadth);
      result->Append(max_track_breadth);
    }
    stream.ConsumeWhitespace();
    return result;
  }

  return (token_id == CSSValueID::kFitContent) ? ConsumeFitContent(stream, context)
                                               : ConsumeGridBreadth(stream, context);
}

bool IsGridBreadthFixedSized(const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(value)) {
    CSSValueID value_id = identifier_value->GetValueID();
    return value_id != CSSValueID::kAuto && value_id != CSSValueID::kMinContent && value_id != CSSValueID::kMaxContent;
  }

  if (auto* primitive_value = DynamicTo<CSSPrimitiveValue>(value)) {
    return !primitive_value->IsFlex();
  }

  NOTREACHED_IN_MIGRATION();
  return true;
}

bool IsGridTrackFixedSized(const CSSValue& value) {
  if (value.IsPrimitiveValue() || value.IsIdentifierValue()) {
    return IsGridBreadthFixedSized(value);
  }

  auto& function = To<CSSFunctionValue>(value);
  if (function.FunctionType() == CSSValueID::kFitContent) {
    return false;
  }

  std::shared_ptr<const CSSValue>&& min_value = function.Item(0);
  std::shared_ptr<const CSSValue>&& max_value = function.Item(1);
  return IsGridBreadthFixedSized(*min_value) || IsGridBreadthFixedSized(*max_value);
}

bool ConsumeGridTrackRepeatFunction(CSSParserTokenStream& stream,
                                    std::shared_ptr<const CSSParserContext> context,
                                    bool is_subgrid_track_list,
                                    CSSValueList& list,
                                    bool& is_auto_repeat,
                                    bool& all_tracks_are_fixed_sized) {
  DCHECK_EQ(stream.Peek().GetType(), kFunctionToken);
  CSSParserTokenStream::BlockGuard guard(stream);
  stream.ConsumeWhitespace();

  // <name-repeat> syntax for subgrids only supports `auto-fill`.
  if (is_subgrid_track_list && IdentMatches<CSSValueID::kAutoFit>(stream.Peek().Id())) {
    return false;
  }

  is_auto_repeat = IdentMatches<CSSValueID::kAutoFill, CSSValueID::kAutoFit>(stream.Peek().Id());
  std::shared_ptr<CSSValueList> repeated_values;
  // The number of repetitions for <auto-repeat> is not important at parsing
  // level because it will be computed later, let's set it to 1.
  size_t repetitions = 1;

  if (is_auto_repeat) {
    repeated_values = std::make_shared<cssvalue::CSSGridAutoRepeatValue>(stream.ConsumeIncludingWhitespace().Id());
  } else {
    // TODO(rob.buis): a consumeIntegerRaw would be more efficient here.
    std::shared_ptr<const CSSPrimitiveValue> repetition = ConsumePositiveInteger(stream, context);
    if (!repetition) {
      return false;
    }
    repetitions = ClampTo<size_t>(repetition->GetDoubleValue(), 0, kGridMaxTracks);
    repeated_values = CSSValueList::CreateSpaceSeparated();
  }

  if (!ConsumeCommaIncludingWhitespace(stream)) {
    return false;
  }

  size_t number_of_line_name_sets = AppendLineNames(stream, context, is_subgrid_track_list, repeated_values);
  size_t number_of_tracks = 0;
  while (!stream.AtEnd()) {
    if (is_subgrid_track_list) {
      if (!number_of_line_name_sets || !AppendLineNames(stream, context, is_subgrid_track_list, repeated_values)) {
        return false;
      }
      ++number_of_line_name_sets;
    } else {
      std::shared_ptr<const CSSValue> track_size = ConsumeGridTrackSize(stream, context);
      if (!track_size) {
        return false;
      }
      if (all_tracks_are_fixed_sized) {
        all_tracks_are_fixed_sized = IsGridTrackFixedSized(*track_size);
      }
      repeated_values->Append(track_size);
      ++number_of_tracks;
      AppendLineNames(stream, context, is_subgrid_track_list, repeated_values);
    }
  }

  // We should have found at least one <track-size> or else it is not a valid
  // <track-list>. If it's a subgrid <line-name-list>, then we should have found
  // at least one named grid line.
  if ((is_subgrid_track_list && !number_of_line_name_sets) || (!is_subgrid_track_list && !number_of_tracks)) {
    return false;
  }

  if (is_auto_repeat) {
    list.Append(repeated_values);
  } else {
    // We clamp the repetitions to a multiple of the repeat() track list's size,
    // while staying below the max grid size.
    repetitions =
        std::min(repetitions, kGridMaxTracks / (is_subgrid_track_list ? number_of_line_name_sets : number_of_tracks));
    auto integer_repeated_values = std::make_shared<cssvalue::CSSGridIntegerRepeatValue>(repetitions);
    for (size_t i = 0; i < repeated_values->length(); ++i) {
      integer_repeated_values->Append(repeated_values->Item(i));
    }
    list.Append(integer_repeated_values);
  }

  return true;
}

std::shared_ptr<const CSSValue> ConsumeGridTrackList(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     TrackListType track_list_type) {
  bool allow_grid_line_names = track_list_type != TrackListType::kGridAuto;
  if (!allow_grid_line_names && stream.Peek().GetType() == kLeftBracketToken) {
    return nullptr;
  }

  bool is_subgrid_track_list = track_list_type == TrackListType::kGridTemplateSubgrid;

  std::shared_ptr<CSSValueList> values = CSSValueList::CreateSpaceSeparated();
  if (is_subgrid_track_list) {
    if (IdentMatches<CSSValueID::kSubgrid>(stream.Peek().Id())) {
      values->Append(ConsumeIdent(stream));
    } else {
      return nullptr;
    }
  }

  AppendLineNames(stream, context, is_subgrid_track_list, values);

  bool allow_repeat = is_subgrid_track_list || track_list_type == TrackListType::kGridTemplate;
  bool seen_auto_repeat = false;
  bool all_tracks_are_fixed_sized = true;
  auto IsRangeAtEnd = [](CSSParserTokenStream& stream) -> bool {
    return stream.AtEnd() || stream.Peek().GetType() == kDelimiterToken;
  };

  do {
    bool is_auto_repeat;
    if (stream.Peek().FunctionId() == CSSValueID::kRepeat) {
      if (!allow_repeat) {
        return nullptr;
      }
      if (!ConsumeGridTrackRepeatFunction(stream, context, is_subgrid_track_list, *values, is_auto_repeat,
                                          all_tracks_are_fixed_sized)) {
        return nullptr;
      }
      stream.ConsumeWhitespace();
      if (is_auto_repeat && seen_auto_repeat) {
        return nullptr;
      }

      seen_auto_repeat = seen_auto_repeat || is_auto_repeat;
    } else if (std::shared_ptr<const CSSValue> value = ConsumeGridTrackSize(stream, context)) {
      // If we find a <track-size> in a subgrid track list, then it isn't a
      // valid <line-name-list>.
      if (is_subgrid_track_list) {
        return nullptr;
      }
      if (all_tracks_are_fixed_sized) {
        all_tracks_are_fixed_sized = IsGridTrackFixedSized(*value);
      }

      values->Append(value);
    } else if (!is_subgrid_track_list) {
      return nullptr;
    }

    if (seen_auto_repeat && !all_tracks_are_fixed_sized) {
      return nullptr;
    }
    if (!allow_grid_line_names && stream.Peek().GetType() == kLeftBracketToken) {
      return nullptr;
    }

    bool did_append_line_names = AppendLineNames(stream, context, is_subgrid_track_list, values);
    if (is_subgrid_track_list && !did_append_line_names && stream.Peek().FunctionId() != CSSValueID::kRepeat) {
      return IsRangeAtEnd(stream) ? values : nullptr;
    }
  } while (!IsRangeAtEnd(stream));

  return values;
}

std::shared_ptr<const CSSValue> ConsumeGridTemplatesRowsOrColumns(CSSParserTokenStream& stream,
                                                                  std::shared_ptr<const CSSParserContext> context) {
  switch (stream.Peek().Id()) {
    case CSSValueID::kNone:
      return ConsumeIdent(stream);
    case CSSValueID::kSubgrid:
      return ConsumeGridTrackList(stream, context, TrackListType::kGridTemplateSubgrid);
    default:
      return ConsumeGridTrackList(stream, context, TrackListType::kGridTemplate);
  }
}

std::vector<std::string> ParseGridTemplateAreasColumnNames(const std::string& grid_row_names) {
  DCHECK(!grid_row_names.empty());

  StringBuilder area_name;
  std::vector<std::string> column_names;
  for (unsigned i = 0; i < grid_row_names.length(); ++i) {
    if (IsCSSSpace(grid_row_names[i])) {
      if (!area_name.empty()) {
        column_names.push_back(area_name.ReleaseString());
      }
      continue;
    }
    if (grid_row_names[i] == '.') {
      if (area_name == ".") {
        continue;
      }
      if (!area_name.empty()) {
        column_names.push_back(area_name.ReleaseString());
      }
    } else {
      if (!IsNameCodePoint(grid_row_names[i])) {
        return {};
      }
      if (area_name == ".") {
        column_names.push_back(area_name.ReleaseString());
      }
    }
    area_name.Append(grid_row_names[i]);
  }

  if (!area_name.empty()) {
    column_names.push_back(area_name.ReleaseString());
  }

  return column_names;
}

bool ParseGridTemplateAreasRow(const std::string& grid_row_names,
                               NamedGridAreaMap& grid_area_map,
                               const size_t row_count,
                               size_t& column_count) {
  if (grid_row_names.empty()) {
    return false;
  }

  std::vector<std::string> column_names = ParseGridTemplateAreasColumnNames(grid_row_names);
  if (row_count == 0) {
    column_count = column_names.size();
    if (column_count == 0) {
      return false;
    }
  } else if (column_count != column_names.size()) {
    // The declaration is invalid if all the rows don't have the number of
    // columns.
    return false;
  }

  for (size_t current_column = 0; current_column < column_count; ++current_column) {
    const std::string& grid_area_name = column_names[current_column];

    // Unamed areas are always valid (we consider them to be 1x1).
    if (grid_area_name == ".") {
      continue;
    }

    size_t look_ahead_column = current_column + 1;
    while (look_ahead_column < column_count && column_names[look_ahead_column] == grid_area_name) {
      look_ahead_column++;
    }

    NamedGridAreaMap::iterator grid_area_it = grid_area_map.find(grid_area_name);
    if (grid_area_it == grid_area_map.end()) {
      grid_area_map.emplace(grid_area_name,
                            GridArea(GridSpan::TranslatedDefiniteGridSpan(row_count, row_count + 1),
                                     GridSpan::TranslatedDefiniteGridSpan(current_column, look_ahead_column)));
    } else {
      GridArea& grid_area = grid_area_it->second;

      // The following checks test that the grid area is a single filled-in
      // rectangle.
      // 1. The new row is adjacent to the previously parsed row.
      if (row_count != grid_area.rows.EndLine()) {
        return false;
      }

      // 2. The new area starts at the same position as the previously parsed
      // area.
      if (current_column != grid_area.columns.StartLine()) {
        return false;
      }

      // 3. The new area ends at the same position as the previously parsed
      // area.
      if (look_ahead_column != grid_area.columns.EndLine()) {
        return false;
      }

      grid_area.rows = GridSpan::TranslatedDefiniteGridSpan(grid_area.rows.StartLine(), grid_area.rows.EndLine() + 1);
    }
    current_column = look_ahead_column - 1;
  }

  return true;
}

bool ConsumeGridTemplateRowsAndAreasAndColumns(bool important,
                                               CSSParserTokenStream& stream,
                                               std::shared_ptr<const CSSParserContext> context,
                                               std::shared_ptr<const CSSValue>& template_rows,
                                               std::shared_ptr<const CSSValue>& template_columns,
                                               std::shared_ptr<const CSSValue>& template_areas) {
  DCHECK(!template_rows);
  DCHECK(!template_columns);
  DCHECK(!template_areas);

  NamedGridAreaMap grid_area_map;
  size_t row_count = 0;
  size_t column_count = 0;
  std::shared_ptr<CSSValueList> template_rows_value_list = CSSValueList::CreateSpaceSeparated();

  // Persists between loop iterations so we can use the same value for
  // consecutive <line-names> values
  std::shared_ptr<CSSBracketedValueList> line_names = nullptr;

  // See comment in Grid::ParseShorthand() about the use of AtEnd.

  do {
    // Handle leading <custom-ident>*.
    bool has_previous_line_names = line_names != nullptr;
    line_names = ConsumeGridLineNames(stream, context, /* is_subgrid_track_list */ false, line_names);
    if (line_names && !has_previous_line_names) {
      template_rows_value_list->Append(line_names);
    }

    // Handle a template-area's row.
    if (stream.Peek().GetType() != kStringToken ||
        !ParseGridTemplateAreasRow(std::string(stream.ConsumeIncludingWhitespace().Value()), grid_area_map, row_count,
                                   column_count)) {
      return false;
    }
    ++row_count;

    // Handle template-rows's track-size.
    std::shared_ptr<const CSSValue> value = ConsumeGridTrackSize(stream, context);
    if (!value) {
      value = CSSIdentifierValue::Create(CSSValueID::kAuto);
    }
    template_rows_value_list->Append(value);

    // This will handle the trailing/leading <custom-ident>* in the grammar.
    line_names = ConsumeGridLineNames(stream, context,
                                      /* is_subgrid_track_list */ false);
    if (line_names) {
      template_rows_value_list->Append(line_names);
    }
  } while (!stream.AtEnd() && !(stream.Peek().GetType() == kDelimiterToken &&
                                (stream.Peek().Delimiter() == '/' || stream.Peek().Delimiter() == '!')));

  if (!stream.AtEnd() && stream.Peek().Delimiter() != '!') {
    if (!ConsumeSlashIncludingWhitespace(stream)) {
      return false;
    }
    template_columns = ConsumeGridTrackList(stream, context, TrackListType::kGridTemplateNoRepeat);
    if (!template_columns || !(stream.AtEnd() || stream.Peek().Delimiter() == '!')) {
      return false;
    }
  } else {
    template_columns = CSSIdentifierValue::Create(CSSValueID::kNone);
  }

  template_rows = template_rows_value_list;
  template_areas = std::make_shared<cssvalue::CSSGridTemplateAreasValue>(grid_area_map, row_count, column_count);
  return true;
}

bool ConsumeGridTemplateShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  std::shared_ptr<const CSSParserContext> context,
                                  std::shared_ptr<const CSSValue>& template_rows,
                                  std::shared_ptr<const CSSValue>& template_columns,
                                  std::shared_ptr<const CSSValue>& template_areas) {
  DCHECK(!template_rows);
  DCHECK(!template_columns);
  DCHECK(!template_areas);

  DCHECK_EQ(gridTemplateShorthand().length(), 3u);

  {
    // 1- <grid-template-rows> / <grid-template-columns>
    CSSParserSavePoint savepoint(stream);
    template_rows = ConsumeIdent<CSSValueID::kNone>(stream);
    if (!template_rows) {
      template_rows = ConsumeGridTemplatesRowsOrColumns(stream, context);
    }

    if (template_rows && ConsumeSlashIncludingWhitespace(stream)) {
      template_columns = ConsumeGridTemplatesRowsOrColumns(stream, context);
      if (template_columns) {
        template_areas = CSSIdentifierValue::Create(CSSValueID::kNone);
        savepoint.Release();
        return true;
      }
    }

    template_rows = nullptr;
    template_columns = nullptr;
    template_areas = nullptr;
  }

  {
    // 2- [ <line-names>? <string> <track-size>? <line-names>? ]+
    // [ / <track-list> ]?
    CSSParserSavePoint savepoint(stream);
    if (ConsumeGridTemplateRowsAndAreasAndColumns(important, stream, context, template_rows, template_columns,
                                                  template_areas)) {
      savepoint.Release();
      return true;
    }
  }

  // 3- 'none' alone case. This must come after the others, since “none“
  // could also be the start of case 1.
  template_rows = ConsumeIdent<CSSValueID::kNone>(stream);
  if (template_rows) {
    template_rows = CSSIdentifierValue::Create(CSSValueID::kNone);
    template_columns = CSSIdentifierValue::Create(CSSValueID::kNone);
    template_areas = CSSIdentifierValue::Create(CSSValueID::kNone);
    return true;
  }

  return false;
}

bool ConsumeFromPageBreakBetween(CSSParserTokenStream& stream, CSSValueID& value) {
  if (!ConsumeCSSValueId(stream, value)) {
    return false;
  }

  if (value == CSSValueID::kAlways) {
    value = CSSValueID::kPage;
    return true;
  }
  return value == CSSValueID::kAuto || value == CSSValueID::kAvoid || value == CSSValueID::kLeft ||
         value == CSSValueID::kRight;
}

bool ConsumeFromColumnBreakBetween(CSSParserTokenStream& stream, CSSValueID& value) {
  if (!ConsumeCSSValueId(stream, value)) {
    return false;
  }

  if (value == CSSValueID::kAlways) {
    value = CSSValueID::kColumn;
    return true;
  }
  return value == CSSValueID::kAuto || value == CSSValueID::kAvoid;
}

bool ConsumeFromColumnOrPageBreakInside(CSSParserTokenStream& stream, CSSValueID& value) {
  if (!ConsumeCSSValueId(stream, value)) {
    return false;
  }
  return value == CSSValueID::kAuto || value == CSSValueID::kAvoid;
}

bool IsBaselineKeyword(CSSValueID id) {
  return IdentMatches<CSSValueID::kFirst, CSSValueID::kLast, CSSValueID::kBaseline>(id);
}

std::shared_ptr<const CSSValue> ConsumeSingleTimelineAxis(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kBlock, CSSValueID::kInline, CSSValueID::kX, CSSValueID::kY>(stream);
}

std::shared_ptr<const CSSValue> ConsumeSingleTimelineName(CSSParserTokenStream& stream,
                                                          std::shared_ptr<const CSSParserContext> context) {
  if (std::shared_ptr<const CSSValue> value = ConsumeIdent<CSSValueID::kNone>(stream)) {
    return value;
  }
  return ConsumeDashedIdent(stream, context);
}

bool IsValidPropertyList(const CSSValueList& value_list) {
  if (value_list.length() < 2) {
    return true;
  }
  for (auto& value : value_list) {
    auto* identifier_value = DynamicTo<CSSIdentifierValue>(value.get());
    if (identifier_value && identifier_value->GetValueID() == CSSValueID::kNone) {
      return false;
    }
  }
  return true;
}

bool IsValidTransitionBehavior(const CSSValueID& value) {
  switch (value) {
    case CSSValueID::kNormal:
    case CSSValueID::kAllowDiscrete:
      return true;
    default:
      return false;
  }
}

bool IsValidTransitionBehaviorList(const CSSValueList& value_list) {
  for (auto& value : value_list) {
    auto* ident_value = DynamicTo<CSSIdentifierValue>(value.get());
    if (!ident_value) {
      return false;
    }
    if (!IsValidTransitionBehavior(ident_value->GetValueID())) {
      return false;
    }
  }
  return true;
}

// Consume the `autospace` production.
// https://drafts.csswg.org/css-text-4/#typedef-autospace
std::shared_ptr<const CSSValue> ConsumeAutospace(CSSParserTokenStream& stream) {
  // Currently, only `no-autospace` is supported.
  return ConsumeIdent<CSSValueID::kNoAutospace>(stream);
}

// Consume the `spacing-trim` production.
// https://drafts.csswg.org/css-text-4/#typedef-spacing-trim
std::shared_ptr<const CSSValue> ConsumeSpacingTrim(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kTrimStart, CSSValueID::kSpaceAll, CSSValueID::kSpaceFirst>(stream);
}

bool IsAuto(CSSValueID id) {
  return IdentMatches<CSSValueID::kAuto>(id);
}

bool IsNormalOrStretch(CSSValueID id) {
  return IdentMatches<CSSValueID::kNormal, CSSValueID::kStretch>(id);
}

bool IsContentDistributionKeyword(CSSValueID id) {
  return IdentMatches<CSSValueID::kSpaceBetween, CSSValueID::kSpaceAround, CSSValueID::kSpaceEvenly,
                      CSSValueID::kStretch>(id);
}

bool IsOverflowKeyword(CSSValueID id) {
  return IdentMatches<CSSValueID::kUnsafe, CSSValueID::kSafe>(id);
}

std::shared_ptr<const CSSValue> ConsumeBaseline(CSSParserTokenStream& stream) {
  std::shared_ptr<const CSSIdentifierValue> preference = ConsumeIdent<CSSValueID::kFirst, CSSValueID::kLast>(stream);
  std::shared_ptr<const CSSIdentifierValue> baseline = ConsumeIdent<CSSValueID::kBaseline>(stream);
  if (!baseline) {
    return nullptr;
  }
  if (preference && preference->GetValueID() == CSSValueID::kLast) {
    return std::make_shared<CSSValuePair>(preference, baseline, CSSValuePair::kDropIdenticalValues);
  }
  return baseline;
}

std::shared_ptr<const CSSIdentifierValue> ConsumeOverflowPositionKeyword(CSSParserTokenStream& stream) {
  return IsOverflowKeyword(stream.Peek().Id()) ? ConsumeIdent(stream) : nullptr;
}

std::shared_ptr<const CSSValue> ConsumeSelfPositionOverflowPosition(CSSParserTokenStream& stream,
                                                                    IsPositionKeyword is_position_keyword) {
  DCHECK(is_position_keyword);
  CSSValueID id = stream.Peek().Id();
  if (IsAuto(id) || IsNormalOrStretch(id)) {
    return ConsumeIdent(stream);
  }

  if (std::shared_ptr<const CSSValue> baseline = ConsumeBaseline(stream)) {
    return baseline;
  }

  std::shared_ptr<const CSSIdentifierValue> overflow_position = ConsumeOverflowPositionKeyword(stream);
  if (!is_position_keyword(stream.Peek().Id())) {
    return nullptr;
  }
  std::shared_ptr<const CSSIdentifierValue> self_position = ConsumeIdent(stream);
  if (overflow_position) {
    return std::make_shared<CSSValuePair>(overflow_position, self_position, CSSValuePair::kDropIdenticalValues);
  }
  return self_position;
}

std::shared_ptr<const CSSValue> ConsumeFirstBaseline(CSSParserTokenStream& stream) {
  ConsumeIdent<CSSValueID::kFirst>(stream);
  return ConsumeIdent<CSSValueID::kBaseline>(stream);
}

CSSValueID GetBaselineKeyword(const CSSValue& value) {
  auto* value_pair = DynamicTo<CSSValuePair>(value);
  if (!value_pair) {
    DCHECK(To<CSSIdentifierValue>(value).GetValueID() == CSSValueID::kBaseline);
    return CSSValueID::kBaseline;
  }

  DCHECK(To<CSSIdentifierValue>(value_pair->First().get())->GetValueID() == CSSValueID::kLast);
  DCHECK(To<CSSIdentifierValue>(value_pair->Second().get())->GetValueID() == CSSValueID::kBaseline);
  return CSSValueID::kLastBaseline;
}

std::shared_ptr<const CSSValue> ConsumeContentDistributionOverflowPosition(CSSParserTokenStream& stream,
                                                                           IsPositionKeyword is_position_keyword) {
  DCHECK(is_position_keyword);
  CSSValueID id = stream.Peek().Id();
  if (IdentMatches<CSSValueID::kNormal>(id)) {
    return std::make_shared<cssvalue::CSSContentDistributionValue>(
        CSSValueID::kInvalid, stream.ConsumeIncludingWhitespace().Id(), CSSValueID::kInvalid);
  }

  if (std::shared_ptr<const CSSValue> baseline = ConsumeFirstBaseline(stream)) {
    return std::make_shared<cssvalue::CSSContentDistributionValue>(CSSValueID::kInvalid, GetBaselineKeyword(*baseline),
                                                                   CSSValueID::kInvalid);
  }

  if (IsContentDistributionKeyword(id)) {
    return std::make_shared<cssvalue::CSSContentDistributionValue>(stream.ConsumeIncludingWhitespace().Id(),
                                                                   CSSValueID::kInvalid, CSSValueID::kInvalid);
  }

  CSSParserSavePoint savepoint(stream);
  CSSValueID overflow = IsOverflowKeyword(id) ? stream.ConsumeIncludingWhitespace().Id() : CSSValueID::kInvalid;
  if (is_position_keyword(stream.Peek().Id())) {
    savepoint.Release();
    return std::make_shared<cssvalue::CSSContentDistributionValue>(CSSValueID::kInvalid,
                                                                   stream.ConsumeIncludingWhitespace().Id(), overflow);
  }

  return nullptr;
}

bool IsLeftOrRightKeyword(CSSValueID id) {
  return IdentMatches<CSSValueID::kLeft, CSSValueID::kRight>(id);
}

bool IsSelfPositionKeyword(CSSValueID id) {
  return IdentMatches<CSSValueID::kStart, CSSValueID::kEnd, CSSValueID::kCenter, CSSValueID::kSelfStart,
                      CSSValueID::kSelfEnd, CSSValueID::kFlexStart, CSSValueID::kFlexEnd, CSSValueID::kAnchorCenter>(
      id);
}

bool IsSelfPositionOrLeftOrRightKeyword(CSSValueID id) {
  return IsSelfPositionKeyword(id) || IsLeftOrRightKeyword(id);
}

bool IsContentPositionKeyword(CSSValueID id) {
  return IdentMatches<CSSValueID::kStart, CSSValueID::kEnd, CSSValueID::kCenter, CSSValueID::kFlexStart,
                      CSSValueID::kFlexEnd>(id);
}

bool IsContentPositionOrLeftOrRightKeyword(CSSValueID id) {
  return IsContentPositionKeyword(id) || IsLeftOrRightKeyword(id);
}

bool ConsumePerspective(CSSParserTokenStream& stream,
                        std::shared_ptr<const CSSParserContext> context,
                        std::shared_ptr<CSSFunctionValue>& transform_value,
                        bool use_legacy_parsing) {
  std::shared_ptr<const CSSValue> parsed_value =
      ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!parsed_value) {
    parsed_value = ConsumeIdent<CSSValueID::kNone>(stream);
  }
  if (!parsed_value && use_legacy_parsing) {
    double perspective;
    if (!ConsumeNumberRaw(stream, context, perspective) || perspective < 0) {
      return false;
    }
    parsed_value = CSSNumericLiteralValue::Create(perspective, CSSPrimitiveValue::UnitType::kPixels);
  }
  if (!parsed_value) {
    return false;
  }
  transform_value->Append(parsed_value);
  return true;
}

bool ConsumeNumbers(CSSParserTokenStream& stream,
                    std::shared_ptr<const CSSParserContext> context,
                    std::shared_ptr<CSSFunctionValue>& transform_value,
                    unsigned number_of_arguments) {
  do {
    std::shared_ptr<const CSSValue> parsed_value = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    if (!parsed_value) {
      return false;
    }
    transform_value->Append(parsed_value);
    if (--number_of_arguments && !ConsumeCommaIncludingWhitespace(stream)) {
      return false;
    }
  } while (number_of_arguments);
  return true;
}

bool ConsumeNumbersOrPercents(CSSParserTokenStream& stream,
                              std::shared_ptr<const CSSParserContext> context,
                              std::shared_ptr<CSSFunctionValue>& transform_value,
                              unsigned number_of_arguments) {
  do {
    std::shared_ptr<const CSSValue> parsed_value =
        ConsumeNumberOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    if (!parsed_value) {
      return false;
    }
    transform_value->Append(parsed_value);
    if (--number_of_arguments && !ConsumeCommaIncludingWhitespace(stream)) {
      return false;
    }
  } while (number_of_arguments);
  return true;
}

bool ConsumeTranslate3d(CSSParserTokenStream& stream,
                        std::shared_ptr<const CSSParserContext> context,
                        std::shared_ptr<CSSFunctionValue>& transform_value) {
  unsigned number_of_arguments = 2;
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  do {
    parsed_value = ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    if (!parsed_value) {
      return false;
    }
    transform_value->Append(parsed_value);
    if (!ConsumeCommaIncludingWhitespace(stream)) {
      return false;
    }
  } while (--number_of_arguments);
  parsed_value = ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  if (!parsed_value) {
    return false;
  }
  transform_value->Append(parsed_value);
  return true;
}

std::shared_ptr<const CSSValue> ConsumeTransformValue(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      bool use_legacy_parsing) {
  CSSValueID function_id = stream.Peek().FunctionId();
  if (!IsValidCSSValueID(function_id)) {
    return nullptr;
  }
  std::shared_ptr<CSSFunctionValue> transform_value = nullptr;
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();
    if (stream.AtEnd()) {
      return nullptr;
    }
    transform_value = std::make_shared<CSSFunctionValue>(function_id);
    std::shared_ptr<const CSSValue> parsed_value = nullptr;
    switch (function_id) {
      case CSSValueID::kRotate:
      case CSSValueID::kRotateX:
      case CSSValueID::kRotateY:
      case CSSValueID::kRotateZ:
      case CSSValueID::kSkewX:
      case CSSValueID::kSkewY:
      case CSSValueID::kSkew:
        parsed_value = ConsumeAngle(stream, context);
        if (!parsed_value) {
          return nullptr;
        }
        if (function_id == CSSValueID::kSkew && ConsumeCommaIncludingWhitespace(stream)) {
          transform_value->Append(parsed_value);
          parsed_value = ConsumeAngle(stream, context);
          if (!parsed_value) {
            return nullptr;
          }
        }
        break;
      case CSSValueID::kScaleX:
      case CSSValueID::kScaleY:
      case CSSValueID::kScaleZ:
      case CSSValueID::kScale:
        parsed_value = ConsumeNumberOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
        if (!parsed_value) {
          return nullptr;
        }
        if (function_id == CSSValueID::kScale && ConsumeCommaIncludingWhitespace(stream)) {
          transform_value->Append(parsed_value);
          parsed_value = ConsumeNumberOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
          if (!parsed_value) {
            return nullptr;
          }
        }
        break;
      case CSSValueID::kPerspective:
        if (!ConsumePerspective(stream, context, transform_value, use_legacy_parsing)) {
          return nullptr;
        }
        break;
      case CSSValueID::kTranslateX:
      case CSSValueID::kTranslateY:
      case CSSValueID::kTranslate:
        parsed_value = ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
        if (!parsed_value) {
          return nullptr;
        }
        if (function_id == CSSValueID::kTranslate && ConsumeCommaIncludingWhitespace(stream)) {
          transform_value->Append(parsed_value);
          parsed_value = ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
          if (!parsed_value) {
            return nullptr;
          }
        }
        break;
      case CSSValueID::kTranslateZ:
        parsed_value = ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kAll);
        break;
      case CSSValueID::kMatrix:
      case CSSValueID::kMatrix3D:
        if (!ConsumeNumbers(stream, context, transform_value, (function_id == CSSValueID::kMatrix3D) ? 16 : 6)) {
          return nullptr;
        }
        break;
      case CSSValueID::kScale3D:
        if (!ConsumeNumbersOrPercents(stream, context, transform_value, 3)) {
          return nullptr;
        }
        break;
      case CSSValueID::kRotate3D:
        if (!ConsumeNumbers(stream, context, transform_value, 3) || !ConsumeCommaIncludingWhitespace(stream)) {
          return nullptr;
        }
        parsed_value = ConsumeAngle(stream, context);
        if (!parsed_value) {
          return nullptr;
        }
        break;
      case CSSValueID::kTranslate3D:
        if (!ConsumeTranslate3d(stream, context, transform_value)) {
          return nullptr;
        }
        break;
      default:
        return nullptr;
    }
    if (parsed_value) {
      transform_value->Append(parsed_value);
    }
    if (!stream.AtEnd()) {
      return nullptr;
    }
    guard.Release();
  }
  stream.ConsumeWhitespace();
  return transform_value;
}

std::shared_ptr<const CSSValue> ConsumeTransformValue(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context) {
  bool use_legacy_parsing = false;
  return ConsumeTransformValue(stream, context, use_legacy_parsing);
}

std::shared_ptr<const CSSValue> ConsumeTransformList(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     const CSSParserLocalContext& local_context) {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return ConsumeIdent(stream);
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  do {
    std::shared_ptr<const CSSValue> parsed_transform_value =
        ConsumeTransformValue(stream, context, local_context.UseAliasParsing());
    if (!parsed_transform_value) {
      break;
    }
    list->Append(parsed_transform_value);
  } while (!stream.AtEnd());

  if (list->length() == 0) {
    return nullptr;
  }

  return list;
}

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeTimelineRangeNameAndPercent(T& stream, std::shared_ptr<const CSSParserContext> context) {
  auto list = CSSValueList::CreateSpaceSeparated();
  std::shared_ptr<const CSSValue> range_name = ConsumeTimelineRangeName(stream);
  if (!range_name) {
    return nullptr;
  }
  list->Append(range_name);
  std::shared_ptr<const CSSValue> percentage = ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  if (!percentage) {
    return nullptr;
  }
  list->Append(percentage);
  return list;
}

template std::shared_ptr<const CSSValue> ConsumeTimelineRangeNameAndPercent(
    CSSParserTokenRange& stream,
    std::shared_ptr<const CSSParserContext> context);

CSSValueID FontFormatToId(std::string font_format) {
  CSSValueID converted_id = CssValueKeywordID(font_format);
  if (converted_id == CSSValueID::kOpentype || converted_id == CSSValueID::kTruetype ||
      converted_id == CSSValueID::kSvg) {
    return converted_id;
  }
  return CSSValueID::kInvalid;
}

bool IsSupportedKeywordTech(CSSValueID keyword) {
  switch (keyword) {
    case CSSValueID::kFeaturesOpentype:
    case CSSValueID::kFeaturesAat:
    case CSSValueID::kColorSbix:
    case CSSValueID::kVariations:
    case CSSValueID::kPalettes:
      return true;
    case CSSValueID::kFeaturesGraphite:
    case CSSValueID::kColorSvg:
    case CSSValueID::kIncremental:
      return false;
    default:
      return false;
  }
  NOTREACHED_IN_MIGRATION();
  return false;
}

bool IsSupportedKeywordFormat(CSSValueID keyword) {
  switch (keyword) {
    case CSSValueID::kCollection:
    case CSSValueID::kOpentype:
    case CSSValueID::kTruetype:
    case CSSValueID::kWoff:
    case CSSValueID::kWoff2:
      return true;
    case CSSValueID::kEmbeddedOpentype:
    case CSSValueID::kSvg:
      return false;
    default:
      return false;
  }
}

std::shared_ptr<const CSSValue> ConsumeTransformList(CSSParserTokenStream& stream,
                                                     std::shared_ptr<const CSSParserContext> context) {
  return ConsumeTransformList(stream, context, CSSParserLocalContext());
}

template <class T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<cssvalue::CSSURIValue>>::type
ConsumeUrlInternal(T& range, std::shared_ptr<const CSSParserContext> context) {
  CSSParserToken url = ConsumeUrlAsToken(range, context);
  if (url.GetType() == kEOFToken) {
    return nullptr;
  }
  return std::make_shared<cssvalue::CSSURIValue>(CollectUrlData(std::string(url.Value()), context));
}

std::shared_ptr<cssvalue::CSSURIValue> ConsumeUrl(CSSParserTokenStream& stream,
                                                  std::shared_ptr<const CSSParserContext> context) {
  return ConsumeUrlInternal(stream, context);
}

std::shared_ptr<cssvalue::CSSURIValue> ConsumeUrl(CSSParserTokenRange& range,
                                                  std::shared_ptr<const CSSParserContext> context) {
  return ConsumeUrlInternal(range, context);
}

std::shared_ptr<const CSSValue> ConsumeCSSWideKeyword(CSSParserTokenRange& range) {
  if (!IsCSSWideKeyword(range.Peek().Id())) {
    return nullptr;
  }
  switch (range.ConsumeIncludingWhitespace().Id()) {
    case CSSValueID::kInitial:
      return CSSInitialValue::Create();
    case CSSValueID::kInherit:
      return CSSInheritedValue::Create();
    case CSSValueID::kUnset:
      return cssvalue::CSSUnsetValue::Create();
    case CSSValueID::kRevert:
      return cssvalue::CSSRevertValue::Create();
    case CSSValueID::kRevertLayer:
      return cssvalue::CSSRevertLayerValue::Create();
    default:
      NOTREACHED_IN_MIGRATION();
      return nullptr;
  }
}

std::shared_ptr<const CSSValue> ConsumeCSSWideKeyword(CSSParserTokenStream& stream) {
  if (!IsCSSWideKeyword(stream.Peek().Id())) {
    return nullptr;
  }
  switch (stream.ConsumeIncludingWhitespace().Id()) {
    case CSSValueID::kInitial:
      return CSSInitialValue::Create();
    case CSSValueID::kInherit:
      return CSSInheritedValue::Create();
    case CSSValueID::kUnset:
      return cssvalue::CSSUnsetValue::Create();
    case CSSValueID::kRevert:
      return cssvalue::CSSRevertValue::Create();
    case CSSValueID::kRevertLayer:
      return cssvalue::CSSRevertLayerValue::Create();
    default:
      NOTREACHED_IN_MIGRATION();
      return nullptr;
  }
}

std::shared_ptr<CSSFunctionValue> ConsumeFilterFunction(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context) {
  CSSValueID filter_type = stream.Peek().FunctionId();
  if (filter_type < CSSValueID::kInvert || filter_type > CSSValueID::kDropShadow) {
    return nullptr;
  }

  std::shared_ptr<CSSFunctionValue> filter_value;
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  bool no_arguments = false;
  {
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();
    filter_value = std::make_shared<CSSFunctionValue>(filter_type);

    if (filter_type == CSSValueID::kDropShadow) {
      parsed_value = ParseSingleShadow(stream, context, AllowInsetAndSpread::kForbid);
    } else {
      if (stream.AtEnd()) {
        no_arguments = true;
      } else if (filter_type == CSSValueID::kBrightness) {
        // FIXME (crbug.com/397061): Support calc expressions like
        // calc(10% + 0.5)
        parsed_value = ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
        if (!parsed_value) {
          parsed_value = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
        }
      } else if (filter_type == CSSValueID::kHueRotate) {
        parsed_value = ConsumeAngle(stream, context);
      } else if (filter_type == CSSValueID::kBlur) {
        CSSParserContext::ParserModeOverridingScope scope(*context, kHTMLStandardMode);
        parsed_value = ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
      } else {
        // FIXME (crbug.com/397061): Support calc expressions like
        // calc(10% + 0.5)
        parsed_value = ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
        if (!parsed_value) {
          parsed_value = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
        }
        if (parsed_value && filter_type != CSSValueID::kSaturate && filter_type != CSSValueID::kContrast) {
          bool is_percentage = To<CSSPrimitiveValue>(parsed_value.get())->IsPercentage();
          double max_allowed = is_percentage ? 100.0 : 1.0;
          if (To<CSSPrimitiveValue>(parsed_value.get())->GetDoubleValue() > max_allowed) {
            parsed_value =
                CSSNumericLiteralValue::Create(max_allowed, is_percentage ? CSSPrimitiveValue::UnitType::kPercentage
                                                                          : CSSPrimitiveValue::UnitType::kNumber);
          }
        }
      }
    }
    if (!no_arguments && (!parsed_value || !stream.AtEnd())) {
      return nullptr;
    }
  }
  stream.ConsumeWhitespace();
  if (parsed_value) {
    filter_value->Append(parsed_value);
  }
  return filter_value;
}

std::shared_ptr<const CSSValue> ConsumeFilterFunctionList(CSSParserTokenStream& stream,
                                                          std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return ConsumeIdent(stream);
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  do {
    CSSParserSavePoint savepoint(stream);
    std::shared_ptr<const CSSValue> filter_value = ConsumeUrl(stream, context);
    if (!filter_value) {
      filter_value = ConsumeFilterFunction(stream, context);
      if (!filter_value) {
        break;
      }
    }
    savepoint.Release();
    list->Append(filter_value);
  } while (!stream.AtEnd());
  if (list->length() == 0) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSValue> ConsumeBackgroundBlendMode(CSSParserTokenStream& stream) {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kNormal || id == CSSValueID::kOverlay ||
      (id >= CSSValueID::kMultiply && id <= CSSValueID::kLuminosity)) {
    return ConsumeIdent(stream);
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> ParseBackgroundBox(CSSParserTokenStream& stream,
                                                   const CSSParserLocalContext& local_context,
                                                   AllowTextValue alias_allow_text_value) {
  // This is legacy behavior that does not match spec, see crbug.com/604023
  if (local_context.UseAliasParsing()) {
    return ConsumeCommaSeparatedList(ConsumePrefixedBackgroundBox, stream, alias_allow_text_value);
  }
  return ConsumeCommaSeparatedList(ConsumeBackgroundBox, stream);
}

std::shared_ptr<const CSSValue> ParseBackgroundSize(CSSParserTokenStream& stream,
                                                    std::shared_ptr<const CSSParserContext> context,
                                                    const CSSParserLocalContext& local_context) {
  return ConsumeCommaSeparatedList(
      static_cast<std::shared_ptr<const CSSValue> (*)(
          CSSParserTokenStream&, std::shared_ptr<const CSSParserContext> context, ParsingStyle)>(ConsumeBackgroundSize),
      stream, context, local_context.UseAliasParsing() ? ParsingStyle::kLegacy : ParsingStyle::kNotLegacy);
}

std::shared_ptr<const CSSValueList> ParseRepeatStyle(CSSParserTokenStream& stream) {
  return ConsumeCommaSeparatedList(ConsumeRepeatStyleValue, stream);
}

std::shared_ptr<const CSSValue> ParseSpacing(CSSParserTokenStream& stream,
                                             std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return ConsumeIdent(stream);
  }
  // TODO(timloh): allow <percentage>s in word-spacing.
  return ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kAll, UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> ParseMaskSize(CSSParserTokenStream& stream,
                                              std::shared_ptr<const CSSParserContext> context,
                                              const CSSParserLocalContext& local_context) {
  return ConsumeCommaSeparatedList(
      static_cast<std::shared_ptr<const CSSValue> (*)(
          CSSParserTokenStream&, std::shared_ptr<const CSSParserContext> context, ParsingStyle)>(ConsumeBackgroundSize),
      stream, context, ParsingStyle::kNotLegacy);
}

std::shared_ptr<const CSSValue> ConsumeWebkitBorderImage(CSSParserTokenStream& stream,
                                                         std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> source = nullptr;
  std::shared_ptr<const CSSValue> slice = nullptr;
  std::shared_ptr<const CSSValue> width = nullptr;
  std::shared_ptr<const CSSValue> outset = nullptr;
  std::shared_ptr<const CSSValue> repeat = nullptr;
  if (ConsumeBorderImageComponents(stream, context, source, slice, width, outset, repeat, DefaultFill::kFill)) {
    return CreateBorderImageValue(source, slice, width, outset, repeat);
  }
  return nullptr;
}

UnitlessQuirk UnitlessUnlessShorthand(const CSSParserLocalContext& local_context) {
  return local_context.CurrentShorthand() == CSSPropertyID::kInvalid ? UnitlessQuirk::kAllow : UnitlessQuirk::kForbid;
}

// https://drafts.csswg.org/css-shapes-1/#typedef-shape-box
std::shared_ptr<const CSSIdentifierValue> ConsumeShapeBox(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kContentBox, CSSValueID::kPaddingBox, CSSValueID::kBorderBox, CSSValueID::kMarginBox>(
      stream);
}

// https://drafts.csswg.org/css-box-4/#typedef-visual-box
std::shared_ptr<const CSSIdentifierValue> ConsumeVisualBox(CSSParserTokenStream& range) {
  return ConsumeIdent<CSSValueID::kContentBox, CSSValueID::kPaddingBox, CSSValueID::kBorderBox>(range);
}

// https://drafts.fxtf.org/css-masking/#typedef-geometry-box
std::shared_ptr<const CSSIdentifierValue> ConsumeGeometryBox(CSSParserTokenStream& stream) {
  return ConsumeIdent<CSSValueID::kBorderBox, CSSValueID::kPaddingBox, CSSValueID::kContentBox, CSSValueID::kMarginBox,
                      CSSValueID::kFillBox, CSSValueID::kStrokeBox, CSSValueID::kViewBox>(stream);
}

std::shared_ptr<const cssvalue::CSSBasicShapeEllipseValue> ConsumeBasicShapeEllipse(
    CSSParserTokenStream& args,
    std::shared_ptr<const CSSParserContext> context) {
  // spec: https://drafts.csswg.org/css-shapes/#supported-basic-shapes
  // ellipse( [<shape-radius>{2}]? [at <position>]? )
  auto shape = std::make_shared<cssvalue::CSSBasicShapeEllipseValue>();
  if (std::shared_ptr<const CSSValue> radius_x = ConsumeShapeRadius(args, context)) {
    std::shared_ptr<const CSSValue> radius_y = ConsumeShapeRadius(args, context);
    if (!radius_y) {
      return nullptr;
    }
    shape->SetRadiusX(radius_x);
    shape->SetRadiusY(radius_y);
  }
  if (ConsumeIdent<CSSValueID::kAt>(args)) {
    std::shared_ptr<const CSSValue> center_x = nullptr;
    std::shared_ptr<const CSSValue> center_y = nullptr;
    if (!ConsumePosition(args, context, UnitlessQuirk::kForbid, center_x, center_y)) {
      return nullptr;
    }
    shape->SetCenterX(center_x);
    shape->SetCenterY(center_y);
  }
  return shape;
}

std::shared_ptr<const CSSValue> ConsumeBasicShape(CSSParserTokenStream& stream,
                                                  std::shared_ptr<const CSSParserContext> context,
                                                  AllowPathValue allow_path,
                                                  AllowBasicShapeRectValue allow_rect,
                                                  AllowBasicShapeXYWHValue allow_xywh) {
  std::shared_ptr<const CSSValue> shape = nullptr;
  if (stream.Peek().GetType() != kFunctionToken) {
    return nullptr;
  }
  CSSValueID id = stream.Peek().FunctionId();
  {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();
    if (id == CSSValueID::kCircle) {
      shape = ConsumeBasicShapeCircle(stream, context);
    } else if (id == CSSValueID::kEllipse) {
      shape = ConsumeBasicShapeEllipse(stream, context);
    }
    //    else if (id == CSSValueID::kPolygon) {
    //      shape = ConsumeBasicShapePolygon(stream, context);
    //    } else if (id == CSSValueID::kInset) {
    //      shape = ConsumeBasicShapeInset(stream, context);
    //    } else if (id == CSSValueID::kPath && allow_path == AllowPathValue::kAllow) {
    //      shape = ConsumeBasicShapePath(stream);
    //    } else if (id == CSSValueID::kRect && allow_rect == AllowBasicShapeRectValue::kAllow) {
    //      shape = ConsumeBasicShapeRect(stream, context);
    //    } else if (id == CSSValueID::kXywh && allow_xywh == AllowBasicShapeXYWHValue::kAllow) {
    //      shape = ConsumeBasicShapeXYWH(stream, context);
    //    }
    if (!shape || !stream.AtEnd()) {
      return nullptr;
    }

    guard.Release();
  }
  stream.ConsumeWhitespace();
  return shape;
}

std::shared_ptr<const CSSValue> ConsumeIntrinsicSizeLonghand(CSSParserTokenStream& stream,
                                                             std::shared_ptr<const CSSParserContext> context) {
  if (css_parsing_utils::IdentMatches<CSSValueID::kNone>(stream.Peek().Id())) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (css_parsing_utils::IdentMatches<CSSValueID::kAuto>(stream.Peek().Id())) {
    list->Append(css_parsing_utils::ConsumeIdent(stream));
  }
  if (css_parsing_utils::IdentMatches<CSSValueID::kNone>(stream.Peek().Id())) {
    list->Append(css_parsing_utils::ConsumeIdent(stream));
  } else {
    std::shared_ptr<const CSSValue> length =
        css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!length) {
      return nullptr;
    }
    list->Append(length);
  }
  return list;
}

std::shared_ptr<const CSSValue> ConsumeFontSizeAdjust(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context) {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<const CSSIdentifierValue> font_metric =
      ConsumeIdent<CSSValueID::kExHeight, CSSValueID::kCapHeight, CSSValueID::kChWidth, CSSValueID::kIcWidth,
                   CSSValueID::kIcHeight>(stream);

  std::shared_ptr<const CSSValue> value =
      css_parsing_utils::ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (!value) {
    value = ConsumeIdent<CSSValueID::kFromFont>(stream);
  }

  if (!value || !font_metric || font_metric->GetValueID() == CSSValueID::kExHeight) {
    return value;
  }

  return std::make_shared<CSSValuePair>(font_metric, value, CSSValuePair::kKeepIdenticalValues);
}

std::shared_ptr<const CSSValue> ConsumeAxis(CSSParserTokenStream& stream,
                                            std::shared_ptr<const CSSParserContext> context) {
  CSSValueID axis_id = stream.Peek().Id();
  if (axis_id == CSSValueID::kX || axis_id == CSSValueID::kY || axis_id == CSSValueID::kZ) {
    ConsumeIdent(stream);
    return std::make_shared<cssvalue::CSSAxisValue>(axis_id);
  }

  std::shared_ptr<const CSSValue> x_dimension = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  std::shared_ptr<const CSSValue> y_dimension = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  std::shared_ptr<const CSSValue> z_dimension = ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  if (!x_dimension || !y_dimension || !z_dimension) {
    return nullptr;
  }
  return std::make_shared<cssvalue::CSSAxisValue>(std::static_pointer_cast<const CSSPrimitiveValue>(x_dimension),
                                                  std::static_pointer_cast<const CSSPrimitiveValue>(y_dimension),
                                                  std::static_pointer_cast<const CSSPrimitiveValue>(z_dimension));
}

// none | [ underline || overline || line-through || blink ] | spelling-error |
// grammar-error
std::shared_ptr<const CSSValue> ConsumeTextDecorationLine(CSSParserTokenStream& stream) {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kNone) {
    return ConsumeIdent(stream);
  }

  if (id == CSSValueID::kSpellingError || id == CSSValueID::kGrammarError) {
    // Note that StyleBuilderConverter::ConvertFlags() requires that values
    // other than 'none' appear in a CSSValueList.
    std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
    list->Append(ConsumeIdent(stream));
    return list;
  }

  std::shared_ptr<const CSSIdentifierValue> underline = nullptr;
  std::shared_ptr<const CSSIdentifierValue> overline = nullptr;
  std::shared_ptr<const CSSIdentifierValue> line_through = nullptr;
  std::shared_ptr<const CSSIdentifierValue> blink = nullptr;

  while (true) {
    id = stream.Peek().Id();
    if (id == CSSValueID::kUnderline && !underline) {
      underline = ConsumeIdent(stream);
    } else if (id == CSSValueID::kOverline && !overline) {
      overline = ConsumeIdent(stream);
    } else if (id == CSSValueID::kLineThrough && !line_through) {
      line_through = ConsumeIdent(stream);
    } else if (id == CSSValueID::kBlink && !blink) {
      blink = ConsumeIdent(stream);
    } else {
      break;
    }
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (underline) {
    list->Append(underline);
  }
  if (overline) {
    list->Append(overline);
  }
  if (line_through) {
    list->Append(line_through);
  }
  if (blink) {
    list->Append(blink);
  }

  if (!list->length()) {
    return nullptr;
  }
  return list;
}

// Consume the `text-box-edge` production.
std::shared_ptr<const CSSValue> ConsumeTextBoxEdge(CSSParserTokenStream& stream) {
  if (auto auto_value = ConsumeIdent<CSSValueID::kAuto>(stream)) {
    return auto_value;
  }

  auto over_type = ConsumeIdent<CSSValueID::kText, CSSValueID::kCap, CSSValueID::kEx>(stream);
  if (!over_type) {
    return nullptr;
  }
  // The second parameter is optional, the first parameter will be used for
  // both if the second parameter is not provided.
  if (auto under_type = ConsumeIdent<CSSValueID::kText, CSSValueID::kAlphabetic>(stream)) {
    // Align with the CSS specification: "If only one value is specified,
    // both edges are assigned that same keyword if possible; else 'text' is
    // assumed as the missing value.".
    // If the `over_type` is 'cap' or 'ex', since it does not have a
    // corresponding line-under baseline, `text` will be used to fill the
    // missing value. If the `over_type` is `text`, the default `under_type` is
    // `text` to prioritize the same keyword.
    // In all cases above, the `under_type` of `text` can be omitted for
    // serialization.
    if (under_type->GetValueID() == CSSValueID::kText) {
      if (over_type->GetValueID() == CSSValueID::kText || over_type->GetValueID() == CSSValueID::kCap ||
          over_type->GetValueID() == CSSValueID::kEx) {
        return over_type;
      }
    }
    auto list = CSSValueList::CreateSpaceSeparated();
    list->Append(over_type);
    list->Append(under_type);
    return list;
  }
  return over_type;
}

bool MaybeConsumeImportant(CSSParserTokenStream& stream, bool allow_important_annotation) {
  stream.ConsumeWhitespace();
  if (stream.AtEnd() || !allow_important_annotation) {
    return false;
  }

  CSSParserSavePoint savepoint(stream);

  // !
  if (stream.Peek().GetType() != kDelimiterToken || stream.Peek().Delimiter() != '!') {
    return false;
  }
  stream.ConsumeIncludingWhitespace();

  // important
  if (stream.Peek().GetType() != kIdentToken || !EqualIgnoringASCIICase(stream.Peek().Value(), "important")) {
    return false;
  }
  stream.ConsumeIncludingWhitespace();

  savepoint.Release();
  return true;
}

}  // namespace css_parsing_utils

}  // namespace webf