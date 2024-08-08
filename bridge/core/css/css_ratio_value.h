// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_RATIO_VALUE_H_
#define WEBF_CORE_CSS_CSS_RATIO_VALUE_H_

#include "core/css/css_primitive_value.h"

namespace webf {

namespace cssvalue {

// https://drafts.csswg.org/css-values-4/#ratios
class CSSRatioValue : public CSSValue {
 public:
  CSSRatioValue(const CSSPrimitiveValue& first, const CSSPrimitiveValue& second);

  // Numerator, but called 'first' by the spec.
  const CSSPrimitiveValue& First() const { return *first_; }

  // Denominator, but called 'second' by the spec.
  const CSSPrimitiveValue& Second() const { return *second_; }

  std::string CustomCSSText() const;
  bool Equals(const CSSRatioValue&) const;

  void TraceAfterDispatch(GCVisitor* visitor) const {
    //    visitor->Trace(first_);
    //    visitor->Trace(second_);
    CSSValue::TraceAfterDispatch(visitor);
  }

 private:
  std::shared_ptr<const CSSPrimitiveValue> first_;
  std::shared_ptr<const CSSPrimitiveValue> second_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSRatioValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsRatioValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_RATIO_VALUE_H_
