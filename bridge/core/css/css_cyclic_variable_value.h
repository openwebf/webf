// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_CYCLIC_VARIABLE_VALUE_H_
#define WEBF_CORE_CSS_CSS_CYCLIC_VARIABLE_VALUE_H_

#include "core/base/types/pass_key.h"
#include "core/css/css_invalid_variable_value.h"
#include "foundation/casting.h"

namespace webf {

class CSSValuePool;

// CSSCyclicVariableValue is a special case of CSSInvalidVariableValue which
// indicates that a custom property is invalid because it's in a cycle.
//
// https://drafts.csswg.org/css-variables/#cycles
class CSSCyclicVariableValue : public CSSInvalidVariableValue {
 public:
  static CSSCyclicVariableValue* Create();

  explicit CSSCyclicVariableValue(webf::PassKey<CSSValuePool>)
      : CSSInvalidVariableValue(kCyclicVariableValueClass) {}

  std::string CustomCSSText() const;

  bool Equals(const CSSCyclicVariableValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSInvalidVariableValue::TraceAfterDispatch(visitor);
  }

 private:
  friend class CSSValuePool;
};

template <>
struct DowncastTraits<CSSCyclicVariableValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsCyclicVariableValue();
  }
};

}  // namespace webf

#endif  // THIRD_PARTY_BLINK_RENDERER_CORE_CSS_CSS_CYCLIC_VARIABLE_VALUE_H_
