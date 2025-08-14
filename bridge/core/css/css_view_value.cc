// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_view_value.h"
#include "../../foundation/string/string_builder.h"
#include "core/base/memory/values_equivalent.h"

namespace webf {

namespace cssvalue {

CSSViewValue::CSSViewValue(const CSSValue* axis, const CSSValue* inset)
    : CSSValue(kViewClass), axis_(axis), inset_(inset) {}

String CSSViewValue::CustomCSSText() const {
  StringBuilder result;
  result.Append("view("_s);
  if (axis_) {
    result.Append(axis_->CssText());
  }
  if (inset_) {
    if (axis_) {
      result.Append(' ');
    }
    result.Append(inset_->CssText());
  }
  result.Append(")"_s);
  return result.ReleaseString();
}

bool CSSViewValue::Equals(const CSSViewValue& other) const {
  return webf::ValuesEquivalent(axis_, other.axis_) && webf::ValuesEquivalent(inset_, other.inset_);
}

void CSSViewValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace cssvalue

}  // namespace webf
