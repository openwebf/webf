// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_TOKEN_H
#define WEBF_CSS_PARSER_TOKEN_H

#include "foundation/string_builder.h"
#include "foundation/string_view.h"
#include "foundation/macros.h"
#include "core/css/css_primitive_value.h"
#include "css_value_keywords.h"
#include "css_property_names.h"
#include "at_rule_descriptors.h"

namespace webf {

enum CSSParserTokenType {
  kIdentToken = 0,
  kFunctionToken,
  kAtKeywordToken,
  kHashToken,
  kUrlToken,
  kBadUrlToken,
  kDelimiterToken,
  kNumberToken,
  kPercentageToken,
  kDimensionToken,
  kIncludeMatchToken,
  kDashMatchToken,
  kPrefixMatchToken,
  kSuffixMatchToken,
  kSubstringMatchToken,
  kColumnToken,
  kUnicodeRangeToken,
  kWhitespaceToken,
  kCDOToken,
  kCDCToken,
  kColonToken,
  kSemicolonToken,
  kCommaToken,
  kLeftParenthesisToken,
  kRightParenthesisToken,
  kLeftBracketToken,
  kRightBracketToken,
  kLeftBraceToken,
  kRightBraceToken,
  kStringToken,
  kBadStringToken,
  kEOFToken,
  kCommentToken,
};

enum NumericSign {
  kNoSign,
  kPlusSign,
  kMinusSign,
};

enum NumericValueType {
  kIntegerValueType,
  kNumberValueType,
};

enum HashTokenType {
  kHashTokenId,
  kHashTokenUnrestricted,
};

class CSSParserToken {
  USING_FAST_MALLOC(CSSParserToken);

 public:
  enum BlockType {
    kNotBlock,
    kBlockStart,
    kBlockEnd,
  };

  // NOTE: There are some fields that we don't actually use (marked here
  // as “Don't care”), but we still set them explicitly, since otherwise,
  // Clang works really hard to preserve their contents.
  explicit CSSParserToken(CSSParserTokenType type, BlockType block_type = kNotBlock)
      : type_(type),
        block_type_(block_type),
        numeric_value_type_(0),  // Don't care.
        numeric_sign_(0),        // Don't care.
        unit_(0),                // Don't care.
        value_is_inline_(false),
        padding_(0)             // Don't care.
  {}

  CSSParserToken(CSSParserTokenType type, std::string_view value, BlockType block_type = kNotBlock)
      : type_(type), block_type_(block_type) {
    InitValueFromStringView(value);
    id_ = -1;
  }
  CSSParserToken(CSSParserTokenType, int32_t,
                 int32_t);  // for UnicodeRangeToken

  CSSParserToken(CSSParserTokenType, double, NumericValueType, NumericSign);  // for NumberToken

  CSSParserToken(CSSParserTokenType, unsigned char);  // for DelimiterToken
  CSSParserToken(HashTokenType, std::string_view);

  bool operator==(const CSSParserToken& other) const;
  bool operator!=(const CSSParserToken& other) const {
    return !(*this == other);
  }

  // Converts NumberToken to DimensionToken.
  void ConvertToDimensionWithUnit(std::string_view);

  // Converts NumberToken to PercentageToken.
  void ConvertToPercentage();

  CSSParserTokenType GetType() const { return static_cast<CSSParserTokenType>(type_); }

  std::string_view Value() const {
    if (value_is_inline_) {
      return {reinterpret_cast<const char*>(value_data_char_inline_),
                        value_length_};
    }
    return {reinterpret_cast<const char*>(value_data_char_raw_),
            value_length_};
  }

  bool IsEOF() const { return type_ == static_cast<unsigned>(kEOFToken); }
  char Delimiter() const;

