// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "css_pending_system_font_value.h"

#include "core/css/parser/css_parser_fast_path.h"
//#include "core/layout/layout_theme_font_provider.h"

namespace webf {

namespace cssvalue {

CSSPendingSystemFontValue::CSSPendingSystemFontValue(CSSValueID system_font_id)
    : CSSValue(kPendingSystemFontValueClass), system_font_id_(system_font_id) {
  DCHECK(CSSParserFastPaths::IsValidSystemFont(system_font_id));
}

// static
std::shared_ptr<CSSPendingSystemFontValue> CSSPendingSystemFontValue::Create(
    CSSValueID system_font_id) {
  return std::make_shared<CSSPendingSystemFontValue>(system_font_id);
}

const AtomicString& CSSPendingSystemFontValue::ResolveFontFamily() const {
  return AtomicString::Empty();
}

float CSSPendingSystemFontValue::ResolveFontSize(
    const Document* document) const {
  return 14;
}

std::string CSSPendingSystemFontValue::CustomCSSText() const {
  return "";
}

void CSSPendingSystemFontValue::TraceAfterDispatch(
    GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace cssvalue

}  // namespace webf