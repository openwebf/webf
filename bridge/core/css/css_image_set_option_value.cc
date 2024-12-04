// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_image_set_option_value.h"
#include "core/base/memory/values_equivalent.h"
#include "core/css/css_image_set_type_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_primitive_value.h"
#include "foundation/string_builder.h"

namespace webf {

CSSImageSetOptionValue::CSSImageSetOptionValue(std::shared_ptr<const CSSValue> image,
                                               std::shared_ptr<const CSSPrimitiveValue> resolution,
                                               std::shared_ptr<const CSSImageSetTypeValue> type)
    : CSSValue(kImageSetOptionClass), image_(image), resolution_(resolution), type_(type) {
  DCHECK(image);

  if (!resolution_) {
    resolution_ = CSSNumericLiteralValue::Create(1.0, CSSPrimitiveValue::UnitType::kX);
  }
}

CSSImageSetOptionValue::~CSSImageSetOptionValue() = default;

double CSSImageSetOptionValue::ComputedResolution() const {
  return resolution_->ComputeDotsPerPixel();
}

bool CSSImageSetOptionValue::IsSupported() const {
  return (!type_ || type_->IsSupported()) && (resolution_->ComputeDotsPerPixel() > 0.0);
}

CSSValue& CSSImageSetOptionValue::GetImage() const {
  return const_cast<CSSValue&>(*image_);
}

const CSSPrimitiveValue& CSSImageSetOptionValue::GetResolution() const {
  return *resolution_;
}

const CSSImageSetTypeValue* CSSImageSetOptionValue::GetType() const {
  return type_.get();
}

std::string CSSImageSetOptionValue::CustomCSSText() const {
  StringBuilder result;

  result.Append(image_->CssText());
  result.Append(' ');
  result.Append(resolution_->CssText());
  if (type_) {
    result.Append(' ');
    result.Append(type_->CssText());
  }

  return result.ReleaseString();
}

bool CSSImageSetOptionValue::Equals(const CSSImageSetOptionValue& other) const {
  return ValuesEquivalent(image_, other.image_) && ValuesEquivalent(resolution_, other.resolution_) &&
         ValuesEquivalent(type_, other.type_);
}

void CSSImageSetOptionValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf