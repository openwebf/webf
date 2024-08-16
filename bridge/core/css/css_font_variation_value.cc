// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "css_font_variation_value.h"

#include "core/css/css_markup.h"

namespace webf {

namespace cssvalue {

CSSFontVariationValue::CSSFontVariationValue(const std::string& tag,
                                             float value)
    : CSSValue(kFontVariationClass), tag_(tag), value_(value) {}

std::string CSSFontVariationValue::CustomCSSText() const {
  std::string builder;
  SerializeString(tag_, builder);
  builder+=' ';
  builder+=value_;
  return builder;
}

bool CSSFontVariationValue::Equals(const CSSFontVariationValue& other) const {
  return tag_ == other.tag_ && value_ == other.value_;
}

}  // namespace cssvalue
}  // namespace webf