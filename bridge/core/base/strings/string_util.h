// Copyright 2013 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_STRING_UTIL_H
#define WEBF_STRING_UTIL_H

#include <cctype>
#include <string>
#include <string_view>
#include <type_traits>

namespace base {

bool StartsWith(std::string_view str, std::string_view search_for);
bool EndsWith(std::string_view str, std::string_view search_for);

size_t Find(const std::string_view needle, const std::string_view& haystack);

bool ReplaceChars(std::string_view input,
                  std::string_view replace_chars,
                  std::string_view replace_with,
                  std::string* output);

template <typename Char>
inline bool IsAsciiAlpha(Char c) {
  return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z');
}
template <typename Char>
inline bool IsAsciiUpper(Char c) {
  return c >= 'A' && c <= 'Z';
}
template <typename Char>
inline bool IsAsciiLower(Char c) {
  return c >= 'a' && c <= 'z';
}
template <typename Char>
inline bool IsAsciiDigit(Char c) {
  return c >= '0' && c <= '9';
}
template <typename Char>
inline bool IsAsciiAlphaNumeric(Char c) {
  return IsAsciiAlpha(c) || IsAsciiDigit(c);
}
template <typename Char>
inline bool IsAsciiPrintable(Char c) {
  return c >= ' ' && c <= '~';
}

template <typename Char>
inline bool IsAsciiControl(Char c) {
  if constexpr (std::is_signed_v<Char>) {
    if (c < 0) {
      return false;
    }
  }
  return c <= 0x1f || c == 0x7f;
}

// These threadsafe functions return references to globally unique empty
// strings.
//
// It is likely faster to construct a new empty string object (just a few
// instructions to set the length to 0) than to get the empty string instance
// returned by these functions (which requires threadsafe static access).
//
// Therefore, DO NOT USE THESE AS A GENERAL-PURPOSE SUBSTITUTE FOR DEFAULT
// CONSTRUCTORS. There is only one case where you should use these: functions
// which need to return a string by reference (e.g. as a class member
// accessor), and don't have an empty string to use (e.g. in an error case).
// These should not be used as initializers, function arguments, or return
// values for functions which return by value or outparam.
const std::string& EmptyString();

// Contains the set of characters representing whitespace in the corresponding
// encoding. Null-terminated. The ASCII versions are the whitespaces as defined
// by HTML5, and don't include control characters.
extern const wchar_t kWhitespaceWide[];  // Includes Unicode.
extern const char kWhitespaceASCII[];

// https://infra.spec.whatwg.org/#ascii-whitespace
extern const char kInfraAsciiWhitespace[];

// Null-terminated string representing the UTF-8 byte order mark.
extern const char kUtf8ByteOrderMark[];

// Determines the type of ASCII character, independent of locale (the C
// library versions will change based on locale).
template <typename Char>
constexpr bool IsAsciiWhitespace(Char c) {
  // kWhitespaceASCII is a null-terminated string.
  for (const char* cur = kWhitespaceASCII; *cur; ++cur) {
    if (*cur == c)
      return true;
  }
  return false;
}

// Returns whether `c` is a Unicode whitespace character.
// This cannot be used on eight-bit characters, since if they are ASCII you
// should call IsAsciiWhitespace(), and if they are from a UTF-8 string they may
// be individual units of a multi-unit code point.  Convert to 16- or 32-bit
// values known to hold the full code point before calling this.
template <typename Char>
requires(sizeof(Char) > 1) constexpr bool IsUnicodeWhitespace(Char c) {
  // kWhitespaceWide is a null-terminated string.
  for (const auto* cur = kWhitespaceWide; *cur; ++cur) {
    if (static_cast<typename std::make_unsigned_t<wchar_t>>(*cur) ==
        static_cast<typename std::make_unsigned_t<Char>>(c))
      return true;
  }
  return false;
}

template <typename Char>
inline bool IsUnicodeControl(Char c) {
  return IsAsciiControl(c) ||
         // C1 control characters: http://unicode.org/charts/PDF/U0080.pdf
         (c >= 0x80 && c <= 0x9F);
}

template <typename Char>
inline bool IsAsciiPunctuation(Char c) {
  return c > 0x20 && c < 0x7f && !IsAsciiAlphaNumeric(c);
}

template <typename Char>
inline bool IsHexDigit(Char c) {
  return (c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f');
}

bool ContainsOnlyASCIIOrEmpty(const std::string& string);

// ASCII-specific tolower.  The standard library's tolower is locale sensitive,
// so we don't want to use it here.
std::string ToLowerASCII(const std::string& string);

// ASCII-specific toupper.  The standard library's toupper is locale sensitive,
// so we don't want to use it here.
template <typename CharT, typename = std::enable_if_t<std::is_integral_v<CharT>>>
CharT ToUpperASCII(CharT c) {
  return (c >= 'a' && c <= 'z') ? static_cast<CharT>(c + 'A' - 'a') : c;
}

// DANGEROUS: Assumes ASCII or not base on the size of `Char`.  You should
// probably be explicitly calling IsUnicodeWhitespace() or IsAsciiWhitespace()
// instead!
template <typename Char>
inline bool IsWhitespace(Char c) {
  if constexpr (sizeof(Char) > 1) {
    return IsUnicodeWhitespace(c);
  } else {
    return IsAsciiWhitespace(c);
  }
}

inline bool EqualsCaseInsensitiveASCII(std::string_view a, std::string b) {
  return std::equal(a.begin(), a.end(), b.begin(), b.end(),
                    [](char lhs, char rhs) -> bool { return tolower(lhs) == tolower(rhs); });
}

}  // namespace base

#endif  // WEBF_STRING_UTIL_H
