// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser_token.h"
#include <cassert>
#include "core/css/css_primitive_value.h"
#include "core/css/parser/css_property_parser.h"
#include "core/css/css_markup.h"

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

bool CSSParserToken::operator==(const CSSParserToken& other) const {
  if (type_ != other.type_) {
    return false;
  }
  switch (type_) {
    case kDelimiterToken:
      return Delimiter() == other.Delimiter();
    case kHashToken:
      if (hash_token_type_ != other.hash_token_type_) {
        return false;
      }
      [[fallthrough]];
    case kIdentToken:
    case kFunctionToken:
    case kStringToken:
    case kUrlToken:
      return ValueDataCharRawEqual(other);
    case kDimensionToken:
      if (!ValueDataCharRawEqual(other)) {
        return false;
      }
      [[fallthrough]];
    case kNumberToken:
    case kPercentageToken:
      return numeric_sign_ == other.numeric_sign_ &&
             numeric_value_ == other.numeric_value_ &&
             numeric_value_type_ == other.numeric_value_type_;
    case kUnicodeRangeToken:
      return unicode_range_.start == other.unicode_range_.start &&
             unicode_range_.end == other.unicode_range_.end;
    default:
      return true;
  }
}

char CSSParserToken::Delimiter() const {
  assert(type_ == static_cast<unsigned>(kDelimiterToken));
  return delimiter_;
}

NumericSign CSSParserToken::GetNumericSign() const {
  // This is valid for DimensionToken and PercentageToken, but only used
  // in <an+b> parsing on NumberTokens.
  assert(type_ == static_cast<unsigned>(kNumberToken));
  return static_cast<NumericSign>(numeric_sign_);
}

NumericValueType CSSParserToken::GetNumericValueType() const {
  assert(type_ == kNumberToken || type_ == kPercentageToken ||
         type_ == kDimensionToken);
  return static_cast<NumericValueType>(numeric_value_type_);
}

double CSSParserToken::NumericValue() const {
  assert(type_ == kNumberToken || type_ == kPercentageToken ||
         type_ == kDimensionToken);
  return numeric_value_;
}

CSSValueID CSSParserToken::Id() const {
  if (type_ != kIdentToken) {
    return CSSValueID::kInvalid;
  }
  if (id_ < 0) {
    id_ = static_cast<int>(CssValueKeywordID(Value()));
  }
  return static_cast<CSSValueID>(id_);
}

CSSValueID CSSParserToken::FunctionId() const {
  if (type_ != kFunctionToken) {
    return CSSValueID::kInvalid;
  }
  if (id_ < 0) {
    id_ = static_cast<int>(CssValueKeywordID(Value()));
  }
  return static_cast<CSSValueID>(id_);
}

bool CSSParserToken::HasStringBacking() const {
  CSSParserTokenType token_type = GetType();
  if (value_is_inline_) {
    return false;
  }
  return token_type == kIdentToken || token_type == kFunctionToken ||
         token_type == kAtKeywordToken || token_type == kHashToken ||
         token_type == kUrlToken || token_type == kDimensionToken ||
         token_type == kStringToken;
}

CSSParserToken CSSParserToken::CopyWithUpdatedString(
    const StringView& string) const {
  CSSParserToken copy(*this);
  copy.InitValueFromStringView(string);
  return copy;
}

CSSPropertyID CSSParserToken::ParseAsUnresolvedCSSPropertyID(
    const ExecutingContext* execution_context,
    CSSParserMode mode) const {
  assert(type_ == static_cast<unsigned>(kIdentToken));
  return UnresolvedCSSPropertyID(execution_context, Value(), mode);
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
  // simple we handle some of the edge cases incorrectly (see comments below).
  switch (GetType()) {
    case kIdentToken:
      SerializeIdentifier(Value(), builder);
      break;
    case kFunctionToken:
      SerializeIdentifier(Value(), builder);
      builder.append("(");
      break;
    case kAtKeywordToken:
      builder.append("@");
      SerializeIdentifier(Value(), builder);
      break;
    case kHashToken:
      builder.append("#");
      SerializeIdentifier(Value(), builder,
                          (GetHashTokenType() == kHashTokenUnrestricted));
      break;
    case kUrlToken:
      builder.append("url(");
      SerializeIdentifier(Value(), builder);
      builder.append(")");
      break;
    case kDelimiterToken:
      if (Delimiter() == '\\') {
        builder.append("\\\n");
        break;
      }
      builder.append(std::string(1, Delimiter()));
      break;
    case kNumberToken:
      if (numeric_value_type_ == kIntegerValueType) {
        builder.append(std::to_string(ClampTo<int64_t>(NumericValue())));
        break;
      } else {
        std::string str = std::to_string(NumericValue());
        builder.append(str);
        // This wasn't parsed as an integer, so when we serialize it back,
        // it cannot be an integer. Otherwise, we would round-trip e.g.
        // “2.0” to “2”, which could make an invalid value suddenly valid.
        if (strchr(str.c_str(), '.') == nullptr && strchr(str.c_str(), 'e') == nullptr) {
          builder.append(".0");
        }
        return;
      }
    case kPercentageToken:
      builder.append(std::to_string(NumericValue()));
      builder.append("%");
      break;
    case kDimensionToken: {
      std::string str = std::to_string(NumericValue());
      builder.append(str);
      // NOTE: We don't need the same “.0” treatment as we did for
      // kNumberToken, as there are no situations where e.g. 2deg
      // would be valid but 2.0deg not.
      SerializeIdentifier(Value(), builder);
      break;
    }
    case kUnicodeRangeToken:
      char buffer[20];
      snprintf(buffer, 20, "U+%X-%X", UnicodeRangeStart(), UnicodeRangeEnd());
      builder.append(buffer);
      return;
    case kStringToken:
      return SerializeString(Value(), builder);
    case kIncludeMatchToken:
      builder.append("~=");
      return;
    case kDashMatchToken:
      builder.append("|=");
      return;
    case kPrefixMatchToken:
      builder.append("^=");
      return;
    case kSuffixMatchToken:
      builder.append("$=");
      return;
    case kSubstringMatchToken:
      builder.append("*=");
      return;
    case kColumnToken:
      builder.append("||");
      return;
    case kCDOToken:
      builder.append("<!--");
      return;
    case kCDCToken:
      builder.append("-->");
      return;
    case kBadStringToken:
      builder.append("'\n");
      return;
    case kBadUrlToken:
      builder.append("url(()");
      return;
    case kWhitespaceToken:
      builder.append(" ");
      return;
    case kColonToken:
      builder.append(":");
      return;
    case kSemicolonToken:
      builder.append(";");
      return;
    case kCommaToken:
      builder.append(",");
      return;
    case kLeftParenthesisToken:
      builder.append("(");
      return;
    case kRightParenthesisToken:
      builder.append(")");
      return;
    case kLeftBracketToken:
      builder.append("[");
      return;
    case kRightBracketToken:
      builder.append("]");
      return;
    case kLeftBraceToken:
      builder.append("{");
      return;
    case kRightBraceToken:
      builder.append("}");
      return;
    case kEOFToken:
    case kCommentToken:
      assert(false);
      return;
  }
}

}  // namespace webf
