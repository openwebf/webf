// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "css_scroll_value.h"

namespace webf {

namespace cssvalue {

CSSScrollValue::CSSScrollValue(const CSSValue* scroller, const CSSValue* axis)
    : CSSValue(kScrollClass), scroller_(scroller), axis_(axis) {}

std::string CSSScrollValue::CustomCSSText() const {
  std::string result;
  result+="scroll(";
  if (scroller_) {
    result+=(scroller_->CssText());
  }
  if (axis_) {
    if (scroller_) {
      result+=(' ');
    }
    result+=(axis_->CssText());
  }
  result+=(")");
  return result;
}

bool CSSScrollValue::Equals(const CSSScrollValue& other) const {
  return webf::ValuesEquivalent(scroller_, other.scroller_) &&
         webf::ValuesEquivalent(axis_, other.axis_);
}

void CSSScrollValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
//  visitor->Trace(scroller_);
//  visitor->Trace(axis_);
}

}  // namespace cssvalue
}  // namespace webf