// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_property_name.h"
#include "core/css/properties/css_property.h"

namespace webf {

struct SameSizeAsCSSPropertyName {
  CSSPropertyID property_id_;
  std::string custom_property_name_;
  size_t custom_property_name_hash_value_{0};
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

const std::string CSSPropertyName::ToString() const {
  if (IsCustomProperty()) {
    return custom_property_name_;
  }

  return CSSProperty::Get(Id()).GetPropertyName();
}

unsigned int CSSPropertyName::GetHash() const {
  if (IsCustomProperty()) {
    if (custom_property_name_hash_value_ != 0) {
      return custom_property_name_hash_value_;
    }
    std::hash<std::string> hash_fn;
    custom_property_name_hash_value_ = hash_fn(custom_property_name_);
    return custom_property_name_hash_value_;
  }
  return value_;
}


}  // namespace webf
