// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_INITIAL_COLOR_VALUE_H_
#define WEBF_CORE_CSS_CSS_INITIAL_COLOR_VALUE_H_

#include "core/base/types/pass_key.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"
/*
namespace WTF {
class String;
}  // namespace WTF

 */

namespace webf {

class CSSValuePool;

// TODO(crbug.com/1046753): Remove this class when canvastext is supported.
class CSSInitialColorValue : public CSSValue {
 public:
  static CSSInitialColorValue* Create();

  explicit CSSInitialColorValue(webf::PassKey<CSSValuePool>)
      : CSSValue(kInitialColorValueClass) {}

  std::string CustomCSSText() const;

  bool Equals(const CSSInitialColorValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }

 private:
  friend class CSSValuePool;
};

template <>
struct DowncastTraits<CSSInitialColorValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsInitialColorValue();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_INITIAL_COLOR_VALUE_H_
