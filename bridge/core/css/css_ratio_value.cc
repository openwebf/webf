// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_ratio_value.h"
#include "../../foundation/string/string_builder.h"

namespace webf {
namespace cssvalue {

CSSRatioValue::CSSRatioValue(std::shared_ptr<const CSSPrimitiveValue> first,
                             std::shared_ptr<const CSSPrimitiveValue> second)
    : CSSValue(kRatioClass), first_(std::move(first)), second_(std::move(second)) {}

String CSSRatioValue::CustomCSSText() const {
  StringBuilder builder;
  builder.Append(first_->CssText());
  builder.Append(" / "_s);
  builder.Append(second_->CssText());
  return builder.ReleaseString();
}

bool CSSRatioValue::Equals(const CSSRatioValue& other) const {
  return first_ == other.first_ && second_ == other.second_;
}

}  // namespace cssvalue

}  // namespace webf
