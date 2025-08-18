// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_image_set_type_value.h"
#include "../../foundation/string/string_builder.h"

namespace webf {

CSSImageSetTypeValue::CSSImageSetTypeValue(const String& type) : CSSValue(kImageSetTypeClass), type_(type) {}

CSSImageSetTypeValue::~CSSImageSetTypeValue() = default;

String CSSImageSetTypeValue::CustomCSSText() const {
  StringBuilder result;

  result.Append("type(\""_s);
  result.Append(type_);
  result.Append("\")"_s);

  return result.ReleaseString();
}

bool CSSImageSetTypeValue::IsSupported() const {
  return true;
}

bool CSSImageSetTypeValue::Equals(const CSSImageSetTypeValue& other) const {
  return type_ == other.type_;
}

void CSSImageSetTypeValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf