// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_function_value.h"
#include "../../foundation/string/string_builder.h"

namespace webf {

String CSSFunctionValue::CustomCSSText() const {
  StringBuilder result;
  result.Append(String::FromUTF8(getValueName(value_id_)));
  result.Append("("_s);
  result.Append(CSSValueList::CustomCSSText());
  result.Append(")"_s);
  return result.ReleaseString();
}

}  // namespace webf
