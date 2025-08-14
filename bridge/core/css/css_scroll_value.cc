// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "css_scroll_value.h"
#include "../../foundation/string/string_builder.h"

namespace webf {

namespace cssvalue {

CSSScrollValue::CSSScrollValue(std::shared_ptr<const CSSValue> scroller, std::shared_ptr<const CSSValue> axis)
    : CSSValue(kScrollClass), scroller_(scroller), axis_(axis) {}

String CSSScrollValue::CustomCSSText() const {
  StringBuilder result;
  result.Append("scroll("_s);
  if (scroller_) {
    result.Append(scroller_->CssText());
  }
  if (axis_) {
    if (scroller_) {
      result.Append(' ');
    }
    result.Append(axis_->CssText());
  }
  result.Append(")"_s);
  return result.ReleaseString();
}

bool CSSScrollValue::Equals(const CSSScrollValue& other) const {
  return webf::ValuesEquivalent(scroller_, other.scroller_) && webf::ValuesEquivalent(axis_, other.axis_);
}

void CSSScrollValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
  //  visitor->Trace(scroller_);
  //  visitor->Trace(axis_);
}

}  // namespace cssvalue
}  // namespace webf