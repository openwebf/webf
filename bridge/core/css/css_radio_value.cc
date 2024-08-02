// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_radio_value.h"

namespace webf {
namespace cssvalue {

CSSRatioValue::CSSRatioValue(const CSSPrimitiveValue& first,
                             const CSSPrimitiveValue& second)
    : CSSValue(kRatioClass), first_(&first), second_(&second) {}

std::string CSSRatioValue::CustomCSSText() const {
  std::string builder;
  builder.append(first_->CssText());
  builder.append(" / ");
  builder.append(second_->CssText());
  return builder;
}

bool CSSRatioValue::Equals(const CSSRatioValue& other) const {
  return first_ == other.first_ && second_ == other.second_;
}


}

}