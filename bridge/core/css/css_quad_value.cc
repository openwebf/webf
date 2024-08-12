// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_quad_value.h"

namespace webf {

std::string CSSQuadValue::CustomCSSText() const {
  std::string top = top_->CssText();
  std::string right = right_->CssText();
  std::string bottom = bottom_->CssText();
  std::string left = left_->CssText();

  if (serialization_type_ == TypeForSerialization::kSerializeAsRect) {
     return "rect(" + top + ", " + right + ", " + bottom + ", " + left + ')';
  }

  std::string result = top;
  if (right != top || bottom != top || left != top) {
    result += " " + right;
    if (bottom != top || right != left) {
      result += " " + bottom;
      if (left != right) {
        result += " " + left;
      }
    }
  }
  return result;
}

void CSSQuadValue::TraceAfterDispatch(webf::GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
