// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CSS_SCROLL_VALUE_H
#define WEBF_CSS_SCROLL_VALUE_H

#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {
namespace cssvalue {

// https://drafts.csswg.org/scroll-animations-1/#scroll-notation
class CSSScrollValue : public CSSValue {
 public:
  CSSScrollValue(std::shared_ptr<const CSSValue> scroller, std::shared_ptr<const CSSValue> axis);

  std::shared_ptr<const CSSValue> Scroller() const { return scroller_; }
  std::shared_ptr<const CSSValue> Axis() const { return axis_; }

  std::string CustomCSSText() const;
  bool Equals(const CSSScrollValue&) const;
  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSValue> scroller_;
  std::shared_ptr<const CSSValue> axis_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSScrollValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsScrollValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_SCROLL_VALUE_H
