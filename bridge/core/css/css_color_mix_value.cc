// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_color_mix_value.h"
#include "core/css/css_numeric_literal_value.h"

namespace webf::cssvalue {

bool CSSColorMixValue::NormalizePercentages(const CSSPrimitiveValue* percentage1,
                                            const CSSPrimitiveValue* percentage2,
                                            double& mix_amount,
                                            double& alpha_multiplier) {
  double p1 = 0.5;
  if (percentage1) {
    p1 = ClampTo<double>(percentage1->GetDoubleValue(), 0.0, 100.0) / 100.0;
  }
  double p2 = 0.5;
  if (percentage2) {
    p2 = ClampTo<double>(percentage2->GetDoubleValue(), 0.0, 100.0) / 100.0;
  }

  if (percentage1 && !percentage2) {
    p2 = 1.0 - p1;
  } else if (percentage2 && !percentage1) {
    p1 = 1.0 - p2;
  }

  if (p1 == 0.0 && p2 == 0.0) {
    return false;
  }

  alpha_multiplier = 1.0;

  double scale = p1 + p2;
  if (scale != 0.0) {
    p1 /= scale;
    p2 /= scale;
    if (scale <= 1.0) {
      alpha_multiplier = scale;
    }
  }

  mix_amount = p2;
  if (p1 == 0.0) {
    mix_amount = 1.0;
  }

  return true;
}

Color CSSColorMixValue::Mix(const Color& color1, const Color& color2) const {
  double alpha_multiplier;
  double mix_amount;
  if (!NormalizePercentages(mix_amount, alpha_multiplier)) {
    return Color();
  }
  return Color::FromColorMix(ColorInterpolationSpace(), HueInterpolationMethod(), color1, color2, mix_amount,
                             alpha_multiplier);
}

bool CSSColorMixValue::Equals(const CSSColorMixValue& other) const {
  return color1_ == other.color1_ && color2_ == other.color2_ && percentage1_ == other.percentage1_ &&
         percentage2_ == other.percentage2_ && color_interpolation_space_ == other.color_interpolation_space_ &&
         hue_interpolation_method_ == other.hue_interpolation_method_;
}

// https://drafts.csswg.org/css-color-5/#serial-color-mix
std::string CSSColorMixValue::CustomCSSText() const {
  std::string result;
  result.append("color-mix(in ");
  result.append(Color::SerializeInterpolationSpace(color_interpolation_space_, hue_interpolation_method_));
  result.append(", ");
  result.append(color1_->CssText());
  bool percentagesNormalized = true;
  if (percentage1_ && percentage2_ && percentage1_->IsNumericLiteralValue() && percentage2_->IsNumericLiteralValue() &&
      (To<CSSNumericLiteralValue>(*percentage1_).ComputePercentage() +
           To<CSSNumericLiteralValue>(*percentage2_).ComputePercentage() !=
       100.0)) {
    percentagesNormalized = false;
  }
  if (percentage1_ &&
      (!percentage1_->IsNumericLiteralValue() ||
       To<CSSNumericLiteralValue>(*percentage1_).ComputePercentage() != 50.0 || !percentagesNormalized)) {
    result.append(" ");
    result.append(percentage1_->CssText());
  }
  if (!percentage1_ && percentage2_ &&
      (!percentage2_->IsNumericLiteralValue() ||
       To<CSSNumericLiteralValue>(*percentage2_).ComputePercentage() != 50.0)) {
    result.append(" ");
    result.append(percentage2_->SubtractFrom(100.0, CSSPrimitiveValue::UnitType::kPercentage)->CustomCSSText());
  }
  result.append(", ");
  result.append(color2_->CssText());
  if (!percentagesNormalized) {
    result.append(" ");
    result.append(percentage2_->CssText());
  }
  result.append(")");

  return result;
}

void CSSColorMixValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf::cssvalue