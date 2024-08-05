// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_math_function_value.h"

namespace webf {

struct SameSizeAsCSSMathFunctionValue : CSSPrimitiveValue {
  std::shared_ptr<const void*> expression;
  ValueRange value_range_in_target_context_;
};
static_assert(sizeof(CSSMathFunctionValue) == sizeof(SameSizeAsCSSMathFunctionValue));

void CSSMathFunctionValue::TraceAfterDispatch(GCVisitor* visitor) const {
  //  visitor->Trace(expression_);
  CSSPrimitiveValue::TraceAfterDispatch(visitor);
}

CSSMathFunctionValue::CSSMathFunctionValue(std::shared_ptr<CSSMathExpressionNode> expression,
                                           CSSPrimitiveValue::ValueRange range)
    : CSSPrimitiveValue(kMathFunctionClass), expression_(std::move(expression)), value_range_in_target_context_(range) {
  needs_tree_scope_population_ = !expression->IsScopedValue();
}

// static
std::shared_ptr<CSSMathFunctionValue> CSSMathFunctionValue::Create(
    const std::shared_ptr<CSSMathExpressionNode>& expression,
    CSSPrimitiveValue::ValueRange range) {
  if (!expression) {
    return nullptr;
  }
  return std::make_shared<CSSMathFunctionValue>(expression, range);
}

// static
// std::shared_ptr<CSSMathFunctionValue> CSSMathFunctionValue::Create(const Length& length,
//                                                   float zoom) {
//  assert(length.IsCalculated());
//  auto calc = length.GetCalculationValue().Zoom(1.0 / zoom);
//  return Create(
//      CSSMathExpressionNode::Create(*calc),
//      CSSPrimitiveValue::ValueRangeForLengthValueRange(calc->GetValueRange()));
//}

bool CSSMathFunctionValue::MayHaveRelativeUnit() const {
  UnitType resolved_type = expression_->ResolvedUnitType();
  return IsRelativeUnit(resolved_type) || resolved_type == UnitType::kUnknown;
}

double CSSMathFunctionValue::DoubleValue() const {
#if DCHECK_IS_ON()
  if (IsPercentage()) {
    DCHECK(!AllowsNegativePercentageReference() || !expression_->InvolvesPercentageComparisons());
  }
#endif
  return ClampToPermittedRange(expression_->DoubleValue());
}

double CSSMathFunctionValue::ComputeSeconds() const {
  assert(kCalcTime == expression_->Category());
  return ClampToPermittedRange(*expression_->ComputeValueInCanonicalUnit());
}

double CSSMathFunctionValue::ComputeDegrees() const {
  assert(kCalcAngle == expression_->Category());
  return ClampToPermittedRange(*expression_->ComputeValueInCanonicalUnit());
}

double CSSMathFunctionValue::ComputeDegrees(const CSSLengthResolver& length_resolver) const {
  assert(kCalcAngle == expression_->Category());
  return ClampToPermittedRange(expression_->ComputeNumber(length_resolver));
}

double CSSMathFunctionValue::ComputeSeconds(const CSSLengthResolver& length_resolver) const {
  assert(kCalcTime == expression_->Category());
  return ClampToPermittedRange(expression_->ComputeNumber(length_resolver));
}

double CSSMathFunctionValue::ComputeLengthPx(const CSSLengthResolver& length_resolver) const {
  // |CSSToLengthConversionData| only resolves relative length units, but not
  // percentages.
  assert(kCalcLength == expression_->Category());
  assert(!expression_->HasPercentage());
  return ClampToPermittedRange(expression_->ComputeLengthPx(length_resolver));
}

int CSSMathFunctionValue::ComputeInteger(const CSSLengthResolver& length_resolver) const {
  // |CSSToLengthConversionData| only resolves relative length units, but not
  // percentages.
  assert(kCalcNumber == expression_->Category());
  assert(!expression_->HasPercentage());
  return ClampTo<int>(ClampToPermittedRange(expression_->ComputeNumber(length_resolver)));
}

double CSSMathFunctionValue::ComputeNumber(const CSSLengthResolver& length_resolver) const {
  // |CSSToLengthConversionData| only resolves relative length units, but not
  // percentages.
  assert(kCalcNumber == expression_->Category());
  assert(!expression_->HasPercentage());
  double value = ClampToPermittedRange(expression_->ComputeNumber(length_resolver));
  return std::isnan(value) ? 0.0 : value;
}

double CSSMathFunctionValue::ComputePercentage(const CSSLengthResolver& length_resolver) const {
  // |CSSToLengthConversionData| only resolves relative length units, but not
  // percentages.
  assert(kCalcPercent == expression_->Category());
  double value = ClampToPermittedRange(expression_->ComputeNumber(length_resolver));
  return std::isnan(value) ? 0.0 : value;
}

double CSSMathFunctionValue::ComputeValueInCanonicalUnit(const CSSLengthResolver& length_resolver) const {
  // Don't use it for mix of length and percentage, as it would compute 10px +
  // 10% to 20.
  assert(!IsCalculatedPercentageWithLength());
  std::optional<double> optional_value = expression_->ComputeValueInCanonicalUnit(length_resolver);
  assert(optional_value.has_value());
  double value = ClampToPermittedRange(optional_value.value());
  return std::isnan(value) ? 0.0 : value;
}

double CSSMathFunctionValue::ComputeDotsPerPixel() const {
  assert(kCalcResolution == expression_->Category());
  return ClampToPermittedRange(*expression_->ComputeValueInCanonicalUnit());
}

bool CSSMathFunctionValue::AccumulateLengthArray(CSSLengthArray& length_array, double multiplier) const {
  return expression_->AccumulateLengthArray(length_array, multiplier);
}

Length CSSMathFunctionValue::ConvertToLength(const CSSLengthResolver& length_resolver) const {
  if (IsResolvableLength()) {
    return Length::Fixed(ComputeLengthPx(length_resolver));
  }
  return g_auto_length;
  //  return Length(ToCalcValue(length_resolver));
}

static std::string BuildCSSText(const std::string& expression) {
  std::string result;
  result.append("calc");
  result.append("(");
  result.append(expression);
  result.append(")");
  return result;
}

std::string CSSMathFunctionValue::CustomCSSText() const {
  const std::string& expression_text = expression_->CustomCSSText();
  if (expression_->IsMathFunction()) {
    // If |expression_| is already a math function (e.g., min/max), we don't
    // need to wrap it in |calc()|.
    return expression_text;
  }
  return BuildCSSText(expression_text);
}

bool CSSMathFunctionValue::Equals(const CSSMathFunctionValue& other) const {
  return expression_ == other.expression_;
}

double CSSMathFunctionValue::ClampToPermittedRange(double value) const {
  switch (PermittedValueRange()) {
    case CSSPrimitiveValue::ValueRange::kInteger:
      return RoundHalfTowardsPositiveInfinity(value);
    case CSSPrimitiveValue::ValueRange::kNonNegativeInteger:
      return RoundHalfTowardsPositiveInfinity(std::max(value, 0.0));
    case CSSPrimitiveValue::ValueRange::kPositiveInteger:
      return RoundHalfTowardsPositiveInfinity(std::max(value, 1.0));
    case CSSPrimitiveValue::ValueRange::kNonNegative:
      return std::max(value, 0.0);
    case CSSPrimitiveValue::ValueRange::kAll:
      return value;
  }
}

CSSPrimitiveValue::BoolStatus CSSMathFunctionValue::IsZero() const {
  if (IsCalculatedPercentageWithLength()) {
    return BoolStatus::kUnresolvable;
  }
  if (expression_->ResolvedUnitType() == UnitType::kUnknown) {
    return BoolStatus::kUnresolvable;
  }
  return expression_->IsZero();
}

CSSPrimitiveValue::BoolStatus CSSMathFunctionValue::IsOne() const {
  if (IsCalculatedPercentageWithLength()) {
    return BoolStatus::kUnresolvable;
  }
  if (expression_->ResolvedUnitType() == UnitType::kUnknown) {
    return BoolStatus::kUnresolvable;
  }
  return expression_->IsOne();
}

CSSPrimitiveValue::BoolStatus CSSMathFunctionValue::IsNegative() const {
  if (IsCalculatedPercentageWithLength()) {
    return BoolStatus::kUnresolvable;
  }
  if (expression_->ResolvedUnitType() == UnitType::kUnknown) {
    return BoolStatus::kUnresolvable;
  }
  return expression_->IsNegative();
}

bool CSSMathFunctionValue::IsPx() const {
  // TODO(crbug.com/979895): This is the result of refactoring, which might be
  // an existing bug. Fix it if necessary.
  return Category() == kCalcLength;
}

bool CSSMathFunctionValue::IsComputationallyIndependent() const {
  return expression_->IsComputationallyIndependent();
}

std::shared_ptr<const CalculationValue> CSSMathFunctionValue::ToCalcValue(
    const CSSLengthResolver& length_resolver) const {
  assert(value_range_in_target_context_ < CSSPrimitiveValue::ValueRange::kInteger);
  assert(value_range_in_target_context_ < CSSPrimitiveValue::ValueRange::kNonNegativeInteger);
  assert(value_range_in_target_context_ < CSSPrimitiveValue::ValueRange::kPositiveInteger);
  return expression_->ToCalcValue(length_resolver,
                                  CSSPrimitiveValue::ConversionToLengthValueRange(PermittedValueRange()),
                                  AllowsNegativePercentageReference());
}

const std::shared_ptr<CSSValue> CSSMathFunctionValue::PopulateWithTreeScope(const TreeScope* tree_scope) const {
  return std::make_shared<CSSMathFunctionValue>(expression_->PopulateWithTreeScope(tree_scope),
                                                value_range_in_target_context_);
}

const std::shared_ptr<const CSSMathFunctionValue> CSSMathFunctionValue::TransformAnchors(
    LogicalAxis logical_axis,
    const TryTacticTransform& transform,
    const WritingDirectionMode& writing_direction) const {
  std::shared_ptr<const CSSMathExpressionNode> transformed =
      expression_->TransformAnchors(logical_axis, transform, writing_direction);
  if (transformed != expression_) {
    return std::make_shared<CSSMathFunctionValue>(transformed, value_range_in_target_context_);
  }
  return std::reinterpret_pointer_cast<const CSSMathFunctionValue>(shared_from_this());
}

}  // namespace webf