// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_COLOR_MIX_VALUE_H_
#define WEBF_CORE_CSS_CSS_COLOR_MIX_VALUE_H_

#include "core/css/css_primitive_value.h"
#include "core/css/css_value.h"
#include "core/platform/graphics/color.h"
#include "foundation/casting.h"

namespace webf {
namespace cssvalue {

// This is a class for storing the result of parsing the color-mix function
// before resolving it into a blink::Color. See
// https://www.w3.org/TR/css-color-5/#color-mix
class CSSColorMixValue : public CSSValue {
 public:
  CSSColorMixValue(const CSSValue* color1,
                   const CSSValue* color2,
                   const CSSPrimitiveValue* p1,
                   const CSSPrimitiveValue* p2,
                   const Color::ColorSpace color_interpolation_space,
                   const Color::HueInterpolationMethod hue_interpolation_method)
      : CSSValue(kColorMixClass),
        color1_(color1),
        color2_(color2),
        percentage1_(p1),
        percentage2_(p2),
        color_interpolation_space_(color_interpolation_space),
        hue_interpolation_method_(hue_interpolation_method) {}

  std::string CustomCSSText() const;

  void TraceAfterDispatch(GCVisitor* visitor) const;

  bool Equals(const CSSColorMixValue& other) const;

  const CSSValue& Color1() const { return *color1_; }
  const CSSValue& Color2() const { return *color2_; }
  const CSSPrimitiveValue* Percentage1() const { return percentage1_.get(); }
  const CSSPrimitiveValue* Percentage2() const { return percentage2_.get(); }
  Color::ColorSpace ColorInterpolationSpace() const {
    return color_interpolation_space_;
  }
  Color::HueInterpolationMethod HueInterpolationMethod() const {
    return hue_interpolation_method_;
  }

  // Mix `color1` with `color2` using the parameters defined by the color-mix()
  // function defined by this CSS value.
  Color Mix(const Color& color1, const Color& color2) const;

  // https://www.w3.org/TR/css-color-5/#color-mix-percent-norm
  static bool NormalizePercentages(const CSSPrimitiveValue* percentage1,
                                   const CSSPrimitiveValue* percentage2,
                                   double& mix_amount,
                                   double& alpha_multiplier);
  bool NormalizePercentages(double& mix_amount,
                            double& alpha_multiplier) const {
    return NormalizePercentages(Percentage1(), Percentage2(), mix_amount,
                                alpha_multiplier);
  }

 private:
  std::shared_ptr<const CSSValue> color1_;
  std::shared_ptr<const CSSValue> color2_;
  std::shared_ptr<const CSSPrimitiveValue> percentage1_;
  std::shared_ptr<const CSSPrimitiveValue> percentage2_;
  const Color::ColorSpace color_interpolation_space_;
  const Color::HueInterpolationMethod hue_interpolation_method_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSColorMixValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsColorMixValue();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_COLOR_MIX_VALUE_H_