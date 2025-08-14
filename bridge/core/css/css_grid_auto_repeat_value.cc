// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_grid_auto_repeat_value.h"
#include "../../foundation/string/string_builder.h"

namespace webf {
namespace cssvalue {

String CSSGridAutoRepeatValue::CustomCSSText() const {
  StringBuilder result;
  result.Append("repeat("_s);
  result.Append(String::FromUTF8(getValueName(AutoRepeatID())));
  result.Append(", "_s);
  result.Append(CSSValueList::CustomCSSText());
  result.Append(')');
  return result.ReleaseString();
}

bool CSSGridAutoRepeatValue::Equals(const CSSGridAutoRepeatValue& other) const {
  return auto_repeat_id_ == other.auto_repeat_id_ && CSSValueList::Equals(other);
}

}  // namespace cssvalue
}  // namespace webf