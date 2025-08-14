// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_light_dart_value_pair.h"
#include "../../foundation/string/string_builder.h"

namespace webf {

String CSSLightDarkValuePair::CustomCSSText() const {
  StringBuilder builder;
  builder.Append("light-dark("_s);
  builder.Append(First()->CssText());
  builder.Append(", "_s);
  builder.Append(Second()->CssText());
  builder.Append(")"_s);
  return builder.ReleaseString();
}

}  // namespace webf