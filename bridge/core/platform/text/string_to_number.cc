// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "string_to_number.h"
#include <cstddef>
#include <cassert>
#include <type_traits>
#include <unicode/uchar.h>
#include "foundation/ascii_types.h"
#include "foundation/string_builder.h"


namespace webf {

template <int base>
bool IsCharacterAllowedInBase(uint8_t);

template <>
bool IsCharacterAllowedInBase<10>(uint8_t c) {
  return IsASCIIDigit(c);
}

template <>
bool IsCharacterAllowedInBase<16>(uint8_t c) {
  return IsASCIIHexDigit(c);
}

inline bool IsSpaceOrNewline(uint8_t c) {
  return std::isspace(c);
}

template <typename IntegralType, int base>
static inline IntegralType ToIntegralType(const unsigned char* data,
                                          size_t length,
                                          NumberParsingOptions options,
                                          NumberParsingResult* parsing_result) {
  static_assert(std::is_integral<IntegralType>::value,
                "IntegralType must be an integral type.");
  static constexpr IntegralType kIntegralMax =
      std::numeric_limits<IntegralType>::max();
  static constexpr IntegralType kIntegralMin =
      std::numeric_limits<IntegralType>::min();
  static constexpr bool kIsSigned =
      std::numeric_limits<IntegralType>::is_signed;
  assert(parsing_result);

  IntegralType value = 0;
  NumberParsingResult result = NumberParsingResult::kError;
  bool is_negative = false;
  bool overflow = false;
  const bool accept_minus = kIsSigned || options.AcceptMinusZeroForUnsigned();

  if (!data)
    goto bye;

  if (options.AcceptWhitespace()) {
    while (length && IsSpaceOrNewline(*data)) {
      --length;
      ++data;
    }
  }

  if (accept_minus && length && *data == '-') {
    --length;
    ++data;
    is_negative = true;
  } else if (length && options.AcceptLeadingPlus() && *data == '+') {
    --length;
    ++data;
  }

  if (!length || !IsCharacterAllowedInBase<base>(*data))
    goto bye;

  while (length && IsCharacterAllowedInBase<base>(*data)) {
    --length;
    IntegralType digit_value;
    uint8_t c = *data;
    if (IsASCIIDigit(c))
      digit_value = c - '0';
    else if (c >= 'a')
      digit_value = c - 'a' + 10;
    else
      digit_value = c - 'A' + 10;

    if (is_negative) {
      if (!kIsSigned && options.AcceptMinusZeroForUnsigned()) {
        if (digit_value != 0) {
          result = NumberParsingResult::kError;
          overflow = true;
        }
      } else {
        // Overflow condition:
        //       value * base - digit_value < kIntegralMin
        //   <=> value < (kIntegralMin + digit_value) / base
        // We must be careful of rounding errors here, but the default rounding
        // mode (round to zero) works well, so we can use this formula as-is.
        if (value < (kIntegralMin + digit_value) / base) {
          result = NumberParsingResult::kOverflowMin;
          overflow = true;
        }
      }
    } else {
      // Overflow condition:
      //       value * base + digit_value > kIntegralMax
      //   <=> value > (kIntegralMax + digit_value) / base
      // Ditto regarding rounding errors.
      if (value > (kIntegralMax - digit_value) / base) {
        result = NumberParsingResult::kOverflowMax;
        overflow = true;
      }
    }

    if (!overflow) {
      if (is_negative)
        value = base * value - digit_value;
      else
        value = base * value + digit_value;
    }
    ++data;
  }

  if (options.AcceptWhitespace()) {
    while (length && IsSpaceOrNewline(*data)) {
      --length;
      ++data;
    }
  }

  if (length == 0 || options.AcceptTrailingGarbage()) {
    if (!overflow)
      result = NumberParsingResult::kSuccess;
  } else {
    // Even if we detected overflow, we return kError for trailing garbage.
    result = NumberParsingResult::kError;
  }
bye:
  *parsing_result = result;
  return result == NumberParsingResult::kSuccess ? value : 0;
}

template <typename IntegralType, int base>
static inline IntegralType ToIntegralType(const uint8_t* data,
                                          size_t length,
                                          NumberParsingOptions options,
                                          bool* ok) {
  NumberParsingResult result;
  IntegralType value = ToIntegralType<IntegralType, base>(
      data, length, options, &result);
  if (ok)
    *ok = result == NumberParsingResult::kSuccess;
  return value;
}

unsigned CharactersToUInt(const unsigned char* data,
                          size_t length,
                          NumberParsingOptions options,
                          NumberParsingResult* result) {
  return ToIntegralType<unsigned, 10>(data, length, options, result);
}


unsigned HexCharactersToUInt(const unsigned char* data,
                             size_t length,
                             NumberParsingOptions options,
                             bool* ok) {
  return ToIntegralType<unsigned, 16>(data, length, options, ok);
}

uint64_t HexCharactersToUInt64(const unsigned char* data,
                               size_t length,
                               NumberParsingOptions options,
                               bool* ok) {
  return ToIntegralType<uint64_t, 16>(data, length, options, ok);
}

int CharactersToInt(const unsigned char* data,
                    size_t length,
                    NumberParsingOptions options,
                    bool* ok) {
  return ToIntegralType<int, 10>(data, length, options, ok);
}

int CharactersToInt(const StringView& string,
                    NumberParsingOptions options,
                    bool* ok) {
  return VisitCharacters(
      string, [&](const auto* chars, uint32_t length) {
        return CharactersToInt(chars, length, options, ok);
      });
}

unsigned CharactersToUInt(const unsigned char* data,
                          size_t length,
                          NumberParsingOptions options,
                          bool* ok) {
  return ToIntegralType<unsigned, 10>(data, length, options, ok);
}

int64_t CharactersToInt64(const unsigned char* data,
                          size_t length,
                          NumberParsingOptions options,
                          bool* ok) {
  return ToIntegralType<int64_t, 10>(data, length, options, ok);
}

uint64_t CharactersToUInt64(const unsigned char* data,
                            size_t length,
                            NumberParsingOptions options,
                            bool* ok) {
  return ToIntegralType<uint64_t, 10>(data, length, options, ok);
}

double ParseDouble(const unsigned char* string, size_t length, size_t& parsed_length) {
  std::string str(reinterpret_cast<const char*>(string), length);
  size_t idx;
  double d = std::stod(str, &idx);
  parsed_length = idx;
  return d;
}

enum TrailingJunkPolicy { kDisallowTrailingJunk, kAllowTrailingJunk };

template <TrailingJunkPolicy policy>
static inline double ToDoubleType(const unsigned char* data,
                                  size_t length,
                                  bool* ok,
                                  size_t& parsed_length) {
  size_t leading_spaces_length = 0;
  while (leading_spaces_length < length &&
         IsASCIISpace(data[leading_spaces_length]))
    ++leading_spaces_length;

  double number = ParseDouble(data + leading_spaces_length,
                              length - leading_spaces_length, parsed_length);
  if (!parsed_length) {
    if (ok)
      *ok = false;
    return 0.0;
  }

  parsed_length += leading_spaces_length;
  if (ok)
    *ok = policy == kAllowTrailingJunk || parsed_length == length;
  return number;
}

double CharactersToDouble(const char* data, size_t length, bool* ok) {
  size_t parsed_length;
  return ToDoubleType<kDisallowTrailingJunk>(reinterpret_cast<const unsigned char*>(data), length, ok,
                                                    parsed_length);
}

double CharactersToDouble(const unsigned char* data,
                          size_t length,
                          size_t& parsed_length) {
  return ToDoubleType<kAllowTrailingJunk>(data, length, nullptr,
                                                 parsed_length);
}

float CharactersToFloat(const unsigned char* data, size_t length, bool* ok) {
  // FIXME: This will return ok even when the string fits into a double but
  // not a float.
  size_t parsed_length;
  return static_cast<float>(ToDoubleType<kDisallowTrailingJunk>(
      data, length, ok, parsed_length));
}

float CharactersToFloat(const unsigned char* data,
                        size_t length,
                        size_t& parsed_length) {
  // FIXME: This will return ok even when the string fits into a double but
  // not a float.
  return static_cast<float>(ToDoubleType<kAllowTrailingJunk>(
      data, length, nullptr, parsed_length));
}

}  // namespace webf
