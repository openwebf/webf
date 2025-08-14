// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_appearance_auto_base_select_value_pair.h"
#include "../../foundation/string/string_builder.h"

namespace webf {

String CSSAppearanceAutoBaseSelectValuePair::CustomCSSText() const {
  StringBuilder builder;
  builder.Append("-internal-appearance-auto-base-select("_s);
  builder.Append(First()->CssText());
  builder.Append(", "_s);
  builder.Append(Second()->CssText());
  builder.Append(")"_s);
  return builder.ReleaseString();
}

}  // namespace webf