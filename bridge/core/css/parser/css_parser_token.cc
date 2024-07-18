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

// Just a helper used for Delimiter tokens.
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

template <typename CharType>
FORCE_INLINE bool Equal(const CharType* a,
                         const CharType* b,
                         size_t length) {
  return std::equal(a, a + length, b);
}

bool CSSParserToken::ValueDataCharRawEqual(const webf::CSSParserToken& other) const {
  if (value_length_ != other.value_length_) {
    return false;
  }

  if (ValueDataCharRaw() == other.ValueDataCharRaw() &&
      value_is_8bit_ == other.value_is_8bit_) {
    return true;
  }

  return Equal(static_cast<const char *>(ValueDataCharRaw()),
        static_cast<const char*>(other.ValueDataCharRaw()),
        value_length_);
}

void CSSParserToken::Serialize(std::string& builder) const {
  // This is currently only used for @supports CSSOM. To keep our implementation
  //  // simple we handle some of the edge cases incorrectly (see comments below).
  //  switch (GetType()) {
  //    case kIdentToken:
  //      SerializeIdentifier(Value().ToString(), builder);
  //      break;
  //    case kFunctionToken:
  //      SerializeIdentifier(Value().ToString(), builder);
  //      return builder.Append('(');
  //    case kAtKeywordToken:
  //      builder.Append('@');
  //      SerializeIdentifier(Value().ToString(), builder);
  //      break;
  //    case kHashToken:
  //      builder.Append('#');
  //      SerializeIdentifier(Value().ToString(), builder,
  //                          (GetHashTokenType() == kHashTokenUnrestricted));
  //      break;
  //    case kUrlToken:
  //      builder.Append("url(");
  //      SerializeIdentifier(Value().ToString(), builder);
  //      return builder.Append(')');
  //    case kDelimiterToken:
  //      if (Delimiter() == '\\') {
  //        return builder.Append("\\\n");
  //      }
  //      return builder.Append(Delimiter());
  //    case kNumberToken:
  //      if (numeric_value_type_ == kIntegerValueType) {
  //        return builder.AppendNumber(ClampTo<int64_t>(NumericValue()));
  //      } else {
  //        NumberToStringBuffer buffer;
  //        const char* str = NumberToString(NumericValue(), buffer);
  //        builder.Append(str);
  //        // This wasn't parsed as an integer, so when we serialize it back,
  //        // it cannot be an integer. Otherwise, we would round-trip e.g.
  //        // “2.0” to “2”, which could make an invalid value suddenly valid.
  //        if (strchr(str, '.') == nullptr && strchr(str, 'e') == nullptr) {
  //          builder.Append(".0");
  //        }
  //        return;
  //      }
  //    case kPercentageToken:
  //      builder.AppendNumber(NumericValue());
  //      return builder.Append('%');
  //    case kDimensionToken: {
  //      // This will incorrectly serialize e.g. 4e3e2 as 4000e2
  //      NumberToStringBuffer buffer;
  //      const char* str = NumberToString(NumericValue(), buffer);
  //      builder.Append(str);
  //      // NOTE: We don't need the same “.0” treatment as we did for
  //      // kNumberToken, as there are no situations where e.g. 2deg
  //      // would be valid but 2.0deg not.
  //      SerializeIdentifier(Value().ToString(), builder);
  //      break;
  //    }
  //    case kUnicodeRangeToken:
  //      return builder.Append(
  //          String::Format("U+%X-%X", UnicodeRangeStart(), UnicodeRangeEnd()));
  //    case kStringToken:
  //      return SerializeString(Value().ToString(), builder);
  //
  //    case kIncludeMatchToken:
  //      return builder.Append("~=");
  //    case kDashMatchToken:
  //      return builder.Append("|=");
  //    case kPrefixMatchToken:
  //      return builder.Append("^=");
  //    case kSuffixMatchToken:
  //      return builder.Append("$=");
  //    case kSubstringMatchToken:
  //      return builder.Append("*=");
  //    case kColumnToken:
  //      return builder.Append("||");
  //    case kCDOToken:
  //      return builder.Append("<!--");
  //    case kCDCToken:
  //      return builder.Append("-->");
  //    case kBadStringToken:
  //      return builder.Append("'\n");
  //    case kBadUrlToken:
  //      return builder.Append("url(()");
  //    case kWhitespaceToken:
  //      return builder.Append(' ');
  //    case kColonToken:
  //      return builder.Append(':');
  //    case kSemicolonToken:
  //      return builder.Append(';');
  //    case kCommaToken:
  //      return builder.Append(',');
  //    case kLeftParenthesisToken:
  //      return builder.Append('(');
  //    case kRightParenthesisToken:
  //      return builder.Append(')');
  //    case kLeftBracketToken:
  //      return builder.Append('[');
  //    case kRightBracketToken:
  //      return builder.Append(']');
  //    case kLeftBraceToken:
  //      return builder.Append('{');
  //    case kRightBraceToken:
  //      return builder.Append('}');
  //
  //    case kEOFToken:
  //    case kCommentToken:
  //      NOTREACHED_IN_MIGRATION();
  //      return;
  //  }
}


}  // namespace webf
