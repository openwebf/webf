// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_NUMERIC_LITERAL_VALUE_H_
#define WEBF_CORE_CSS_CSS_NUMERIC_LITERAL_VALUE_H_

#include "core/css/css_primitive_value.h"

namespace webf {

class CSSLengthResolver;

// Numeric values that can be expressed as a single unit (or a naked number or
// percentage). The equivalence of CSS Typed OM's |CSSUnitValue| in the
// |CSSValue| class hierarchy.
class CSSNumericLiteralValue : public CSSPrimitiveValue {
 public:
  static std::shared_ptr<const CSSNumericLiteralValue> Create(double num, UnitType);

  CSSNumericLiteralValue(double num, UnitType type);

  UnitType GetType() const {
    return static_cast<UnitType>(numeric_literal_unit_type_);
  }

  bool IsAngle() const { return CSSPrimitiveValue::IsAngle(GetType()); }
  bool IsFontRelativeLength() const {
    switch (GetType()) {
      case UnitType::kQuirkyEms:
      case UnitType::kEms:
      case UnitType::kExs:
      case UnitType::kRems:
      case UnitType::kChs:
      case UnitType::kIcs:
      case UnitType::kLhs:
      case UnitType::kCaps:
      case UnitType::kRcaps:
      case UnitType::kRexs:
      case UnitType::kRchs:
      case UnitType::kRics:
      case UnitType::kRlhs:
        return true;
      default:
        return false;
    }
  }
  bool IsQuirkyEms() const { return GetType() == UnitType::kQuirkyEms; }
  bool IsViewportPercentageLength() const {
    return CSSPrimitiveValue::IsViewportPercentageLength(GetType());
  }
  bool IsLength() const { return CSSPrimitiveValue::IsLength(GetType()); }
  bool IsPx() const { return GetType() == UnitType::kPixels; }
  bool IsNumber() const {
    return GetType() == UnitType::kNumber || GetType() == UnitType::kInteger;
  }
  bool IsInteger() const { return GetType() == UnitType::kInteger; }
  bool IsPercentage() const { return GetType() == UnitType::kPercentage; }
  bool IsTime() const { return CSSPrimitiveValue::IsTime(GetType()); }
  bool IsResolution() const {
    return CSSPrimitiveValue::IsResolution(GetType());
  }
  bool IsFlex() const { return CSSPrimitiveValue::IsFlex(GetType()); }

  BoolStatus IsZero() const {
    return !DoubleValue() ? BoolStatus::kTrue : BoolStatus::kFalse;
  }
  BoolStatus IsOne() const {
    return DoubleValue() == 1.0 ? BoolStatus::kTrue : BoolStatus::kFalse;
  }
  BoolStatus IsNegative() const {
    return DoubleValue() < 0.0 ? BoolStatus::kTrue : BoolStatus::kFalse;
  }

  bool IsComputationallyIndependent() const;

  double DoubleValue() const { return num_; }
  double ComputeSeconds() const;
  double ComputeDegrees() const;
  double ComputeDotsPerPixel() const;
  double ComputeInCanonicalUnit() const;
  double ComputeInCanonicalUnit(const CSSLengthResolver&) const;

  int ComputeInteger() const;
  double ComputeNumber() const;
  double ComputePercentage() const;
  double ComputeLengthPx(const CSSLengthResolver&) const;
  bool AccumulateLengthArray(CSSLengthArray& length_array,
                             double multiplier) const;
  void AccumulateLengthUnitTypes(LengthTypeFlags& types) const;

  std::string CustomCSSText() const;
  bool Equals(const CSSNumericLiteralValue& other) const;

  UnitType CanonicalUnit() const;
  std::shared_ptr<const CSSNumericLiteralValue> CreateCanonicalUnitValue() const;

  void TraceAfterDispatch(GCVisitor* visitor) const;

 private:
  const double num_;
};

template <>
struct DowncastTraits<CSSNumericLiteralValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsNumericLiteralValue();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_NUMERIC_LITERAL_VALUE_H_
