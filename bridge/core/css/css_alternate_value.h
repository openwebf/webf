// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_ALTERNATE_VALUE_H
#define WEBF_CSS_ALTERNATE_VALUE_H

#include "core/css/css_custom_ident_value.h"
#include "core/css/css_function_value.h"
#include "foundation/casting.h"

namespace webf {

namespace cssvalue {

// A function-like entry in the font-variant-alternates property.
// https://drafts.csswg.org/css-fonts-4/#font-variant-alternates-prop
class CSSAlternateValue : public CSSValue {
 public:
  CSSAlternateValue(std::shared_ptr<const CSSFunctionValue>& function, std::shared_ptr<const CSSValueList>& alias_list);

  const CSSFunctionValue& Function() const { return *function_; }
  const CSSValueList& Aliases() const { return *aliases_; }

  std::string CustomCSSText() const;
  bool Equals(const CSSAlternateValue&) const;

  void TraceAfterDispatch(GCVisitor* visitor) const {
    //    visitor->Trace(function_);
    //    visitor->Trace(aliases_);
    CSSValue::TraceAfterDispatch(visitor);
  }

 private:
  std::shared_ptr<const CSSFunctionValue> function_;
  std::shared_ptr<const CSSValueList> aliases_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSAlternateValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsAlternateValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_ALTERNATE_VALUE_H
