/*
 * Copyright (C) 2017 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CSS_FONT_STYLE_RANGE_VALUE_H
#define WEBF_CSS_FONT_STYLE_RANGE_VALUE_H

#include "core/css/css_identifier_value.h"
#include "core/css/css_value_list.h"
#include "foundation/casting.h"

namespace webf {

namespace cssvalue {

class CSSFontStyleRangeValue final : public CSSValue {
 public:
  CSSFontStyleRangeValue(const std::shared_ptr<const CSSIdentifierValue>& font_style_value,
                         const std::shared_ptr<const CSSValueList>& oblique_values)
      : CSSValue(kFontStyleRangeClass), font_style_value_(font_style_value), oblique_values_(oblique_values) {}

  CSSFontStyleRangeValue(const CSSIdentifierValue& font_style_value)
      : CSSValue(kFontStyleRangeClass), font_style_value_(&font_style_value), oblique_values_(nullptr) {}

  std::shared_ptr<const CSSIdentifierValue> GetFontStyleValue() const { return font_style_value_; }
  std::shared_ptr<const CSSValueList> GetObliqueValues() const { return oblique_values_; }

  std::string CustomCSSText() const;

  bool Equals(const CSSFontStyleRangeValue&) const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSIdentifierValue> font_style_value_;
  std::shared_ptr<const CSSValueList> oblique_values_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSFontStyleRangeValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsFontStyleRangeValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_FONT_STYLE_RANGE_VALUE_H
