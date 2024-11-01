// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_LIGHT_DART_VALUE_PAIR_H_
#define WEBF_CORE_CSS_CSS_LIGHT_DART_VALUE_PAIR_H_

#include "core/css/css_value_pair.h"

namespace webf {

class CSSLightDarkValuePair : public CSSValuePair {
 public:
  CSSLightDarkValuePair(const std::shared_ptr<const CSSValue>& first, const std::shared_ptr<const CSSValue>& second)
      : CSSValuePair(kLightDarkValuePairClass, first, second) {}
  std::string CustomCSSText() const;
  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValuePair::TraceAfterDispatch(visitor); }
};

template <>
struct DowncastTraits<CSSLightDarkValuePair> {
  static bool AllowFrom(const CSSValue& value) { return value.IsLightDarkValuePair(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_LIGHT_DART_VALUE_PAIR_H_
