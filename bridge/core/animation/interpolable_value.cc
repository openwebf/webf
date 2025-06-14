// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/animation/interpolable_value.h"

#include <memory>

//#include "core/animation/css_color_interpolation_type.h"
//#include "core/animation/interpolable_style_color.h"
#include "core/css/css_math_expression_node.h"
#include "core/css/css_numeric_literal_value.h"

namespace webf {

namespace {

using UnitType = CSSPrimitiveValue::UnitType;

CSSMathExpressionNode* NumberNode(double number, UnitType unit_type = UnitType::kNumber) {
  // TODO(guopengfei)：
  // return CSSMathExpressionNumericLiteral::Create(
  //    CSSNumericLiteralValue::Create(number, unit_type));
  return nullptr;
}

}  // namespace

InterpolableNumber::InterpolableNumber(double value, UnitType unit_type) {
  SetDouble(value, unit_type);
}

InterpolableNumber::InterpolableNumber(const CSSMathExpressionNode& expression) {
  SetExpression(expression);
}

double InterpolableNumber::Value(const CSSLengthResolver& length_resolver) const {
  if (IsDoubleValue()) {
    return value_.Value();
  }
  return expression_->ComputeNumber(length_resolver);
}

void InterpolableNumber::SetExpression(const CSSMathExpressionNode& expression) {
  type_ = Type::kExpression;
  expression_ = std::shared_ptr<const CSSMathExpressionNode>(&expression);
}

void InterpolableNumber::SetDouble(double value, UnitType unit_type) {
  type_ = Type::kDouble;
  value_.Set(value);
  unit_type_ = unit_type;
}

const CSSMathExpressionNode& InterpolableNumber::AsExpression() const {
  if (IsExpression()) {
    return *expression_;
  }
  return *NumberNode(value_.Value(), unit_type_);
}

bool InterpolableNumber::Equals(const InterpolableValue& other) const {
  const auto& other_number = To<InterpolableNumber>(other);
  if (IsDoubleValue() && other_number.IsDoubleValue()) {
    return value_.Value() == To<InterpolableNumber>(other).value_.Value();
  }
  return AsExpression().CustomCSSText() == other_number.AsExpression().CustomCSSText();
}

bool InterpolableList::Equals(const InterpolableValue& other) const {
  const auto& other_list = To<InterpolableList>(other);
  if (length() != other_list.length())
    return false;
  for (uint32_t i = 0; i < length(); i++) {
    if (!values_[i]->Equals(*other_list.values_[i]))
      return false;
  }
  return true;
}

double InlinedInterpolableDouble::Interpolate(double to, const double progress) const {
  if (progress == 0 || value_ == to) {
    return value_;
  } else if (progress == 1) {
    return to;
  } else {
    return value_ * (1 - progress) + to * progress;
  }
}

void InterpolableNumber::AssertCanInterpolateWith(const InterpolableValue& other) const {
  assert(other.IsNumber());
}

void InterpolableNumber::Interpolate(const InterpolableValue& to,
                                     const double progress,
                                     InterpolableValue& result) const {
  const auto& to_number = To<InterpolableNumber>(to);
  auto& result_number = To<InterpolableNumber>(result);
  if (IsDoubleValue() && to_number.IsDoubleValue()) {
    result_number.SetDouble(value_.Interpolate(to_number.Value(), progress), unit_type_);
    return;
  }
  /*   // TODO(guopengfei)：CSSMathExpressionOperation未迁移
  CSSMathExpressionNode* blended_from =
      CSSMathExpressionOperation::CreateArithmeticOperationAndSimplifyCalcSize(
          &AsExpression(), NumberNode(1 - progress),
          CSSMathOperator::kMultiply);
  CSSMathExpressionNode* blended_to =
      CSSMathExpressionOperation::CreateArithmeticOperationAndSimplifyCalcSize(
          &to_number.AsExpression(), NumberNode(progress),
          CSSMathOperator::kMultiply);
  CSSMathExpressionNode* result_expression =
      CSSMathExpressionOperation::CreateArithmeticOperationAndSimplifyCalcSize(
          blended_from, blended_to, CSSMathOperator::kAdd);
  result_number.SetExpression(*result_expression);

   */
}

void InterpolableList::AssertCanInterpolateWith(const InterpolableValue& other) const {
  assert(other.IsList());
  assert(To<InterpolableList>(other).length() == length());
}

void InterpolableList::Interpolate(const InterpolableValue& to,
                                   const double progress,
                                   InterpolableValue& result) const {
  const auto& to_list = To<InterpolableList>(to);
  auto& result_list = To<InterpolableList>(result);

  for (uint32_t i = 0; i < length(); i++) {
    assert(values_[i]);
    assert(to_list.values_[i]);
    if (values_[i]->IsStyleColor() || to_list.values_[i]->IsStyleColor() || result_list.values_[i]->IsStyleColor()) {
      // TODO(guopengfei)：未迁移
      // CSSColorInterpolationType::EnsureInterpolableStyleColor(result_list, i);
      // InterpolableStyleColor::Interpolate(*values_[i], *(to_list.values_[i]),
      //                                    progress, *(result_list.values_[i]));
      continue;
    }
    values_[i]->Interpolate(*(to_list.values_[i]), progress, *(result_list.values_[i]));
  }
}

std::shared_ptr<InterpolableList> InterpolableList::RawCloneAndZero() const {
  std::shared_ptr<InterpolableList> result = std::make_shared<InterpolableList>(length());
  for (uint32_t i = 0; i < length(); i++) {
    result->Set(i, values_[i]->CloneAndZero());
  }
  return result;
}

void InterpolableNumber::Scale(double scale) {
  if (IsDoubleValue()) {
    value_.Scale(scale);
    return;
  }
  /* // TODO(guopengfei)：未迁移
  SetExpression(
      *CSSMathExpressionOperation::CreateArithmeticOperationAndSimplifyCalcSize(
          expression_, NumberNode(scale), CSSMathOperator::kMultiply));*/
}

void InterpolableNumber::Scale(const InterpolableNumber& other) {
  if (IsDoubleValue()) {
    /* // TODO(guopengfei)：未迁移
      SetExpression(*CSSMathExpressionOperation::
                        CreateArithmeticOperationAndSimplifyCalcSize(
                            &other.AsExpression(), NumberNode(value_.Value()),
                            CSSMathOperator::kMultiply));

     */
    return;
  }
  /* // TODO(guopengfei)：未迁移
  SetExpression(
      *CSSMathExpressionOperation::CreateArithmeticOperationAndSimplifyCalcSize(
          expression_, &other.AsExpression(), CSSMathOperator::kMultiply));

   */
}

void InterpolableList::Scale(double scale) {
  for (uint32_t i = 0; i < length(); i++)
    values_[i]->Scale(scale);
}

void InterpolableNumber::Add(const InterpolableValue& other) {
  const auto& other_number = To<InterpolableNumber>(other);
  if (IsDoubleValue() && other_number.IsDoubleValue()) {
    value_.Add(other_number.value_.Value());
    return;
  }
  /*  // TODO(guopengfei)：未迁移
  CSSMathExpressionNode* result =
      CSSMathExpressionOperation::CreateArithmeticOperationAndSimplifyCalcSize(
          &AsExpression(), &other_number.AsExpression(), CSSMathOperator::kAdd);
  SetExpression(*result);

   */
}

void InterpolableList::Add(const InterpolableValue& other) {
  const auto& other_list = To<InterpolableList>(other);
  assert(other_list.length() == length());
  for (uint32_t i = 0; i < length(); i++)
    values_[i]->Add(*other_list.values_[i]);
}

void InterpolableList::ScaleAndAdd(double scale, const InterpolableValue& other) {
  const auto& other_list = To<InterpolableList>(other);
  assert(other_list.length() == length());
  for (uint32_t i = 0; i < length(); i++)
    values_[i]->ScaleAndAdd(scale, *other_list.values_[i]);
}

}  // namespace webf
