// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_alternate_value.h"

namespace webf::cssvalue {

CSSAlternateValue::CSSAlternateValue(std::shared_ptr<const CSSFunctionValue>& function,
                                     std::shared_ptr<const CSSValueList>& alias_list)
    : CSSValue(kAlternateClass), function_(function), aliases_(alias_list) {}

std::string CSSAlternateValue::CustomCSSText() const {
  std::string builder;
  builder+= getValueName(function_->FunctionType());
  builder+='(';
  builder+= aliases_->CssText();
  builder += ')';
  return builder;
}

bool CSSAlternateValue::Equals(const CSSAlternateValue& other) const {
  return webf::ValuesEquivalent(function_, other.function_) &&
         webf::ValuesEquivalent(aliases_, other.aliases_);
}
}  // namespace webf