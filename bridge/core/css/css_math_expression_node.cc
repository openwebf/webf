/*
 * Copyright (C) 2011, 2012 Google Inc. All rights reserved.
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

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_math_expression_node.h"
#include "core/platform/geometry/calculation_expression_node.h"
#include "core/css/properties/css_parsing_utils.h"
#include "css_math_operator.h"
#include "css_color_channel_map.h"
#include "css_value_clamping_utils.h"

namespace webf {

static CalculationResultCategory UnitCategory(CSSPrimitiveValue::UnitType type) {
  switch (type) {
    case CSSPrimitiveValue::UnitType::kNumber:
    case CSSPrimitiveValue::UnitType::kInteger:
      return kCalcNumber;
    case CSSPrimitiveValue::UnitType::kPercentage:
      return kCalcPercent;
    case CSSPrimitiveValue::UnitType::kEms:
    case CSSPrimitiveValue::UnitType::kExs:
    case CSSPrimitiveValue::UnitType::kPixels:
    case CSSPrimitiveValue::UnitType::kCentimeters:
    case CSSPrimitiveValue::UnitType::kMillimeters:
    case CSSPrimitiveValue::UnitType::kQuarterMillimeters:
    case CSSPrimitiveValue::UnitType::kInches:
    case CSSPrimitiveValue::UnitType::kPoints:
    case CSSPrimitiveValue::UnitType::kPicas:
    case CSSPrimitiveValue::UnitType::kUserUnits:
    case CSSPrimitiveValue::UnitType::kRems:
    case CSSPrimitiveValue::UnitType::kChs:
    case CSSPrimitiveValue::UnitType::kViewportWidth:
    case CSSPrimitiveValue::UnitType::kViewportHeight:
    case CSSPrimitiveValue::UnitType::kViewportMin:
    case CSSPrimitiveValue::UnitType::kViewportMax:
    case CSSPrimitiveValue::UnitType::kRexs:
    case CSSPrimitiveValue::UnitType::kRchs:
    case CSSPrimitiveValue::UnitType::kRics:
    case CSSPrimitiveValue::UnitType::kRlhs:
    case CSSPrimitiveValue::UnitType::kIcs:
    case CSSPrimitiveValue::UnitType::kLhs:
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
      return kCalcLength;
    case CSSPrimitiveValue::UnitType::kDegrees:
    case CSSPrimitiveValue::UnitType::kGradians:
    case CSSPrimitiveValue::UnitType::kRadians:
    case CSSPrimitiveValue::UnitType::kTurns:
      return kCalcAngle;
    case CSSPrimitiveValue::UnitType::kMilliseconds:
    case CSSPrimitiveValue::UnitType::kSeconds:
      return kCalcTime;
    case CSSPrimitiveValue::UnitType::kHertz:
    case CSSPrimitiveValue::UnitType::kKilohertz:
      return kCalcFrequency;

    // Resolution units
    case CSSPrimitiveValue::UnitType::kDotsPerPixel:
    case CSSPrimitiveValue::UnitType::kX:
    case CSSPrimitiveValue::UnitType::kDotsPerInch:
    case CSSPrimitiveValue::UnitType::kDotsPerCentimeter:
      return kCalcResolution;

    // Identifier
    case CSSPrimitiveValue::UnitType::kIdent:
      return kCalcIdent;

    default:
      return kCalcOther;
  }
}

CSSMathOperator CSSValueIDToCSSMathOperator(CSSValueID id) {
  switch (id) {
#define CONVERSION_CASE(value_id) \
  case CSSValueID::value_id:      \
    return CSSMathOperator::value_id;

    CONVERSION_CASE(kProgress)
    CONVERSION_CASE(kMediaProgress)
    CONVERSION_CASE(kContainerProgress)

#undef CONVERSION_CASE
    default:
      assert(false);
  }
}

static bool HasDoubleValue(CSSPrimitiveValue::UnitType type) {
  switch (type) {
    case CSSPrimitiveValue::UnitType::kNumber:
    case CSSPrimitiveValue::UnitType::kPercentage:
    case CSSPrimitiveValue::UnitType::kEms:
    case CSSPrimitiveValue::UnitType::kExs:
    case CSSPrimitiveValue::UnitType::kChs:
    case CSSPrimitiveValue::UnitType::kIcs:
    case CSSPrimitiveValue::UnitType::kLhs:
    case CSSPrimitiveValue::UnitType::kCaps:
    case CSSPrimitiveValue::UnitType::kRcaps:
    case CSSPrimitiveValue::UnitType::kRlhs:
    case CSSPrimitiveValue::UnitType::kRems:
    case CSSPrimitiveValue::UnitType::kRexs:
    case CSSPrimitiveValue::UnitType::kRchs:
    case CSSPrimitiveValue::UnitType::kRics:
    case CSSPrimitiveValue::UnitType::kPixels:
    case CSSPrimitiveValue::UnitType::kCentimeters:
    case CSSPrimitiveValue::UnitType::kMillimeters:
    case CSSPrimitiveValue::UnitType::kQuarterMillimeters:
    case CSSPrimitiveValue::UnitType::kInches:
    case CSSPrimitiveValue::UnitType::kPoints:
    case CSSPrimitiveValue::UnitType::kPicas:
    case CSSPrimitiveValue::UnitType::kUserUnits:
    case CSSPrimitiveValue::UnitType::kDegrees:
    case CSSPrimitiveValue::UnitType::kRadians:
    case CSSPrimitiveValue::UnitType::kGradians:
    case CSSPrimitiveValue::UnitType::kTurns:
    case CSSPrimitiveValue::UnitType::kMilliseconds:
    case CSSPrimitiveValue::UnitType::kSeconds:
    case CSSPrimitiveValue::UnitType::kHertz:
    case CSSPrimitiveValue::UnitType::kKilohertz:
    case CSSPrimitiveValue::UnitType::kViewportWidth:
    case CSSPrimitiveValue::UnitType::kViewportHeight:
    case CSSPrimitiveValue::UnitType::kViewportMin:
    case CSSPrimitiveValue::UnitType::kViewportMax:
    case CSSPrimitiveValue::UnitType::kContainerWidth:
    case CSSPrimitiveValue::UnitType::kContainerHeight:
    case CSSPrimitiveValue::UnitType::kContainerInlineSize:
    case CSSPrimitiveValue::UnitType::kContainerBlockSize:
    case CSSPrimitiveValue::UnitType::kContainerMin:
    case CSSPrimitiveValue::UnitType::kContainerMax:
    case CSSPrimitiveValue::UnitType::kDotsPerPixel:
    case CSSPrimitiveValue::UnitType::kX:
    case CSSPrimitiveValue::UnitType::kDotsPerInch:
    case CSSPrimitiveValue::UnitType::kDotsPerCentimeter:
    case CSSPrimitiveValue::UnitType::kFlex:
    case CSSPrimitiveValue::UnitType::kInteger:
      return true;
    default:
      return false;
  }
}

class CSSMathExpressionNodeParser {
  WEBF_STACK_ALLOCATED();

 public:
  using Flag = CSSMathExpressionNode::Flag;
  using Flags = CSSMathExpressionNode::Flags;

  // A struct containing parser state that varies within the expression tree.
  struct State {
    WEBF_STACK_ALLOCATED();

   public:
    uint8_t depth;
    bool allow_size_keyword;

    static_assert(uint8_t(kMaxExpressionDepth + 1) == kMaxExpressionDepth + 1);

    State() : depth(0), allow_size_keyword(false) {}
    State(const State&) = default;
    State& operator=(const State&) = default;
  };

  CSSMathExpressionNodeParser(const CSSParserContext& context,
                              const Flags parsing_flags,
                              CSSAnchorQueryTypes allowed_anchor_queries,
                              const CSSColorChannelMap& color_channel_map)
      : context_(context),
        allowed_anchor_queries_(allowed_anchor_queries),
        parsing_flags_(parsing_flags),
        color_channel_map_(color_channel_map) {}

  static bool IsSupportedMathFunction(CSSValueID function_id) {
    switch (function_id) {
      case CSSValueID::kMin:
      case CSSValueID::kMax:
      case CSSValueID::kClamp:
      case CSSValueID::kCalc:
      case CSSValueID::kWebkitCalc:
      case CSSValueID::kSin:
      case CSSValueID::kCos:
      case CSSValueID::kTan:
      case CSSValueID::kAsin:
      case CSSValueID::kAcos:
      case CSSValueID::kAtan:
      case CSSValueID::kAtan2:
      case CSSValueID::kPow:
      case CSSValueID::kSqrt:
      case CSSValueID::kHypot:
      case CSSValueID::kLog:
      case CSSValueID::kExp:
      case CSSValueID::kRound:
      case CSSValueID::kMod:
      case CSSValueID::kRem:
      case CSSValueID::kAbs:
      case CSSValueID::kSign:
      case CSSValueID::kAnchor:
      case CSSValueID::kAnchorSize:
      case CSSValueID::kProgress:
      case CSSValueID::kMediaProgress:
      case CSSValueID::kContainerProgress:
      case CSSValueID::kCalcSize:
        return true;
      default:
        return false;
    }
  }

  CSSMathExpressionNode* ParseAnchorQuery(CSSValueID function_id,
                                          CSSParserTokenRange& tokens) {
    CSSAnchorQueryType anchor_query_type;
    switch (function_id) {
      case CSSValueID::kAnchor:
        anchor_query_type = CSSAnchorQueryType::kAnchor;
        break;
      case CSSValueID::kAnchorSize:
        anchor_query_type = CSSAnchorQueryType::kAnchorSize;
        break;
      default:
        return nullptr;
    }

    if (!(static_cast<CSSAnchorQueryTypes>(anchor_query_type) &
          allowed_anchor_queries_)) {
      return nullptr;
    }

    // |anchor_specifier| may be omitted to represent the default anchor.
    const CSSValue* anchor_specifier =
        css_parsing_utils::ConsumeDashedIdent(tokens, context_);

    tokens.ConsumeWhitespace();
    const CSSValue* value = nullptr;
    switch (anchor_query_type) {
      case CSSAnchorQueryType::kAnchor:
        value = css_parsing_utils::ConsumeIdent<
            CSSValueID::kInside, CSSValueID::kOutside, CSSValueID::kTop,
            CSSValueID::kLeft, CSSValueID::kRight, CSSValueID::kBottom,
            CSSValueID::kStart, CSSValueID::kEnd, CSSValueID::kSelfStart,
            CSSValueID::kSelfEnd, CSSValueID::kCenter>(tokens);
        if (!value) {
          value = css_parsing_utils::ConsumePercent(
              tokens, context_, CSSPrimitiveValue::ValueRange::kAll);
        }
        break;
      case CSSAnchorQueryType::kAnchorSize:
        value = css_parsing_utils::ConsumeIdent<
            CSSValueID::kWidth, CSSValueID::kHeight, CSSValueID::kBlock,
            CSSValueID::kInline, CSSValueID::kSelfBlock,
            CSSValueID::kSelfInline>(tokens);
        break;
    }
    if (!value) {
      return nullptr;
    }

    const CSSPrimitiveValue* fallback = nullptr;
    if (css_parsing_utils::ConsumeCommaIncludingWhitespace(tokens)) {
      fallback = css_parsing_utils::ConsumeLengthOrPercent(
          tokens, context_, CSSPrimitiveValue::ValueRange::kAll,
          css_parsing_utils::UnitlessQuirk::kForbid, allowed_anchor_queries_);
      if (!fallback) {
        return nullptr;
      }
    }

    tokens.ConsumeWhitespace();
    if (!tokens.AtEnd()) {
      return nullptr;
    }
    return MakeGarbageCollected<CSSMathExpressionAnchorQuery>(
        anchor_query_type, anchor_specifier, *value, fallback);
  }

  bool ParseProgressNotationFromTo(
      CSSParserTokenRange& tokens,
      State state,
      CSSMathExpressionOperation::Operands& nodes) {
    if (tokens.ConsumeIncludingWhitespace().Id() != CSSValueID::kFrom) {
      return false;
    }
    if (CSSMathExpressionNode* node = ParseValueExpression(tokens, state)) {
      nodes.push_back(node);
    }
    if (tokens.ConsumeIncludingWhitespace().Id() != CSSValueID::kTo) {
      return false;
    }
    if (CSSMathExpressionNode* node = ParseValueExpression(tokens, state)) {
      nodes.push_back(node);
    }
    return true;
  }

  // https://drafts.csswg.org/css-values-5/#progress-func
  // https://drafts.csswg.org/css-values-5/#media-progress-func
  // https://drafts.csswg.org/css-values-5/#container-progress-func
  CSSMathExpressionNode* ParseProgressNotation(CSSValueID function_id,
                                               CSSParserTokenRange& tokens,
                                               State state) {
    if (function_id != CSSValueID::kProgress &&
        function_id != CSSValueID::kMediaProgress &&
        function_id != CSSValueID::kContainerProgress) {
      return nullptr;
    }
    // <media-progress()> = media-progress(<media-feature> from <calc-sum> to
    // <calc-sum>)
    CSSMathExpressionOperation::Operands nodes;
    tokens.ConsumeWhitespace();
    if (function_id == CSSValueID::kMediaProgress) {
      if (CSSMathExpressionKeywordLiteral* node = ParseKeywordLiteral(
              tokens,
              CSSMathExpressionKeywordLiteral::Context::kMediaProgress)) {
        nodes.push_back(node);
      }
    } else if (function_id == CSSValueID::kContainerProgress) {
      // <container-progress()> = container-progress(<size-feature> [ of
      // <container-name> ]? from <calc-sum> to <calc-sum>)
      const CSSIdentifierValue* size_feature =
          css_parsing_utils::ConsumeIdent(tokens);
      if (!size_feature) {
        return nullptr;
      }
      if (tokens.Peek().Id() == CSSValueID::kOf) {
        tokens.ConsumeIncludingWhitespace();
        const CSSCustomIdentValue* container_name =
            css_parsing_utils::ConsumeCustomIdent(tokens, context_);
        if (!container_name) {
          return nullptr;
        }
        nodes.push_back(MakeGarbageCollected<CSSMathExpressionContainerFeature>(
            size_feature, container_name));
      } else {
        nodes.push_back(MakeGarbageCollected<CSSMathExpressionContainerFeature>(
            size_feature, nullptr));
      }
    } else if (CSSMathExpressionNode* node =
                   ParseValueExpression(tokens, state)) {
      // <progress()> = progress(<calc-sum> from <calc-sum> to <calc-sum>)
      nodes.push_back(node);
    }
    if (!ParseProgressNotationFromTo(tokens, state, nodes)) {
      return nullptr;
    }
    if (nodes.size() != 3u || !tokens.AtEnd() ||
        !CheckProgressFunctionTypes(function_id, nodes)) {
      return nullptr;
    }
    // Note: we don't need to resolve percents in such case,
    // as all the operands are numeric literals,
    // so p% / (t% - f%) will lose %.
    // Note: we can not simplify media-progress.
    ProgressArgsSimplificationStatus status =
        CanEagerlySimplifyProgressArgs(nodes);
    if (function_id == CSSValueID::kProgress &&
        status != ProgressArgsSimplificationStatus::kCanNotSimplify) {
      Vector<double> double_values;
      double_values.reserve(nodes.size());
      for (const CSSMathExpressionNode* operand : nodes) {
        if (status ==
            ProgressArgsSimplificationStatus::kAllArgsResolveToCanonical) {
          std::optional<double> canonical_value =
              operand->ComputeValueInCanonicalUnit();
          CHECK(canonical_value.has_value());
          double_values.push_back(canonical_value.value());
        } else {
          CHECK(HasDoubleValue(operand->ResolvedUnitType()));
          double_values.push_back(operand->DoubleValue());
        }
      }
      double progress_value = (double_values[0] - double_values[1]) /
                              (double_values[2] - double_values[1]);
      return CSSMathExpressionNumericLiteral::Create(
          progress_value, CSSPrimitiveValue::UnitType::kNumber);
    }
    return MakeGarbageCollected<CSSMathExpressionOperation>(
        CalculationResultCategory::kCalcNumber, std::move(nodes),
        CSSValueIDToCSSMathOperator(function_id));
  }

  CSSMathExpressionNode* ParseCalcSize(CSSValueID function_id,
                                       CSSParserTokenRange& tokens,
                                       State state) {
    if (function_id != CSSValueID::kCalcSize ||
        !parsing_flags_.Has(Flag::AllowCalcSize)) {
      return nullptr;
    }

    DCHECK(RuntimeEnabledFeatures::CSSCalcSizeFunctionEnabled());

    // TODO(https://crbug.com/313072): Restrict usage of calc-size() inside of
    // calc(), probably along the lines of
    // https://github.com/w3c/csswg-drafts/issues/626#issuecomment-1881898328

    tokens.ConsumeWhitespace();

    CSSMathExpressionNode* basis = nullptr;

    CSSValueID id = tokens.Peek().Id();
    bool basis_is_any = id == CSSValueID::kAny;
    if (id != CSSValueID::kInvalid &&
        (id == CSSValueID::kAny ||
         (id == CSSValueID::kAuto &&
          parsing_flags_.Has(Flag::AllowAutoInCalcSize)) ||
         css_parsing_utils::ValidWidthOrHeightKeyword(id, context_))) {
      // Note: We don't want to accept 'none' (for 'max-*' properties) since
      // it's not meaningful for animation, since it's equivalent to infinity.
      tokens.ConsumeIncludingWhitespace();
      basis = CSSMathExpressionKeywordLiteral::Create(
          id, CSSMathExpressionKeywordLiteral::Context::kCalcSize);
    } else {
      basis = ParseValueExpression(tokens, state);
      if (!basis) {
        return nullptr;
      }
      // TODO(https://crbug.com/313072): If basis is a calc-size()
      // expression whose basis is 'any', set basis_is_any to true.
    }

    CSSMathExpressionNode* calculation = nullptr;
    if (css_parsing_utils::ConsumeCommaIncludingWhitespace(tokens)) {
      state.allow_size_keyword = !basis_is_any;
      calculation = ParseValueExpression(tokens, state);
      if (!calculation) {
        return nullptr;
      }
    } else {
      // Handle the 1-argument form of calc-size().  Based on the discussion
      // in https://github.com/w3c/csswg-drafts/issues/10259 , eagerly convert
      // it to the two-argument form.
      bool argument_is_basis;
      if (basis->IsKeywordLiteral()) {
        CHECK(To<CSSMathExpressionKeywordLiteral>(basis)->GetContext() ==
              CSSMathExpressionKeywordLiteral::Context::kCalcSize);
        if (basis_is_any) {
          return nullptr;
        }
        argument_is_basis = true;
      } else {
        argument_is_basis =
            basis->IsOperation() &&
            To<CSSMathExpressionOperation>(basis)->OperatorType() ==
                CSSMathOperator::kCalcSize;
      }

      if (argument_is_basis) {
        calculation = CSSMathExpressionKeywordLiteral::Create(
            CSSValueID::kSize,
            CSSMathExpressionKeywordLiteral::Context::kCalcSize);
      } else {
        std::swap(basis, calculation);
        basis = CSSMathExpressionKeywordLiteral::Create(
            CSSValueID::kAny,
            CSSMathExpressionKeywordLiteral::Context::kCalcSize);
      }
    }

    return CSSMathExpressionOperation::CreateCalcSizeOperation(basis,
                                                               calculation);
  }

  CSSMathExpressionNode* ParseMathFunction(CSSValueID function_id,
                                           CSSParserTokenRange& tokens,
                                           State state) {
    if (!IsSupportedMathFunction(function_id)) {
      return nullptr;
    }
    if (RuntimeEnabledFeatures::CSSAnchorPositioningEnabled()) {
      if (auto* anchor_query = ParseAnchorQuery(function_id, tokens)) {
        context_.Count(WebFeature::kCSSAnchorPositioning);
        return anchor_query;
      }
    }
    if (RuntimeEnabledFeatures::CSSProgressNotationEnabled()) {
      if (CSSMathExpressionNode* progress =
              ParseProgressNotation(function_id, tokens, state)) {
        return progress;
      }
    }
    if (RuntimeEnabledFeatures::CSSCalcSizeFunctionEnabled()) {
      if (CSSMathExpressionNode* calc_size =
              ParseCalcSize(function_id, tokens, state)) {
        return calc_size;
      }
    }

    // "arguments" refers to comma separated ones.
    wtf_size_t min_argument_count = 1;
    wtf_size_t max_argument_count = std::numeric_limits<wtf_size_t>::max();

    switch (function_id) {
      case CSSValueID::kCalc:
      case CSSValueID::kWebkitCalc:
        max_argument_count = 1;
        break;
      case CSSValueID::kMin:
      case CSSValueID::kMax:
        break;
      case CSSValueID::kClamp:
        min_argument_count = 3;
        max_argument_count = 3;
        break;
      case CSSValueID::kSin:
      case CSSValueID::kCos:
      case CSSValueID::kTan:
      case CSSValueID::kAsin:
      case CSSValueID::kAcos:
      case CSSValueID::kAtan:
        max_argument_count = 1;
        break;
      case CSSValueID::kPow:
        DCHECK(RuntimeEnabledFeatures::CSSExponentialFunctionsEnabled());
        max_argument_count = 2;
        min_argument_count = 2;
        break;
      case CSSValueID::kExp:
      case CSSValueID::kSqrt:
        DCHECK(RuntimeEnabledFeatures::CSSExponentialFunctionsEnabled());
        max_argument_count = 1;
        break;
      case CSSValueID::kHypot:
        DCHECK(RuntimeEnabledFeatures::CSSExponentialFunctionsEnabled());
        max_argument_count = kMaxExpressionDepth;
        break;
      case CSSValueID::kLog:
        DCHECK(RuntimeEnabledFeatures::CSSExponentialFunctionsEnabled());
        max_argument_count = 2;
        break;
      case CSSValueID::kRound:
        DCHECK(RuntimeEnabledFeatures::CSSSteppedValueFunctionsEnabled());
        max_argument_count = 3;
        min_argument_count = 1;
        break;
      case CSSValueID::kMod:
      case CSSValueID::kRem:
        DCHECK(RuntimeEnabledFeatures::CSSSteppedValueFunctionsEnabled());
        max_argument_count = 2;
        min_argument_count = 2;
        break;
      case CSSValueID::kAtan2:
        max_argument_count = 2;
        min_argument_count = 2;
        break;
      case CSSValueID::kAbs:
      case CSSValueID::kSign:
        DCHECK(RuntimeEnabledFeatures::CSSSignRelatedFunctionsEnabled());
        max_argument_count = 1;
        min_argument_count = 1;
        break;
      // TODO(crbug.com/1284199): Support other math functions.
      default:
        break;
    }

    HeapVector<Member<const CSSMathExpressionNode>> nodes;
    // Parse the initial (optional) <rounding-strategy> argument to the round()
    // function.
    if (function_id == CSSValueID::kRound) {
      CSSMathExpressionNode* rounding_strategy = ParseRoundingStrategy(tokens);
      if (rounding_strategy) {
        nodes.push_back(rounding_strategy);
      }
    }

    while (!tokens.AtEnd() && nodes.size() < max_argument_count) {
      if (nodes.size()) {
        if (!css_parsing_utils::ConsumeCommaIncludingWhitespace(tokens)) {
          return nullptr;
        }
      }

      tokens.ConsumeWhitespace();
      CSSMathExpressionNode* node = ParseValueExpression(tokens, state);
      if (!node) {
        return nullptr;
      }

      nodes.push_back(node);
    }

    if (!tokens.AtEnd() || nodes.size() < min_argument_count) {
      return nullptr;
    }

    switch (function_id) {
      case CSSValueID::kCalc:
      case CSSValueID::kWebkitCalc: {
        const CSSMathExpressionNode* node = nodes.front();
        if (node->Category() == kCalcIntrinsicSize) {
          return nullptr;
        }
        return const_cast<CSSMathExpressionNode*>(node);
      }
      case CSSValueID::kMin:
      case CSSValueID::kMax:
      case CSSValueID::kClamp: {
        CSSMathOperator op = CSSMathOperator::kMin;
        if (function_id == CSSValueID::kMax) {
          op = CSSMathOperator::kMax;
        }
        if (function_id == CSSValueID::kClamp) {
          op = CSSMathOperator::kClamp;
        }
        CSSMathExpressionNode* node =
            CSSMathExpressionOperation::CreateComparisonFunctionSimplified(
                std::move(nodes), op);
        if (node) {
          context_.Count(WebFeature::kCSSComparisonFunctions);
        }
        return node;
      }
      case CSSValueID::kSin:
      case CSSValueID::kCos:
      case CSSValueID::kTan:
      case CSSValueID::kAsin:
      case CSSValueID::kAcos:
      case CSSValueID::kAtan:
      case CSSValueID::kAtan2:
        return CSSMathExpressionOperation::
            CreateTrigonometricFunctionSimplified(std::move(nodes),
                                                  function_id);
      case CSSValueID::kPow:
      case CSSValueID::kSqrt:
      case CSSValueID::kHypot:
      case CSSValueID::kLog:
      case CSSValueID::kExp:
        DCHECK(RuntimeEnabledFeatures::CSSExponentialFunctionsEnabled());
        return CSSMathExpressionOperation::CreateExponentialFunction(
            std::move(nodes), function_id);
      case CSSValueID::kRound:
      case CSSValueID::kMod:
      case CSSValueID::kRem: {
        DCHECK(RuntimeEnabledFeatures::CSSSteppedValueFunctionsEnabled());
        CSSMathOperator op;
        if (function_id == CSSValueID::kRound) {
          DCHECK_GE(nodes.size(), 1u);
          DCHECK_LE(nodes.size(), 3u);
          // If the first argument is a rounding strategy, use the specified
          // operation and drop the argument from the list of operands.
          const auto* maybe_rounding_strategy =
              DynamicTo<CSSMathExpressionOperation>(*nodes[0]);
          if (maybe_rounding_strategy &&
              maybe_rounding_strategy->IsRoundingStrategyKeyword()) {
            op = maybe_rounding_strategy->OperatorType();
            nodes.EraseAt(0);
          } else {
            op = CSSMathOperator::kRoundNearest;
          }
          if (!CanonicalizeRoundArguments(nodes)) {
            return nullptr;
          }
        } else if (function_id == CSSValueID::kMod) {
          op = CSSMathOperator::kMod;
        } else {
          op = CSSMathOperator::kRem;
        }
        DCHECK_EQ(nodes.size(), 2u);
        return CSSMathExpressionOperation::CreateSteppedValueFunction(
            std::move(nodes), op);
      }
      case CSSValueID::kAbs:
      case CSSValueID::kSign:
        // TODO(seokho): Relative and Percent values cannot be evaluated at the
        // parsing time. So we should implement cannot be simplified value
        // using CalculationExpressionNode
        DCHECK(RuntimeEnabledFeatures::CSSSignRelatedFunctionsEnabled());
        return CSSMathExpressionOperation::CreateSignRelatedFunction(
            std::move(nodes), function_id);

      // TODO(crbug.com/1284199): Support other math functions.
      default:
        return nullptr;
    }
  }

 private:
  CSSMathExpressionNode* ParseValue(CSSParserTokenRange& tokens, State state) {
    CSSParserToken token = tokens.ConsumeIncludingWhitespace();
    if (token.Id() == CSSValueID::kInfinity) {
      return CSSMathExpressionNumericLiteral::Create(
          std::numeric_limits<double>::infinity(),
          CSSPrimitiveValue::UnitType::kNumber);
    }
    if (token.Id() == CSSValueID::kNegativeInfinity) {
      return CSSMathExpressionNumericLiteral::Create(
          -std::numeric_limits<double>::infinity(),
          CSSPrimitiveValue::UnitType::kNumber);
    }
    if (token.Id() == CSSValueID::kNan) {
      return CSSMathExpressionNumericLiteral::Create(
          std::numeric_limits<double>::quiet_NaN(),
          CSSPrimitiveValue::UnitType::kNumber);
    }
    if (token.Id() == CSSValueID::kPi) {
      return CSSMathExpressionNumericLiteral::Create(
          M_PI, CSSPrimitiveValue::UnitType::kNumber);
    }
    if (token.Id() == CSSValueID::kE) {
      return CSSMathExpressionNumericLiteral::Create(
          M_E, CSSPrimitiveValue::UnitType::kNumber);
    }
    if (state.allow_size_keyword && token.Id() == CSSValueID::kSize) {
      return CSSMathExpressionKeywordLiteral::Create(
          CSSValueID::kSize,
          CSSMathExpressionKeywordLiteral::Context::kCalcSize);
    }
    if (!(token.GetType() == kNumberToken ||
          (token.GetType() == kPercentageToken &&
           parsing_flags_.Has(Flag::AllowPercent)) ||
          token.GetType() == kDimensionToken)) {
      // For relative color syntax. Swap in the associated value of a color
      // channel here. e.g. color(from color(srgb 1 0 0) calc(r * 2) 0 0) should
      // swap in "1" for the value of "r" in the calc expression.
      if (color_channel_map_.Contains(token.Id())) {
        return CSSMathExpressionNumericLiteral::Create(
            color_channel_map_.at(token.Id()),
            CSSPrimitiveValue::UnitType::kNumber);
      }
      return nullptr;
    }

    CSSPrimitiveValue::UnitType type = token.GetUnitType();
    if (UnitCategory(type) == kCalcOther) {
      return nullptr;
    }

    return CSSMathExpressionNumericLiteral::Create(
        CSSNumericLiteralValue::Create(token.NumericValue(), type));
  }

  CSSMathExpressionNode* ParseRoundingStrategy(CSSParserTokenRange& tokens) {
    CSSMathOperator rounding_op = CSSMathOperator::kInvalid;
    switch (tokens.Peek().Id()) {
      case CSSValueID::kNearest:
        rounding_op = CSSMathOperator::kRoundNearest;
        break;
      case CSSValueID::kUp:
        rounding_op = CSSMathOperator::kRoundUp;
        break;
      case CSSValueID::kDown:
        rounding_op = CSSMathOperator::kRoundDown;
        break;
      case CSSValueID::kToZero:
        rounding_op = CSSMathOperator::kRoundToZero;
        break;
      default:
        return nullptr;
    }
    tokens.ConsumeIncludingWhitespace();
    return MakeGarbageCollected<CSSMathExpressionOperation>(
        CalculationResultCategory::kCalcNumber, rounding_op);
  }

  CSSMathExpressionNode* ParseValueTerm(CSSParserTokenRange& tokens,
                                        State state) {
    if (tokens.AtEnd()) {
      return nullptr;
    }

    if (tokens.Peek().GetType() == kLeftParenthesisToken ||
        tokens.Peek().FunctionId() == CSSValueID::kCalc) {
      CSSParserTokenRange inner_range = tokens.ConsumeBlock();
      tokens.ConsumeWhitespace();
      inner_range.ConsumeWhitespace();
      CSSMathExpressionNode* result = ParseValueExpression(inner_range, state);
      if (!result || !inner_range.AtEnd()) {
        return nullptr;
      }
      result->SetIsNestedCalc();
      return result;
    }

    if (tokens.Peek().GetType() == kFunctionToken) {
      CSSValueID function_id = tokens.Peek().FunctionId();
      CSSParserTokenRange inner_range = tokens.ConsumeBlock();
      tokens.ConsumeWhitespace();
      inner_range.ConsumeWhitespace();
      return ParseMathFunction(function_id, inner_range, state);
    }

    return ParseValue(tokens, state);
  }

  CSSMathExpressionNode* ParseValueMultiplicativeExpression(
      CSSParserTokenRange& tokens,
      State state) {
    if (tokens.AtEnd()) {
      return nullptr;
    }

    CSSMathExpressionNode* result = ParseValueTerm(tokens, state);
    if (!result) {
      return nullptr;
    }

    while (!tokens.AtEnd()) {
      CSSMathOperator math_operator = ParseCSSArithmeticOperator(tokens.Peek());
      if (math_operator != CSSMathOperator::kMultiply &&
          math_operator != CSSMathOperator::kDivide) {
        break;
      }
      tokens.ConsumeIncludingWhitespace();

      CSSMathExpressionNode* rhs = ParseValueTerm(tokens, state);
      if (!rhs) {
        return nullptr;
      }

      result = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
          result, rhs, math_operator);

      if (!result) {
        return nullptr;
      }
    }

    return result;
  }

  CSSMathExpressionNode* ParseAdditiveValueExpression(
      CSSParserTokenRange& tokens,
      State state) {
    if (tokens.AtEnd()) {
      return nullptr;
    }

    CSSMathExpressionNode* result =
        ParseValueMultiplicativeExpression(tokens, state);
    if (!result) {
      return nullptr;
    }

    while (!tokens.AtEnd()) {
      CSSMathOperator math_operator = ParseCSSArithmeticOperator(tokens.Peek());
      if (math_operator != CSSMathOperator::kAdd &&
          math_operator != CSSMathOperator::kSubtract) {
        break;
      }
      if ((&tokens.Peek() - 1)->GetType() != kWhitespaceToken) {
        return nullptr;  // calc(1px+ 2px) is invalid
      }
      tokens.Consume();
      if (tokens.Peek().GetType() != kWhitespaceToken) {
        return nullptr;  // calc(1px +2px) is invalid
      }
      tokens.ConsumeIncludingWhitespace();

      CSSMathExpressionNode* rhs =
          ParseValueMultiplicativeExpression(tokens, state);
      if (!rhs) {
        return nullptr;
      }

      result = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
          result, rhs, math_operator);

      if (!result) {
        return nullptr;
      }
    }

    if (auto* operation = DynamicTo<CSSMathExpressionOperation>(result)) {
      if (operation->IsAddOrSubtract()) {
        result = MaybeSimplifySumNode(operation);
      }
    }

    return result;
  }

  CSSMathExpressionKeywordLiteral* ParseKeywordLiteral(
      CSSParserTokenRange& tokens,
      CSSMathExpressionKeywordLiteral::Context context) {
    const CSSParserToken& token = tokens.ConsumeIncludingWhitespace();
    if (token.GetType() == kIdentToken) {
      return CSSMathExpressionKeywordLiteral::Create(token.Id(), context);
    }
    return nullptr;
  }

  CSSMathExpressionNode* ParseValueExpression(CSSParserTokenRange& tokens,
                                              State state) {
    if (++state.depth > kMaxExpressionDepth) {
      return nullptr;
    }
    return ParseAdditiveValueExpression(tokens, state);
  }

  const CSSParserContext& context_;
  const CSSAnchorQueryTypes allowed_anchor_queries_;
  const Flags parsing_flags_;
  const CSSColorChannelMap& color_channel_map_;
};

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionNode::Create(const CalculationValue& calc) {
  if (calc.IsExpression()) {
    return Create(*calc.GetOrCreateExpression());
  }
  return Create(calc.GetPixelsAndPercent());
}

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionNode::Create(PixelsAndPercent value) {
  double percent = value.percent;
  double pixels = value.pixels;
  if (!value.has_explicit_pixels) {
    assert(!pixels);
    return CSSMathExpressionNumericLiteral::Create(percent, CSSPrimitiveValue::UnitType::kPercentage);
  }
  if (!value.has_explicit_percent) {
    assert(!percent);
    return CSSMathExpressionNumericLiteral::Create(pixels, CSSPrimitiveValue::UnitType::kPixels);
  }
  CSSMathOperator op = CSSMathOperator::kAdd;
  if (pixels < 0) {
    pixels = -pixels;
    op = CSSMathOperator::kSubtract;
  }
  return CSSMathExpressionOperation::CreateArithmeticOperation(
      CSSMathExpressionNumericLiteral::Create(
          CSSNumericLiteralValue::Create(percent, CSSPrimitiveValue::UnitType::kPercentage)),
      CSSMathExpressionNumericLiteral::Create(
          CSSNumericLiteralValue::Create(pixels, CSSPrimitiveValue::UnitType::kPixels)),
      op);
}

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionNode::Create(const CalculationExpressionNode& node) {
  if (node.IsPixelsAndPercent()) {
    const auto& pixels_and_percent = To<CalculationExpressionPixelsAndPercentNode>(node);
    return Create(pixels_and_percent.GetPixelsAndPercent());
  }

  if (node.IsIdentifier()) {
    return CSSMathExpressionIdentifierLiteral::Create(To<CalculationExpressionIdentifierNode>(node).Value());
  }

  if (node.IsSizingKeyword()) {
    return CSSMathExpressionKeywordLiteral::Create(
        SizingKeywordToCSSValueID(To<CalculationExpressionSizingKeywordNode>(node).Value()),
        CSSMathExpressionKeywordLiteral::Context::kCalcSize);
  }

  if (node.IsNumber()) {
    return CSSMathExpressionNumericLiteral::Create(To<CalculationExpressionNumberNode>(node).Value(),
                                                   CSSPrimitiveValue::UnitType::kNumber);
  }

  assert(node.IsOperation());

  const auto& operation = To<CalculationExpressionOperationNode>(node);
  const auto& children = operation.GetChildren();
  const auto calc_op = operation.GetOperator();
  switch (calc_op) {
    case CalculationOperator::kMultiply: {
      assert(children.size() == 2u);
      return CSSMathExpressionOperation::CreateArithmeticOperation(Create(*children.front()), Create(*children.back()),
                                                                   CSSMathOperator::kMultiply);
    }
    case CalculationOperator::kAdd:
    case CalculationOperator::kSubtract: {
      assert(children.size() == 2u);
      auto lhs = Create(*children[0]);
      auto rhs = Create(*children[1]);
      CSSMathOperator op = (calc_op == CalculationOperator::kAdd) ? CSSMathOperator::kAdd : CSSMathOperator::kSubtract;
      return CSSMathExpressionOperation::CreateArithmeticOperation(lhs, rhs, op);
    }
    case CalculationOperator::kMin:
    case CalculationOperator::kMax: {
      assert(children.size());
      CSSMathExpressionOperation::Operands operands;
      for (const auto& child : children) {
        operands.push_back(Create(*child));
      }
      CSSMathOperator op = (calc_op == CalculationOperator::kMin) ? CSSMathOperator::kMin : CSSMathOperator::kMax;
      return CSSMathExpressionOperation::CreateComparisonFunction(std::move(operands), op);
    }
    case CalculationOperator::kClamp: {
      assert(children.size() == 3u);
      CSSMathExpressionOperation::Operands operands;
      for (const auto& child : children) {
        operands.push_back(Create(*child));
      }
      return CSSMathExpressionOperation::CreateComparisonFunction(std::move(operands), CSSMathOperator::kClamp);
    }
    case CalculationOperator::kRoundNearest:
    case CalculationOperator::kRoundUp:
    case CalculationOperator::kRoundDown:
    case CalculationOperator::kRoundToZero:
    case CalculationOperator::kMod:
    case CalculationOperator::kRem: {
      assert(children.size() == 2u);
      CSSMathExpressionOperation::Operands operands;
      for (const auto& child : children) {
        operands.push_back(Create(*child));
      }
      CSSMathOperator op;
      if (calc_op == CalculationOperator::kRoundNearest) {
        op = CSSMathOperator::kRoundNearest;
      } else if (calc_op == CalculationOperator::kRoundUp) {
        op = CSSMathOperator::kRoundUp;
      } else if (calc_op == CalculationOperator::kRoundDown) {
        op = CSSMathOperator::kRoundDown;
      } else if (calc_op == CalculationOperator::kRoundToZero) {
        op = CSSMathOperator::kRoundToZero;
      } else if (calc_op == CalculationOperator::kMod) {
        op = CSSMathOperator::kMod;
      } else {
        op = CSSMathOperator::kRem;
      }
      return CSSMathExpressionOperation::CreateSteppedValueFunction(std::move(operands), op);
    }
    case CalculationOperator::kHypot: {
      assert(children.size() > 1u);
      CSSMathExpressionOperation::Operands operands;
      for (const auto& child : children) {
        operands.push_back(Create(*child));
      }
      return CSSMathExpressionOperation::CreateExponentialFunction(std::move(operands), CSSValueID::kHypot);
    }
    case CalculationOperator::kAbs:
    case CalculationOperator::kSign: {
      assert(children.size() == 1u);
      CSSMathExpressionOperation::Operands operands;
      operands.push_back(Create(*children.front()));
      CSSValueID op = calc_op == CalculationOperator::kAbs ? CSSValueID::kAbs : CSSValueID::kSign;
      return CSSMathExpressionOperation::CreateSignRelatedFunction(std::move(operands), op);
    }
    case CalculationOperator::kProgress:
    case CalculationOperator::kMediaProgress:
    case CalculationOperator::kContainerProgress: {
      assert(children.size() == 3u);
      CSSMathExpressionOperation::Operands operands;
      operands.push_back(Create(*children.front()));
      operands.push_back(Create(*children[1]));
      operands.push_back(Create(*children.back()));
      CSSMathOperator op =
          calc_op == CalculationOperator::kProgress ? CSSMathOperator::kProgress : CSSMathOperator::kMediaProgress;
      return MakeGarbageCollected<CSSMathExpressionOperation>(CalculationResultCategory::kCalcNumber,
                                                              std::move(operands), op);
    }
    case CalculationOperator::kCalcSize: {
      assert(children.size() == 2u);
      return CSSMathExpressionOperation::CreateCalcSizeOperation(Create(*children.front()), Create(*children.back()));
    }
    case CalculationOperator::kInvalid:
      assert(false);
      return nullptr;
  }
}

CSSMathExpressionNode* CSSMathExpressionNode::ParseMathFunction(
    CSSValueID function_id,
    CSSParserTokenRange tokens,
    const CSSParserContext&,
    const CSSMathExpressionNode::Flags parsing_flags,
    CSSAnchorQueryTypes allowed_anchor_queries,
    const std::unordered_map<CSSValueID, double>& color_channel_keyword_values) {
  CSSMathExpressionNodeParser parser(context, parsing_flags,
                                     allowed_anchor_queries, color_channel_map);
  CSSMathExpressionNodeParser::State state;
  CSSMathExpressionNode* result =
      parser.ParseMathFunction(function_id, tokens, state);

  // TODO(pjh0718): Do simplificiation for result above.
  return result;
}

}  // namespace webf
