// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_appearance_auto_base_select_value_pair.h"

namespace webf {

std::string CSSAppearanceAutoBaseSelectValuePair::CustomCSSText() const {
  std::string first = First()->CssText();
  std::string second = Second()->CssText();
  return "-internal-appearance-auto-base-select(" + first + ", " + second + ")";
}

}  // namespace blink