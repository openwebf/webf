// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_content_distribution_value.h"

#include <iostream>
#include "core/css/css_value_list.h"

namespace webf {

namespace cssvalue {

CSSContentDistributionValue::CSSContentDistributionValue(CSSValueID distribution,
                                                         CSSValueID position,
                                                         CSSValueID overflow)
    : CSSValue(kCSSContentDistributionClass), distribution_(distribution), position_(position), overflow_(overflow) {}

std::string CSSContentDistributionValue::CustomCSSText() const {
  const std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();

  if (IsValidCSSValueID(distribution_)) {
    list->Append(CSSIdentifierValue::Create(distribution_));
  }
  if (IsValidCSSValueID(position_)) {
    if (position_ == CSSValueID::kFirstBaseline || position_ == CSSValueID::kLastBaseline) {
      CSSValueID preference = position_ == CSSValueID::kFirstBaseline ? CSSValueID::kFirst : CSSValueID::kLast;
      list->Append(CSSIdentifierValue::Create(preference));
      list->Append(CSSIdentifierValue::Create(CSSValueID::kBaseline));
    } else {
      if (IsValidCSSValueID(overflow_)) {
        list->Append(CSSIdentifierValue::Create(overflow_));
      }
      list->Append(CSSIdentifierValue::Create(position_));
    }
  }
  return list->CustomCSSText();
}

bool CSSContentDistributionValue::Equals(const CSSContentDistributionValue& other) const {
  return distribution_ == other.distribution_ && position_ == other.position_ && overflow_ == other.overflow_;
}

}  // namespace cssvalue
}  // namespace webf