// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_APPEARANCE_AUTO_BASE_SELECT_VALUE_PAIR_H_
#define WEBF_CORE_CSS_CSS_APPEARANCE_AUTO_BASE_SELECT_VALUE_PAIR_H_

#include "core/css/css_value_pair.h"

namespace webf {

class CSSAppearanceAutoBaseSelectValuePair : public CSSValuePair {
 public:
  explicit CSSAppearanceAutoBaseSelectValuePair(const std::shared_ptr<const CSSValue>& first,
                                                const std::shared_ptr<const CSSValue>& second)
      : CSSValuePair(kAppearanceAutoBaseSelectValuePairClass, first, second) {}
  std::string CustomCSSText() const;
  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValuePair::TraceAfterDispatch(visitor); }
};

template <>
struct DowncastTraits<CSSAppearanceAutoBaseSelectValuePair> {
  static bool AllowFrom(const CSSValue& value) { return value.IsAppearanceAutoBaseSelectValuePair(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_APPEARANCE_AUTO_BASE_SELECT_VALUE_PAIR_H_