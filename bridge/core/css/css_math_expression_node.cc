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
#include "core/base/containers/enum_set.h"
#include "core/base/memory/shared_ptr.h"
#include "core/css/anchor_query.h"
#include "core/css/css_identifier_value.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/platform/geometry/calculation_expression_node.h"
#include "core/platform/geometry/math_functions.h"
#include "core/platform/geometry/sin_cos_degrees.h"
#include "core/platform/text/writing_mode_utils.h"
#include "css_color_channel_map.h"
#include "css_math_operator.h"
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

enum class ProgressArgsSimplificationStatus {
  kAllArgsResolveToCanonical,
  kAllArgsHaveSameType,
  kCanNotSimplify,
};

// Either all the arguments are numerics and have the same unit type (e.g.
// progress(1em from 0em to 1em)), or they are all numerics and can be resolved
// to the canonical unit (e.g. progress(1deg from 0rad to 1deg)). Note: this
// can't be eagerly simplified - progress(1em from 0px to 1em).
ProgressArgsSimplificationStatus CanEagerlySimplifyProgressArgs(const CSSMathExpressionOperation::Operands& operands) {
  if (std::all_of(operands.begin(), operands.end(), [](const std::shared_ptr<const CSSMathExpressionNode>& node) {
        return node->IsNumericLiteral() && node->ComputeValueInCanonicalUnit().has_value();
      })) {
    return ProgressArgsSimplificationStatus::kAllArgsResolveToCanonical;
  }
  if (std::all_of(operands.begin(), operands.end(), [&](const std::shared_ptr<const CSSMathExpressionNode>& node) {
        return node->IsNumericLiteral() && node->ResolvedUnitType() == operands.front()->ResolvedUnitType();
      })) {
    return ProgressArgsSimplificationStatus::kAllArgsHaveSameType;
  }
  return ProgressArgsSimplificationStatus::kCanNotSimplify;
}

using UnitsHashMap = std::unordered_map<CSSPrimitiveValue::UnitType, double>;

bool IsAllowedMediaFeature(const CSSValueID& id) {
  return id == CSSValueID::kWidth || id == CSSValueID::kHeight;
}

// TODO(crbug.com/40944203): For now we only support width and height
// size features.
bool IsAllowedContainerFeature(const CSSValueID& id) {
  return id == CSSValueID::kWidth || id == CSSValueID::kHeight;
}

