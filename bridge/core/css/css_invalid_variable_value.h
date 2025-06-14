// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_INVALID_VARIABLE_VALUE_H_
#define WEBF_CORE_CSS_CSS_INVALID_VARIABLE_VALUE_H_

#include "core/css/css_value.h"

// namespace WTF {
// class String;
//}  // namespace WTF

namespace webf {

// A value which represents custom properties that are invalid at computed-
// value time.
//
// https://drafts.csswg.org/css-variables/#invalid-at-computed-value-time
class CSSInvalidVariableValue : public CSSValue {
 public:
  static std::shared_ptr<const CSSInvalidVariableValue> Create();

  // Only construct through MakeGarbageCollected for the initial value. Use
  // Create() to get the pooled value.
  CSSInvalidVariableValue() : CSSValue(kInvalidVariableValueClass) {}

  std::string CustomCSSText() const;

  bool Equals(const CSSInvalidVariableValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValue::TraceAfterDispatch(visitor); }

 protected:
  explicit CSSInvalidVariableValue(ClassType class_type) : CSSValue(class_type) {}

 private:
  friend class CSSValuePool;
};

template <>
struct DowncastTraits<CSSInvalidVariableValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsInvalidVariableValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_INVALID_VARIABLE_VALUE_H_
