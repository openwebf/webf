// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_CONTENT_DISTRIBUTION_VALUE_H
#define WEBF_CSS_CONTENT_DISTRIBUTION_VALUE_H

#include "core/css/css_identifier_value.h"
#include "core/css/css_value.h"
#include "core/css/css_value_pair.h"
//#include "foundation/casting.h"

namespace webf {

namespace cssvalue {

class CSSContentDistributionValue : public CSSValue {
 public:
  CSSContentDistributionValue(CSSValueID distribution,
                              CSSValueID position,
                              CSSValueID overflow);

  CSSValueID Distribution() const { return distribution_; }

  CSSValueID Position() const { return position_; }

  CSSValueID Overflow() const { return overflow_; }

  std::string CustomCSSText() const;

  bool Equals(const CSSContentDistributionValue&) const;

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }

 private:
  CSSValueID distribution_;
  CSSValueID position_;
  CSSValueID overflow_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSContentDistributionValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsContentDistributionValue();
  }
};


}  // namespace webf

#endif  // WEBF_CSS_CONTENT_DISTRIBUTION_VALUE_H
