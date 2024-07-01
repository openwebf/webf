// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */


#include "css_parser_token.h"
#include <cassert>
#include "core/css/css_primitive_value.h"

namespace webf {

CSSParserToken::CSSParserToken(CSSParserTokenType type, unsigned char c)
    : type_(type),
      block_type_(kNotBlock),
      value_is_inline_(false),
      delimiter_(c) {
  assert(type_ == static_cast<unsigned>(kDelimiterToken));
}


CSSParserToken::CSSParserToken(HashTokenType type, StringView value)
    : type_(kHashToken),
      block_type_(kNotBlock),
      value_is_inline_(false),
      hash_token_type_(type) {
  InitValueFromStringView(value);
}

CSSParserToken::CSSParserToken(CSSParserTokenType type,
                               int32_t start,
                               int32_t end)
    : type_(kUnicodeRangeToken),
      block_type_(kNotBlock),
      value_is_inline_(false) {
  assert(type == kUnicodeRangeToken);
  unicode_range_.start = start;
  unicode_range_.end = end;
}


CSSParserToken::CSSParserToken(CSSParserTokenType type,
                               double numeric_value,
                               NumericValueType numeric_value_type,
                               NumericSign sign)
    : type_(type),
      block_type_(kNotBlock),
      numeric_value_type_(numeric_value_type),
      numeric_sign_(sign),
      unit_(static_cast<unsigned>(CSSPrimitiveValue::UnitType::kNumber)),
      value_is_inline_(false) {
  assert(type == kNumberToken);
  numeric_value_ =
      ClampTo<double>(numeric_value, -std::numeric_limits<float>::max(),
                      std::numeric_limits<float>::max());
}


char16_t CSSParserToken::Delimiter() const {
  assert(type_ == static_cast<unsigned>(kDelimiterToken));
  return delimiter_;
}

void CSSParserToken::ConvertToDimensionWithUnit(StringView unit) {
  assert(type_ == static_cast<unsigned>(kNumberToken));
  type_ = kDimensionToken;
  InitValueFromStringView(unit);
  unit_ = static_cast<unsigned>(CSSPrimitiveValue::StringToUnitType(unit));
}

void CSSParserToken::ConvertToPercentage() {
  assert(type_ == static_cast<unsigned>(kNumberToken));
  type_ = kPercentageToken;
  unit_ = static_cast<unsigned>(CSSPrimitiveValue::UnitType::kPercentage);
}

}  // namespace webf
