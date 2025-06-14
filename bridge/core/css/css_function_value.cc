// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_function_value.h"

namespace webf {

std::string CSSFunctionValue::CustomCSSText() const {
  std::string result;
  result.append(getValueName(value_id_));
  result.append("(");
  result.append(CSSValueList::CustomCSSText());
  result.append(")");
  return result;
}

}  // namespace webf
