// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_alternate_value.h"
#include "../../foundation/string/string_builder.h"

namespace webf::cssvalue {

CSSAlternateValue::CSSAlternateValue(std::shared_ptr<const CSSFunctionValue>& function,
                                     std::shared_ptr<const CSSValueList>& alias_list)
    : CSSValue(kAlternateClass), function_(function), aliases_(alias_list) {}

String CSSAlternateValue::CustomCSSText() const {
  StringBuilder builder;
  builder.Append(String::FromUTF8(getValueName(function_->FunctionType())));
  builder.Append('(');
  builder.Append(aliases_->CssText());
  builder.Append(')');
  return builder.ReleaseString();
}

bool CSSAlternateValue::Equals(const CSSAlternateValue& other) const {
  return webf::ValuesEquivalent(function_, other.function_) && webf::ValuesEquivalent(aliases_, other.aliases_);
}
}  // namespace webf::cssvalue