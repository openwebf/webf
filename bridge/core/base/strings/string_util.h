// Copyright 2013 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_STRING_UTIL_H
#define WEBF_STRING_UTIL_H

#include <string_view>
#include <cctype>
#include <string>
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
template <typename CharT>
requires(std::integral<CharT>)
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

inline bool EqualsCaseInsensitiveASCII(std::string_view a,
                                        std::string b) {
  return std::equal(a.begin(), a.end(), b.begin(), b.end(), [](char lhs, char rhs) -> bool {
    return tolower(lhs) == tolower(rhs);
  });
}


}  // namespace base

#endif  // WEBF_STRING_UTIL_H
