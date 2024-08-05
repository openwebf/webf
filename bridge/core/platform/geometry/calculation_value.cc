// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/platform/geometry/calculation_value.h"
#include "core/platform/geometry/blend.h"
#include "core/platform/geometry/calculation_expression_node.h"
#include "core/platform/geometry/length.h"

namespace webf {

CalculationValue::DataUnion::DataUnion(std::shared_ptr<const CalculationExpressionNode> expression)
    : expression(std::move(expression)) {}

CalculationValue::DataUnion::~DataUnion() {
  // Release of |expression| is left to CalculationValue::~CalculationValue().
}

// static
std::shared_ptr<const CalculationValue> CalculationValue::CreateSimplified(
    std::shared_ptr<const CalculationExpressionNode> expression,
    Length::ValueRange range) {
  if (expression->IsPixelsAndPercent()) {
    return Create(To<CalculationExpressionPixelsAndPercentNode>(*expression).GetPixelsAndPercent(), range);
  }
  return std::make_shared<CalculationValue>(std::move(expression), range);
}

CalculationValue::CalculationValue(std::shared_ptr<const CalculationExpressionNode> expression,
                                   Length::ValueRange range)
    : data_(std::move(expression)), is_expression_(true), is_non_negative_(range == Length::ValueRange::kNonNegative) {}

CalculationValue::~CalculationValue() {
}

float CalculationValue::Evaluate(float max_value, const Length::EvaluationInput& input) const {
  float value = ClampTo<float>(is_expression_ ? data_.expression->Evaluate(max_value, input)
                                              : Pixels() + Percent() / 100 * max_value);
  return (IsNonNegative() && value < 0) ? 0 : value;
}

bool CalculationValue::operator==(const CalculationValue& other) const {
  if (IsNonNegative() != other.IsNonNegative()) {
    return false;
  }

  if (IsExpression())
    return other.IsExpression() && *data_.expression == *other.data_.expression;
  return !other.IsExpression() && Pixels() == other.Pixels() && Percent() == other.Percent();
}

std::shared_ptr<const CalculationExpressionNode> CalculationValue::GetOrCreateExpression() const {
  if (IsExpression())
    return data_.expression;
  return std::make_shared<CalculationExpressionPixelsAndPercentNode>(GetPixelsAndPercent());
}

std::shared_ptr<const CalculationValue> CalculationValue::Blend(const CalculationValue& from,
                                                                double progress,
                                                                Length::ValueRange range) const {
  if (!IsExpression() && !from.IsExpression()) {
    PixelsAndPercent from_pixels_and_percent = from.GetPixelsAndPercent();
    PixelsAndPercent to_pixels_and_percent = GetPixelsAndPercent();
    const float pixels = webf::Blend(from_pixels_and_percent.pixels, to_pixels_and_percent.pixels, progress);
    const float percent = webf::Blend(from_pixels_and_percent.percent, to_pixels_and_percent.percent, progress);
    bool has_explicit_pixels = from_pixels_and_percent.has_explicit_pixels | to_pixels_and_percent.has_explicit_pixels;
    bool has_explicit_percent =
        from_pixels_and_percent.has_explicit_percent | to_pixels_and_percent.has_explicit_percent;
    return Create(PixelsAndPercent(pixels, percent, has_explicit_pixels, has_explicit_percent), range);
  }

  auto blended_from = CalculationExpressionOperationNode::CreateSimplified(
      CalculationExpressionOperationNode::Children(
          {from.GetOrCreateExpression(), std::make_shared<CalculationExpressionNumberNode>(1.0 - progress)}),
      CalculationOperator::kMultiply);
  auto blended_to = CalculationExpressionOperationNode::CreateSimplified(
      CalculationExpressionOperationNode::Children(
          {GetOrCreateExpression(), std::make_shared<CalculationExpressionNumberNode>(progress)}),
      CalculationOperator::kMultiply);
  auto result_expression = CalculationExpressionOperationNode::CreateSimplified(
      {std::move(blended_from), std::move(blended_to)}, CalculationOperator::kAdd);
  return CreateSimplified(result_expression, range);
}

std::shared_ptr<const CalculationValue> CalculationValue::SubtractFromOneHundredPercent() const {
  if (!IsExpression()) {
    PixelsAndPercent result(-Pixels(), 100 - Percent(), HasExplicitPixels(),
                            /*has_explicit_percent=*/true);
    return Create(result, Length::ValueRange::kAll);
  }
  auto hundred_percent =
      std::make_shared<CalculationExpressionPixelsAndPercentNode>(PixelsAndPercent(0, 100, false, true));
  auto result_expression = CalculationExpressionOperationNode::CreateSimplified(
      CalculationExpressionOperationNode::Children({std::move(hundred_percent), GetOrCreateExpression()}),
      CalculationOperator::kSubtract);
  return CreateSimplified(std::move(result_expression), Length::ValueRange::kAll);
}

std::shared_ptr<const CalculationValue> CalculationValue::Add(const CalculationValue& other) const {
  auto result_expression = CalculationExpressionOperationNode::CreateSimplified(
      {GetOrCreateExpression(), other.GetOrCreateExpression()}, CalculationOperator::kAdd);
  return CreateSimplified(result_expression, Length::ValueRange::kAll);
}

std::shared_ptr<const CalculationValue> CalculationValue::Zoom(double factor) const {
  if (!IsExpression()) {
    PixelsAndPercent result(Pixels() * factor, Percent(), HasExplicitPixels(), HasExplicitPercent());
    return Create(result, GetValueRange());
  }
  return CreateSimplified(data_.expression->Zoom(factor), GetValueRange());
}

bool CalculationValue::HasAuto() const {
  return IsExpression() && data_.expression->HasAuto();
}

bool CalculationValue::HasContentOrIntrinsicSize() const {
  return IsExpression() && data_.expression->HasContentOrIntrinsicSize();
}

bool CalculationValue::HasAutoOrContentOrIntrinsicSize() const {
  return IsExpression() && data_.expression->HasAutoOrContentOrIntrinsicSize();
}

bool CalculationValue::HasPercent() const {
  if (!IsExpression()) {
    return HasExplicitPercent();
  }
  return data_.expression->HasPercent();
}

bool CalculationValue::HasPercentOrStretch() const {
  if (!IsExpression()) {
    return HasExplicitPercent();
  }
  return data_.expression->HasPercentOrStretch();
}

bool CalculationValue::HasStretch() const {
  if (!IsExpression()) {
    return false;
  }
  return data_.expression->HasStretch();
}

bool CalculationValue::HasMinContent() const {
  if (!IsExpression()) {
    return false;
  }
  return data_.expression->HasContentOrIntrinsicSize() && data_.expression->HasMinContent();
}

bool CalculationValue::HasMaxContent() const {
  if (!IsExpression()) {
    return false;
  }
  return data_.expression->HasContentOrIntrinsicSize() && data_.expression->HasMaxContent();
}

bool CalculationValue::HasFitContent() const {
  if (!IsExpression()) {
    return false;
  }
  return data_.expression->HasContentOrIntrinsicSize() && data_.expression->HasFitContent();
}

}  // namespace webf
