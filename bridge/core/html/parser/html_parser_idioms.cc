/*
 * Copyright (C) 2010 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1.  Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 2.  Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "html_parser_idioms.h"
#include "core/base/strings/string_number_conversions.h"
#include "foundation/dtoa.h"

namespace webf {

std::string StripLeadingAndTrailingHTMLSpaces(const std::optional<std::string>& string) {
  unsigned length = string.has_value() ? string->length() : 0;

  if (!length)
    return !string.has_value() ? string.value() : "";

  const auto* chars = string->c_str();

  unsigned num_leading_spaces = 0;
  unsigned num_trailing_spaces = 0;

  for (; num_leading_spaces < length; ++num_leading_spaces) {
    if (IsNotHTMLSpace(chars[num_leading_spaces]))
      break;
  }

  if (num_leading_spaces == length)
    return !string.has_value() ? string.value() : "";

  for (; num_trailing_spaces < length; ++num_trailing_spaces) {
    if (IsNotHTMLSpace(chars[length - num_trailing_spaces - 1]))
      break;
  }

  DCHECK_LT(num_leading_spaces + num_trailing_spaces, length);

  if (!(num_leading_spaces | num_trailing_spaces))
    return string.value();

  return string->substr(num_leading_spaces, length - (num_leading_spaces + num_trailing_spaces));
}

template <typename CharType, bool characterPredicate(CharType)>
void SkipWhile(const CharType*& position, const CharType* end) {
  while (position < end && characterPredicate(*position))
    ++position;
}

template <typename CharType, bool characterPredicate(CharType)>
void SkipUntil(const CharType*& position, const CharType* end) {
  while (position < end && !characterPredicate(*position))
    ++position;
}

// TODO(iclelland): Consider refactoring this into a general
// String::Split(predicate) method
std::vector<std::string> SplitOnASCIIWhitespace(const std::string& input) {
  std::vector<std::string> output;
  unsigned length = input.length();
  if (!length) {
    return output;
  }
  const auto* cursor = input.c_str();
  using CharacterType = std::decay_t<decltype(*cursor)>;
  const CharacterType* string_start = cursor;
  const CharacterType* string_end = cursor + length;
  SkipWhile<CharacterType, IsHTMLSpace>(cursor, string_end);
  while (cursor < string_end) {
    const CharacterType* token_start = cursor;
    SkipUntil<CharacterType, IsHTMLSpace>(cursor, string_end);
    output.push_back(input.substr((unsigned)(token_start - string_start), (unsigned)(cursor - token_start)));
    SkipWhile<CharacterType, IsHTMLSpace>(cursor, string_end);
  }
  return output;
}

std::string SerializeForNumberType(const Decimal& number) {
  if (number.IsZero()) {
    // Decimal::toString appends exponent, e.g. "0e-18"
    return number.IsNegative() ? "-0" : "0";
  }
  return number.ToString();
}

std::string SerializeForNumberType(double number) {
  NumberToStringBuffer buffer;

  // According to HTML5, "the best representation of the number n as a floating
  // point number" is a string produced by applying ToString() to n.
  return NumberToString(number, buffer);
}

Decimal ParseToDecimalForNumberType(const std::string& string, const Decimal& fallback_value) {
  // http://www.whatwg.org/specs/web-apps/current-work/#floating-point-numbers
  // and parseToDoubleForNumberType String::toDouble() accepts leading + and
  // whitespace characters, which are not valid here.
  const char first_character = string[0];
  if (first_character != '-' && first_character != '.' && !IsASCIIDigit(first_character))
    return fallback_value;

  const Decimal value = Decimal::FromString(string);
  if (!value.IsFinite())
    return fallback_value;

  // Numbers are considered finite IEEE 754 Double-precision floating point
  // values.
  const Decimal double_max = Decimal::FromDouble(std::numeric_limits<double>::max());
  if (value < -double_max || value > double_max)
    return fallback_value;

  // We return +0 for -0 case.
  return value.IsZero() ? Decimal(0) : value;
}

static double CheckDoubleValue(double value, bool valid, double fallback_value) {
  if (!valid)
    return fallback_value;

  // NaN and infinity are considered valid by String::toDouble, but not valid
  // here.
  if (!std::isfinite(value))
    return fallback_value;

  // Numbers are considered finite IEEE 754 Double-precision floating point
  // values.
  if (-std::numeric_limits<double>::max() > value || value > std::numeric_limits<double>::max())
    return fallback_value;

  // The following expression converts -0 to +0.
  return value ? value : 0;
}

double ParseToDoubleForNumberType(const std::string& string, double fallback_value) {
  // http://www.whatwg.org/specs/web-apps/current-work/#floating-point-numbers
  // String::toDouble() accepts leading + and whitespace characters, which are
  // not valid here.
  char first_character = string[0];
  if (first_character != '-' && first_character != '.' && !IsASCIIDigit(first_character))
    return fallback_value;
  if (string.ends_with('.'))
    return fallback_value;

  double value;
  bool valid = base::StringToDouble(string, &value);
  return CheckDoubleValue(value, valid, fallback_value);
}

template <typename CharacterType>
static bool ParseHTMLIntegerInternal(const CharacterType* position, const CharacterType* end, int& value) {}

template <typename CharacterType>
static bool IsSpaceOrDelimiter(CharacterType c) {
  return IsHTMLSpace(c) || c == ',' || c == ';';
}

template <typename CharacterType>
static bool IsNotSpaceDelimiterOrNumberStart(CharacterType c) {
  return !(IsSpaceOrDelimiter(c) || IsASCIIDigit(c) || c == '.' || c == '-');
}

static const char kCharsetString[] = "charset";
static const size_t kCharsetLength = sizeof("charset") - 1;

enum class MetaAttribute {
  kNone,
  kCharset,
  kPragma,
};

}  // namespace webf