bool CheckProgressFunctionTypes(CSSValueID function_id, const CSSMathExpressionOperation::Operands& nodes) {
  switch (function_id) {
    case CSSValueID::kProgress: {
      CalculationResultCategory first_category = nodes[0]->Category();
      if (first_category != nodes[1]->Category() || first_category != nodes[2]->Category() ||
          first_category == CalculationResultCategory::kCalcIntrinsicSize) {
        return false;
      }
      break;
    }
    // TODO(crbug.com/40944203): For now we only support kCalcLength media
    // features
    case CSSValueID::kMediaProgress: {
      if (!IsAllowedMediaFeature(To<CSSMathExpressionKeywordLiteral>(*nodes[0]).GetValue())) {
        return false;
      }
      if (nodes[1]->Category() != CalculationResultCategory::kCalcLength ||
          nodes[2]->Category() != CalculationResultCategory::kCalcLength) {
        return false;
      }
      break;
    }
    case CSSValueID::kContainerProgress: {
      if (!IsAllowedContainerFeature(To<CSSMathExpressionContainerFeature>(*nodes[0]).GetValue())) {
        return false;
      }
      if (nodes[1]->Category() != CalculationResultCategory::kCalcLength ||
          nodes[2]->Category() != CalculationResultCategory::kCalcLength) {
        return false;
      }
      break;
    }
    default:
      assert(false);
      break;
  }
  return true;
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

struct CSSMathExpressionNodeWithOperator {
  WEBF_DISALLOW_NEW();

 public:
  CSSMathOperator op;
  std::shared_ptr<const CSSMathExpressionNode> node;

  CSSMathExpressionNodeWithOperator(CSSMathOperator op, const std::shared_ptr<const CSSMathExpressionNode>& node)
      : op(op), node(node) {}

  void Trace(GCVisitor* visitor) const {}
};

CSSMathOperator MaybeChangeOperatorSignIfNesting(bool is_in_nesting,
                                                 CSSMathOperator outer_op,
                                                 CSSMathOperator current_op) {
  // For the cases like "a - (b + c)" we need to turn + c into - c.
  if (is_in_nesting && outer_op == CSSMathOperator::kSubtract && current_op == CSSMathOperator::kAdd) {
    return CSSMathOperator::kSubtract;
  }
  // For the cases like "a - (b - c)" we need to turn - c into + c.
  if (is_in_nesting && outer_op == CSSMathOperator::kSubtract && current_op == CSSMathOperator::kSubtract) {
    return CSSMathOperator::kAdd;
  }
  // No need to change the sign.
  return current_op;
}

bool IsNumericNodeWithDoubleValue(const CSSMathExpressionNode* node) {
  return node->IsNumericLiteral() && HasDoubleValue(node->ResolvedUnitType());
}

using UnitsVector = std::vector<CSSMathExpressionNodeWithOperator>;

// This function combines numeric values that have double value and are of the
// same unit type together in numeric_children and saves all the non add/sub
// operation children and their correct simplified operator in all_children.
void CombineNumericChildrenFromNode(const std::shared_ptr<const CSSMathExpressionNode>& root,
                                    CSSMathOperator op,
                                    UnitsHashMap& numeric_children,
                                    UnitsVector& all_children,
                                    bool is_in_nesting = false) {
  const CSSPrimitiveValue::UnitType unit_type = root->ResolvedUnitType();
  // Go deeper inside the operation node if possible.
  if (auto* operation = DynamicTo<CSSMathExpressionOperation>(root.get()); operation && operation->IsAddOrSubtract()) {
    const CSSMathOperator operation_op = operation->OperatorType();
    is_in_nesting |= operation->IsNestedCalc();
    // Nest from the left (first op) to the right (second op).
    CombineNumericChildrenFromNode(operation->GetOperands().front(), op, numeric_children, all_children, is_in_nesting);
    // Change the sign of expression, if we are nesting (inside brackets).
    op = MaybeChangeOperatorSignIfNesting(is_in_nesting, op, operation_op);
    CombineNumericChildrenFromNode(operation->GetOperands().back(), op, numeric_children, all_children, is_in_nesting);
    return;
  }
  // If we have numeric with double value - combine under one unit type.
  if (IsNumericNodeWithDoubleValue(root.get())) {
    double value = op == CSSMathOperator::kAdd ? root->DoubleValue() : -root->DoubleValue();
    if (auto it = numeric_children.find(unit_type); it != numeric_children.end()) {
      it->second += value;
    } else {
      numeric_children.insert(std::make_pair(unit_type, value));
    }
  }
  // Save all non add/sub operations.
  all_children.emplace_back(op, root);
}

CSSMathExpressionNodeWithOperator MaybeReplaceNodeWithCombined(const std::shared_ptr<const CSSMathExpressionNode>& node,
                                                               CSSMathOperator op,
                                                               const UnitsHashMap& units_map) {
  if (!node->IsNumericLiteral()) {
    return {op, node};
  }
  CSSPrimitiveValue::UnitType unit_type = node->ResolvedUnitType();
  auto it = units_map.find(unit_type);
  if (it != units_map.end()) {
    double value = it->second;
    CSSMathOperator new_op = value < 0.0f ? CSSMathOperator::kSubtract : CSSMathOperator::kAdd;
    std::shared_ptr<CSSMathExpressionNode> new_node =
        CSSMathExpressionNumericLiteral::Create(std::abs(value), unit_type);
    return {new_op, new_node};
  }
  return {op, node};
}

std::shared_ptr<const CSSMathExpressionNode> MaybeNegateFirstNode(
    CSSMathOperator op,
    const std::shared_ptr<const CSSMathExpressionNode>& node) {
  // If first node's operator is -, negate the value.
  if (IsNumericNodeWithDoubleValue(node.get()) && op == CSSMathOperator::kSubtract) {
    return CSSMathExpressionNumericLiteral::Create(-node->DoubleValue(), node->ResolvedUnitType());
  }
  return node;
}

// This function follows:
// https://drafts.csswg.org/css-values-4/#calc-simplification
// As in Blink the math expression tree is binary, we need to collect all the
// elements of this tree together and create a new tree as a result.
std::shared_ptr<CSSMathExpressionNode> MaybeSimplifySumNode(
    const std::shared_ptr<const CSSMathExpressionOperation>& root) {
  assert(root->IsAddOrSubtract());
  assert(root->GetOperands().size() == 2u);
  // Hash map of numeric literal values of the same type, that can be
  // combined.
  UnitsHashMap numeric_children;
  // Vector of all non add/sub operation children.
  UnitsVector all_children;
  // Collect all the numeric literal values together.
  // Note: using kAdd here as the operator for the first child
  // (e.g. a - b = +a - b, a + b = +a + b)
  CombineNumericChildrenFromNode(root, CSSMathOperator::kAdd, numeric_children, all_children);
  // Form the final node.
  std::unordered_set<CSSPrimitiveValue::UnitType> used_units;
  std::shared_ptr<CSSMathExpressionNode> final_node = nullptr;
  for (const auto& child : all_children) {
    auto [op, node] = MaybeReplaceNodeWithCombined(child.node, child.op, numeric_children);
    CSSPrimitiveValue::UnitType unit_type = node->ResolvedUnitType();
    // Skip already used unit types, as they have been already combined.
    if (IsNumericNodeWithDoubleValue(node.get())) {
      if (used_units.count(unit_type) > 0) {
        continue;
      }
      used_units.insert(unit_type);
    }
    if (!final_node) {
      // First child.
      final_node = MaybeNegateFirstNode(op, node)->Copy();
      continue;
    }
    final_node = std::make_shared<CSSMathExpressionOperation>(final_node, node, op, root->Category());
  }
  return final_node;
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

  CSSMathExpressionNodeParser(std::shared_ptr<const CSSParserContext> context,
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

  //  std::shared_ptr<const CSSMathExpressionNode> ParseAnchorQuery(CSSValueID function_id, CSSParserTokenRange& tokens)
  //  {
  //    CSSAnchorQueryType anchor_query_type;
  //    switch (function_id) {
  //      case CSSValueID::kAnchor:
  //        anchor_query_type = CSSAnchorQueryType::kAnchor;
  //        break;
  //      case CSSValueID::kAnchorSize:
  //        anchor_query_type = CSSAnchorQueryType::kAnchorSize;
  //        break;
  //      default:
  //        return nullptr;
  //    }
  //
  //    if (!(static_cast<CSSAnchorQueryTypes>(anchor_query_type) & allowed_anchor_queries_)) {
  //      return nullptr;
  //    }
  //
  //    // |anchor_specifier| may be omitted to represent the default anchor.
  //    auto anchor_specifier = css_parsing_utils::ConsumeDashedIdent(tokens, context_);
  //
  //    tokens.ConsumeWhitespace();
  //    std::shared_ptr<const CSSValue> value = nullptr;
  //    switch (anchor_query_type) {
  //      case CSSAnchorQueryType::kAnchor:
  //        value = css_parsing_utils::ConsumeIdent<CSSValueID::kInside, CSSValueID::kOutside, CSSValueID::kTop,
  //                                                CSSValueID::kLeft, CSSValueID::kRight, CSSValueID::kBottom,
  //                                                CSSValueID::kStart, CSSValueID::kEnd, CSSValueID::kSelfStart,
  //                                                CSSValueID::kSelfEnd, CSSValueID::kCenter>(tokens);
  //        if (!value) {
  //          value = css_parsing_utils::ConsumePercent(tokens, context_, CSSPrimitiveValue::ValueRange::kAll);
  //        }
  //        break;
  //      case CSSAnchorQueryType::kAnchorSize:
  //        value = css_parsing_utils::ConsumeIdent<CSSValueID::kWidth, CSSValueID::kHeight, CSSValueID::kBlock,
  //                                                CSSValueID::kInline, CSSValueID::kSelfBlock,
  //                                                CSSValueID::kSelfInline>(
  //            tokens);
  //        break;
  //    }
  //    if (!value) {
  //      return nullptr;
  //    }
  //
  //    std::shared_ptr<const CSSPrimitiveValue> fallback = nullptr;
  //    if (css_parsing_utils::ConsumeCommaIncludingWhitespace(tokens)) {
  //      fallback =
  //          css_parsing_utils::ConsumeLengthOrPercent(tokens, context_, CSSPrimitiveValue::ValueRange::kAll,
  //                                                    css_parsing_utils::UnitlessQuirk::kForbid,
  //                                                    allowed_anchor_queries_);
  //      if (!fallback) {
  //        return nullptr;
  //      }
  //    }
  //
  //    tokens.ConsumeWhitespace();
  //    if (!tokens.AtEnd()) {
  //      return nullptr;
  //    }
  //    return std::make_shared<CSSMathExpressionAnchorQuery>(anchor_query_type, anchor_specifier, *value, fallback);
  //  }

  bool ParseProgressNotationFromTo(CSSParserTokenRange& tokens,
                                   State state,
                                   CSSMathExpressionOperation::Operands& nodes) {
    if (tokens.ConsumeIncludingWhitespace().Id() != CSSValueID::kFrom) {
      return false;
    }
    if (auto node = ParseValueExpression(tokens, state)) {
      nodes.emplace_back(node);
    }
    if (tokens.ConsumeIncludingWhitespace().Id() != CSSValueID::kTo) {
      return false;
    }
    if (auto node = ParseValueExpression(tokens, state)) {
      nodes.emplace_back(node);
    }
    return true;
  }

  // https://drafts.csswg.org/css-values-5/#progress-func
  // https://drafts.csswg.org/css-values-5/#media-progress-func
  // https://drafts.csswg.org/css-values-5/#container-progress-func
  std::shared_ptr<const CSSMathExpressionNode> ParseProgressNotation(CSSValueID function_id,
                                                                     CSSParserTokenRange& tokens,
                                                                     State state) {
    if (function_id != CSSValueID::kProgress && function_id != CSSValueID::kMediaProgress &&
        function_id != CSSValueID::kContainerProgress) {
      return nullptr;
    }
    // <media-progress()> = media-progress(<media-feature> from <calc-sum> to
    // <calc-sum>)
    CSSMathExpressionOperation::Operands nodes;
    tokens.ConsumeWhitespace();
    if (function_id == CSSValueID::kMediaProgress) {
      if (auto node = ParseKeywordLiteral(tokens, CSSMathExpressionKeywordLiteral::Context::kMediaProgress)) {
        nodes.emplace_back(node);
      }
    } else if (function_id == CSSValueID::kContainerProgress) {
      // <container-progress()> = container-progress(<size-feature> [ of
      // <container-name> ]? from <calc-sum> to <calc-sum>)
      auto size_feature = css_parsing_utils::ConsumeIdent(tokens);
      if (!size_feature) {
        return nullptr;
      }
      if (tokens.Peek().Id() == CSSValueID::kOf) {
        tokens.ConsumeIncludingWhitespace();
        auto container_name = css_parsing_utils::ConsumeCustomIdent(tokens, context_);
        if (!container_name) {
          return nullptr;
        }
        nodes.emplace_back(std::make_shared<CSSMathExpressionContainerFeature>(size_feature, container_name));
      } else {
        nodes.emplace_back(std::make_shared<CSSMathExpressionContainerFeature>(size_feature, nullptr));
      }
    } else if (auto node = ParseValueExpression(tokens, state)) {
      // <progress()> = progress(<calc-sum> from <calc-sum> to <calc-sum>)
      nodes.emplace_back(node);
    }
    if (!ParseProgressNotationFromTo(tokens, state, nodes)) {
      return nullptr;
    }
    if (nodes.size() != 3u || !tokens.AtEnd() || !CheckProgressFunctionTypes(function_id, nodes)) {
      return nullptr;
    }
    // Note: we don't need to resolve percents in such case,
    // as all the operands are numeric literals,
    // so p% / (t% - f%) will lose %.
    // Note: we can not simplify media-progress.
    ProgressArgsSimplificationStatus status = CanEagerlySimplifyProgressArgs(nodes);
    if (function_id == CSSValueID::kProgress && status != ProgressArgsSimplificationStatus::kCanNotSimplify) {
      std::vector<double> double_values;
      double_values.reserve(nodes.size());
      for (const std::shared_ptr<const CSSMathExpressionNode>& operand : nodes) {
        if (status == ProgressArgsSimplificationStatus::kAllArgsResolveToCanonical) {
          std::optional<double> canonical_value = operand->ComputeValueInCanonicalUnit();
          assert(canonical_value.has_value());
          double_values.push_back(canonical_value.value());
        } else {
          assert(HasDoubleValue(operand->ResolvedUnitType()));
          double_values.push_back(operand->DoubleValue());
        }
      }
      double progress_value = (double_values[0] - double_values[1]) / (double_values[2] - double_values[1]);
      return CSSMathExpressionNumericLiteral::Create(progress_value, CSSPrimitiveValue::UnitType::kNumber);
    }
    return std::make_shared<CSSMathExpressionOperation>(CalculationResultCategory::kCalcNumber, std::move(nodes),
                                                        CSSValueIDToCSSMathOperator(function_id));
  }

  std::shared_ptr<CSSMathExpressionNode> ParseCalcSize(CSSValueID function_id,
                                                       CSSParserTokenRange& tokens,
                                                       State state) {
    if (function_id != CSSValueID::kCalcSize || !parsing_flags_.Has(Flag::AllowCalcSize)) {
      return nullptr;
    }

    // TODO(https://crbug.com/313072): Restrict usage of calc-size() inside of
    // calc(), probably along the lines of
    // https://github.com/w3c/csswg-drafts/issues/626#issuecomment-1881898328

    tokens.ConsumeWhitespace();

    std::shared_ptr<CSSMathExpressionNode> basis = nullptr;

    CSSValueID id = tokens.Peek().Id();
    bool basis_is_any = id == CSSValueID::kAny;
    if (id != CSSValueID::kInvalid &&
        (id == CSSValueID::kAny || (id == CSSValueID::kAuto && parsing_flags_.Has(Flag::AllowAutoInCalcSize)) ||
         css_parsing_utils::ValidWidthOrHeightKeyword(id, context_))) {
      // Note: We don't want to accept 'none' (for 'max-*' properties) since
      // it's not meaningful for animation, since it's equivalent to infinity.
      tokens.ConsumeIncludingWhitespace();
      basis = std::const_pointer_cast<CSSMathExpressionKeywordLiteral>(
          CSSMathExpressionKeywordLiteral::Create(id, CSSMathExpressionKeywordLiteral::Context::kCalcSize));
    } else {
      basis = std::const_pointer_cast<CSSMathExpressionNode>(ParseValueExpression(tokens, state));
      if (!basis) {
        return nullptr;
      }
      // TODO(https://crbug.com/313072): If basis is a calc-size()
      // expression whose basis is 'any', set basis_is_any to true.
    }

    std::shared_ptr<CSSMathExpressionNode> calculation = nullptr;
    if (css_parsing_utils::ConsumeCommaIncludingWhitespace(tokens)) {
      state.allow_size_keyword = !basis_is_any;
      calculation = std::const_pointer_cast<CSSMathExpressionNode>(ParseValueExpression(tokens, state));
      if (!calculation) {
        return nullptr;
      }
    } else {
      // Handle the 1-argument form of calc-size().  Based on the discussion
      // in https://github.com/w3c/csswg-drafts/issues/10259 , eagerly convert
      // it to the two-argument form.
      bool argument_is_basis;
      if (basis->IsKeywordLiteral()) {
        assert(To<CSSMathExpressionKeywordLiteral>(basis.get())->GetContext() ==
               CSSMathExpressionKeywordLiteral::Context::kCalcSize);
        if (basis_is_any) {
          return nullptr;
        }
        argument_is_basis = true;
      } else {
        argument_is_basis = basis->IsOperation() &&
                            To<CSSMathExpressionOperation>(basis.get())->OperatorType() == CSSMathOperator::kCalcSize;
      }

      if (argument_is_basis) {
        calculation = CSSMathExpressionKeywordLiteral::Create(CSSValueID::kSize,
                                                              CSSMathExpressionKeywordLiteral::Context::kCalcSize);
      } else {
        std::swap(basis, calculation);
        basis = CSSMathExpressionKeywordLiteral::Create(CSSValueID::kAny,
                                                        CSSMathExpressionKeywordLiteral::Context::kCalcSize);
      }
    }

    return CSSMathExpressionOperation::CreateCalcSizeOperation(basis, calculation);
  }

  static bool CanonicalizeRoundArguments(CSSMathExpressionOperation::Operands& nodes) {
    if (nodes.size() == 2) {
      return true;
    }
    // If the type of A matches <number>, then B may be omitted, and defaults to
    // 1; omitting B is otherwise invalid.
    // (https://drafts.csswg.org/css-values-4/#round-func)
    if (nodes.size() == 1 && nodes[0]->Category() == CalculationResultCategory::kCalcNumber) {
      // Add B=1 to get the function on canonical form.
      nodes.push_back(CSSMathExpressionNumericLiteral::Create(1, CSSPrimitiveValue::UnitType::kNumber));
      return true;
    }
    return false;
  }

  std::shared_ptr<const CSSMathExpressionNode> ParseMathFunction(CSSValueID function_id,
                                                                 CSSParserTokenRange& tokens,
                                                                 State state) {
    if (!IsSupportedMathFunction(function_id)) {
      return nullptr;
    }
    if (auto progress = ParseProgressNotation(function_id, tokens, state)) {
      return progress;
    }
    if (auto calc_size = ParseCalcSize(function_id, tokens, state)) {
      return calc_size;
    }

    // "arguments" refers to comma separated ones.
    size_t min_argument_count = 1;
    size_t max_argument_count = std::numeric_limits<size_t>::max();

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
        max_argument_count = 2;
        min_argument_count = 2;
        break;
      case CSSValueID::kExp:
      case CSSValueID::kSqrt:
        max_argument_count = 1;
        break;
      case CSSValueID::kHypot:
        max_argument_count = kMaxExpressionDepth;
        break;
      case CSSValueID::kLog:
        max_argument_count = 2;
        break;
      case CSSValueID::kRound:
        max_argument_count = 3;
        min_argument_count = 1;
        break;
      case CSSValueID::kMod:
      case CSSValueID::kRem:
        max_argument_count = 2;
        min_argument_count = 2;
        break;
      case CSSValueID::kAtan2:
        max_argument_count = 2;
        min_argument_count = 2;
        break;
      case CSSValueID::kAbs:
      case CSSValueID::kSign:
        max_argument_count = 1;
        min_argument_count = 1;
        break;
      // TODO(crbug.com/1284199): Support other math functions.
      default:
        break;
    }

    std::vector<std::shared_ptr<const CSSMathExpressionNode>> nodes;
    // Parse the initial (optional) <rounding-strategy> argument to the round()
    // function.
    if (function_id == CSSValueID::kRound) {
      std::shared_ptr<const CSSMathExpressionNode> rounding_strategy = ParseRoundingStrategy(tokens);
      if (rounding_strategy) {
        nodes.emplace_back(rounding_strategy);
      }
    }

    while (!tokens.AtEnd() && nodes.size() < max_argument_count) {
      if (!nodes.empty()) {
        if (!css_parsing_utils::ConsumeCommaIncludingWhitespace(tokens)) {
          return nullptr;
        }
      }

      tokens.ConsumeWhitespace();
      auto node = ParseValueExpression(tokens, state);
      if (!node) {
        return nullptr;
      }

      nodes.emplace_back(node);
    }

    if (!tokens.AtEnd() || nodes.size() < min_argument_count) {
      return nullptr;
    }

    switch (function_id) {
      case CSSValueID::kCalc:
      case CSSValueID::kWebkitCalc: {
        auto node = nodes.front();
        if (node->Category() == kCalcIntrinsicSize) {
          return nullptr;
        }
        return std::const_pointer_cast<CSSMathExpressionNode>(node);
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
        auto node = CSSMathExpressionOperation::CreateComparisonFunctionSimplified(std::move(nodes), op);
        return node;
      }
      case CSSValueID::kSin:
      case CSSValueID::kCos:
      case CSSValueID::kTan:
      case CSSValueID::kAsin:
      case CSSValueID::kAcos:
      case CSSValueID::kAtan:
      case CSSValueID::kAtan2:
        return CSSMathExpressionOperation::CreateTrigonometricFunctionSimplified(std::move(nodes), function_id);
      case CSSValueID::kPow:
      case CSSValueID::kSqrt:
      case CSSValueID::kHypot:
      case CSSValueID::kLog:
      case CSSValueID::kExp:
        return CSSMathExpressionOperation::CreateExponentialFunction(std::move(nodes), function_id);
      case CSSValueID::kRound:
      case CSSValueID::kMod:
      case CSSValueID::kRem: {
        CSSMathOperator op;
        if (function_id == CSSValueID::kRound) {
          DCHECK_GE(nodes.size(), 1u);
          DCHECK_LE(nodes.size(), 3u);
          // If the first argument is a rounding strategy, use the specified
          // operation and drop the argument from the list of operands.
          const auto* maybe_rounding_strategy = DynamicTo<CSSMathExpressionOperation>(*nodes[0]);
          if (maybe_rounding_strategy && maybe_rounding_strategy->IsRoundingStrategyKeyword()) {
            op = maybe_rounding_strategy->OperatorType();
            nodes.erase(nodes.begin());
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
        assert(nodes.size() == 2u);
        return CSSMathExpressionOperation::CreateSteppedValueFunction(std::move(nodes), op);
      }
      case CSSValueID::kAbs:
      case CSSValueID::kSign:
        // TODO(seokho): Relative and Percent values cannot be evaluated at the
        // parsing time. So we should implement cannot be simplified value
        // using CalculationExpressionNode
        return CSSMathExpressionOperation::CreateSignRelatedFunction(std::move(nodes), function_id);

      // TODO(crbug.com/1284199): Support other math functions.
      default:
        return nullptr;
    }
  }

 private:
  std::shared_ptr<const CSSMathExpressionNode> ParseValue(CSSParserTokenRange& tokens, State state) {
    CSSParserToken token = tokens.ConsumeIncludingWhitespace();
    if (token.Id() == CSSValueID::kInfinity) {
      return CSSMathExpressionNumericLiteral::Create(std::numeric_limits<double>::infinity(),
                                                     CSSPrimitiveValue::UnitType::kNumber);
    }
    if (token.Id() == CSSValueID::kNegativeInfinity) {
      return CSSMathExpressionNumericLiteral::Create(-std::numeric_limits<double>::infinity(),
                                                     CSSPrimitiveValue::UnitType::kNumber);
    }
    if (token.Id() == CSSValueID::kNan) {
      return CSSMathExpressionNumericLiteral::Create(std::numeric_limits<double>::quiet_NaN(),
                                                     CSSPrimitiveValue::UnitType::kNumber);
    }
    if (token.Id() == CSSValueID::kPi) {
      return CSSMathExpressionNumericLiteral::Create(M_PI, CSSPrimitiveValue::UnitType::kNumber);
    }
    if (token.Id() == CSSValueID::kE) {
      return CSSMathExpressionNumericLiteral::Create(M_E, CSSPrimitiveValue::UnitType::kNumber);
    }
    if (state.allow_size_keyword && token.Id() == CSSValueID::kSize) {
      return CSSMathExpressionKeywordLiteral::Create(CSSValueID::kSize,
                                                     CSSMathExpressionKeywordLiteral::Context::kCalcSize);
    }
    if (!(token.GetType() == kNumberToken ||
          (token.GetType() == kPercentageToken && parsing_flags_.Has(Flag::AllowPercent)) ||
          token.GetType() == kDimensionToken)) {
      // For relative color syntax. Swap in the associated value of a color
      // channel here. e.g. color(from color(srgb 1 0 0) calc(r * 2) 0 0) should
      // swap in "1" for the value of "r" in the calc expression.
      if (color_channel_map_.count(token.Id()) > 0) {
        return CSSMathExpressionNumericLiteral::Create(color_channel_map_.at(token.Id()),
                                                       CSSPrimitiveValue::UnitType::kNumber);
      }
      return nullptr;
    }

    CSSPrimitiveValue::UnitType type = token.GetUnitType();
    if (UnitCategory(type) == kCalcOther) {
      return nullptr;
    }

    return CSSMathExpressionNumericLiteral::Create(CSSNumericLiteralValue::Create(token.NumericValue(), type));
  }

  std::shared_ptr<const CSSMathExpressionNode> ParseRoundingStrategy(CSSParserTokenRange& tokens) {
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
    return std::make_shared<CSSMathExpressionOperation>(CalculationResultCategory::kCalcNumber, rounding_op);
  }

  std::shared_ptr<const CSSMathExpressionNode> ParseValueTerm(CSSParserTokenRange& tokens, State state) {
    if (tokens.AtEnd()) {
      return nullptr;
    }

    if (tokens.Peek().GetType() == kLeftParenthesisToken || tokens.Peek().FunctionId() == CSSValueID::kCalc) {
      CSSParserTokenRange inner_range = tokens.ConsumeBlock();
      tokens.ConsumeWhitespace();
      inner_range.ConsumeWhitespace();
      auto result = std::const_pointer_cast<CSSMathExpressionNode>(ParseValueExpression(inner_range, state));
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

  std::shared_ptr<const CSSMathExpressionNode> ParseValueMultiplicativeExpression(CSSParserTokenRange& tokens,
                                                                                  State state) {
    if (tokens.AtEnd()) {
      return nullptr;
    }

    std::shared_ptr<const CSSMathExpressionNode> result = ParseValueTerm(tokens, state);
    if (!result) {
      return nullptr;
    }

    while (!tokens.AtEnd()) {
      CSSMathOperator math_operator = ParseCSSArithmeticOperator(tokens.Peek());
      if (math_operator != CSSMathOperator::kMultiply && math_operator != CSSMathOperator::kDivide) {
        break;
      }
      tokens.ConsumeIncludingWhitespace();

      std::shared_ptr<const CSSMathExpressionNode> rhs = ParseValueTerm(tokens, state);
      if (!rhs) {
        return nullptr;
      }

      result = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(result, rhs, math_operator);

      if (!result) {
        return nullptr;
      }
    }

    return result;
  }

  std::shared_ptr<const CSSMathExpressionNode> ParseAdditiveValueExpression(CSSParserTokenRange& tokens, State state) {
    if (tokens.AtEnd()) {
      return nullptr;
    }

    std::shared_ptr<CSSMathExpressionNode> result =
        std::const_pointer_cast<CSSMathExpressionNode>(ParseValueMultiplicativeExpression(tokens, state));
    if (!result) {
      return nullptr;
    }

    while (!tokens.AtEnd()) {
      CSSMathOperator math_operator = ParseCSSArithmeticOperator(tokens.Peek());
      if (math_operator != CSSMathOperator::kAdd && math_operator != CSSMathOperator::kSubtract) {
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

      std::shared_ptr<const CSSMathExpressionNode> rhs = ParseValueMultiplicativeExpression(tokens, state);
      if (!rhs) {
        return nullptr;
      }

      result = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(result, rhs, math_operator);

      if (!result) {
        return nullptr;
      }
    }

    if (auto* operation = DynamicTo<CSSMathExpressionOperation>(result.get())) {
      if (operation->IsAddOrSubtract()) {
        result = MaybeSimplifySumNode(reinterpret_pointer_cast<CSSMathExpressionOperation>(result));
      }
    }

    return result;
  }

  std::shared_ptr<CSSMathExpressionKeywordLiteral> ParseKeywordLiteral(
      CSSParserTokenRange& tokens,
      CSSMathExpressionKeywordLiteral::Context context) {
    const CSSParserToken& token = tokens.ConsumeIncludingWhitespace();
    if (token.GetType() == kIdentToken) {
      return CSSMathExpressionKeywordLiteral::Create(token.Id(), context);
    }
    return nullptr;
  }

  std::shared_ptr<const CSSMathExpressionNode> ParseValueExpression(CSSParserTokenRange& tokens, State state) {
    if (++state.depth > kMaxExpressionDepth) {
      return nullptr;
    }
    return ParseAdditiveValueExpression(tokens, state);
  }

  std::shared_ptr<const CSSParserContext> context_;
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

CSSValueID SizingKeywordToCSSValueID(CalculationExpressionSizingKeywordNode::Keyword keyword) {
  // This should match CSSValueIDToSizingKeyword above.
  switch (keyword) {
#define KEYWORD_CASE(kw)                                    \
  case CalculationExpressionSizingKeywordNode::Keyword::kw: \
    return CSSValueID::kw;

    KEYWORD_CASE(kAny)
    KEYWORD_CASE(kSize)
    KEYWORD_CASE(kAuto)
    KEYWORD_CASE(kMinContent)
    KEYWORD_CASE(kWebkitMinContent)
    KEYWORD_CASE(kMaxContent)
    KEYWORD_CASE(kWebkitMaxContent)
    KEYWORD_CASE(kFitContent)
    KEYWORD_CASE(kWebkitFitContent)
    KEYWORD_CASE(kWebkitFillAvailable)

#undef KEYWORD_CASE
  }

  assert(false);
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
      return std::make_shared<CSSMathExpressionOperation>(CalculationResultCategory::kCalcNumber, std::move(operands),
                                                          op);
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

const PixelsAndPercent CreateClampedSamePixelsAndPercent(float value) {
  return PixelsAndPercent(CSSValueClampingUtils::ClampLength(value), CSSValueClampingUtils::ClampLength(value),
                          /*has_explicit_pixels=*/true,
                          /*has_explicit_percent=*/true);
}

bool IsNaN(PixelsAndPercent value, bool allows_negative_percentage_reference) {
  if (std::isnan(value.pixels + value.percent) || (allows_negative_percentage_reference && std::isinf(value.percent))) {
    return true;
  }
  return false;
}

std::optional<PixelsAndPercent> EvaluateValueIfNaNorInfinity(
    std::shared_ptr<const webf::CalculationExpressionNode> value,
    bool allows_negative_percentage_reference) {
  // |input| is not needed because this function is just for handling
  // inf and NaN.
  float evaluated_value = value->Evaluate(1, {});
  if (!std::isfinite(evaluated_value)) {
    return CreateClampedSamePixelsAndPercent(evaluated_value);
  }
  if (allows_negative_percentage_reference) {
    evaluated_value = value->Evaluate(-1, {});
    if (!std::isfinite(evaluated_value)) {
      return CreateClampedSamePixelsAndPercent(evaluated_value);
    }
  }
  return std::nullopt;
}

std::shared_ptr<const CalculationValue> CSSMathExpressionNode::ToCalcValue(
    const CSSLengthResolver& length_resolver,
    Length::ValueRange range,
    bool allows_negative_percentage_reference) const {
  if (auto maybe_pixels_and_percent = ToPixelsAndPercent(length_resolver)) {
    // Clamping if pixels + percent could result in NaN. In special case,
    // inf px + inf % could evaluate to nan when
    // allows_negative_percentage_reference is true.
    if (IsNaN(*maybe_pixels_and_percent, allows_negative_percentage_reference)) {
      maybe_pixels_and_percent = CreateClampedSamePixelsAndPercent(std::numeric_limits<float>::quiet_NaN());
    } else {
      maybe_pixels_and_percent->pixels = CSSValueClampingUtils::ClampLength(maybe_pixels_and_percent->pixels);
      maybe_pixels_and_percent->percent = CSSValueClampingUtils::ClampLength(maybe_pixels_and_percent->percent);
    }
    return CalculationValue::Create(*maybe_pixels_and_percent, range);
  }

  auto value = ToCalculationExpression(length_resolver);
  std::optional<PixelsAndPercent> evaluated_value =
      EvaluateValueIfNaNorInfinity(value, allows_negative_percentage_reference);
  if (evaluated_value.has_value()) {
    return CalculationValue::Create(evaluated_value.value(), range);
  }
  return CalculationValue::CreateSimplified(value, range);
}

std::shared_ptr<const CSSMathExpressionNode> CSSMathExpressionNode::ParseMathFunction(
    CSSValueID function_id,
    CSSParserTokenRange tokens,
    std::shared_ptr<const CSSParserContext> context,
    const CSSMathExpressionNode::Flags parsing_flags,
    CSSAnchorQueryTypes allowed_anchor_queries,
    const std::unordered_map<CSSValueID, double>& color_channel_map) {
  CSSMathExpressionNodeParser parser(context, parsing_flags, allowed_anchor_queries, color_channel_map);
  CSSMathExpressionNodeParser::State state;
  auto result = parser.ParseMathFunction(function_id, tokens, state);
  // TODO(pjh0718): Do simplificiation for result above.
  return result;
}

// ------ Start of CSSMathExpressionNumericLiteral member functions ------

// static
std::shared_ptr<CSSMathExpressionNumericLiteral> CSSMathExpressionNumericLiteral::Create(
    std::shared_ptr<const CSSNumericLiteralValue> value) {
  return std::make_shared<CSSMathExpressionNumericLiteral>(std::move(value));
}

// static
std::shared_ptr<CSSMathExpressionNumericLiteral> CSSMathExpressionNumericLiteral::Create(
    double value,
    CSSPrimitiveValue::UnitType type) {
  return std::make_shared<CSSMathExpressionNumericLiteral>(CSSNumericLiteralValue::Create(value, type));
}

bool CanEagerlySimplify(const CSSMathExpressionNode* operand) {
  if (operand->IsOperation()) {
    return false;
  }

  switch (operand->Category()) {
    case CalculationResultCategory::kCalcNumber:
    case CalculationResultCategory::kCalcAngle:
    case CalculationResultCategory::kCalcTime:
    case CalculationResultCategory::kCalcFrequency:
    case CalculationResultCategory::kCalcResolution:
      return true;
    case CalculationResultCategory::kCalcLength:
      return !CSSPrimitiveValue::IsRelativeUnit(operand->ResolvedUnitType()) && !operand->IsAnchorQuery();
    default:
      return false;
  }
}

CSSMathExpressionNumericLiteral::CSSMathExpressionNumericLiteral(std::shared_ptr<const CSSNumericLiteralValue> value)
    : CSSMathExpressionNode(UnitCategory(value->GetType()),
                            false /* has_comparisons*/,
                            false /* has_anchor_functions*/,
                            false /* needs_tree_scope_population*/),
      value_(std::move(value)) {
  if (!value_->IsNumber() && CanEagerlySimplify(this)) {
    // "If root is a dimension that is not expressed in its canonical unit, and
    // there is enough information available to convert it to the canonical
    // unit, do so, and return the value."
    // https://w3c.github.io/csswg-drafts/css-values/#calc-simplification
    //
    // However, Numbers should not be eagerly simplified here since that would
    // result in converting Integers to Doubles (kNumber, canonical unit for
    // Numbers).

    value_ = value_->CreateCanonicalUnitValue();
  }
}

CSSPrimitiveValue::BoolStatus CSSMathExpressionNumericLiteral::IsNegative() const {
  std::optional<double> maybe_value = ComputeValueInCanonicalUnit();
  if (!maybe_value.has_value()) {
    return CSSPrimitiveValue::BoolStatus::kUnresolvable;
  }
  return maybe_value.value() < 0.0 ? CSSPrimitiveValue::BoolStatus::kTrue : CSSPrimitiveValue::BoolStatus::kFalse;
}

std::string CSSMathExpressionNumericLiteral::CustomCSSText() const {
  return value_->CssText();
}

std::shared_ptr<const CalculationExpressionNode> CSSMathExpressionNumericLiteral::ToCalculationExpression(
    const CSSLengthResolver& length_resolver) const {
  if (Category() == kCalcNumber) {
    return std::make_shared<CalculationExpressionNumberNode>(value_->DoubleValue());
  }
  return std::make_shared<CalculationExpressionPixelsAndPercentNode>(*ToPixelsAndPercent(length_resolver));
}

std::optional<PixelsAndPercent> CSSMathExpressionNumericLiteral::ToPixelsAndPercent(
    const CSSLengthResolver& length_resolver) const {
  switch (category_) {
    case kCalcLength:
      return PixelsAndPercent(value_->ComputeLengthPx(length_resolver), 0.0f,
                              /*has_explicit_pixels=*/true,
                              /*has_explicit_percent=*/false);
    case kCalcPercent:
      DCHECK(value_->IsPercentage());
      return PixelsAndPercent(0.0f, value_->GetDoubleValueWithoutClamping(),
                              /*has_explicit_pixels=*/false,
                              /*has_explicit_percent=*/true);
    case kCalcNumber:
      // TODO(alancutter): Stop treating numbers like pixels unconditionally
      // in calcs to be able to accomodate border-image-width
      // https://drafts.csswg.org/css-backgrounds-3/#the-border-image-width
      return PixelsAndPercent(value_->GetFloatValue() * length_resolver.Zoom(), 0.0f, /*has_explicit_pixels=*/true,
                              /*has_explicit_percent=*/false);
    default:
      NOTREACHED_IN_MIGRATION();
      return {};
  }
}

double CSSMathExpressionNumericLiteral::DoubleValue() const {
  if (HasDoubleValue(ResolvedUnitType())) {
    return value_->GetDoubleValueWithoutClamping();
  }
  NOTREACHED_IN_MIGRATION();
  return 0;
}

std::optional<double> CSSMathExpressionNumericLiteral::ComputeValueInCanonicalUnit() const {
  switch (category_) {
    case kCalcNumber:
    case kCalcPercent:
      return value_->DoubleValue();
    case kCalcLength:
      if (CSSPrimitiveValue::IsRelativeUnit(value_->GetType())) {
        return std::nullopt;
      }
      [[fallthrough]];
    case kCalcAngle:
    case kCalcTime:
    case kCalcFrequency:
    case kCalcResolution:
      return value_->DoubleValue() * CSSPrimitiveValue::ConversionToCanonicalUnitsScaleFactor(value_->GetType());
    default:
      return std::nullopt;
  }
}

std::optional<double> CSSMathExpressionNumericLiteral::ComputeValueInCanonicalUnit(
    const CSSLengthResolver& length_resolver) const {
  return value_->ComputeInCanonicalUnit(length_resolver);
}

double CSSMathExpressionNumericLiteral::ComputeDouble(const CSSLengthResolver& length_resolver) const {
  switch (category_) {
    case kCalcLength:
      return value_->ComputeLengthPx(length_resolver);
    case kCalcPercent:
    case kCalcNumber:
      return value_->DoubleValue();
    case kCalcAngle:
      return value_->ComputeDegrees();
    case kCalcTime:
      return value_->ComputeSeconds();
    case kCalcResolution:
      return value_->ComputeDotsPerPixel();
    case kCalcFrequency:
      return value_->ComputeInCanonicalUnit();
    case kCalcLengthFunction:
    case kCalcIntrinsicSize:
    case kCalcOther:
    case kCalcIdent:
      NOTREACHED_IN_MIGRATION();
      break;
  }
  NOTREACHED_IN_MIGRATION();
  return 0;
}

double CSSMathExpressionNumericLiteral::ComputeLengthPx(const CSSLengthResolver& length_resolver) const {
  switch (category_) {
    case kCalcLength:
      return value_->ComputeLengthPx(length_resolver);
    case kCalcNumber:
    case kCalcPercent:
    case kCalcAngle:
    case kCalcFrequency:
    case kCalcLengthFunction:
    case kCalcIntrinsicSize:
    case kCalcTime:
    case kCalcResolution:
    case kCalcOther:
    case kCalcIdent:
      NOTREACHED_IN_MIGRATION();
      break;
  }
  NOTREACHED_IN_MIGRATION();
  return 0;
}

bool CSSMathExpressionNumericLiteral::AccumulateLengthArray(CSSLengthArray& length_array, double multiplier) const {
  DCHECK_NE(Category(), kCalcNumber);
  return value_->AccumulateLengthArray(length_array, multiplier);
}

void CSSMathExpressionNumericLiteral::AccumulateLengthUnitTypes(CSSPrimitiveValue::LengthTypeFlags& types) const {
  value_->AccumulateLengthUnitTypes(types);
}

bool CSSMathExpressionNumericLiteral::operator==(const CSSMathExpressionNode& other) const {
  if (!other.IsNumericLiteral()) {
    return false;
  }

  return value_ == To<CSSMathExpressionNumericLiteral>(other).value_;
}

CSSPrimitiveValue::UnitType CSSMathExpressionNumericLiteral::ResolvedUnitType() const {
  return value_->GetType();
}

bool CSSMathExpressionNumericLiteral::IsComputationallyIndependent() const {
  return value_->IsComputationallyIndependent();
}

void CSSMathExpressionNumericLiteral::Trace(GCVisitor* visitor) const {
  CSSMathExpressionNode::Trace(visitor);
}

#if DCHECK_IS_ON()
bool CSSMathExpressionNumericLiteral::InvolvesPercentageComparisons() const {
  return false;
}
#endif

CSSPrimitiveValue::BoolStatus CSSMathExpressionNumericLiteral::ResolvesTo(double value) const {
  std::optional<double> maybe_value = ComputeValueInCanonicalUnit();
  if (!maybe_value.has_value()) {
    return CSSPrimitiveValue::BoolStatus::kUnresolvable;
  }
  return maybe_value.value() == value ? CSSPrimitiveValue::BoolStatus::kTrue : CSSPrimitiveValue::BoolStatus::kFalse;
}

// ------ Start of CSSMathExpressionIdentifierLiteral member functions -

CSSMathExpressionIdentifierLiteral::CSSMathExpressionIdentifierLiteral(std::string identifier)
    : CSSMathExpressionNode(UnitCategory(CSSPrimitiveValue::UnitType::kIdent),
                            false /* has_comparisons*/,
                            false /* has_anchor_unctions*/,
                            false /* needs_tree_scope_population*/),
      identifier_(std::move(identifier)) {}

std::shared_ptr<const CalculationExpressionNode> CSSMathExpressionIdentifierLiteral::ToCalculationExpression(
    const CSSLengthResolver&) const {
  return std::make_shared<CalculationExpressionIdentifierNode>(identifier_);
}

// ------ End of CSSMathExpressionIdentifierLiteral member functions ----

// ------ Start of CSSMathExpressionKeywordLiteral member functions -

namespace {

CalculationExpressionSizingKeywordNode::Keyword CSSValueIDToSizingKeyword(CSSValueID keyword) {
  // The keywords supported here should be the ones supported in
  // css_parsing_utils::ValidWidthOrHeightKeyword plus 'any', 'auto' and 'size'.

  // This should also match SizingKeywordToCSSValueID below.
  switch (keyword) {
#define KEYWORD_CASE(kw) \
  case CSSValueID::kw:   \
    return CalculationExpressionSizingKeywordNode::Keyword::kw;

    KEYWORD_CASE(kAny)
    KEYWORD_CASE(kSize)
    KEYWORD_CASE(kAuto)
    KEYWORD_CASE(kMinContent)
    KEYWORD_CASE(kWebkitMinContent)
    KEYWORD_CASE(kMaxContent)
    KEYWORD_CASE(kWebkitMaxContent)
    KEYWORD_CASE(kFitContent)
    KEYWORD_CASE(kWebkitFitContent)
    KEYWORD_CASE(kWebkitFillAvailable)

#undef KEYWORD_CASE

    default:
      break;
  }

  assert(false);
}

CSSValueID SizingKeywordToCSSValueID(CalculationExpressionSizingKeywordNode::Keyword keyword) {
  // This should match CSSValueIDToSizingKeyword above.
  switch (keyword) {
#define KEYWORD_CASE(kw)                                    \
  case CalculationExpressionSizingKeywordNode::Keyword::kw: \
    return CSSValueID::kw;

    KEYWORD_CASE(kAny)
    KEYWORD_CASE(kSize)
    KEYWORD_CASE(kAuto)
    KEYWORD_CASE(kMinContent)
    KEYWORD_CASE(kWebkitMinContent)
    KEYWORD_CASE(kMaxContent)
    KEYWORD_CASE(kWebkitMaxContent)
    KEYWORD_CASE(kFitContent)
    KEYWORD_CASE(kWebkitFitContent)
    KEYWORD_CASE(kWebkitFillAvailable)

#undef KEYWORD_CASE
  }

  assert(false);
}

CalculationResultCategory DetermineKeywordCategory(CSSValueID keyword,
                                                   CSSMathExpressionKeywordLiteral::Context context) {
  switch (context) {
    case CSSMathExpressionKeywordLiteral::Context::kMediaProgress:
      return kCalcLength;
    case CSSMathExpressionKeywordLiteral::Context::kCalcSize:
      return kCalcLengthFunction;
    case CSSMathExpressionKeywordLiteral::Context::kColorChannel:
      return kCalcNumber;
  };
}

}  // namespace

CSSMathExpressionKeywordLiteral::CSSMathExpressionKeywordLiteral(CSSValueID keyword, Context context)
    : CSSMathExpressionNode(DetermineKeywordCategory(keyword, context),
                            false /* has_comparisons*/,
                            false /* has_anchor_unctions*/,
                            false /* needs_tree_scope_population*/),
      keyword_(keyword),
      context_(context) {}

std::shared_ptr<const CalculationExpressionNode> CSSMathExpressionKeywordLiteral::ToCalculationExpression(
    const CSSLengthResolver& length_resolver) const {
  switch (context_) {
    case CSSMathExpressionKeywordLiteral::Context::kMediaProgress: {
      switch (keyword_) {
        case CSSValueID::kWidth:
          return std::make_shared<CalculationExpressionPixelsAndPercentNode>(
              PixelsAndPercent(length_resolver.ViewportWidth()));
        case CSSValueID::kHeight:
          return std::make_shared<CalculationExpressionPixelsAndPercentNode>(
              PixelsAndPercent(length_resolver.ViewportHeight()));
        default:
          assert(false);
      }
    }
    case CSSMathExpressionKeywordLiteral::Context::kCalcSize:
      return std::make_shared<CalculationExpressionSizingKeywordNode>(CSSValueIDToSizingKeyword(keyword_));
    case CSSMathExpressionKeywordLiteral::Context::kColorChannel:
      // TODO(crbug.com/325309578): Produce a CalculationExpressionNode-derived
      // object for color channel keywords.
      assert(false);
  };
}

std::optional<PixelsAndPercent> CSSMathExpressionKeywordLiteral::ToPixelsAndPercent(
    const CSSLengthResolver& length_resolver) const {
  switch (context_) {
    case CSSMathExpressionKeywordLiteral::Context::kMediaProgress:
      switch (keyword_) {
        case CSSValueID::kWidth:
          return PixelsAndPercent(length_resolver.ViewportWidth());
        case CSSValueID::kHeight:
          return PixelsAndPercent(length_resolver.ViewportHeight());
        default:
          assert(false);
      }
    case CSSMathExpressionKeywordLiteral::Context::kCalcSize:
    case CSSMathExpressionKeywordLiteral::Context::kColorChannel:
      return std::nullopt;
  }
}

double CSSMathExpressionKeywordLiteral::ComputeDouble(const CSSLengthResolver& length_resolver) const {
  switch (context_) {
    case CSSMathExpressionKeywordLiteral::Context::kMediaProgress: {
      switch (keyword_) {
        case CSSValueID::kWidth:
          return length_resolver.ViewportWidth();
        case CSSValueID::kHeight:
          return length_resolver.ViewportHeight();
        default:
          assert(false);
      }
    }
    case CSSMathExpressionKeywordLiteral::Context::kCalcSize:
    case CSSMathExpressionKeywordLiteral::Context::kColorChannel:
      assert(false);
  };
}

// ------ End of CSSMathExpressionKeywordLiteral member functions ----

// ------ Start of CSSMathExpressionOperation member functions ------

static const CalculationResultCategory kAddSubtractResult[kCalcOther][kCalcOther] = {
    /* CalcNumber */
    {kCalcNumber, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther,
     kCalcOther},
    /* CalcLength */
    {kCalcOther, kCalcLength, kCalcLengthFunction, kCalcLengthFunction, kCalcOther, kCalcOther, kCalcOther, kCalcOther,
     kCalcOther, kCalcOther},
    /* CalcPercent */
    {kCalcOther, kCalcLengthFunction, kCalcPercent, kCalcLengthFunction, kCalcOther, kCalcOther, kCalcOther, kCalcOther,
     kCalcOther, kCalcOther},
    /* CalcLengthFunction */
    {kCalcOther, kCalcLengthFunction, kCalcLengthFunction, kCalcLengthFunction, kCalcOther, kCalcOther, kCalcOther,
     kCalcOther, kCalcOther, kCalcOther},
    /* CalcIntrinsicSize */
    {kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther,
     kCalcOther},
    /* CalcAngle */
    {kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcAngle, kCalcOther, kCalcOther, kCalcOther,
     kCalcOther},
    /* CalcTime */
    {kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcTime, kCalcOther, kCalcOther,
     kCalcOther},
    /* CalcFrequency */
    {kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcFrequency, kCalcOther,
     kCalcOther},
    /* CalcResolution */
    {kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcResolution,
     kCalcOther},
    /* CalcIdent */
    {kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther, kCalcOther,
     kCalcOther},
};

static CalculationResultCategory DetermineCategory(const CSSMathExpressionNode& left_side,
                                                   const CSSMathExpressionNode& right_side,
                                                   CSSMathOperator op) {
  CalculationResultCategory left_category = left_side.Category();
  CalculationResultCategory right_category = right_side.Category();

  if (left_category == kCalcOther || right_category == kCalcOther) {
    return kCalcOther;
  }

  if (left_category == kCalcIntrinsicSize || right_category == kCalcIntrinsicSize) {
    return kCalcOther;
  }

  switch (op) {
    case CSSMathOperator::kAdd:
    case CSSMathOperator::kSubtract:
      return kAddSubtractResult[left_category][right_category];
    case CSSMathOperator::kMultiply:
      if (left_category != kCalcNumber && right_category != kCalcNumber) {
        return kCalcOther;
      }
      return left_category == kCalcNumber ? right_category : left_category;
    case CSSMathOperator::kDivide:
      if (right_category != kCalcNumber) {
        return kCalcOther;
      }
      return left_category;
    default:
      break;
  }

  NOTREACHED_IN_MIGRATION();
  return kCalcOther;
}

bool CSSMathExpressionOperation::AllOperandsAreNumeric() const {
  return std::all_of(operands_.begin(), operands_.end(),
                     [](const std::shared_ptr<const CSSMathExpressionNode>& op) { return op->IsNumericLiteral(); });
}

static CalculationResultCategory DetermineCalcSizeCategory(const CSSMathExpressionNode& left_side,
                                                           const CSSMathExpressionNode& right_side,
                                                           CSSMathOperator op) {
  CalculationResultCategory basis_category = left_side.Category();
  CalculationResultCategory calculation_category = right_side.Category();

  if ((basis_category == kCalcLength || basis_category == kCalcPercent || basis_category == kCalcLengthFunction ||
       basis_category == kCalcIntrinsicSize) &&
      (calculation_category == kCalcLength || calculation_category == kCalcPercent ||
       calculation_category == kCalcLengthFunction)) {
    return kCalcIntrinsicSize;
  }
  return kCalcOther;
}

static CalculationResultCategory DetermineComparisonCategory(const CSSMathExpressionOperation::Operands& operands) {
  DCHECK(!operands.empty());

  bool is_first = true;
  CalculationResultCategory category = kCalcOther;
  for (auto&& operand : operands) {
    if (is_first) {
      category = operand->Category();
    } else {
      category = kAddSubtractResult[category][operand->Category()];
    }

    is_first = false;
    if (category == kCalcOther) {
      break;
    }
  }

  return category;
}

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateArithmeticOperation(
    std::shared_ptr<const CSSMathExpressionNode> left_side,
    std::shared_ptr<const CSSMathExpressionNode> right_side,
    CSSMathOperator op) {
  DCHECK_NE(left_side->Category(), kCalcOther);
  DCHECK_NE(right_side->Category(), kCalcOther);

  CalculationResultCategory new_category = DetermineCategory(*left_side, *right_side, op);
  if (new_category == kCalcOther) {
    return nullptr;
  }

  return std::make_shared<CSSMathExpressionOperation>(std::move(left_side), std::move(right_side), op, new_category);
}

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateCalcSizeOperation(
    std::shared_ptr<const CSSMathExpressionNode> left_side,
    std::shared_ptr<const CSSMathExpressionNode> right_side) {
  DCHECK_NE(left_side->Category(), kCalcOther);
  DCHECK_NE(right_side->Category(), kCalcOther);

  const CSSMathOperator op = CSSMathOperator::kCalcSize;
  CalculationResultCategory new_category = DetermineCalcSizeCategory(*left_side, *right_side, op);
  if (new_category == kCalcOther) {
    return nullptr;
  }

  return std::make_shared<CSSMathExpressionOperation>(std::move(left_side), std::move(right_side), op, new_category);
}

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateComparisonFunction(Operands&& operands,
                                                                                            CSSMathOperator op) {
  DCHECK(op == CSSMathOperator::kMin || op == CSSMathOperator::kMax || op == CSSMathOperator::kClamp);

  CalculationResultCategory category = DetermineComparisonCategory(operands);
  if (category == kCalcOther) {
    return nullptr;
  }

  return std::make_shared<CSSMathExpressionOperation>(category, std::move(operands), op);
}

bool CanEagerlySimplify(const CSSMathExpressionOperation::Operands& operands) {
  for (auto&& operand : operands) {
    if (!CanEagerlySimplify(operand.get())) {
      return false;
    }
  }
  return true;
}

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateComparisonFunctionSimplified(
    Operands&& operands,
    CSSMathOperator op) {
  DCHECK(op == CSSMathOperator::kMin || op == CSSMathOperator::kMax || op == CSSMathOperator::kClamp);

  CalculationResultCategory category = DetermineComparisonCategory(operands);
  if (category == kCalcOther) {
    return nullptr;
  }

  if (CanEagerlySimplify(operands)) {
    std::vector<double> canonical_values;
    canonical_values.reserve(operands.size());
    for (auto&& operand : operands) {
      std::optional<double> canonical_value = operand->ComputeValueInCanonicalUnit();

      DCHECK(canonical_value.has_value());

      canonical_values.push_back(canonical_value.value());
    }

    CSSPrimitiveValue::UnitType canonical_unit = CSSPrimitiveValue::CanonicalUnit(operands.front()->ResolvedUnitType());

    return CSSMathExpressionNumericLiteral::Create(EvaluateOperator(canonical_values, op), canonical_unit);
  }

  if (operands.size() == 1) {
    return operands.front()->Copy();
  }

  return std::make_shared<CSSMathExpressionOperation>(category, std::move(operands), op);
}

// Helper function for parsing number value
static double ValueAsNumber(const CSSMathExpressionNode* node, bool& error) {
  if (node->Category() == kCalcNumber) {
    return node->DoubleValue();
  }
  error = true;
  return 0;
}

// Helper function for parsing trigonometric functions' parameter
static double ValueAsDegrees(const CSSMathExpressionNode* node, bool& error) {
  if (node->Category() == kCalcAngle) {
    return node->ComputeValueInCanonicalUnit().value();
  }
  return Rad2deg(ValueAsNumber(node, error));
}

namespace {

double TanDegrees(double degrees) {
  // Use table values for tan() if possible.
  // We pick a pretty arbitrary limit that should be safe.
  if (degrees > -90000000.0 && degrees < 90000000.0) {
    // Make sure 0, 45, 90, 135, 180, 225 and 270 degrees get exact results.
    double n45degrees = degrees / 45.0;
    int octant = static_cast<int>(n45degrees);
    if (octant == n45degrees) {
      constexpr double kTanN45[] = {
          /* 0deg */ 0.0,
          /* 45deg */ 1.0,
          /* 90deg */ std::numeric_limits<double>::infinity(),
          /* 135deg */ -1.0,
          /* 180deg */ 0.0,
          /* 225deg */ 1.0,
          /* 270deg */ -std::numeric_limits<double>::infinity(),
          /* 315deg */ -1.0,
      };
      return kTanN45[octant & 7];
    }
  }
  // Slow path for non-table cases.
  double x = Deg2rad(degrees);
  return std::tan(x);
}

}  // namespace

static bool SupportedCategoryForAtan2(const CalculationResultCategory category) {
  switch (category) {
    case kCalcNumber:
    case kCalcLength:
    case kCalcPercent:
    case kCalcTime:
    case kCalcFrequency:
    case kCalcAngle:
      return true;
    default:
      return false;
  }
}

static bool IsRelativeLength(CSSPrimitiveValue::UnitType type) {
  return CSSPrimitiveValue::IsRelativeUnit(type) && CSSPrimitiveValue::IsLength(type);
}

static double ResolveAtan2(const CSSMathExpressionNode* y_node, const CSSMathExpressionNode* x_node, bool& error) {
  const CalculationResultCategory category = y_node->Category();
  if (category != x_node->Category() || !SupportedCategoryForAtan2(category)) {
    error = true;
    return 0;
  }
  CSSPrimitiveValue::UnitType y_type = y_node->ResolvedUnitType();
  CSSPrimitiveValue::UnitType x_type = x_node->ResolvedUnitType();

  // TODO(crbug.com/1392594): We ignore parameters in complex relative units
  // (e.g., 1rem + 1px) until they can be supported.
  if (y_type == CSSPrimitiveValue::UnitType::kUnknown || x_type == CSSPrimitiveValue::UnitType::kUnknown) {
    error = true;
    return 0;
  }

  if (IsRelativeLength(y_type) || IsRelativeLength(x_type)) {
    // TODO(crbug.com/1392594): Relative length units are currently hard
    // to resolve. We ignore the units for now, so that
    // we can at least support the case where both operands have the same unit.
    double y = y_node->DoubleValue();
    double x = x_node->DoubleValue();
    return std::atan2(y, x);
  }
  auto y = y_node->ComputeValueInCanonicalUnit();
  auto x = x_node->ComputeValueInCanonicalUnit();
  return std::atan2(y.value(), x.value());
}

std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateTrigonometricFunctionSimplified(
    Operands&& operands,
    CSSValueID function_id) {
  double value;
  auto unit_type = CSSPrimitiveValue::UnitType::kUnknown;
  bool error = false;
  switch (function_id) {
    case CSSValueID::kSin: {
      DCHECK_EQ(operands.size(), 1u);
      unit_type = CSSPrimitiveValue::UnitType::kNumber;
      value = gfx::SinCosDegrees(ValueAsDegrees(operands[0].get(), error)).sin;
      break;
    }
    case CSSValueID::kCos: {
      DCHECK_EQ(operands.size(), 1u);
      unit_type = CSSPrimitiveValue::UnitType::kNumber;
      value = gfx::SinCosDegrees(ValueAsDegrees(operands[0].get(), error)).cos;
      break;
    }
    case CSSValueID::kTan: {
      DCHECK_EQ(operands.size(), 1u);
      unit_type = CSSPrimitiveValue::UnitType::kNumber;
      value = TanDegrees(ValueAsDegrees(operands[0].get(), error));
      break;
    }
    case CSSValueID::kAsin: {
      DCHECK_EQ(operands.size(), 1u);
      unit_type = CSSPrimitiveValue::UnitType::kDegrees;
      value = Rad2deg(std::asin(ValueAsNumber(operands[0].get(), error)));
      DCHECK(value >= -90 && value <= 90 || std::isnan(value));
      break;
    }
    case CSSValueID::kAcos: {
      DCHECK_EQ(operands.size(), 1u);
      unit_type = CSSPrimitiveValue::UnitType::kDegrees;
      value = Rad2deg(std::acos(ValueAsNumber(operands[0].get(), error)));
      DCHECK(value >= 0 && value <= 180 || std::isnan(value));
      break;
    }
    case CSSValueID::kAtan: {
      DCHECK_EQ(operands.size(), 1u);
      unit_type = CSSPrimitiveValue::UnitType::kDegrees;
      value = Rad2deg(std::atan(ValueAsNumber(operands[0].get(), error)));
      DCHECK(value >= -90 && value <= 90 || std::isnan(value));
      break;
    }
    case CSSValueID::kAtan2: {
      DCHECK_EQ(operands.size(), 2u);
      unit_type = CSSPrimitiveValue::UnitType::kDegrees;
      value = Rad2deg(ResolveAtan2(operands[0].get(), operands[1].get(), error));
      DCHECK(value >= -180 && value <= 180 || std::isnan(value));
      break;
    }
    default:
      return nullptr;
  }

  if (error) {
    return nullptr;
  }

  DCHECK_NE(unit_type, CSSPrimitiveValue::UnitType::kUnknown);
  return CSSMathExpressionNumericLiteral::Create(value, unit_type);
}

std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateSteppedValueFunction(Operands&& operands,
                                                                                              CSSMathOperator op) {
  DCHECK_EQ(operands.size(), 2u);
  if (operands[0]->Category() == kCalcOther || operands[1]->Category() == kCalcOther) {
    return nullptr;
  }
  CalculationResultCategory category = kAddSubtractResult[operands[0]->Category()][operands[1]->Category()];
  if (category == kCalcOther) {
    return nullptr;
  }
  if (CanEagerlySimplify(operands)) {
    std::optional<double> a = operands[0]->ComputeValueInCanonicalUnit();
    std::optional<double> b = operands[1]->ComputeValueInCanonicalUnit();
    DCHECK(a.has_value());
    DCHECK(b.has_value());
    double value = EvaluateSteppedValueFunction(op, a.value(), b.value());
    return CSSMathExpressionNumericLiteral::Create(
        value, CSSPrimitiveValue::CanonicalUnit(operands.front()->ResolvedUnitType()));
  }
  return std::make_shared<CSSMathExpressionOperation>(category, std::move(operands), op);
}

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateExponentialFunction(Operands&& operands,
                                                                                             CSSValueID function_id) {
  double value = 0;
  bool error = false;
  auto unit_type = CSSPrimitiveValue::UnitType::kNumber;
  switch (function_id) {
    case CSSValueID::kPow: {
      DCHECK_EQ(operands.size(), 2u);
      double a = ValueAsNumber(operands[0].get(), error);
      double b = ValueAsNumber(operands[1].get(), error);
      value = std::pow(a, b);
      break;
    }
    case CSSValueID::kSqrt: {
      DCHECK_EQ(operands.size(), 1u);
      double a = ValueAsNumber(operands[0].get(), error);
      value = std::sqrt(a);
      break;
    }
    case CSSValueID::kHypot: {
      DCHECK_GE(operands.size(), 1u);
      CalculationResultCategory category = DetermineComparisonCategory(operands);
      if (category == kCalcOther) {
        return nullptr;
      }
      if (CanEagerlySimplify(operands)) {
        for (auto&& operand : operands) {
          std::optional<double> a = operand->ComputeValueInCanonicalUnit();
          DCHECK(a.has_value());
          value = std::hypot(value, a.value());
        }
        unit_type = CSSPrimitiveValue::CanonicalUnit(operands.front()->ResolvedUnitType());
      } else {
        return std::make_shared<CSSMathExpressionOperation>(category, std::move(operands), CSSMathOperator::kHypot);
      }
      break;
    }
    case CSSValueID::kLog: {
      DCHECK_GE(operands.size(), 1u);
      DCHECK_LE(operands.size(), 2u);
      double a = ValueAsNumber(operands[0].get(), error);
      if (operands.size() == 2) {
        double b = ValueAsNumber(operands[1].get(), error);
        value = std::log2(a) / std::log2(b);
      } else {
        value = std::log(a);
      }
      break;
    }
    case CSSValueID::kExp: {
      DCHECK_EQ(operands.size(), 1u);
      double a = ValueAsNumber(operands[0].get(), error);
      value = std::exp(a);
      break;
    }
    default:
      return nullptr;
  }
  if (error) {
    return nullptr;
  }

  DCHECK_NE(unit_type, CSSPrimitiveValue::UnitType::kUnknown);
  return CSSMathExpressionNumericLiteral::Create(value, unit_type);
}

std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateSignRelatedFunction(Operands&& operands,
                                                                                             CSSValueID function_id) {
  std::shared_ptr<const CSSMathExpressionNode> operand = operands.front();

  if (operand->Category() == kCalcIntrinsicSize) {
    return nullptr;
  }

  switch (function_id) {
    case CSSValueID::kAbs: {
      if (CanEagerlySimplify(operand.get())) {
        const std::optional<double> opt = operand->ComputeValueInCanonicalUnit();
        DCHECK(opt.has_value());
        return CSSMathExpressionNumericLiteral::Create(std::abs(opt.value()), operand->ResolvedUnitType());
      }
      return std::make_shared<CSSMathExpressionOperation>(operand->Category(), std::move(operands),
                                                          CSSMathOperator::kAbs);
    }
    case CSSValueID::kSign: {
      if (CanEagerlySimplify(operand.get())) {
        const std::optional<double> opt = operand->ComputeValueInCanonicalUnit();
        DCHECK(opt.has_value());
        const double value = opt.value();
        const double signum = (value == 0 || std::isnan(value)) ? value : ((value > 0) ? 1 : -1);
        return CSSMathExpressionNumericLiteral::Create(signum, CSSPrimitiveValue::UnitType::kNumber);
      }
      return std::make_shared<CSSMathExpressionOperation>(kCalcNumber, std::move(operands), CSSMathOperator::kSign);
    }
    default:
      NOTREACHED_IN_MIGRATION();
      return nullptr;
  }
}

std::shared_ptr<CSSMathExpressionNode> MaybeDistributeArithmeticOperation(
    std::shared_ptr<const CSSMathExpressionNode> left_side,
    std::shared_ptr<const CSSMathExpressionNode> right_side,
    CSSMathOperator op) {
  if (op != CSSMathOperator::kMultiply && op != CSSMathOperator::kDivide) {
    return nullptr;
  }
  // NOTE: we should not simplify num * (fn + fn), all the operands inside
  // the sum should be numeric.
  // Case (Op1 + Op2) * Num.
  auto* left_operation = DynamicTo<CSSMathExpressionOperation>(left_side.get());
  auto* right_numeric = DynamicTo<CSSMathExpressionNumericLiteral>(right_side.get());
  if (left_operation && left_operation->IsAddOrSubtract() && left_operation->AllOperandsAreNumeric() && right_numeric &&
      right_numeric->Category() == CalculationResultCategory::kCalcNumber) {
    auto new_left_side = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
        left_operation->GetOperands().front(), right_side, op);
    auto new_right_side = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
        left_operation->GetOperands().back(), right_side, op);
    std::shared_ptr<CSSMathExpressionNode> operation = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
        new_left_side, new_right_side, left_operation->OperatorType());
    // Note: setting SetIsNestedCalc is needed, as we can be in this situation:
    // A - B * (C + D)
    //     /\/\/\/\/\ - we are B * (C + D)
    // and we don't know about the -, as it's another operation,
    // so make the simplified operation nested to end up with:
    // A - (B * C + B * D).
    operation->SetIsNestedCalc();
    return operation;
  }
  // Case Num * (Op1 + Op2). But don't do num / (Op1 + Op2), as it can invert
  // the type.
  auto* right_operation = DynamicTo<CSSMathExpressionOperation>(right_side.get());
  auto* left_numeric = DynamicTo<CSSMathExpressionNumericLiteral>(left_side.get());
  if (right_operation && right_operation->IsAddOrSubtract() && right_operation->AllOperandsAreNumeric() &&
      left_numeric && left_numeric->Category() == CalculationResultCategory::kCalcNumber &&
      op != CSSMathOperator::kDivide) {
    auto new_right_side = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
        left_side, right_operation->GetOperands().front(), op);
    auto new_left_side = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
        left_side, right_operation->GetOperands().back(), op);
    std::shared_ptr<CSSMathExpressionNode> operation = CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
        new_right_side, new_left_side, right_operation->OperatorType());
    // Note: setting SetIsNestedCalc is needed, as we can be in this situation:
    // A - (C + D) * B
    //     /\/\/\/\/\ - we are (C + D) * B
    // and we don't know about the -, as it's another operation,
    // so make the simplified operation nested to end up with:
    // A - (B * C + B * D).
    operation->SetIsNestedCalc();
    return operation;
  }
  return nullptr;
}

namespace {

inline std::shared_ptr<const CSSMathExpressionOperation> DynamicToCalcSize(
    std::shared_ptr<const CSSMathExpressionNode> node) {
  const CSSMathExpressionOperation* operation = DynamicTo<CSSMathExpressionOperation>(node.get());
  if (!operation || !operation->IsCalcSize()) {
    return nullptr;
  }
  return reinterpret_pointer_cast<const CSSMathExpressionOperation>(node);
}

inline bool CanArithmeticOperationBeSimplified(const CSSMathExpressionNode* left_side,
                                               const CSSMathExpressionNode* right_side) {
  return !left_side->IsOperation() && !right_side->IsOperation();
}

}  // namespace

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateArithmeticOperationSimplified(
    std::shared_ptr<const CSSMathExpressionNode> left_side,
    std::shared_ptr<const CSSMathExpressionNode> right_side,
    CSSMathOperator op) {
  DCHECK(op == CSSMathOperator::kAdd || op == CSSMathOperator::kSubtract || op == CSSMathOperator::kMultiply ||
         op == CSSMathOperator::kDivide);

  if (std::shared_ptr<CSSMathExpressionNode> result = MaybeDistributeArithmeticOperation(left_side, right_side, op)) {
    return result;
  }

  if (!CanArithmeticOperationBeSimplified(left_side.get(), right_side.get())) {
    return CreateArithmeticOperation(left_side, right_side, op);
  }

  CalculationResultCategory left_category = left_side->Category();
  CalculationResultCategory right_category = right_side->Category();
  DCHECK_NE(left_category, kCalcOther);
  DCHECK_NE(right_category, kCalcOther);

  // Simplify numbers.
  if (left_category == kCalcNumber && left_side->IsNumericLiteral() && right_category == kCalcNumber &&
      right_side->IsNumericLiteral()) {
    return CSSMathExpressionNumericLiteral::Create(
        EvaluateOperator({left_side->DoubleValue(), right_side->DoubleValue()}, op),
        CSSPrimitiveValue::UnitType::kNumber);
  }

  // Simplify addition and subtraction between same types.
  if (op == CSSMathOperator::kAdd || op == CSSMathOperator::kSubtract) {
    if (left_category == right_side->Category()) {
      CSSPrimitiveValue::UnitType left_type = left_side->ResolvedUnitType();
      if (HasDoubleValue(left_type)) {
        CSSPrimitiveValue::UnitType right_type = right_side->ResolvedUnitType();
        if (left_type == right_type) {
          return CSSMathExpressionNumericLiteral::Create(
              EvaluateOperator({left_side->DoubleValue(), right_side->DoubleValue()}, op), left_type);
        }
        CSSPrimitiveValue::UnitCategory left_unit_category = CSSPrimitiveValue::UnitTypeToUnitCategory(left_type);
        if (left_unit_category != CSSPrimitiveValue::kUOther &&
            left_unit_category == CSSPrimitiveValue::UnitTypeToUnitCategory(right_type)) {
          CSSPrimitiveValue::UnitType canonical_type =
              CSSPrimitiveValue::CanonicalUnitTypeForCategory(left_unit_category);
          if (canonical_type != CSSPrimitiveValue::UnitType::kUnknown) {
            double left_value =
                left_side->DoubleValue() * CSSPrimitiveValue::ConversionToCanonicalUnitsScaleFactor(left_type);
            double right_value =
                right_side->DoubleValue() * CSSPrimitiveValue::ConversionToCanonicalUnitsScaleFactor(right_type);
            return CSSMathExpressionNumericLiteral::Create(EvaluateOperator({left_value, right_value}, op),
                                                           canonical_type);
          }
        }
      }
    }
  } else {
    // Simplify multiplying or dividing by a number for simplifiable types.
    DCHECK(op == CSSMathOperator::kMultiply || op == CSSMathOperator::kDivide);
    const CSSMathExpressionNode* number_side = GetNumericLiteralSide(left_side.get(), right_side.get());
    if (!number_side) {
      return CreateArithmeticOperation(left_side, right_side, op);
    }
    if (number_side == left_side.get() && op == CSSMathOperator::kDivide) {
      return nullptr;
    }
    const CSSMathExpressionNode* other_side = left_side.get() == number_side ? right_side.get() : left_side.get();

    double number = number_side->DoubleValue();

    CSSPrimitiveValue::UnitType other_type = other_side->ResolvedUnitType();
    if (HasDoubleValue(other_type)) {
      return CSSMathExpressionNumericLiteral::Create(EvaluateOperator({other_side->DoubleValue(), number}, op),
                                                     other_type);
    }
  }

  return CreateArithmeticOperation(left_side, right_side, op);
}

namespace {

std::tuple<std::shared_ptr<const CSSMathExpressionNode>, size_t> SubstituteForSizeKeyword(
    const std::shared_ptr<const CSSMathExpressionNode>& source,
    const std::shared_ptr<const CSSMathExpressionNode>& size_substitution,
    size_t count_in_substitution) {
  CHECK_GT(count_in_substitution, 0u);
  if (const auto* operation = DynamicTo<CSSMathExpressionOperation>(source.get())) {
    using Operands = CSSMathExpressionOperation::Operands;
    const Operands& source_operands = operation->GetOperands();
    Operands dest_operands;
    dest_operands.reserve(source_operands.size());
    size_t total_substitution_count = 0;
    for (auto&& source_op : source_operands) {
      std::shared_ptr<const CSSMathExpressionNode> dest_op;
      size_t substitution_count;
      std::tie(dest_op, substitution_count) =
          SubstituteForSizeKeyword(source_op, size_substitution, count_in_substitution);
      CHECK_EQ(dest_op == source_op, substitution_count == 0);
      total_substitution_count += substitution_count;
      if (!dest_op || total_substitution_count > (1u << 16)) {
        // hit the size limit
        return std::make_tuple(nullptr, total_substitution_count);
      }
      dest_operands.push_back(dest_op);
    }

    if (total_substitution_count == 0) {
      // return the original rather than making a new one
      return std::make_tuple(source, 0);
    }

    return std::make_tuple(std::make_shared<CSSMathExpressionOperation>(operation->Category(), std::move(dest_operands),
                                                                        operation->OperatorType()),
                           total_substitution_count);
  }

  auto* literal = DynamicTo<CSSMathExpressionKeywordLiteral>(source.get());
  if (literal && literal->GetContext() == CSSMathExpressionKeywordLiteral::Context::kCalcSize &&
      literal->GetValue() == CSSValueID::kSize) {
    return std::make_tuple(size_substitution, count_in_substitution);
  }
  return std::make_tuple(source, 0);
}

}  // namespace

// Do substitution in order to produce a calc-size() whose basis is not
// another calc-size().
std::shared_ptr<const CSSMathExpressionNode> UnnestCalcSize(
    const std::shared_ptr<const CSSMathExpressionOperation>& calc_size_input) {
  DCHECK(calc_size_input->IsCalcSize());
  std::vector<std::shared_ptr<const CSSMathExpressionNode>> calculation_stack;
  std::shared_ptr<const CSSMathExpressionNode> innermost_basis = nullptr;
  std::shared_ptr<const CSSMathExpressionNode> current_result = nullptr;

  std::shared_ptr<const CSSMathExpressionOperation> current_calc_size = calc_size_input;
  while (true) {
    std::shared_ptr<const CSSMathExpressionNode> basis = current_calc_size->GetOperands()[0];
    std::shared_ptr<const CSSMathExpressionNode> calculation = current_calc_size->GetOperands()[1];
    std::shared_ptr<const CSSMathExpressionOperation> basis_calc_size = DynamicToCalcSize(basis);
    if (!basis_calc_size) {
      current_result = calculation;
      innermost_basis = basis;
      break;
    }
    calculation_stack.push_back(calculation);
    current_calc_size = basis_calc_size;
  }

  if (calculation_stack.empty()) {
    // No substitution is needed; return the original.
    return calc_size_input;
  }

  size_t substitution_count = 1;
  do {
    std::tie(current_result, substitution_count) = SubstituteForSizeKeyword(
        calculation_stack.back(), current_result, std::max(substitution_count, static_cast<size_t>(1u)));
    if (!current_result) {
      // too much expansion
      return nullptr;
    }
    calculation_stack.pop_back();
  } while (!calculation_stack.empty());

  return CSSMathExpressionOperation::CreateCalcSizeOperation(innermost_basis, current_result);
}

// static
std::shared_ptr<CSSMathExpressionNode> CSSMathExpressionOperation::CreateArithmeticOperationAndSimplifyCalcSize(
    std::shared_ptr<const CSSMathExpressionNode> left_side,
    std::shared_ptr<const CSSMathExpressionNode> right_side,
    CSSMathOperator op) {
  DCHECK(op == CSSMathOperator::kAdd || op == CSSMathOperator::kSubtract || op == CSSMathOperator::kMultiply ||
         op == CSSMathOperator::kDivide);

  // Merge calc-size() expressions to keep calc-size() always at the top level.
  std::shared_ptr<const CSSMathExpressionOperation> left_calc_size = DynamicToCalcSize(left_side);
  std::shared_ptr<const CSSMathExpressionOperation> right_calc_size = DynamicToCalcSize(right_side);
  if (left_calc_size) {
    if (right_calc_size) {
      if (op != CSSMathOperator::kAdd && op != CSSMathOperator::kSubtract) {
        return nullptr;
      }
      std::shared_ptr<const CSSMathExpressionNode> left_basis = left_calc_size->GetOperands()[0];
      std::shared_ptr<const CSSMathExpressionNode> right_basis = right_calc_size->GetOperands()[0];
      std::shared_ptr<const CSSMathExpressionNode> final_basis = nullptr;
      // If the bases are equal, or one of them is
      // any keyword, then we can interpolate only the calculations.
      if (*left_basis == *right_basis) {
        final_basis = left_basis;
      } else {
        if (DynamicToCalcSize(left_basis) || DynamicToCalcSize(right_basis)) {
          // If either value has a calc-size() as a basis, substitute to
          // produce an un-nested calc-size() and try again recursively (with
          // only one level of recursion possible).
          std::shared_ptr<const CSSMathExpressionNode> left_unnested = UnnestCalcSize(left_calc_size);
          std::shared_ptr<const CSSMathExpressionNode> right_unnested = UnnestCalcSize(right_calc_size);
          if (!left_unnested || !right_unnested) {
            // hit the expansion limit
            return nullptr;
          }
          return CreateArithmeticOperationAndSimplifyCalcSize(std::move(left_unnested), std::move(right_unnested), op);
        }

        auto is_any_keyword = [](const std::shared_ptr<const CSSMathExpressionNode>& node) -> bool {
          const auto* literal = DynamicTo<CSSMathExpressionKeywordLiteral>(node.get());
          return literal && literal->GetValue() == CSSValueID::kAny &&
                 literal->GetContext() == CSSMathExpressionKeywordLiteral::Context::kCalcSize;
        };
        if (is_any_keyword(left_basis)) {
          final_basis = right_basis;
        } else if (is_any_keyword(right_basis)) {
          final_basis = left_basis;
        }
      }
      std::shared_ptr<const CSSMathExpressionNode> left_calculation = left_calc_size->GetOperands()[1];
      std::shared_ptr<const CSSMathExpressionNode> right_calculation = right_calc_size->GetOperands()[1];
      if (final_basis) {
        return CreateCalcSizeOperation(final_basis,
                                       CreateArithmeticOperationSimplified(left_calculation, right_calculation, op));
      } else {
        // We need to interpolate between the values *following* substitution
        // of the basis in the calculation, because if we interpolate the two
        // separately we are likely to get nonlinear interpolation behavior
        // (since we would be interpolating two different things linearly and
        // then multiplying them together).
        CHECK(!DynamicToCalcSize(left_basis));
        CHECK(!DynamicToCalcSize(right_basis));

        auto is_sizing_keyword = [](const std::shared_ptr<const CSSMathExpressionNode>& node) -> bool {
          const auto* literal = DynamicTo<CSSMathExpressionKeywordLiteral>(node.get());
          if (!literal || literal->GetContext() != CSSMathExpressionKeywordLiteral::Context::kCalcSize) {
            return false;
          }
          CHECK(literal->GetValue() != CSSValueID::kAny);
          return true;
        };

        if (is_sizing_keyword(left_basis) || is_sizing_keyword(right_basis)) {
          // It's not possible to interpolate between incompatible
          // sizing keywords (theoretically hard), or between a sizing
          // keyword and a <calc-sum> (disallowed by the spec but could
          // be implemented in an extra 5-10 lines of code here, by
          // substituting on one side and using the basis from the other
          // side).
          return nullptr;
        }

        final_basis = CSSMathExpressionKeywordLiteral::Create(CSSValueID::kAny,
                                                              CSSMathExpressionKeywordLiteral::Context::kCalcSize);
        std::tie(right_calculation, std::ignore) = SubstituteForSizeKeyword(right_calculation, right_basis, 1);
        std::tie(left_calculation, std::ignore) = SubstituteForSizeKeyword(left_calculation, left_basis, 1);
        if (!right_calculation || !left_calculation) {
          // We hit the substitution limit (which would be surprising for
          // non-recursive substitution).
          return nullptr;
        }

        return CreateCalcSizeOperation(final_basis,
                                       CreateArithmeticOperationSimplified(left_calculation, right_calculation, op));
      }
    } else {
      std::shared_ptr<const CSSMathExpressionNode> left_basis = left_calc_size->GetOperands()[0];
      std::shared_ptr<const CSSMathExpressionNode> left_calculation = left_calc_size->GetOperands()[1];
      return CreateCalcSizeOperation(left_basis, CreateArithmeticOperationSimplified(left_calculation, right_side, op));
    }
  } else if (right_calc_size) {
    std::shared_ptr<const CSSMathExpressionNode> right_basis = right_calc_size->GetOperands()[0];
    std::shared_ptr<const CSSMathExpressionNode> right_calculation = right_calc_size->GetOperands()[1];
    return CreateCalcSizeOperation(right_basis, CreateArithmeticOperationSimplified(left_side, right_calculation, op));
  }

  return CreateArithmeticOperationSimplified(left_side, right_side, op);
}

CSSMathExpressionOperation::CSSMathExpressionOperation(std::shared_ptr<const CSSMathExpressionNode> left_side,
                                                       std::shared_ptr<const CSSMathExpressionNode> right_side,
                                                       CSSMathOperator op,
                                                       CalculationResultCategory category)
    : CSSMathExpressionNode(category,
                            left_side->HasComparisons() || right_side->HasComparisons(),
                            left_side->HasAnchorFunctions() || right_side->HasAnchorFunctions(),
                            !left_side->IsScopedValue() || !right_side->IsScopedValue()),
      operands_({std::move(left_side), std::move(right_side)}),
      operator_(op) {}

static bool AnyOperandHasComparisons(CSSMathExpressionOperation::Operands& operands) {
  for (auto&& operand : operands) {
    if (operand->HasComparisons()) {
      return true;
    }
  }
  return false;
}

static bool AnyOperandHasAnchorFunctions(CSSMathExpressionOperation::Operands& operands) {
  for (auto&& operand : operands) {
    if (operand->HasAnchorFunctions()) {
      return true;
    }
  }
  return false;
}

static bool AnyOperandNeedsTreeScopePopulation(CSSMathExpressionOperation::Operands& operands) {
  for (auto&& operand : operands) {
    if (!operand->IsScopedValue()) {
      return true;
    }
  }
  return false;
}

CSSMathExpressionOperation::CSSMathExpressionOperation(CalculationResultCategory category,
                                                       Operands&& operands,
                                                       CSSMathOperator op)
    : CSSMathExpressionNode(category,
                            IsComparison(op) || AnyOperandHasComparisons(operands),
                            AnyOperandHasAnchorFunctions(operands),
                            AnyOperandNeedsTreeScopePopulation(operands)),
      operands_(std::move(operands)),
      operator_(op) {}

CSSMathExpressionOperation::CSSMathExpressionOperation(CalculationResultCategory category, CSSMathOperator op)
    : CSSMathExpressionNode(category, IsComparison(op), false /*has_anchor_functions*/, false), operator_(op) {}

bool CSSMathExpressionOperation::HasPercentage() const {
  if (Category() == kCalcPercent) {
    return true;
  }
  if (Category() != kCalcLengthFunction && Category() != kCalcIntrinsicSize) {
    return false;
  }
  switch (operator_) {
    case CSSMathOperator::kProgress:
      return false;
    case CSSMathOperator::kCalcSize:
      DCHECK_EQ(operands_.size(), 2u);
      return operands_[0]->HasPercentage();
    default:
      break;
  }
  for (auto&& operand : operands_) {
    if (operand->HasPercentage()) {
      return true;
    }
  }
  return false;
}

bool CSSMathExpressionOperation::InvolvesLayout() const {
  if (Category() == kCalcPercent || Category() == kCalcLengthFunction) {
    return true;
  }
  for (auto&& operand : operands_) {
    if (operand->InvolvesLayout()) {
      return true;
    }
  }
  return false;
}

CSSPrimitiveValue::BoolStatus CSSMathExpressionOperation::IsNegative() const {
  std::optional<double> maybe_value = ComputeValueInCanonicalUnit();
  if (!maybe_value.has_value()) {
    return CSSPrimitiveValue::BoolStatus::kUnresolvable;
  }
  return maybe_value.value() < 0.0 ? CSSPrimitiveValue::BoolStatus::kTrue : CSSPrimitiveValue::BoolStatus::kFalse;
}

std::shared_ptr<const CalculationExpressionNode> CSSMathExpressionOperation::ToCalculationExpression(
    const CSSLengthResolver& length_resolver) const {
  switch (operator_) {
    case CSSMathOperator::kAdd:
      DCHECK_EQ(operands_.size(), 2u);
      return CalculationExpressionOperationNode::CreateSimplified(
          CalculationExpressionOperationNode::Children({operands_[0]->ToCalculationExpression(length_resolver),
                                                        operands_[1]->ToCalculationExpression(length_resolver)}),
          CalculationOperator::kAdd);
    case CSSMathOperator::kSubtract:
      DCHECK_EQ(operands_.size(), 2u);
      return CalculationExpressionOperationNode::CreateSimplified(
          CalculationExpressionOperationNode::Children({operands_[0]->ToCalculationExpression(length_resolver),
                                                        operands_[1]->ToCalculationExpression(length_resolver)}),
          CalculationOperator::kSubtract);
    case CSSMathOperator::kMultiply:
      DCHECK_EQ(operands_.size(), 2u);
      return CalculationExpressionOperationNode::CreateSimplified(
          {operands_.front()->ToCalculationExpression(length_resolver),
           operands_.back()->ToCalculationExpression(length_resolver)},
          CalculationOperator::kMultiply);
    case CSSMathOperator::kDivide:
      DCHECK_EQ(operands_.size(), 2u);
      DCHECK_EQ(operands_[1]->Category(), kCalcNumber);
      return CalculationExpressionOperationNode::CreateSimplified(
          CalculationExpressionOperationNode::Children(
              {operands_[0]->ToCalculationExpression(length_resolver),
               std::make_shared<CalculationExpressionNumberNode>(1.0 / operands_[1]->DoubleValue())}),
          CalculationOperator::kMultiply);
    case CSSMathOperator::kMin:
    case CSSMathOperator::kMax: {
      std::vector<std::shared_ptr<const CalculationExpressionNode>> operands;
      operands.reserve(operands_.size());
      for (auto&& operand : operands_) {
        operands.push_back(operand->ToCalculationExpression(length_resolver));
      }
      auto expression_operator =
          operator_ == CSSMathOperator::kMin ? CalculationOperator::kMin : CalculationOperator::kMax;
      return CalculationExpressionOperationNode::CreateSimplified(std::move(operands), expression_operator);
    }
    case CSSMathOperator::kClamp: {
      std::vector<std::shared_ptr<const CalculationExpressionNode>> operands;
      operands.reserve(operands_.size());
      for (auto&& operand : operands_) {
        operands.push_back(operand->ToCalculationExpression(length_resolver));
      }
      return CalculationExpressionOperationNode::CreateSimplified(std::move(operands), CalculationOperator::kClamp);
    }
    case CSSMathOperator::kRoundNearest:
    case CSSMathOperator::kRoundUp:
    case CSSMathOperator::kRoundDown:
    case CSSMathOperator::kRoundToZero:
    case CSSMathOperator::kMod:
    case CSSMathOperator::kRem:
    case CSSMathOperator::kHypot:
    case CSSMathOperator::kAbs:
    case CSSMathOperator::kSign:
    case CSSMathOperator::kProgress:
    case CSSMathOperator::kMediaProgress:
    case CSSMathOperator::kContainerProgress:
    case CSSMathOperator::kCalcSize: {
      std::vector<std::shared_ptr<const CalculationExpressionNode>> operands;
      operands.reserve(operands_.size());
      for (auto&& operand : operands_) {
        operands.push_back(operand->ToCalculationExpression(length_resolver));
      }
      CalculationOperator op;
      if (operator_ == CSSMathOperator::kRoundNearest) {
        op = CalculationOperator::kRoundNearest;
      } else if (operator_ == CSSMathOperator::kRoundUp) {
        op = CalculationOperator::kRoundUp;
      } else if (operator_ == CSSMathOperator::kRoundDown) {
        op = CalculationOperator::kRoundDown;
      } else if (operator_ == CSSMathOperator::kRoundToZero) {
        op = CalculationOperator::kRoundToZero;
      } else if (operator_ == CSSMathOperator::kMod) {
        op = CalculationOperator::kMod;
      } else if (operator_ == CSSMathOperator::kRem) {
        op = CalculationOperator::kRem;
      } else if (operator_ == CSSMathOperator::kHypot) {
        op = CalculationOperator::kHypot;
      } else if (operator_ == CSSMathOperator::kAbs) {
        op = CalculationOperator::kAbs;
      } else if (operator_ == CSSMathOperator::kSign) {
        op = CalculationOperator::kSign;
      } else if (operator_ == CSSMathOperator::kProgress) {
        op = CalculationOperator::kProgress;
      } else if (operator_ == CSSMathOperator::kMediaProgress) {
        op = CalculationOperator::kMediaProgress;
      } else if (operator_ == CSSMathOperator::kContainerProgress) {
        op = CalculationOperator::kContainerProgress;
      } else {
        CHECK(operator_ == CSSMathOperator::kCalcSize);
        op = CalculationOperator::kCalcSize;
      }
      return CalculationExpressionOperationNode::CreateSimplified(std::move(operands), op);
    }
    case CSSMathOperator::kInvalid:
      NOTREACHED_IN_MIGRATION();
      return nullptr;
  }
}

double CSSMathExpressionOperation::DoubleValue() const {
  DCHECK(HasDoubleValue(ResolvedUnitType()));
  std::vector<double> double_values;
  double_values.reserve(operands_.size());
  for (auto&& operand : operands_) {
    double_values.push_back(operand->DoubleValue());
  }
  return Evaluate(double_values);
}

std::optional<PixelsAndPercent> CSSMathExpressionOperation::ToPixelsAndPercent(
    const CSSLengthResolver& length_resolver) const {
  std::optional<PixelsAndPercent> result;
  switch (operator_) {
    case CSSMathOperator::kAdd:
    case CSSMathOperator::kSubtract: {
      DCHECK_EQ(operands_.size(), 2u);
      result = operands_[0]->ToPixelsAndPercent(length_resolver);
      if (!result) {
        return std::nullopt;
      }

      std::optional<PixelsAndPercent> other_side = operands_[1]->ToPixelsAndPercent(length_resolver);
      if (!other_side) {
        return std::nullopt;
      }
      if (operator_ == CSSMathOperator::kAdd) {
        result.value() += other_side.value();
      } else {
        result.value() -= other_side.value();
      }
      break;
    }
    case CSSMathOperator::kMultiply:
    case CSSMathOperator::kDivide: {
      DCHECK_EQ(operands_.size(), 2u);
      const CSSMathExpressionNode* number_side = GetNumericLiteralSide(operands_[0].get(), operands_[1].get());
      if (!number_side) {
        return std::nullopt;
      }
      const CSSMathExpressionNode* other_side =
          operands_[0].get() == number_side ? operands_[1].get() : operands_[0].get();
      result = other_side->ToPixelsAndPercent(length_resolver);
      if (!result) {
        return std::nullopt;
      }
      float number = number_side->DoubleValue();
      if (operator_ == CSSMathOperator::kDivide) {
        number = 1.0 / number;
      }
      result.value() *= number;
      break;
    }
    case CSSMathOperator::kCalcSize:
      // While it looks like we might be able to handle some calc-size() cases
      // here, we don't want to do because it would be difficult to avoid a
      // has_explicit_percent state inside the calculation propagating to the
      // result (which should not happen; only the has_explicit_percent state
      // from the basis should do so).
      return std::nullopt;
    case CSSMathOperator::kMin:
    case CSSMathOperator::kMax:
    case CSSMathOperator::kClamp:
    case CSSMathOperator::kRoundNearest:
    case CSSMathOperator::kRoundUp:
    case CSSMathOperator::kRoundDown:
    case CSSMathOperator::kRoundToZero:
    case CSSMathOperator::kMod:
    case CSSMathOperator::kRem:
    case CSSMathOperator::kHypot:
    case CSSMathOperator::kAbs:
    case CSSMathOperator::kSign:
    case CSSMathOperator::kProgress:
    case CSSMathOperator::kMediaProgress:
    case CSSMathOperator::kContainerProgress:
      return std::nullopt;
    case CSSMathOperator::kInvalid:
      NOTREACHED_IN_MIGRATION();
  }
  return result;
}

static bool HasCanonicalUnit(CalculationResultCategory category) {
  return category == kCalcNumber || category == kCalcLength || category == kCalcPercent || category == kCalcAngle ||
         category == kCalcTime || category == kCalcFrequency || category == kCalcResolution;
}

std::optional<double> CSSMathExpressionOperation::ComputeValueInCanonicalUnit() const {
  if (!HasCanonicalUnit(category_)) {
    return std::nullopt;
  }

  std::vector<double> double_values;
  double_values.reserve(operands_.size());
  for (auto&& operand : operands_) {
    std::optional<double> maybe_value = operand->ComputeValueInCanonicalUnit();
    if (!maybe_value) {
      return std::nullopt;
    }
    double_values.push_back(*maybe_value);
  }
  return Evaluate(double_values);
}

std::optional<double> CSSMathExpressionOperation::ComputeValueInCanonicalUnit(
    const CSSLengthResolver& length_resolver) const {
  if (!HasCanonicalUnit(category_)) {
    return std::nullopt;
  }

  std::vector<double> double_values;
  double_values.reserve(operands_.size());
  for (auto&& operand : operands_) {
    std::optional<double> maybe_value = operand->ComputeValueInCanonicalUnit(length_resolver);
    if (!maybe_value.has_value()) {
      return std::nullopt;
    }
    double_values.push_back(maybe_value.value());
  }
  return Evaluate(double_values);
}

double CSSMathExpressionOperation::ComputeLengthPx(const CSSLengthResolver& length_resolver) const {
  DCHECK(!HasPercentage());
  DCHECK_EQ(Category(), kCalcLength);
  return ComputeDouble(length_resolver);
}

bool CSSMathExpressionOperation::AccumulateLengthArray(CSSLengthArray& length_array, double multiplier) const {
  switch (operator_) {
    case CSSMathOperator::kAdd:
      DCHECK_EQ(operands_.size(), 2u);
      if (!operands_[0]->AccumulateLengthArray(length_array, multiplier)) {
        return false;
      }
      if (!operands_[1]->AccumulateLengthArray(length_array, multiplier)) {
        return false;
      }
      return true;
    case CSSMathOperator::kSubtract:
      DCHECK_EQ(operands_.size(), 2u);
      if (!operands_[0]->AccumulateLengthArray(length_array, multiplier)) {
        return false;
      }
      if (!operands_[1]->AccumulateLengthArray(length_array, -multiplier)) {
        return false;
      }
      return true;
    case CSSMathOperator::kMultiply:
      DCHECK_EQ(operands_.size(), 2u);
      DCHECK_NE((operands_[0]->Category() == kCalcNumber), (operands_[1]->Category() == kCalcNumber));
      if (operands_[0]->Category() == kCalcNumber) {
        return operands_[1]->AccumulateLengthArray(length_array, multiplier * operands_[0]->DoubleValue());
      } else {
        return operands_[0]->AccumulateLengthArray(length_array, multiplier * operands_[1]->DoubleValue());
      }
    case CSSMathOperator::kDivide:
      DCHECK_EQ(operands_.size(), 2u);
      DCHECK_EQ(operands_[1]->Category(), kCalcNumber);
      return operands_[0]->AccumulateLengthArray(length_array, multiplier / operands_[1]->DoubleValue());
    case CSSMathOperator::kMin:
    case CSSMathOperator::kMax:
    case CSSMathOperator::kClamp:
      // When comparison functions are involved, we can't resolve the expression
      // into a length array.
    case CSSMathOperator::kRoundNearest:
    case CSSMathOperator::kRoundUp:
    case CSSMathOperator::kRoundDown:
    case CSSMathOperator::kRoundToZero:
    case CSSMathOperator::kMod:
    case CSSMathOperator::kRem:
    case CSSMathOperator::kHypot:
    case CSSMathOperator::kAbs:
    case CSSMathOperator::kSign:
      // When stepped value functions are involved, we can't resolve the
      // expression into a length array.
    case CSSMathOperator::kProgress:
    case CSSMathOperator::kCalcSize:
    case CSSMathOperator::kMediaProgress:
    case CSSMathOperator::kContainerProgress:
      return false;
    case CSSMathOperator::kInvalid:
      NOTREACHED_IN_MIGRATION();
      return false;
  }
}

void CSSMathExpressionOperation::AccumulateLengthUnitTypes(CSSPrimitiveValue::LengthTypeFlags& types) const {
  for (auto&& operand : operands_) {
    operand->AccumulateLengthUnitTypes(types);
  }
}

bool CSSMathExpressionOperation::IsComputationallyIndependent() const {
  for (auto&& operand : operands_) {
    if (!operand->IsComputationallyIndependent()) {
      return false;
    }
  }
  return true;
}

using UnitsVectorHashMap = std::unordered_map<CSSPrimitiveValue::UnitType, std::shared_ptr<UnitsVector>>;

// This function collects numeric values that have double value
// in the numeric_children vector under the same type and saves all the complex
// children and their correct simplified operator in complex_children.
void CollectNumericChildrenFromNode(std::shared_ptr<const CSSMathExpressionNode> root,
                                    CSSMathOperator op,
                                    UnitsVectorHashMap& numeric_children,
                                    UnitsVector& complex_children,
                                    bool is_in_nesting = false) {
  // Go deeper inside the operation node if possible.
  if (auto* operation = DynamicTo<CSSMathExpressionOperation>(root.get()); operation && operation->IsAddOrSubtract()) {
    const CSSMathOperator operation_op = operation->OperatorType();
    is_in_nesting |= operation->IsNestedCalc();
    // Nest from the left (first op) to the right (second op).
    CollectNumericChildrenFromNode(operation->GetOperands().front(), op, numeric_children, complex_children,
                                   is_in_nesting);
    // Change the sign of expression, if we are nesting (inside brackets).
    op = MaybeChangeOperatorSignIfNesting(is_in_nesting, op, operation_op);
    CollectNumericChildrenFromNode(operation->GetOperands().back(), op, numeric_children, complex_children,
                                   is_in_nesting);
    return;
  }
  CSSPrimitiveValue::UnitType unit_type = root->ResolvedUnitType();
  // If we have numeric with double value - collect in numeric_children.
  if (IsNumericNodeWithDoubleValue(root.get())) {
    if (auto it = numeric_children.find(unit_type); it != numeric_children.end()) {
      it->second->emplace_back(op, root);
    } else {
      numeric_children.insert(
          std::make_pair(unit_type, std::make_shared<UnitsVector>(1, CSSMathExpressionNodeWithOperator(op, root))));
    }
    return;
  }
  // Save all non add/sub operations.
  complex_children.emplace_back(op, root);
}

std::shared_ptr<CSSMathExpressionNode> AddNodeToSumNode(std::shared_ptr<const CSSMathExpressionNode> sum_node,
                                                        const std::shared_ptr<const CSSMathExpressionNode>& node,
                                                        CSSMathOperator op) {
  // If the sum node is nullptr, create and return the numeric literal node.
  if (!sum_node) {
    return MaybeNegateFirstNode(op, node)->Copy();
  }
  // If the node is numeric with double values,
  // add the numeric literal node with |value| and
  // operator to match the value's sign.
  if (IsNumericNodeWithDoubleValue(node.get())) {
    double value = node->DoubleValue();
    auto new_node = CSSMathExpressionNumericLiteral::Create(std::abs(value), node->ResolvedUnitType());
    // Change the operator correctly.
    if (value < 0.0f && op == CSSMathOperator::kAdd) {
      // + -10 -> -10
      op = CSSMathOperator::kSubtract;
    } else if (value < 0.0f && op == CSSMathOperator::kSubtract) {
      // - -10 -> + 10.
      op = CSSMathOperator::kAdd;
    }
    return std::make_shared<CSSMathExpressionOperation>(sum_node, new_node, op, sum_node->Category());
  }
  // Add the node to the sum_node otherwise.
  return std::make_shared<CSSMathExpressionOperation>(sum_node, node, op, sum_node->Category());
}

std::shared_ptr<const CSSMathExpressionNode> AddNodesVectorToSumNode(
    std::shared_ptr<const CSSMathExpressionNode> sum_node,
    const UnitsVector& vector) {
  for (const auto& [op, node] : vector) {
    sum_node = AddNodeToSumNode(sum_node, node, op);
  }
  return sum_node;
}

// This function follows:
// https://drafts.csswg.org/css-values-4/#sort-a-calculations-children
// As in Blink the math expression tree is binary, we need to collect all the
// elements of this tree together and create a new tree as a result.
std::shared_ptr<const CSSMathExpressionNode> MaybeSortSumNode(std::shared_ptr<const CSSMathExpressionOperation> root) {
  CHECK(root->IsAddOrSubtract());
  CHECK_EQ(root->GetOperands().size(), 2u);
  // Hash map of vectors of numeric literal values with double value with the
  // same unit type.
  UnitsVectorHashMap numeric_children;
  // Vector of all non add/sub operation children.
  UnitsVector complex_children;
  // Collect all the numeric literal with double value in one vector.
  // Note: using kAdd here as the operator for the first child
  // (e.g. a - b = +a - b, a + b = +a + b)
  CollectNumericChildrenFromNode(root, CSSMathOperator::kAdd, numeric_children, complex_children, false);
  // Form the final node.
  std::shared_ptr<const CSSMathExpressionNode> final_node = nullptr;
  // From spec: If nodes contains a number, remove it from nodes and append it
  // to ret.
  if (auto it = numeric_children.find(CSSPrimitiveValue::UnitType::kNumber); it != numeric_children.end()) {
    final_node = AddNodesVectorToSumNode(final_node, *it->second);
    numeric_children.erase(it);
  }
  // From spec: If nodes contains a percentage, remove it from nodes and append
  // it to ret.
  if (auto it = numeric_children.find(CSSPrimitiveValue::UnitType::kPercentage); it != numeric_children.end()) {
    final_node = AddNodesVectorToSumNode(final_node, *it->second);
    numeric_children.erase(it);
  }
  // Now, sort the rest numeric values alphabatically.
  // From spec: If nodes contains any dimensions, remove them from nodes, sort
  // them by their units, ordered ASCII case-insensitively, and append them to
  // ret.
  auto comp = [&](const CSSPrimitiveValue::UnitType& key_a, const CSSPrimitiveValue::UnitType& key_b) {
    return strcmp(CSSPrimitiveValue::UnitTypeToString(key_a), CSSPrimitiveValue::UnitTypeToString(key_b)) < 0;
  };
  std::vector<CSSPrimitiveValue::UnitType> keys;
  keys.reserve(numeric_children.size());
  for (const auto& pair : numeric_children) {
    keys.push_back(pair.first);
  }
  std::sort(keys.begin(), keys.end(), comp);
  // Now, add those numeric nodes in the sorted order.
  for (const auto& unit_type : keys) {
    final_node = AddNodesVectorToSumNode(final_node, *numeric_children.at(unit_type));
  }
  // Now, add all the complex (non-numerics with double value) values.
  final_node = AddNodesVectorToSumNode(final_node, complex_children);
  return final_node;
}

static bool ShouldSerializeRoundingStep(const CSSMathExpressionOperation::Operands& operands) {
  // Omit the step (B) operand to round(...) if the type of A is <number> and
  // the step is the literal 1.
  if (operands[0]->Category() != CalculationResultCategory::kCalcNumber) {
    return true;
  }
  auto* literal = DynamicTo<CSSMathExpressionNumericLiteral>(*operands[1]);
  if (!literal) {
    return true;
  }
  const CSSNumericLiteralValue& literal_value = literal->GetValue();
  if (!literal_value.IsNumber() || literal_value.DoubleValue() != 1) {
    return true;
  }
  return false;
}

std::string CSSMathExpressionOperation::CustomCSSText() const {
  switch (operator_) {
    case CSSMathOperator::kAdd:
    case CSSMathOperator::kSubtract:
    case CSSMathOperator::kMultiply:
    case CSSMathOperator::kDivide: {
      DCHECK_EQ(operands_.size(), 2u);

      // As per
      // https://drafts.csswg.org/css-values-4/#sort-a-calculations-children
      // we should sort the dimensions of the sum node.
      std::shared_ptr<const CSSMathExpressionOperation> operation =
          std::static_pointer_cast<const CSSMathExpressionOperation>(shared_from_this());
      if (IsAddOrSubtract()) {
        std::shared_ptr<const CSSMathExpressionNode> node =
            MaybeSortSumNode(reinterpret_pointer_cast<const CSSMathExpressionOperation>(shared_from_this()));
        // Note: we can hit here, since CSS Typed OM doesn't currently follow
        // the same simplifications as CSS Values spec.
        // https://github.com/w3c/csswg-drafts/issues/9451
        if (!node->IsOperation()) {
          return node->CustomCSSText();
        }
        operation = std::static_pointer_cast<const CSSMathExpressionOperation>(node);
      }
      CSSMathOperator op = operation->OperatorType();
      const Operands& operands = operation->GetOperands();

      std::string result;

      // After all the simplifications we only need parentheses here for the
      // cases like: (lhs as unsimplified sum/sub) [* or /] rhs
      const bool left_side_needs_parentheses =
          IsMultiplyOrDivide() && operands.front()->IsOperation() &&
          To<CSSMathExpressionOperation>(operands.front().get())->IsAddOrSubtract();
      if (left_side_needs_parentheses) {
        result.append("(");
      }
      result.append(operands[0]->CustomCSSText());
      if (left_side_needs_parentheses) {
        result.append(")");
      }

      result.append(" ");
      result.append(ToString(op));
      result.append(" ");

      // After all the simplifications we only need parentheses here for the
      // cases like: lhs [* or /] (rhs as unsimplified sum/sub)
      const bool right_side_needs_parentheses =
          IsMultiplyOrDivide() && operands.back()->IsOperation() &&
          To<CSSMathExpressionOperation>(operands.back().get())->IsAddOrSubtract();
      if (right_side_needs_parentheses) {
        result.append("(");
      }
      result.append(operands[1]->CustomCSSText());
      if (right_side_needs_parentheses) {
        result.append(")");
      }

      return result;
    }
    case CSSMathOperator::kMin:
    case CSSMathOperator::kMax:
    case CSSMathOperator::kClamp:
    case CSSMathOperator::kMod:
    case CSSMathOperator::kRem:
    case CSSMathOperator::kHypot:
    case CSSMathOperator::kAbs:
    case CSSMathOperator::kSign:
    case CSSMathOperator::kCalcSize: {
      std::string result;
      result.append(ToString(operator_));
      result.append("(");
      result.append(operands_.front()->CustomCSSText());
      for (auto&& operand : SecondToLastOperands()) {
        result.append(", ");
        result.append(operand->CustomCSSText());
      }
      result.append(")");

      return result;
    }
    case CSSMathOperator::kRoundNearest:
    case CSSMathOperator::kRoundUp:
    case CSSMathOperator::kRoundDown:
    case CSSMathOperator::kRoundToZero: {
      std::string result;
      result.append(ToString(operator_));
      result.append("(");
      if (operator_ != CSSMathOperator::kRoundNearest) {
        result.append(ToRoundingStrategyString(operator_));
        result.append(", ");
      }
      result.append(operands_[0]->CustomCSSText());
      if (ShouldSerializeRoundingStep(operands_)) {
        result.append(", ");
        result.append(operands_[1]->CustomCSSText());
      }
      result.append(")");

      return result;
    }
    case CSSMathOperator::kProgress:
    case CSSMathOperator::kMediaProgress:
    case CSSMathOperator::kContainerProgress: {
      CHECK_EQ(operands_.size(), 3u);
      std::string result;
      result.append(ToString(operator_));
      result.append("(");
      result.append(operands_.front()->CustomCSSText());
      result.append(" from ");
      result.append(operands_[1]->CustomCSSText());
      result.append(" to ");
      result.append(operands_.back()->CustomCSSText());
      result.append(")");

      return result;
    }
    case CSSMathOperator::kInvalid:
      NOTREACHED_IN_MIGRATION();
      return "";
  }
}

bool CSSMathExpressionOperation::operator==(const CSSMathExpressionNode& exp) const {
  if (!exp.IsOperation()) {
    return false;
  }

  const CSSMathExpressionOperation& other = To<CSSMathExpressionOperation>(exp);
  if (operator_ != other.operator_) {
    return false;
  }
  if (operands_.size() != other.operands_.size()) {
    return false;
  }
  for (size_t i = 0; i < operands_.size(); ++i) {
    if ((operands_[i] != other.operands_[i])) {
      return false;
    }
  }
  return true;
}

CSSPrimitiveValue::UnitType CSSMathExpressionOperation::ResolvedUnitType() const {
  switch (category_) {
    case kCalcNumber:
      return CSSPrimitiveValue::UnitType::kNumber;
    case kCalcAngle:
    case kCalcTime:
    case kCalcFrequency:
    case kCalcLength:
    case kCalcPercent:
    case kCalcResolution:
      switch (operator_) {
        case CSSMathOperator::kMultiply:
        case CSSMathOperator::kDivide: {
          DCHECK_EQ(operands_.size(), 2u);
          if (operands_[0]->Category() == kCalcNumber) {
            return operands_[1]->ResolvedUnitType();
          }
          if (operands_[1]->Category() == kCalcNumber) {
            return operands_[0]->ResolvedUnitType();
          }
          NOTREACHED_IN_MIGRATION();
          return CSSPrimitiveValue::UnitType::kUnknown;
        }
        case CSSMathOperator::kAdd:
        case CSSMathOperator::kSubtract:
        case CSSMathOperator::kMin:
        case CSSMathOperator::kMax:
        case CSSMathOperator::kClamp:
        case CSSMathOperator::kRoundNearest:
        case CSSMathOperator::kRoundUp:
        case CSSMathOperator::kRoundDown:
        case CSSMathOperator::kRoundToZero:
        case CSSMathOperator::kMod:
        case CSSMathOperator::kRem:
        case CSSMathOperator::kHypot:
        case CSSMathOperator::kAbs: {
          CSSPrimitiveValue::UnitType first_type = operands_.front()->ResolvedUnitType();
          if (first_type == CSSPrimitiveValue::UnitType::kUnknown) {
            return CSSPrimitiveValue::UnitType::kUnknown;
          }
          for (auto&& operand : SecondToLastOperands()) {
            CSSPrimitiveValue::UnitType next = operand->ResolvedUnitType();
            if (next == CSSPrimitiveValue::UnitType::kUnknown || next != first_type) {
              return CSSPrimitiveValue::UnitType::kUnknown;
            }
          }
          return first_type;
        }
        case CSSMathOperator::kSign:
        case CSSMathOperator::kProgress:
        case CSSMathOperator::kMediaProgress:
        case CSSMathOperator::kContainerProgress:
          return CSSPrimitiveValue::UnitType::kNumber;
        case CSSMathOperator::kCalcSize: {
          DCHECK_EQ(operands_.size(), 2u);
          CSSPrimitiveValue::UnitType calculation_type = operands_[1]->ResolvedUnitType();
          if (calculation_type != CSSPrimitiveValue::UnitType::kIdent) {
            // The basis is not involved.
            return calculation_type;
          }
          // TODO(https://crbug.com/313072): We could in theory resolve the
          // 'size' keyword to produce a correct answer in more cases.
          return CSSPrimitiveValue::UnitType::kUnknown;
        }
        case CSSMathOperator::kInvalid:
          NOTREACHED_IN_MIGRATION();
          return CSSPrimitiveValue::UnitType::kUnknown;
      }
    case kCalcLengthFunction:
    case kCalcIntrinsicSize:
    case kCalcOther:
      return CSSPrimitiveValue::UnitType::kUnknown;
    case kCalcIdent:
      return CSSPrimitiveValue::UnitType::kIdent;
  }

  NOTREACHED_IN_MIGRATION();
  return CSSPrimitiveValue::UnitType::kUnknown;
}

std::shared_ptr<const CSSMathExpressionNode> CSSMathExpressionOperation::PopulateWithTreeScope(
    const TreeScope* tree_scope) const {
  Operands populated_operands;
  for (auto&& op : operands_) {
    populated_operands.emplace_back(op->EnsureScopedValue(tree_scope));
  }
  return std::make_shared<CSSMathExpressionOperation>(Category(), std::move(populated_operands), operator_);
}

std::shared_ptr<const CSSMathExpressionNode> CSSMathExpressionOperation::TransformAnchors(
    LogicalAxis logical_axis,
    const TryTacticTransform& transform,
    const WritingDirectionMode& writing_direction) const {
  Operands transformed_operands;
  for (auto&& op : operands_) {
    transformed_operands.push_back(op->TransformAnchors(logical_axis, transform, writing_direction));
  }
  if (transformed_operands != operands_) {
    return std::make_shared<CSSMathExpressionOperation>(Category(), std::move(transformed_operands), operator_);
  }
  return shared_from_this();
}

bool CSSMathExpressionOperation::HasInvalidAnchorFunctions(const CSSLengthResolver& length_resolver) const {
  for (auto&& op : operands_) {
    if (op->HasInvalidAnchorFunctions(length_resolver)) {
      return true;
    }
  }
  return false;
}

void CSSMathExpressionOperation::Trace(webf::GCVisitor* visitor) const {}

#if DCHECK_IS_ON()
bool CSSMathExpressionOperation::InvolvesPercentageComparisons() const {
  if (IsMinOrMax() && Category() == kCalcPercent && operands_.size() > 1u) {
    return true;
  }
  for (auto&& operand : operands_) {
    if (operand->InvolvesPercentageComparisons()) {
      return true;
    }
  }
  return false;
}
#endif

double CSSMathExpressionOperation::ComputeDouble(const CSSLengthResolver& length_resolver) const {
  std::vector<double> double_values;
  double_values.reserve(operands_.size());
  for (auto&& operand : operands_) {
    double_values.emplace_back(CSSMathExpressionNode::ComputeDouble(operand.get(), length_resolver));
  }
  return Evaluate(double_values);
}

CSSPrimitiveValue::BoolStatus CSSMathExpressionOperation::ResolvesTo(double value) const {
  std::optional<double> maybe_value = ComputeValueInCanonicalUnit();
  if (!maybe_value.has_value()) {
    return CSSPrimitiveValue::BoolStatus::kUnresolvable;
  }
  return maybe_value.value() == value ? CSSPrimitiveValue::BoolStatus::kTrue : CSSPrimitiveValue::BoolStatus::kFalse;
}

// static
const CSSMathExpressionNode* CSSMathExpressionOperation::GetNumericLiteralSide(
    const CSSMathExpressionNode* left_side,
    const CSSMathExpressionNode* right_side) {
  if (left_side->Category() == kCalcNumber && left_side->IsNumericLiteral()) {
    return left_side;
  }
  if (right_side->Category() == kCalcNumber && right_side->IsNumericLiteral()) {
    return right_side;
  }
  return nullptr;
}

// static
double CSSMathExpressionOperation::EvaluateOperator(const std::vector<double>& operands, CSSMathOperator op) {
  // Design doc for infinity and NaN: https://bit.ly/349gXjq

  // Any operation with at least one NaN argument produces NaN
  // https://drafts.csswg.org/css-values/#calc-type-checking
  for (double operand : operands) {
    if (std::isnan(operand)) {
      return operand;
    }
  }

  switch (op) {
    case CSSMathOperator::kAdd:
      DCHECK_EQ(operands.size(), 2u);
      return operands[0] + operands[1];
    case CSSMathOperator::kSubtract:
      DCHECK_EQ(operands.size(), 2u);
      return operands[0] - operands[1];
    case CSSMathOperator::kMultiply:
      DCHECK_EQ(operands.size(), 2u);
      return operands[0] * operands[1];
    case CSSMathOperator::kDivide:
      DCHECK(operands.size() == 1u || operands.size() == 2u);
      return operands[0] / operands[1];
    case CSSMathOperator::kMin: {
      if (operands.empty()) {
        return std::numeric_limits<double>::quiet_NaN();
      }
      double minimum = operands[0];
      for (double operand : operands) {
        // std::min(0.0, -0.0) returns 0.0, manually check for such situation
        // and set result to -0.0.
        if (minimum == 0 && operand == 0 && std::signbit(minimum) != std::signbit(operand)) {
          minimum = -0.0;
          continue;
        }
        minimum = std::min(minimum, operand);
      }
      return minimum;
    }
    case CSSMathOperator::kMax: {
      if (operands.empty()) {
        return std::numeric_limits<double>::quiet_NaN();
      }
      double maximum = operands[0];
      for (double operand : operands) {
        // std::max(-0.0, 0.0) returns -0.0, manually check for such situation
        // and set result to 0.0.
        if (maximum == 0 && operand == 0 && std::signbit(maximum) != std::signbit(operand)) {
          maximum = 0.0;
          continue;
        }
        maximum = std::max(maximum, operand);
      }
      return maximum;
    }
    case CSSMathOperator::kClamp: {
      DCHECK_EQ(operands.size(), 3u);
      double min = operands[0];
      double val = operands[1];
      double max = operands[2];
      // clamp(MIN, VAL, MAX) is identical to max(MIN, min(VAL, MAX))
      // according to the spec,
      // https://drafts.csswg.org/css-values-4/#funcdef-clamp.
      double minimum = std::min(val, max);
      // std::min(0.0, -0.0) returns 0.0, so manually check for this situation
      // to set result to -0.0.
      if (val == 0 && max == 0 && !std::signbit(val) && std::signbit(max)) {
        minimum = -0.0;
      }
      double maximum = std::max(min, minimum);
      // std::max(-0.0, 0.0) returns -0.0, so manually check for this situation
      // to set result to 0.0.
      if (min == 0 && minimum == 0 && std::signbit(min) && !std::signbit(minimum)) {
        maximum = 0.0;
      }
      return maximum;
    }
    case CSSMathOperator::kRoundNearest:
    case CSSMathOperator::kRoundUp:
    case CSSMathOperator::kRoundDown:
    case CSSMathOperator::kRoundToZero:
    case CSSMathOperator::kMod:
    case CSSMathOperator::kRem: {
      DCHECK_EQ(operands.size(), 2u);
      return EvaluateSteppedValueFunction(op, operands[0], operands[1]);
    }
    case CSSMathOperator::kHypot: {
      DCHECK_GE(operands.size(), 1u);
      double value = 0;
      for (double operand : operands) {
        value = std::hypot(value, operand);
      }
      return value;
    }
    case CSSMathOperator::kAbs: {
      DCHECK_EQ(operands.size(), 1u);
      return std::abs(operands.front());
    }
    case CSSMathOperator::kSign: {
      DCHECK_EQ(operands.size(), 1u);
      const double value = operands.front();
      const double signum = (value == 0 || std::isnan(value)) ? value : ((value > 0) ? 1 : -1);
      return signum;
    }
    case CSSMathOperator::kProgress:
    case CSSMathOperator::kMediaProgress:
    case CSSMathOperator::kContainerProgress: {
      CHECK_EQ(operands.size(), 3u);
      return (operands[0] - operands[1]) / (operands[2] - operands[1]);
    }
    case CSSMathOperator::kCalcSize: {
      CHECK_EQ(operands.size(), 2u);
      // TODO(https://crbug.com/313072): In theory we could also
      // evaluate (a) cases where the basis (operand 0) is not a double,
      // and (b) cases where the basis (operand 0) is a double and the
      // calculation (operand 1) requires 'size' keyword substitutions.
      // But for now just handle the simplest case.
      return operands[1];
    }
    case CSSMathOperator::kInvalid:
      NOTREACHED_IN_MIGRATION();
      break;
  }
  return 0;
}

// ------ End of CSSMathExpressionOperation member functions ------
// ------ Start of CSSMathExpressionContainerProgress member functions ----

namespace {

double EvaluateContainerSize(const CSSIdentifierValue* size_feature,
                             const CSSCustomIdentValue* container_name,
                             const CSSLengthResolver& length_resolver) {
  if (container_name) {
    auto name = std::make_shared<ScopedCSSName>(container_name->Value(), container_name->GetTreeScope());
    switch (size_feature->GetValueID()) {
      case CSSValueID::kWidth:
        return length_resolver.ContainerWidth(*name);
      case CSSValueID::kHeight:
        return length_resolver.ContainerHeight(*name);
      default:
        assert(false);
    }
  } else {
    switch (size_feature->GetValueID()) {
      case CSSValueID::kWidth:
        return length_resolver.ContainerWidth();
      case CSSValueID::kHeight:
        return length_resolver.ContainerHeight();
      default:
        assert(false);
    }
  }
}

}  // namespace

CSSMathExpressionContainerFeature::CSSMathExpressionContainerFeature(
    std::shared_ptr<const CSSIdentifierValue> size_feature,
    std::shared_ptr<const CSSCustomIdentValue> container_name)
    : CSSMathExpressionNode(CalculationResultCategory::kCalcLength,
                            /*has_comparisons =*/false,
                            /*has_anchor_functions =*/false,
                            /*needs_tree_scope_population =*/
                            (container_name && !container_name->IsScopedValue())),
      size_feature_(size_feature),
      container_name_(container_name) {
  CHECK(size_feature);
}

std::string CSSMathExpressionContainerFeature::CustomCSSText() const {
  std::string builder;
  builder.append(size_feature_->CustomCSSText());
  if (container_name_ && !container_name_->Value().empty()) {
    builder.append(" of ");
    builder.append(container_name_->CustomCSSText());
  }
  return builder;
}

std::shared_ptr<const CalculationExpressionNode> CSSMathExpressionContainerFeature::ToCalculationExpression(
    const CSSLengthResolver& length_resolver) const {
  double progress = EvaluateContainerSize(size_feature_.get(), container_name_.get(), length_resolver);
  return std::make_shared<CalculationExpressionPixelsAndPercentNode>(PixelsAndPercent(progress));
}

std::optional<PixelsAndPercent> CSSMathExpressionContainerFeature::ToPixelsAndPercent(
    const CSSLengthResolver& length_resolver) const {
  return PixelsAndPercent(ComputeDouble(length_resolver));
}

double CSSMathExpressionContainerFeature::ComputeDouble(const CSSLengthResolver& length_resolver) const {
  return EvaluateContainerSize(size_feature_.get(), container_name_.get(), length_resolver);
}

}  // namespace webf