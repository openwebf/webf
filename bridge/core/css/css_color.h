// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_COLOR_H
#define WEBF_CSS_COLOR_H

#include "core/css/css_value.h"
#include "core/platform/graphics/color.h"
#include "foundation/casting.h"

namespace webf {


class CSSValuePool; // TODO(xiezuobing): core/css/css_value_pool.h

namespace cssvalue {

// Represents the non-keyword subset of <color>.
class CSSColor : public CSSValue {
 public:
  static CSSColor* Create(const Color& color);

  CSSColor(Color color) : CSSValue(kColorClass), color_(color) {}

  AtomicString CustomCSSText() const { return SerializeAsCSSComponentValue(color_); }

  Color Value() const { return color_; }

  bool Equals(const CSSColor& other) const { return color_ == other.color_; }

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }

  // Returns the color serialized according to CSSOM:
  // https://drafts.csswg.org/cssom/#serialize-a-css-component-value
  static AtomicString SerializeAsCSSComponentValue(Color color);

 private:
  friend class ::webf::CSSValuePool;

  Color color_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSColor> {
  static bool AllowFrom(const CSSValue& value) { return value.IsColorValue(); }
};


}  // namespace webf

#endif  // WEBF_CSS_COLOR_H
