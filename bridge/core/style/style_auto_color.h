/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_STYLE_STYLE_AUTO_COLOR_H_
#define WEBF_CORE_STYLE_STYLE_AUTO_COLOR_H_

#include <cassert>
#include "core/css/style_color.h"
#include "foundation/macros.h"

namespace webf {

class StyleAutoColor : public StyleColor {
  WEBF_DISALLOW_NEW();

 public:
  explicit StyleAutoColor(StyleColor&& color) : StyleColor(color) {}

  static StyleAutoColor AutoColor() {
    return StyleAutoColor(StyleColor(CSSValueID::kAuto));
  }

  bool IsAutoColor() const { return color_keyword_ == CSSValueID::kAuto; }

  const StyleColor& ToStyleColor() const {
    DCHECK(!IsAutoColor());
    return *this;
  }
};

inline bool operator==(const StyleAutoColor& a, const StyleAutoColor& b) {
  if (a.IsAutoColor() || b.IsAutoColor()) {
    return a.IsAutoColor() && b.IsAutoColor();
  }
  return a.ToStyleColor() == b.ToStyleColor();
}

inline bool operator!=(const StyleAutoColor& a, const StyleAutoColor& b) {
  return !(a == b);
}

}  // namespace webf

#endif  // WEBF_CORE_STYLE_STYLE_AUTO_COLOR_H_