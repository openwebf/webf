// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_property_name.h"
#include "css_property.h"

namespace webf {

struct SameSizeAsCSSPropertyName {
  CSSPropertyID property_id_;
  std::string custom_property_name_;
};

static_assert(sizeof(CSSPropertyName) == sizeof(SameSizeAsCSSPropertyName));

bool CSSPropertyName::operator==(const CSSPropertyName& other) const {
  if (value_ != other.value_) {
    return false;
  }
  if (value_ != static_cast<int>(CSSPropertyID::kVariable)) {
    return true;
  }
  return custom_property_name_ == other.custom_property_name_;
}

std::string CSSPropertyName::ToString() const {
  if (IsCustomProperty()) {
    return custom_property_name_;
  }

  return CSSProperty::Get
}


}  // namespace webf
