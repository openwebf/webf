// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_REVERT_VALUE_H_
#define WEBF_CORE_CSS_CSS_REVERT_VALUE_H_

#include "core/base/types/pass_key.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace WTF {
class String;
}  // namespace WTF

namespace webf {

class CSSValuePool;

namespace cssvalue {

class CSSRevertValue : public CSSValue {
 public:
  static CSSRevertValue* Create();

  explicit CSSRevertValue(webf::PassKey<CSSValuePool>)
      : CSSValue(kRevertClass) {}

  std::string CustomCSSText() const;

  bool Equals(const CSSRevertValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSRevertValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsRevertValue(); }
};

}  // namespace blink

#endif  // WEBF_CORE_CSS_CSS_REVERT_VALUE_H_
