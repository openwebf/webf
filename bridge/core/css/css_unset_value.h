// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_UNSET_VALUE_H
#define WEBF_CSS_UNSET_VALUE_H


#include "core/base/types/pass_key.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {

class CSSValuePool;

namespace cssvalue {

class CSSUnsetValue : public CSSValue {
 public:
  static std::shared_ptr<const CSSUnsetValue> Create();

  explicit CSSUnsetValue(webf::PassKey<CSSValuePool>) : CSSValue(kUnsetClass) {}

  std::string CustomCSSText() const;

  bool Equals(const CSSUnsetValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSUnsetValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsUnsetValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_UNSET_VALUE_H
