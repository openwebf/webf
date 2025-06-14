// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_light_dart_value_pair.h"

namespace webf {

std::string CSSLightDarkValuePair::CustomCSSText() const {
  std::string first = First()->CssText();
  std::string second = Second()->CssText();
  return "light-dark(" + first + ", " + second + ")";
}

}  // namespace webf