  NumericSign GetNumericSign() const;
  NumericValueType GetNumericValueType() const;
  double NumericValue() const;
  HashTokenType GetHashTokenType() const {
    assert(type_ == static_cast<unsigned>(kHashToken));
    return hash_token_type_;
  }
  BlockType GetBlockType() const { return static_cast<BlockType>(block_type_); }
  CSSPrimitiveValue::UnitType GetUnitType() const {
    return static_cast<CSSPrimitiveValue::UnitType>(unit_);
  }
  int32_t UnicodeRangeStart() const {
    assert(type_ == static_cast<unsigned>(kUnicodeRangeToken));
    return unicode_range_.start;
  }
  int32_t UnicodeRangeEnd() const {
    assert(type_ == static_cast<unsigned>(kUnicodeRangeToken));
    return unicode_range_.end;
  }
  CSSValueID Id() const;
  CSSValueID FunctionId() const;

  bool HasStringBacking() const;

  CSSPropertyID ParseAsUnresolvedCSSPropertyID(
      const ExecutingContext* execution_context,
      CSSParserMode mode = kHTMLStandardMode) const;
  AtRuleDescriptorID ParseAsAtRuleDescriptorID() const;

  void Serialize(StringBuilder&) const;

  CSSParserToken CopyWithUpdatedString(const std::string_view&) const;

  static CSSParserTokenType ClosingTokenType(CSSParserTokenType opening_type) {
    switch (opening_type) {
      case kFunctionToken:
      case kLeftParenthesisToken:
        return kRightParenthesisToken;
      case kLeftBracketToken:
        return kRightBracketToken;
      case kLeftBraceToken:
        return kRightBraceToken;
      default:
        assert(false);
        return kEOFToken;
    }
  }

  // For debugging/logging only.
  friend std::ostream& operator<<(std::ostream& stream,
                                  const CSSParserToken& token) {
    if (token.GetType() == kEOFToken) {
      return stream << "<EOF>";
    } else if (token.GetType() == kCommentToken) {
      return stream << "/* comment */";
    } else {
      StringBuilder sb;
      token.Serialize(sb);
      return stream << sb.ReleaseString();
    }
  }


 private:
  void InitValueFromStringView(std::string_view string) {
    value_length_ = string.length();
    if (value_length_ <= sizeof(value_data_char_inline_)) {
      memcpy(value_data_char_inline_, string.data(), value_length_);
      value_is_inline_ = true;
    } else {
      value_data_char_raw_ = string.data();
      value_is_inline_ = false;
    }
  }
  bool ValueDataCharRawEqual(const CSSParserToken& other) const;
  const void* ValueDataCharRaw() const {
    if (value_is_inline_) {
      return value_data_char_inline_;
    } else {
      return value_data_char_raw_;
    }
  }

  unsigned type_ : 6;                // CSSParserTokenType
  unsigned block_type_ : 2;          // BlockType
  unsigned numeric_value_type_ : 1;  // NumericValueType
  unsigned numeric_sign_ : 2;        // NumericSign
  unsigned unit_ : 7;                // CSSPrimitiveValue::UnitType

  // The variables below are only used if the token type is string-backed
  // (which depends on type_; see HasStringBacking() for the list).

  // Short strings (eight bytes or fewer) may be stored directly into the
  // CSSParserToken, freeing us from allocating a backing string for the
  // contents (saving RAM and a little time). If so, value_is_inline_
  // is set to mark that the buffer contains the string itself instead of
  // a pointer to the string. It also guarantees value_is_8bit_ == true.
  unsigned value_is_inline_ : 1;

  // These are free bits. You may take from them if you need.
  unsigned padding_ : 12;

  unsigned value_length_;
  union {
    char value_data_char_inline_[8];   // If value_is_inline_ is true.
    const void* value_data_char_raw_;  // Either LChar* or UChar*.
  };

  union {
    unsigned char delimiter_;
    HashTokenType hash_token_type_;
    // NOTE: For DimensionToken, this value stores the numeric part,
    // value_data_char_raw_ (or value_data_char_inline_) stores the
    // unit as text, and unit_ stores the unit as enum (assuming it
    // is a valid unit). So for e.g. “100px”, numeric_value_ = 100.0,
    // value_length_ = 2, value_data_char_inline_ = "px", and
    // unit_ = kPixels.
    double numeric_value_;
    mutable int id_;

    struct {
      int32_t start;
      int32_t end;
    } unicode_range_;
  };
};

}  // namespace webf

#endif  // WEBF_CSS_PARSER_TOKEN_H