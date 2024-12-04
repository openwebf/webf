// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CSS_FONT_VARIATION_VALUE_H
#define WEBF_CSS_FONT_VARIATION_VALUE_H

#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {

namespace cssvalue {

class CSSFontVariationValue : public CSSValue {
 public:
  CSSFontVariationValue(const std::string& tag, float value);

  const std::string& Tag() const { return tag_; }
  float Value() const { return value_; }
  std::string CustomCSSText() const;

  bool Equals(const CSSFontVariationValue&) const;

  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValue::TraceAfterDispatch(visitor); }

 private:
  std::string tag_;
  const float value_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSFontVariationValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsFontVariationValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_FONT_VARIATION_VALUE_H
