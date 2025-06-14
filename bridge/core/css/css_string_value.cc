// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_string_value.h"
#include "core/css/css_markup.h"

namespace webf {

CSSStringValue::CSSStringValue(const std::string& str) : CSSValue(kStringClass), string_(str) {}

std::string CSSStringValue::CustomCSSText() const {
  return SerializeString(string_);
}

void CSSStringValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf