// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CSS_FONT_FAMILY_VALUE_H
#define WEBF_CSS_FONT_FAMILY_VALUE_H

#include "core/css/css_value.h"
#include "foundation/casting.h"
namespace webf {

class CSSFontFamilyValue : public CSSValue {
 public:
  static std::shared_ptr<CSSFontFamilyValue> Create(const std::string& family_name);

  explicit CSSFontFamilyValue(const std::string&);

  const std::string& Value() const { return string_; }

  std::string CustomCSSText() const;

  bool Equals(const CSSFontFamilyValue& other) const {
    return string_ == other.string_;
  }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  friend class CSSValuePool;

  std::string string_;
};

template <>
struct DowncastTraits<CSSFontFamilyValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsFontFamilyValue();
  }
};
}  // namespace webf

#endif  // WEBF_CSS_FONT_FAMILY_VALUE_H
