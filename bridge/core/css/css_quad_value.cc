// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_quad_value.h"
#include "../../foundation/string/string_builder.h"

namespace webf {

String CSSQuadValue::CustomCSSText() const {
  String top = top_->CssText();
  String right = right_->CssText();
  String bottom = bottom_->CssText();
  String left = left_->CssText();

  if (serialization_type_ == TypeForSerialization::kSerializeAsRect) {
    StringBuilder result;
    result.Append("rect("_s);
    result.Append(top);
    result.Append(", "_s);
    result.Append(right);
    result.Append(", "_s);
    result.Append(bottom);
    result.Append(", "_s);
    result.Append(left);
    result.Append(")"_s);
    return result.ReleaseString();
  }

  StringBuilder result;
  result.Append(top);
  if (right != top || bottom != top || left != top) {
    result.Append(" "_s);
    result.Append(right);
    if (bottom != top || right != left) {
      result.Append(" "_s);
      result.Append(bottom);
      if (left != right) {
        result.Append(" "_s);
        result.Append(left);
      }
    }
  }
  return result.ReleaseString();
}

void CSSQuadValue::TraceAfterDispatch(webf::GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
