// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/css_revert_value.h"
#include "core/css/css_value_pool.h"

namespace webf {
namespace cssvalue {

std::shared_ptr<const CSSRevertValue> CSSRevertValue::Create() {
  return CssValuePool().RevertValue();
}

std::string CSSRevertValue::CustomCSSText() const {
  return "revert";
}

}  // namespace cssvalue
}  // namespace webf
