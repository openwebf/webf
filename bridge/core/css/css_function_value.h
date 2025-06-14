// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_FUNCTION_VALUE_H_
#define WEBF_CORE_CSS_CSS_FUNCTION_VALUE_H_

#include "core/css/css_value_list.h"
#include "css_value_keywords.h"

namespace webf {

class CSSFunctionValue : public CSSValueList {
 public:
  CSSFunctionValue(CSSValueID id) : CSSValueList(kFunctionClass, kCommaSeparator), value_id_(id) {}

  std::string CustomCSSText() const;

  bool Equals(const CSSFunctionValue& other) const {
    return value_id_ == other.value_id_ && CSSValueList::Equals(other);
  }
  CSSValueID FunctionType() const { return value_id_; }

  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValueList::TraceAfterDispatch(visitor); }

 private:
  const CSSValueID value_id_;
};

template <>
struct DowncastTraits<CSSFunctionValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsFunctionValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_FUNCTION_VALUE_H_