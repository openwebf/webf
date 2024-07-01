// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_TOKEN_H
#define WEBF_CSS_PARSER_TOKEN_H

#include "foundation/webf_malloc.h"
#include "foundation/string_view.h"

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

  explicit CSSParserToken(CSSParserTokenType type,
                          BlockType block_type = kNotBlock)
      : type_(type),
        block_type_(block_type),
        numeric_value_type_(0),  // Don't care.
        numeric_sign_(0),        // Don't care.
        unit_(0),                // Don't care.
        value_is_inline_(false),
        value_is_8bit_(false),  // Don't care.
        padding_(0)             // Don't care.
  {}

  CSSParserToken(CSSParserTokenType type,
                 StringView value,
                 BlockType block_type = kNotBlock)
      : type_(type), block_type_(block_type) {
    InitValueFromStringView(value);
    id_ = -1;
  }
  CSSParserToken(CSSParserTokenType,
                 int32_t,
                 int32_t);  // for UnicodeRangeToken

  CSSParserToken(CSSParserTokenType, double, NumericValueType, NumericSign);  // for NumberToken

  CSSParserToken(CSSParserTokenType, unsigned char);  // for DelimiterToken
  CSSParserToken(HashTokenType, StringView);

  CSSParserTokenType GetType() const {
    return static_cast<CSSParserTokenType>(type_);
  }

  BlockType GetBlockType() const { return static_cast<BlockType>(block_type_); }

  StringView Value() const {
    if (value_is_inline_) {
      assert(value_is_8bit_);
      return StringView(reinterpret_cast<const char*>(value_data_char_inline_),
                        value_length_);
    }
    if (value_is_8bit_) {
      return StringView(reinterpret_cast<const char*>(value_data_char_raw_),
                        value_length_);
    }
    return StringView(reinterpret_cast<const char16_t*>(value_data_char_raw_),
                      value_length_);
  }

  bool IsEOF() const { return type_ == static_cast<unsigned>(kEOFToken); }
  char16_t Delimiter() const;

  // Converts NumberToken to DimensionToken.
  void ConvertToDimensionWithUnit(StringView);

  // Converts NumberToken to PercentageToken.
  void ConvertToPercentage();

 private:
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

  // value_... is an unpacked StringView so that we can pack it
  // tightly with the rest of this object for a smaller object size.
  unsigned value_is_8bit_ : 1;

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


  void InitValueFromStringView(StringView string) {
    value_length_ = string.length();
    value_is_8bit_ = string.Is8Bit();
    if (value_is_8bit_ && value_length_ <= sizeof(value_data_char_inline_)) {
      memcpy(value_data_char_inline_, string.Bytes(), value_length_);
      value_is_inline_ = true;
    } else {
      value_data_char_raw_ = string.Bytes();
      value_is_inline_ = false;
    }
  }
};

}  // namespace webf

#endif  // WEBF_CSS_PARSER_TOKEN_H
