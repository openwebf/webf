// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/properties/css_parsing_utils.h"
#include "core/css/css_appearance_auto_base_select_value_pair.h"
#include "core/css/css_color_channel_map.h"
#include "core/css/css_color_mix_value.h"
#include "core/css/css_initial_value.h"
#include "core/css/css_light_dart_value_pair.h"
#include "core/css/css_math_expression_node.h"
#include "core/css/css_math_function_value.h"
#include "core/css/css_radio_value.h"
#include "core/css/parser/css_parser_fast_path.h"
#include "core/css/parser/css_parser_save_point.h"
#include "core/css/properties/css_color_function_parser.h"
#include "core/css/properties/longhand.h"
#include "core/css/style_color.h"
#include "core/platform/graphics/color.h"

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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> class MathFunctionParser {
  WEBF_STACK_ALLOCATED();

 public:
  using Flag = CSSMathExpressionNode::Flag;
  using Flags = CSSMathExpressionNode::Flags;

  MathFunctionParser(T& stream,
                     const CSSParserContext& context,
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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue> ConsumeIntegerInternal(
        T& range,
        const CSSParserContext& context,
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

  using enum CSSMathExpressionNode::Flag;
  using Flags = CSSMathExpressionNode::Flags;

  Flags parsing_flags;
  if (is_percentage_allowed) {
    parsing_flags.Put(AllowPercent);
  }

  MathFunctionParser<T> math_parser(range, context, value_range, parsing_flags);
  if (const std::shared_ptr<const CSSMathFunctionValue>* math_value = math_parser.Value()) {
    if (math_value->get()->Category() != kCalcNumber) {
      return nullptr;
    }
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeInteger(CSSParserTokenRange& range,
                                                        const CSSParserContext& context,
                                                        double minimum_value,
                                                        const bool is_percentage_allowed) {
  return ConsumeIntegerInternal(range, context, minimum_value, is_percentage_allowed);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeInteger(CSSParserTokenStream& stream,
                                                        const CSSParserContext& context,
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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue>
    ConsumeIntegerOrNumberCalc(T& range, const CSSParserContext& context, CSSPrimitiveValue::ValueRange value_range) {
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
  if (auto* calculation = math_parser.Value()) {
    if (calculation->get()->Category() != kCalcNumber) {
      return nullptr;
    }
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

template std::shared_ptr<const CSSPrimitiveValue> ConsumeIntegerOrNumberCalc(CSSParserTokenStream& stream,
                                                                             const CSSParserContext& context,
                                                                             CSSPrimitiveValue::ValueRange value_range);
template std::shared_ptr<const CSSPrimitiveValue> ConsumeIntegerOrNumberCalc(CSSParserTokenRange& range,
                                                                             const CSSParserContext& context,
                                                                             CSSPrimitiveValue::ValueRange value_range);

std::shared_ptr<const CSSPrimitiveValue> ConsumePositiveInteger(CSSParserTokenRange& range,
                                                                const CSSParserContext& context) {
  return ConsumeInteger(range, context, 1);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumePositiveInteger(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context) {
  return ConsumeInteger(stream, context, 1);
}

bool ConsumeNumberRaw(CSSParserTokenRange& range, const CSSParserContext& context, double& result) {
  if (range.Peek().GetType() == kNumberToken) {
    result = range.ConsumeIncludingWhitespace().NumericValue();
    return true;
  }
  MathFunctionParser math_parser(range, context, CSSPrimitiveValue::ValueRange::kAll);
  return math_parser.ConsumeNumberRaw(result);
}

bool ConsumeNumberRaw(CSSParserTokenStream& stream, const CSSParserContext& context, double& result) {
  if (stream.Peek().GetType() == kNumberToken) {
    result = stream.ConsumeIncludingWhitespace().NumericValue();
    return true;
  }
  MathFunctionParser math_parser(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  return math_parser.ConsumeNumberRaw(result);
}

// TODO(timloh): Work out if this can just call consumeNumberRaw
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumber(CSSParserTokenRange& range,
                                                       const CSSParserContext& context,
                                                       CSSPrimitiveValue::ValueRange value_range) {
  const CSSParserToken& token = range.Peek();
  if (token.GetType() == kNumberToken) {
    if (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(), token.GetUnitType());
  }
  MathFunctionParser math_parser(range, context, value_range);
  if (auto* calculation = math_parser.Value()) {
    if (calculation->get()->Category() != kCalcNumber) {
      return nullptr;
    }
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeNumber(CSSParserTokenStream& stream,
                                                       const CSSParserContext& context,
                                                       CSSPrimitiveValue::ValueRange value_range) {
  const CSSParserToken token = stream.Peek();
  if (token.GetType() == kNumberToken) {
    if (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(stream.ConsumeIncludingWhitespace().NumericValue(), token.GetUnitType());
  }
  MathFunctionParser math_parser(stream, context, value_range);
  if (auto* calculation = math_parser.Value()) {
    if (calculation->get()->Category() != kCalcNumber) {
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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthInternal(
        T& range,
        const CSSParserContext& context,
        CSSPrimitiveValue::ValueRange value_range,
        UnitlessQuirk unitless) {
  const CSSParserToken token = range.Peek();
  if (token.GetType() == kDimensionToken) {
    switch (token.GetUnitType()) {
      case CSSPrimitiveValue::UnitType::kQuirkyEms:
        if (context.Mode() != kUASheetMode) {
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
    if (!ShouldAcceptUnitlessLength(token.NumericValue(), context.Mode(), unitless) ||
        (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0)) {
      return nullptr;
    }
    CSSPrimitiveValue::UnitType unit_type = CSSPrimitiveValue::UnitType::kPixels;
    if (context.Mode() == kSVGAttributeMode) {
      unit_type = CSSPrimitiveValue::UnitType::kUserUnits;
    }
    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(), unit_type);
  }
  if (context.Mode() == kSVGAttributeMode) {
    return nullptr;
  }
  MathFunctionParser math_parser(range, context, value_range);
  if (math_parser.Value() && math_parser.Value()->get()->Category() == kCalcLength) {
    return math_parser.ConsumeValue();
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLength(CSSParserTokenRange& range,
                                                       const CSSParserContext& context,
                                                       CSSPrimitiveValue::ValueRange value_range,
                                                       UnitlessQuirk unitless) {
  return ConsumeLengthInternal(range, context, value_range, unitless);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLength(CSSParserTokenStream& stream,
                                                       const CSSParserContext& context,
                                                       CSSPrimitiveValue::ValueRange value_range,
                                                       UnitlessQuirk unitless) {
  return ConsumeLengthInternal(stream, context, value_range, unitless);
}

template <class T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue>
    ConsumePercentInternal(T& range, const CSSParserContext& context, CSSPrimitiveValue::ValueRange value_range) {
  const CSSParserToken token = range.Peek();
  if (token.GetType() == kPercentageToken) {
    if (value_range == CSSPrimitiveValue::ValueRange::kNonNegative && token.NumericValue() < 0) {
      return nullptr;
    }
    return CSSNumericLiteralValue::Create(range.ConsumeIncludingWhitespace().NumericValue(),
                                          CSSPrimitiveValue::UnitType::kPercentage);
  }
  MathFunctionParser math_parser(range, context, value_range);
  if (auto* calculation = math_parser.Value()) {
    if (calculation->get()->Category() == kCalcPercent) {
      return math_parser.ConsumeValue();
    }
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumePercent(CSSParserTokenRange& range,
                                                        const CSSParserContext& context,
                                                        CSSPrimitiveValue::ValueRange value_range) {
  return ConsumePercentInternal(range, context, value_range);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumePercent(CSSParserTokenStream& stream,
                                                        const CSSParserContext& context,
                                                        CSSPrimitiveValue::ValueRange value_range) {
  return ConsumePercentInternal(stream, context, value_range);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeNumberOrPercent(CSSParserTokenRange& range,
                                                                const CSSParserContext& context,
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
                                                                const CSSParserContext& context,
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
                                                           const CSSParserContext& context) {
  return ConsumeNumberOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

bool CanConsumeCalcValue(CalculationResultCategory category, CSSParserMode css_parser_mode) {
  return category == kCalcLength || category == kCalcPercent || category == kCalcLengthFunction ||
         category == kCalcIntrinsicSize || (css_parser_mode == kSVGAttributeMode && category == kCalcNumber);
}

template <class T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercentInternal(
        T& range,
        const CSSParserContext& context,
        CSSPrimitiveValue::ValueRange value_range,
        UnitlessQuirk unitless,
        CSSAnchorQueryTypes allowed_anchor_queries,
        AllowCalcSize allow_calc_size) {
  using enum CSSMathExpressionNode::Flag;
  using Flags = CSSMathExpressionNode::Flags;

  const CSSParserToken& token = range.Peek();
  if (token.GetType() == kDimensionToken || token.GetType() == kNumberToken) {
    return ConsumeLength(range, context, value_range, unitless);
  }
  if (token.GetType() == kPercentageToken) {
    return ConsumePercent(range, context, value_range);
  }
  Flags parsing_flags({AllowPercent});
  switch (allow_calc_size) {
    case AllowCalcSize::kAllowWithAutoAndContent:
      parsing_flags.Put(AllowContentInCalcSize);
      [[fallthrough]];
    case AllowCalcSize::kAllowWithAuto:
      parsing_flags.Put(AllowAutoInCalcSize);
      [[fallthrough]];
    case AllowCalcSize::kAllowWithoutAuto:
      parsing_flags.Put(AllowCalcSize);
      [[fallthrough]];
    case AllowCalcSize::kForbid:
      break;
  }
  MathFunctionParser math_parser(range, context, value_range, parsing_flags, allowed_anchor_queries);
  if (auto* calculation = math_parser.Value()) {
    if (CanConsumeCalcValue(calculation->get()->Category(), context.Mode())) {
      return math_parser.ConsumeValue();
    }
  }
  return nullptr;
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercent(CSSParserTokenRange& range,
                                                                const CSSParserContext& context,
                                                                CSSPrimitiveValue::ValueRange value_range,
                                                                UnitlessQuirk unitless,
                                                                CSSAnchorQueryTypes allowed_anchor_queries,
                                                                AllowCalcSize allow_calc_size) {
  return ConsumeLengthOrPercentInternal(range, context, value_range, unitless, allowed_anchor_queries, allow_calc_size);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercent(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                CSSPrimitiveValue::ValueRange value_range,
                                                                UnitlessQuirk unitless,
                                                                CSSAnchorQueryTypes allowed_anchor_queries,
                                                                AllowCalcSize allow_calc_size) {
  return ConsumeLengthOrPercentInternal(stream, context, value_range, unitless, allowed_anchor_queries,
                                        allow_calc_size);
}

template <class T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> static std::shared_ptr<const CSSPrimitiveValue> ConsumeNumericLiteralAngle(
        T& range,
        const CSSParserContext& context) {
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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> static std::shared_ptr<const CSSPrimitiveValue> ConsumeMathFunctionAngle(
        T& range,
        const CSSParserContext& context) {
  MathFunctionParser<T> math_parser(range, context, CSSPrimitiveValue::ValueRange::kAll);
  if (auto calculation = math_parser.Value()) {
    if (calculation->get()->Category() != kCalcAngle) {
      return nullptr;
    }
  }
  return math_parser.ConsumeValue();
}

template <class T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> static std::shared_ptr<const CSSPrimitiveValue>
    ConsumeMathFunctionAngle(T& range, const CSSParserContext& context, double minimum_value, double maximum_value) {
  MathFunctionParser math_parser(range, context, CSSPrimitiveValue::ValueRange::kAll);
  if (auto calculation = math_parser.Value()) {
    if (calculation->get()->Category() != kCalcAngle) {
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
                                                      const CSSParserContext& context,
                                                      double minimum_value,
                                                      double maximum_value) {
  if (auto result = ConsumeNumericLiteralAngle(stream, context)) {
    return result;
  }

  return ConsumeMathFunctionAngle(stream, context, minimum_value, maximum_value);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenRange& range,
                                                      const CSSParserContext& context,
                                                      double minimum_value,
                                                      double maximum_value) {
  if (auto result = ConsumeNumericLiteralAngle(range, context)) {
    return result;
  }

  return ConsumeMathFunctionAngle(range, context, minimum_value, maximum_value);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenRange& range, const CSSParserContext& context) {
  if (auto result = ConsumeNumericLiteralAngle(range, context)) {
    return result;
  }

  return ConsumeMathFunctionAngle(range, context);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenStream& stream, const CSSParserContext& context) {
  if (auto result = ConsumeNumericLiteralAngle(stream, context)) {
    return result;
  }

  return ConsumeMathFunctionAngle(stream, context);
}

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue>
    ConsumeTime(T& stream, const CSSParserContext& context, CSSPrimitiveValue::ValueRange value_range) {
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
  if (auto calculation = math_parser.Value()) {
    if (calculation->get()->Category() == kCalcTime) {
      return math_parser.ConsumeValue();
    }
  }
  return nullptr;
}

template std::shared_ptr<const CSSPrimitiveValue> ConsumeTime(CSSParserTokenRange& stream,
                                                              const CSSParserContext& context,
                                                              CSSPrimitiveValue::ValueRange value_range);

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue> ConsumeResolution(
        T& range,
        const CSSParserContext& context) {
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
  auto math_value = math_parser.Value();
  if (math_value && math_value->get()->IsResolution()) {
    return math_parser.ConsumeValue();
  }

  return nullptr;
}

template std::shared_ptr<const CSSPrimitiveValue> ConsumeResolution(CSSParserTokenRange& range,
                                                                    const CSSParserContext& context);
template std::shared_ptr<const CSSPrimitiveValue> ConsumeResolution(CSSParserTokenStream& range,
                                                                    const CSSParserContext& context);

// https://drafts.csswg.org/css-values-4/#ratio-value
//
// <ratio> = <number [0,+inf]> [ / <number [0,+inf]> ]?
std::shared_ptr<const CSSValue> ConsumeRatio(CSSParserTokenStream& stream, const CSSParserContext& context) {
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
                                                              const CSSParserContext& context) {
  if (range.Peek().GetType() != kIdentToken || IsCSSWideKeyword(range.Peek().Id()) ||
      range.Peek().Id() == CSSValueID::kDefault) {
    return nullptr;
  }
  return std::make_shared<CSSCustomIdentValue>(range.ConsumeIncludingWhitespace().Value());
}

std::shared_ptr<const CSSCustomIdentValue> ConsumeCustomIdent(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context) {
  if (stream.Peek().GetType() != kIdentToken || IsCSSWideKeyword(stream.Peek().Id()) ||
      stream.Peek().Id() == CSSValueID::kDefault) {
    return nullptr;
  }
  return std::make_shared<CSSCustomIdentValue>(stream.ConsumeIncludingWhitespace().Value());
}

static bool ConsumeColorInterpolationSpace(CSSParserTokenRange& args,
                                           Color::ColorSpace& color_space,
                                           Color::HueInterpolationMethod& hue_interpolation) {
  if (!ConsumeIdent<CSSValueID::kIn>(args)) {
    return false;
  }

  std::optional<Color::ColorSpace> read_color_space;
  if (ConsumeIdent<CSSValueID::kXyz>(args)) {
    read_color_space = Color::ColorSpace::kXYZD65;
  } else if (ConsumeIdent<CSSValueID::kXyzD50>(args)) {
    read_color_space = Color::ColorSpace::kXYZD50;
  } else if (ConsumeIdent<CSSValueID::kXyzD65>(args)) {
    read_color_space = Color::ColorSpace::kXYZD65;
  } else if (ConsumeIdent<CSSValueID::kSrgbLinear>(args)) {
    read_color_space = Color::ColorSpace::kSRGBLinear;
  } else if (ConsumeIdent<CSSValueID::kDisplayP3>(args)) {
    read_color_space = Color::ColorSpace::kDisplayP3;
  } else if (ConsumeIdent<CSSValueID::kA98Rgb>(args)) {
    read_color_space = Color::ColorSpace::kA98RGB;
  } else if (ConsumeIdent<CSSValueID::kProphotoRgb>(args)) {
    read_color_space = Color::ColorSpace::kProPhotoRGB;
  } else if (ConsumeIdent<CSSValueID::kRec2020>(args)) {
    read_color_space = Color::ColorSpace::kRec2020;
  } else if (ConsumeIdent<CSSValueID::kLab>(args)) {
    read_color_space = Color::ColorSpace::kLab;
  } else if (ConsumeIdent<CSSValueID::kOklab>(args)) {
    read_color_space = Color::ColorSpace::kOklab;
  } else if (ConsumeIdent<CSSValueID::kLch>(args)) {
    read_color_space = Color::ColorSpace::kLch;
  } else if (ConsumeIdent<CSSValueID::kOklch>(args)) {
    read_color_space = Color::ColorSpace::kOklch;
  } else if (ConsumeIdent<CSSValueID::kSrgb>(args)) {
    read_color_space = Color::ColorSpace::kSRGB;
  } else if (ConsumeIdent<CSSValueID::kHsl>(args)) {
    read_color_space = Color::ColorSpace::kHSL;
  } else if (ConsumeIdent<CSSValueID::kHwb>(args)) {
    read_color_space = Color::ColorSpace::kHWB;
  }

  if (read_color_space) {
    color_space = read_color_space.value();
    std::optional<Color::HueInterpolationMethod> read_hue;
    if (color_space == Color::ColorSpace::kHSL || color_space == Color::ColorSpace::kHWB ||
        color_space == Color::ColorSpace::kLch || color_space == Color::ColorSpace::kOklch) {
      if (ConsumeIdent<CSSValueID::kShorter>(args)) {
        read_hue = Color::HueInterpolationMethod::kShorter;
      } else if (ConsumeIdent<CSSValueID::kLonger>(args)) {
        read_hue = Color::HueInterpolationMethod::kLonger;
      } else if (ConsumeIdent<CSSValueID::kDecreasing>(args)) {
        read_hue = Color::HueInterpolationMethod::kDecreasing;
      } else if (ConsumeIdent<CSSValueID::kIncreasing>(args)) {
        read_hue = Color::HueInterpolationMethod::kIncreasing;
      }
      if (read_hue) {
        if (!ConsumeIdent<CSSValueID::kHue>(args)) {
          return false;
        }
        hue_interpolation = read_hue.value();
      } else {
        // Shorter is the default method for hue interpolation.
        hue_interpolation = Color::HueInterpolationMethod::kShorter;
      }
    }
    return true;
  }

  return false;
}

template <class T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue>
    ConsumeColorInternal(T&, const CSSParserContext&, bool accept_quirky_colors, AllowedColors);

template <class T, typename Func>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSLightDarkValuePair>
    ConsumeLightDark(Func consume_value, T& range, const CSSParserContext& context) {
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

// https://www.w3.org/TR/css-color-5/#color-mix
static std::shared_ptr<const CSSValue> ConsumeColorMixFunction(CSSParserTokenRange& range,
                                                               const CSSParserContext& context,
                                                               AllowedColors allowed_colors) {
  assert(range.Peek().FunctionId() == CSSValueID::kColorMix);

  CSSParserSavePoint savepoint(range);
  CSSParserTokenRange args = ConsumeFunction(range);
  // First argument is the colorspace
  Color::ColorSpace color_space;
  Color::HueInterpolationMethod hue_interpolation_method = Color::HueInterpolationMethod::kShorter;
  if (!ConsumeColorInterpolationSpace(args, color_space, hue_interpolation_method)) {
    return nullptr;
  }

  if (!ConsumeCommaIncludingWhitespace(args)) {
    return nullptr;
  }

  const bool no_quirky_colors = false;

  auto color1 = ConsumeColorInternal(args, context, no_quirky_colors, allowed_colors);
  auto p1 = ConsumePercent(args, context, CSSPrimitiveValue::ValueRange::kAll);
  // Color can come after the percentage
  if (!color1) {
    color1 = ConsumeColorInternal(args, context, no_quirky_colors, allowed_colors);
    if (!color1) {
      return nullptr;
    }
  }
  // Reject negative values and values > 100%, but not calc() values.
  if (auto* p1_numeric = DynamicTo<CSSNumericLiteralValue>(p1.get());
      p1_numeric && (p1_numeric->ComputePercentage() < 0.0 || p1_numeric->ComputePercentage() > 100.0)) {
    return nullptr;
  }

  if (!ConsumeCommaIncludingWhitespace(args)) {
    return nullptr;
  }

  auto color2 = ConsumeColorInternal(args, context, no_quirky_colors, allowed_colors);
  auto p2 = ConsumePercent(args, context, CSSPrimitiveValue::ValueRange::kAll);
  // Color can come after the percentage
  if (!color2) {
    color2 = ConsumeColorInternal(args, context, no_quirky_colors, allowed_colors);
    if (!color2) {
      return nullptr;
    }
  }
  // Reject negative values and values > 100%, but not calc() values.
  if (auto* p2_numeric = DynamicTo<CSSNumericLiteralValue>(p2.get());
      p2_numeric && (p2_numeric->ComputePercentage() < 0.0 || p2_numeric->ComputePercentage() > 100.0)) {
    return nullptr;
  }

  // If both values are literally zero (and not calc()) reject at parse time
  if (p1 && p2 && p1->IsNumericLiteralValue() && To<CSSNumericLiteralValue>(p1.get())->ComputePercentage() == 0.0f &&
      p2->IsNumericLiteralValue() && To<CSSNumericLiteralValue>(p2.get())->ComputePercentage() == 0.0) {
    return nullptr;
  }

  if (!args.AtEnd()) {
    return nullptr;
  }

  savepoint.Release();

  auto result =
      std::make_shared<cssvalue::CSSColorMixValue>(color1, color2, p1, p2, color_space, hue_interpolation_method);
  return result;
}

static std::shared_ptr<const CSSValue> ConsumeColorMixFunction(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               AllowedColors allowed_colors) {
  assert(stream.Peek().FunctionId() == CSSValueID::kColorMix);

  CSSParserTokenStream::State savepoint = stream.Save();
  CSSParserTokenRange args = ConsumeFunction(stream);
  // First argument is the colorspace
  Color::ColorSpace color_space;
  Color::HueInterpolationMethod hue_interpolation_method = Color::HueInterpolationMethod::kShorter;
  if (!ConsumeColorInterpolationSpace(args, color_space, hue_interpolation_method)) {
    stream.Restore(savepoint);
    return nullptr;
  }

  if (!ConsumeCommaIncludingWhitespace(args)) {
    stream.Restore(savepoint);
    return nullptr;
  }

  const bool no_quirky_colors = false;

  auto color1 = ConsumeColorInternal(args, context, no_quirky_colors, allowed_colors);
  auto p1 = ConsumePercent(args, context, CSSPrimitiveValue::ValueRange::kAll);
  // Color can come after the percentage
  if (!color1) {
    color1 = ConsumeColorInternal(args, context, no_quirky_colors, allowed_colors);
    if (!color1) {
      stream.Restore(savepoint);
      return nullptr;
    }
  }
  // Reject negative values and values > 100%, but not calc() values.
  if (auto* p1_numeric = DynamicTo<CSSNumericLiteralValue>(p1.get());
      p1_numeric && (p1_numeric->ComputePercentage() < 0.0 || p1_numeric->ComputePercentage() > 100.0)) {
    stream.Restore(savepoint);
    return nullptr;
  }

  if (!ConsumeCommaIncludingWhitespace(args)) {
    stream.Restore(savepoint);
    return nullptr;
  }

  auto color2 = ConsumeColorInternal(args, context, no_quirky_colors, allowed_colors);
  auto p2 = ConsumePercent(args, context, CSSPrimitiveValue::ValueRange::kAll);
  // Color can come after the percentage
  if (!color2) {
    color2 = ConsumeColorInternal(args, context, no_quirky_colors, allowed_colors);
    if (!color2) {
      stream.Restore(savepoint);
      return nullptr;
    }
  }
  // Reject negative values and values > 100%, but not calc() values.
  if (auto* p2_numeric = DynamicTo<CSSNumericLiteralValue>(p2.get());
      p2_numeric && (p2_numeric->ComputePercentage() < 0.0 || p2_numeric->ComputePercentage() > 100.0)) {
    stream.Restore(savepoint);
    return nullptr;
  }

  // If both values are literally zero (and not calc()) reject at parse time
  if (p1 && p2 && p1->IsNumericLiteralValue() && To<CSSNumericLiteralValue>(p1.get())->ComputePercentage() == 0.0f &&
      p2->IsNumericLiteralValue() && To<CSSNumericLiteralValue>(p2.get())->ComputePercentage() == 0.0) {
    stream.Restore(savepoint);
    return nullptr;
  }

  if (!args.AtEnd()) {
    stream.Restore(savepoint);
    return nullptr;
  }

  auto result =
      std::make_shared<cssvalue::CSSColorMixValue>(color1, color2, p1, p2, color_space, hue_interpolation_method);
  return result;
}

template <class T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> static bool ParseHexColor(T& range,
                                                                     Color& result,
                                                                     bool accept_quirky_colors) {
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
        color = std::to_string(static_cast<int>(token.NumericValue())) + token.Value();
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

template <class T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeColorInternal(
        T& range,
        const CSSParserContext& context,
        bool accept_quirky_colors,
        AllowedColors allowed_colors) {
  if (range.Peek().FunctionId() == CSSValueID::kColorMix) {
    auto color = ConsumeColorMixFunction(range, context, allowed_colors);
    return color;
  }

  CSSValueID id = range.Peek().Id();
  if ((id == CSSValueID::kAccentcolor || id == CSSValueID::kAccentcolortext)) {
    return nullptr;
  }
  if (StyleColor::IsColorKeyword(id)) {
    if (!isValueAllowedInMode(id, context.Mode())) {
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

std::shared_ptr<const CSSValue> ConsumeColorMaybeQuirky(CSSParserTokenStream& stream, const CSSParserContext& context) {
  return ConsumeColorInternal(stream, context, IsQuirksModeBehavior(context.Mode()), AllowedColors::kAll);
}

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeColor(
        T& range,
        const CSSParserContext& context) {
  return ConsumeColorInternal(range, context, false /* accept_quirky_colors */, AllowedColors::kAll);
}

template std::shared_ptr<const CSSValue> ConsumeColor(CSSParserTokenRange& range, const CSSParserContext& context);
template std::shared_ptr<const CSSValue> ConsumeColor(CSSParserTokenStream& stream, const CSSParserContext& context);

std::shared_ptr<const CSSValue> ConsumeLineWidth(CSSParserTokenRange& range,
                                                 const CSSParserContext& context,
                                                 UnitlessQuirk unitless) {
  CSSValueID id = range.Peek().Id();
  if (id == CSSValueID::kThin || id == CSSValueID::kMedium || id == CSSValueID::kThick) {
    return ConsumeIdent(range);
  }
  return ConsumeLength(range, context, CSSPrimitiveValue::ValueRange::kNonNegative, unitless);
}

std::shared_ptr<const CSSValue> ConsumeLineWidth(CSSParserTokenStream& stream,
                                                 const CSSParserContext& context,
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
    auto current_value = std::reinterpret_pointer_cast<const CSSIdentifierValue>(values[i]);
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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> static std::shared_ptr<const CSSValue> ConsumePositionComponent(
        T& stream,
        const CSSParserContext& context,
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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValuePair>
    ConsumePosition(T& range, const CSSParserContext& context, UnitlessQuirk unitless) {
  std::shared_ptr<const CSSValue> result_x = nullptr;
  std::shared_ptr<const CSSValue> result_y = nullptr;
  if (ConsumePosition(range, context, unitless, result_x, result_y)) {
    return std::make_shared<CSSValuePair>(result_x, result_y, CSSValuePair::kKeepIdenticalValues);
  }
  return nullptr;
}

template std::shared_ptr<const CSSValuePair> ConsumePosition(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             UnitlessQuirk unitless);
template std::shared_ptr<const CSSValuePair> ConsumePosition(CSSParserTokenRange& range,
                                                             const CSSParserContext& context,
                                                             UnitlessQuirk unitless);

bool ConsumePosition(CSSParserTokenRange& range,
                     const CSSParserContext& context,
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
                     const CSSParserContext& context,
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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> bool ConsumeOneOrTwoValuedPosition(
        T& range,
        const CSSParserContext& context,
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
                            const CSSParserContext& context,
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
                                                   const CSSParserContext& context,
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
                                                     const CSSParserContext& context,
                                                     const CSSParserLocalContext& local_context) {
  CSSPropertyID shorthand = local_context.CurrentShorthand();
  bool allow_quirky_lengths = IsQuirksModeBehavior(context.Mode()) &&
                              (shorthand == CSSPropertyID::kInvalid || shorthand == CSSPropertyID::kBorderWidth);
  UnitlessQuirk unitless = allow_quirky_lengths ? UnitlessQuirk::kAllow : UnitlessQuirk::kForbid;
  return ConsumeBorderWidth(stream, context, unitless);
}

std::shared_ptr<const CSSValue> ParseBorderStyleSide(CSSParserTokenStream& stream, const CSSParserContext& context) {
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
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSAppearanceAutoBaseSelectValuePair>
    ConsumeAppearanceAutoBaseSelectColor(T& range, const CSSParserContext& context) {
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
                                                       const CSSParserContext& context,
                                                       const CSSParserLocalContext& local_context) {
  CSSPropertyID shorthand = local_context.CurrentShorthand();
  bool allow_quirky_colors = IsQuirksModeBehavior(context.Mode()) &&
                             (shorthand == CSSPropertyID::kInvalid || shorthand == CSSPropertyID::kBorderColor);
  if (stream.Peek().FunctionId() == CSSValueID::kInternalAppearanceAutoBaseSelect &&
      IsUASheetBehavior(context.Mode())) {
    return ConsumeAppearanceAutoBaseSelectColor(stream, context);
  }
  return ConsumeColorInternal(stream, context, allow_quirky_colors, AllowedColors::kAll);
}

std::shared_ptr<const CSSValue> ParseLonghand(CSSPropertyID unresolved_property,
                                              CSSPropertyID current_shorthand,
                                              const CSSParserContext& context,
                                              CSSParserTokenStream& stream) {
  CSSPropertyID property_id = ResolveCSSPropertyID(unresolved_property);
  CSSValueID value_id = stream.Peek().Id();
  assert(!CSSProperty::Get(property_id).IsShorthand());
  if (CSSParserFastPaths::IsHandledByKeywordFastPath(property_id)) {
    if (CSSParserFastPaths::IsValidKeywordPropertyAndValue(property_id, stream.Peek().Id(), context.Mode())) {
      CountKeywordOnlyPropertyUsage(property_id, context, value_id);
      return ConsumeIdent(stream);
    }
    WarnInvalidKeywordPropertyUsage(property_id, context, value_id);
    return nullptr;
  }

  const auto local_context = CSSParserLocalContext()
                                 .WithAliasParsing(IsPropertyAlias(unresolved_property))
                                 .WithCurrentShorthand(current_shorthand);

  std::shared_ptr<const CSSValue> result = To<Longhand>(CSSProperty::Get(property_id)).ParseSingleValue(stream, context, local_context);
  return result;
}

void CountKeywordOnlyPropertyUsage(CSSPropertyID property, const CSSParserContext& context, CSSValueID value_id) {
  if (!context.IsUseCounterRecordingEnabled()) {
    return;
  }
  switch (property) {
    case CSSPropertyID::kAppearance:
    case CSSPropertyID::kAliasWebkitAppearance: {
      if (value_id == CSSValueID::kSliderVertical) {
        if (const auto* document = context.GetDocument()) {
          WEBF_LOG(WARN) << "The keyword 'slider-vertical' specified to an 'appearance' "
                            "property is not standardized. It will be removed in the future. "
                            "Use <input type=range style=\"writing-mode: vertical-lr; "
                            "direction: rtl\"> instead.";
        }
      }
      break;
    }
    default:
      break;
  }
}

void WarnInvalidKeywordPropertyUsage(CSSPropertyID property, const CSSParserContext& context, CSSValueID value_id) {}

bool ValidWidthOrHeightKeyword(CSSValueID id, const CSSParserContext& context) {
  // The keywords supported here should be kept in sync with
  // CalculationExpressionSizingKeywordNode::Keyword and the things that use
  // it.
  // TODO(https://crbug.com/353538495): This should also be kept in sync with
  // FlexBasis::ParseSingleValue, although we should eventually make it use
  // this function instead.
  if (id == CSSValueID::kWebkitMinContent ||
      id == CSSValueID::kWebkitMaxContent ||
      id == CSSValueID::kWebkitFillAvailable ||
      id == CSSValueID::kWebkitFitContent || id == CSSValueID::kMinContent ||
      id == CSSValueID::kMaxContent || id == CSSValueID::kFitContent) {
    return true;
  }
  return false;
}


}  // namespace css_parsing_utils

}  // namespace webf
