// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef THIRD_PARTY_BLINK_RENDERER_CORE_CSS_PARSER_FONT_VARIANT_ALTERNATES_PARSER_H_
#define THIRD_PARTY_BLINK_RENDERER_CORE_CSS_PARSER_FONT_VARIANT_ALTERNATES_PARSER_H_

#include "core/css/css_alternate_value.h"
#include "core/css/css_value_list.h"

namespace webf {

class CSSParserContext;
class CSSIdentifierValue;
class CSSParserTokenStream;

class FontVariantAlternatesParser {
  WEBF_STACK_ALLOCATED();

 public:
  FontVariantAlternatesParser();

  enum class ParseResult { kConsumedValue, kDisallowedValue, kUnknownValue };

  ParseResult ConsumeAlternates(CSSParserTokenStream& stream,
                                std::shared_ptr<const CSSParserContext> context);

  std::shared_ptr<const CSSValue> FinalizeValue();

 private:
  bool ConsumeAlternate(CSSParserTokenStream& stream,
                        std::shared_ptr<const CSSParserContext> context);

  bool ConsumeHistoricalForms(CSSParserTokenStream& stream);

  std::shared_ptr<CSSValueList> alternates_list_;
  std::shared_ptr<cssvalue::CSSAlternateValue> stylistic_ = nullptr;
  std::shared_ptr<const CSSIdentifierValue> historical_forms_ = nullptr;
  std::shared_ptr<cssvalue::CSSAlternateValue> styleset_ = nullptr;
  std::shared_ptr<cssvalue::CSSAlternateValue> character_variant_ = nullptr;
  std::shared_ptr<cssvalue::CSSAlternateValue> swash_ = nullptr;
  std::shared_ptr<cssvalue::CSSAlternateValue> ornaments_ = nullptr;
  std::shared_ptr<cssvalue::CSSAlternateValue> annotation_ = nullptr;
};

}  // namespace blink

#endif  // THIRD_PARTY_BLINK_RENDERER_CORE_CSS_PARSER_FONT_VARIANT_ALTERNATES_PARSER_H_