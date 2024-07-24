// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/css_initial_color_value.h"

#include "core/css/css_value_pool.h"

namespace webf {

CSSInitialColorValue* CSSInitialColorValue::Create() {
  return CssValuePool().InitialColorValue();
}

std::string CSSInitialColorValue::CustomCSSText() const {
  return "";
}

}  // namespace blink
