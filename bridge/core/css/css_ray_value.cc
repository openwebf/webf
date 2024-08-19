// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_ray_value.h"
#include "foundation/string_builder.h"
#include "core/css/css_identifier_value.h"
#include "core/base/memory/values_equivalent.h"

namespace webf {


namespace cssvalue {

CSSRayValue::CSSRayValue(const std::shared_ptr<const CSSPrimitiveValue>& angle,
                         const std::shared_ptr<const CSSIdentifierValue>& size,
                         const std::shared_ptr<const CSSIdentifierValue>& contain,
                         const std::shared_ptr<const CSSValue>& center_x,
                         const std::shared_ptr<const CSSValue>& center_y)
    : CSSValue(kRayClass),
      angle_(angle),
      size_(size),
      contain_(contain),
      center_x_(center_x),
      center_y_(center_y) {}

std::string CSSRayValue::CustomCSSText() const {
  StringBuilder result;
  result.Append("ray(");
  result.Append(angle_->CssText());
  if (size_->GetValueID() != CSSValueID::kClosestSide) {
    result.Append(' ');
    result.Append(size_->CssText());
  }
  if (contain_) {
    result.Append(' ');
    result.Append(contain_->CssText());
  }
  if (center_x_) {
    result.Append(" at ");
    result.Append(center_x_->CssText());
    result.Append(' ');
    result.Append(center_y_->CssText());
  }
  result.Append(')');
  return result.ReleaseString();
}

bool CSSRayValue::Equals(const CSSRayValue& other) const {
  return ValuesEquivalent(angle_, other.angle_) &&
         ValuesEquivalent(size_, other.size_) &&
         ValuesEquivalent(contain_, other.contain_) &&
         ValuesEquivalent(center_x_, other.center_x_) &&
         ValuesEquivalent(center_y_, other.center_y_);
}

void CSSRayValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace cssvalue

}