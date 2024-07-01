//
// Created by 谢作兵 on 20/06/24.
//

#include "string_to_number.h"
#include <cstddef>
#include <cassert>
#include <type_traits>
#include <unicode/uchar.h>
#include "foundation/ascii_types.h"
#include "foundation/string_builder.h"


namespace webf {

template <int base>
bool IsCharacterAllowedInBase(uint16_t);

template <>
bool IsCharacterAllowedInBase<10>(uint16_t c) {
  return IsASCIIDigit(c);
}

template <>
bool IsCharacterAllowedInBase<16>(uint16_t c) {
  return IsASCIIHexDigit(c);
}

inline bool IsSpaceOrNewline(uint16_t c) {
  if (c <= 0x7F) {
    // 使用标准库函数处理ASCII字符
    return std::isspace(c);
  } else {
    // 使用ICU库函数处理非ASCII字符
    return u_isspace(c);
  }
}

template <typename IntegralType, typename CharType, int base>
static inline IntegralType ToIntegralType(const CharType* data,
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
    CharType c = *data;
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

template <typename IntegralType, typename CharType, int base>
static inline IntegralType ToIntegralType(const CharType* data,
                                          size_t length,
                                          NumberParsingOptions options,
                                          bool* ok) {
  NumberParsingResult result;
  IntegralType value = ToIntegralType<IntegralType, CharType, base>(
      data, length, options, &result);
  if (ok)
    *ok = result == NumberParsingResult::kSuccess;
  return value;
}


// Visits the characters of a WTF::String, StringView or compatible type.
//
// Intended to be used with a generic lambda or other functor overloaded to
// handle either LChar* or UChar*. Reduces code duplication in many cases.
// The functor should return the same type in both branches.
//
// Callers should ensure that characters exist (i.e. the string is not null)
// first.
//
// Example:
//
//   if (string.IsNull())
//     return false;
//
//   return WTF::VisitCharacters(string, [&](const auto* chars, unsigned len) {
//     bool contains_space = false;
//     for (unsigned i = 0; i < len; i++)
//       contains_space |= IsASCIISpace(chars[i]);
//     return contains_space;
//   });
//
// This will instantiate the functor for both LChar (8-bit) and UChar (16-bit)
// automatically.
template <typename StringType, typename Functor>
decltype(auto) VisitCharacters(const StringType& string,
                               const Functor& functor) {
  return string.Is8Bit() ? functor(string.Characters8(), string.length())
                         : functor(string.Characters16(), string.length());
}

unsigned CharactersToUInt(const unsigned char* data,
                          size_t length,
                          NumberParsingOptions options,
                          NumberParsingResult* result) {
  return ToIntegralType<unsigned, unsigned char, 10>(data, length, options, result);
}

unsigned CharactersToUInt(const uint16_t* data,
                          size_t length,
                          NumberParsingOptions options,
                          NumberParsingResult* result) {
  return ToIntegralType<unsigned, uint16_t, 10>(data, length, options, result);
}

unsigned HexCharactersToUInt(const unsigned char* data,
                             size_t length,
                             NumberParsingOptions options,
                             bool* ok) {
  return ToIntegralType<unsigned, unsigned char, 16>(data, length, options, ok);
}

unsigned HexCharactersToUInt(const uint16_t* data,
                             size_t length,
                             NumberParsingOptions options,
                             bool* ok) {
  return ToIntegralType<unsigned, uint16_t, 16>(data, length, options, ok);
}

uint64_t HexCharactersToUInt64(const unsigned char* data,
                               size_t length,
                               NumberParsingOptions options,
                               bool* ok) {
  return ToIntegralType<uint64_t, unsigned char, 16>(data, length, options, ok);
}

uint64_t HexCharactersToUInt64(const uint16_t* data,
                               size_t length,
                               NumberParsingOptions options,
                               bool* ok) {
  return ToIntegralType<uint64_t, uint16_t, 16>(data, length, options, ok);
}

int CharactersToInt(const unsigned char* data,
                    size_t length,
                    NumberParsingOptions options,
                    bool* ok) {
  return ToIntegralType<int, unsigned char, 10>(data, length, options, ok);
}

int CharactersToInt(const uint16_t* data,
                    size_t length,
                    NumberParsingOptions options,
                    bool* ok) {
  return ToIntegralType<int, uint16_t, 10>(data, length, options, ok);
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
  return ToIntegralType<unsigned, unsigned char, 10>(data, length, options, ok);
}

unsigned CharactersToUInt(const uint16_t* data,
                          size_t length,
                          NumberParsingOptions options,
                          bool* ok) {
  return ToIntegralType<unsigned, uint16_t, 10>(data, length, options, ok);
}

int64_t CharactersToInt64(const unsigned char* data,
                          size_t length,
                          NumberParsingOptions options,
                          bool* ok) {
  return ToIntegralType<int64_t, unsigned char, 10>(data, length, options, ok);
}

int64_t CharactersToInt64(const uint16_t* data,
                          size_t length,
                          NumberParsingOptions options,
                          bool* ok) {
  return ToIntegralType<int64_t, uint16_t, 10>(data, length, options, ok);
}

uint64_t CharactersToUInt64(const unsigned char* data,
                            size_t length,
                            NumberParsingOptions options,
                            bool* ok) {
  return ToIntegralType<uint64_t, unsigned char, 10>(data, length, options, ok);
}

uint64_t CharactersToUInt64(const uint16_t* data,
                            size_t length,
                            NumberParsingOptions options,
                            bool* ok) {
  return ToIntegralType<uint64_t, uint16_t, 10>(data, length, options, ok);
}


// 使用标准库函数实现从窄字符字符串解析为双精度浮点数
double ParseDouble(const char* string, size_t length, size_t& parsed_length) {
  std::string str(string, length);
  try {
    size_t idx;
    double d = std::stod(str, &idx);
    parsed_length = idx;
    return d;
  } catch (const std::invalid_argument&) {
    parsed_length = 0;
    return 0.0; // 或者抛出异常
  } catch (const std::out_of_range&) {
    parsed_length = 0;
    return 0.0; // 或者抛出异常
  }
}

// 使用标准库函数实现从宽字符字符串解析为双精度浮点数
double ParseDouble(const uint16_t * string, size_t length, size_t& parsed_length) {
  const size_t kConversionBufferSize = 64;
  if (length > kConversionBufferSize) {
    // 当字符串长度超过缓冲区大小时，调用其他函数处理
    return ParseDoubleFromLongString(string, length, parsed_length);
  }
  char conversion_buffer[kConversionBufferSize];
  std::wcstombs(conversion_buffer, string, length);
  return ParseDouble(conversion_buffer, length, parsed_length);
}

enum TrailingJunkPolicy { kDisallowTrailingJunk, kAllowTrailingJunk };

template <typename CharType, TrailingJunkPolicy policy>
static inline double ToDoubleType(const CharType* data,
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

double CharactersToDouble(const unsigned char* data, size_t length, bool* ok) {
  size_t parsed_length;
  return ToDoubleType<unsigned char, kDisallowTrailingJunk>(data, length, ok,
                                                    parsed_length);
}

double CharactersToDouble(const uint16_t* data, size_t length, bool* ok) {
  size_t parsed_length;
  return ToDoubleType<uint16_t, kDisallowTrailingJunk>(data, length, ok,
                                                    parsed_length);
}

double CharactersToDouble(const unsigned char* data,
                          size_t length,
                          size_t& parsed_length) {
  return ToDoubleType<unsigned char, kAllowTrailingJunk>(data, length, nullptr,
                                                 parsed_length);
}

double CharactersToDouble(const uint16_t* data,
                          size_t length,
                          size_t& parsed_length) {
  return ToDoubleType<uint16_t, kAllowTrailingJunk>(data, length, nullptr,
                                                 parsed_length);
}

float CharactersToFloat(const unsigned char* data, size_t length, bool* ok) {
  // FIXME: This will return ok even when the string fits into a double but
  // not a float.
  size_t parsed_length;
  return static_cast<float>(ToDoubleType<unsigned char, kDisallowTrailingJunk>(
      data, length, ok, parsed_length));
}

float CharactersToFloat(const uint16_t* data, size_t length, bool* ok) {
  // FIXME: This will return ok even when the string fits into a double but
  // not a float.
  size_t parsed_length;
  return static_cast<float>(ToDoubleType<uint16_t, kDisallowTrailingJunk>(
      data, length, ok, parsed_length));
}

float CharactersToFloat(const unsigned char* data,
                        size_t length,
                        size_t& parsed_length) {
  // FIXME: This will return ok even when the string fits into a double but
  // not a float.
  return static_cast<float>(ToDoubleType<unsigned char, kAllowTrailingJunk>(
      data, length, nullptr, parsed_length));
}

float CharactersToFloat(const uint16_t* data,
                        size_t length,
                        size_t& parsed_length) {
  // FIXME: This will return ok even when the string fits into a double but
  // not a float.
  return static_cast<float>(ToDoubleType<uint16_t, kAllowTrailingJunk>(
      data, length, nullptr, parsed_length));
}

}  // namespace webf