// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_grid_integer_repeat_value.h"
#include "foundation/string_builder.h"

namespace webf {
namespace cssvalue {

std::string CSSGridIntegerRepeatValue::CustomCSSText() const {
  StringBuilder result;
  result.Append("repeat(");
  result.Append(std::to_string(Repetitions()));
  result.Append(", ");
  result.Append(CSSValueList::CustomCSSText());
  result.Append(')');
  return result.ReleaseString();
}

bool CSSGridIntegerRepeatValue::Equals(const CSSGridIntegerRepeatValue& other) const {
  return repetitions_ == other.repetitions_ && CSSValueList::Equals(other);
}

}  // namespace cssvalue
}  // namespace webf