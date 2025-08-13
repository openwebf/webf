// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "css_font_family_value.h"

#include "core/css/css_markup.h"
#include "core/css/css_value_pool.h"

namespace webf {

std::shared_ptr<CSSFontFamilyValue> CSSFontFamilyValue::Create(const AtomicString& family_name) {
  CSSValuePool::FontFamilyValueCache font_family_cache_ = CssValuePool().GetFontFamilyCache();
  String family_name_string = family_name.GetString();
  auto it = font_family_cache_.find(family_name_string);
  if (it != font_family_cache_.end()) {
    return it->second;
  }
  auto new_value = std::make_shared<CSSFontFamilyValue>(family_name);
  font_family_cache_[family_name_string] = new_value;
  return new_value;
}

CSSFontFamilyValue::CSSFontFamilyValue(const AtomicString& str) : CSSValue(kFontFamilyClass), string_(str) {}

String CSSFontFamilyValue::CustomCSSText() const {
  return SerializeFontFamily(string_);
}

void CSSFontFamilyValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf