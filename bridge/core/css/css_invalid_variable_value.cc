// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/css_invalid_variable_value.h"
#include "core/css/css_value_pool.h"

namespace webf {

CSSInvalidVariableValue* CSSInvalidVariableValue::Create() {
  return CssValuePool().InvalidVariableValue();
}

std::string CSSInvalidVariableValue::CustomCSSText() const {
  return "";
}

}  // namespace webf
