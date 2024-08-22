// Copyright 2013 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// This file defines utility functions for working with strings.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifdef UNSAFE_BUFFERS_BUILD
// TODO(crbug.com/40284755): Remove this and spanify to fix the errors.
#pragma allow_unsafe_buffers
#endif

#ifndef BASE_STRINGS_STRING_UTIL_H_
#define BASE_STRINGS_STRING_UTIL_H_

#include <stdarg.h>  // va_list
#include <stddef.h>
#include <stdint.h>

#include <concepts>
#include <initializer_list>
#include <memory>
#include <string>
#include <cctype>


namespace webf {

#define WHITESPACE_ASCII_NO_CR_LF      \
  0x09,     /* CHARACTER TABULATION */ \
      0x0B, /* LINE TABULATION */      \
      0x0C, /* FORM FEED (FF) */       \
      0x20  /* SPACE */

#define WHITESPACE_ASCII                                                  \
  WHITESPACE_ASCII_NO_CR_LF, /* Comment to make clang-format linebreak */ \
      0x0A,                  /* LINE FEED (LF) */                         \
      0x0D                   /* CARRIAGE RETURN (CR) */

const char kWhitespaceASCII[] = {WHITESPACE_ASCII, 0};

inline int snprintf(char* buffer, size_t size, const char* format, ...) {
  va_list arguments;
  va_start(arguments, format);
  int result = vsnprintf(buffer, size, format, arguments);
  va_end(arguments);
  return result;
}

// ASCII-specific tolower.  The standard library's tolower is locale sensitive,
// so we don't want to use it here.
template <typename CharT>
  requires(std::integral<CharT>)
constexpr CharT ToLowerASCII(CharT c) {
  //return internal::ToLowerASCII(c);
  return std::tolower(static_cast<unsigned char>(c));
}

// ASCII-specific toupper.  The standard library's toupper is locale sensitive,
// so we don't want to use it here.
template <typename CharT>
  requires(std::integral<CharT>)
CharT ToUpperASCII(CharT c) {
  return (c >= 'a' && c <= 'z') ? static_cast<CharT>(c + 'A' - 'a') : c;
}

enum TrimPositions {
  TRIM_NONE     = 0,
  TRIM_LEADING  = 1 << 0,
  TRIM_TRAILING = 1 << 1,
  TRIM_ALL      = TRIM_LEADING | TRIM_TRAILING,
};

// Indicates case sensitivity of comparisons. Only ASCII case insensitivity
// is supported. Full Unicode case-insensitive conversions would need to go in
// base/i18n so it can use ICU.
//
// If you need to do Unicode-aware case-insensitive StartsWith/EndsWith, it's
// best to call base::i18n::ToLower() or base::i18n::FoldCase() (see
// base/i18n/case_conversion.h for usage advice) on the arguments, and then use
// the results to a case-sensitive comparison.
enum class CompareCase {
  SENSITIVE,
  INSENSITIVE_ASCII,
};

// Determines the type of ASCII character, independent of locale (the C
// library versions will change based on locale).
template <typename Char>
inline bool IsAsciiWhitespace(Char c) {
  // kWhitespaceASCII is a null-terminated string.
  for (const char* cur = kWhitespaceASCII; *cur; ++cur) {
    if (*cur == c)
      return true;
  }
  return false;
}
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
  return (c >= '0' && c <= '9') ||
         (c >= 'A' && c <= 'F') ||
         (c >= 'a' && c <= 'f');
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

}  // namespace webf

#endif  // BASE_STRINGS_STRING_UTIL_H_
