// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_unset_value.h"
#include "core/css/css_value_pool.h"

namespace webf {

namespace cssvalue {

std::shared_ptr<const CSSUnsetValue> CSSUnsetValue::Create() {
  return CssValuePool().UnsetValue();
}

std::string CSSUnsetValue::CustomCSSText() const {
  return "unset";
}

}  // namespace cssvalue

}  // namespace webf
