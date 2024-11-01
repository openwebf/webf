// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CSS_PENDING_SUBSTITUTION_VALUE_H
#define WEBF_CSS_PENDING_SUBSTITUTION_VALUE_H

#include "css_property_names.h"
#include "core/css/css_unparsed_declaration_value.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {


namespace cssvalue {

class CSSPendingSubstitutionValue : public CSSValue {
 public:
  CSSPendingSubstitutionValue(CSSPropertyID shorthand_property_id,
                              std::shared_ptr<CSSUnparsedDeclarationValue> shorthand_value)
      : CSSValue(kPendingSubstitutionValueClass),
        shorthand_property_id_(shorthand_property_id),
        shorthand_value_(std::move(shorthand_value)) {}

  CSSUnparsedDeclarationValue* ShorthandValue() const {
    return shorthand_value_.get();
  }

  CSSPropertyID ShorthandPropertyId() const { return shorthand_property_id_; }

  bool Equals(const CSSPendingSubstitutionValue& other) const {
    return shorthand_value_ == other.shorthand_value_;
  }
  std::string CustomCSSText() const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  CSSPropertyID shorthand_property_id_;
  std::shared_ptr<CSSUnparsedDeclarationValue> shorthand_value_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSPendingSubstitutionValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsPendingSubstitutionValue();
  }
};

}  // namespace webf

#endif  // WEBF_CSS_PENDING_SUBSTITUTION_VALUE_H
