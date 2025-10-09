/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_TYPE_H
#define WEBF_TYPE_H

#include <string>
#include <string_view>
#include <cstring>

namespace webf {

// Latin1 chars
typedef unsigned char LChar;

struct Latin1CharTrait {
  using char_type  = LChar;
  using int_type   = unsigned int;
  using off_type   = std::ptrdiff_t;
  using pos_type   = std::size_t;
  using state_type = std::mbstate_t;

  static void assign(char_type& r, const char_type& a) noexcept { r = a; }
  static constexpr bool eq(char_type a, char_type b) noexcept { return a == b; }
  static constexpr bool lt(char_type a, char_type b) noexcept { return a < b; }

  static int compare(const char_type* s1, const char_type* s2, std::size_t n) noexcept {
    for (; n; --n, ++s1, ++s2) {
      if (*s1 < *s2) return -1;
      if (*s2 < *s1) return  1;
    }
    return 0;
  }
  static std::size_t length(const char_type* s) {
    const char_type* p = s; while (*p) ++p; return static_cast<std::size_t>(p - s);
  }
  static const char_type* find(const char_type* s, std::size_t n, const char_type& a) {
    for (; n; --n, ++s) if (*s == a) return s; return nullptr;
  }
  static char_type* move(char_type* d, const char_type* s, std::size_t n) {
    return static_cast<char_type*>(std::memmove(d, s, n));
  }
  static char_type* copy(char_type* d, const char_type* s, std::size_t n) {
    return static_cast<char_type*>(std::memcpy(d, s, n));
  }
  static char_type* assign(char_type* d, std::size_t n, char_type a) {
    for (std::size_t i = 0; i < n; ++i) d[i] = a; return d;
  }

  static constexpr int_type to_int_type(char_type c) noexcept { return c; }
  static constexpr char_type to_char_type(int_type c) noexcept { return static_cast<char_type>(c); }
  static constexpr bool eq_int_type(int_type a, int_type b) noexcept { return a == b; }
  static constexpr int_type eof() noexcept { return static_cast<int_type>(-1); }
  static constexpr int_type not_eof(int_type c) noexcept { return c == eof() ? 0 : c; }
};

// UTF16 units
typedef char16_t UChar;
// UTF8 units
typedef char UTF8Char;
// Unicode
typedef uint32_t UCharCodePoint;

// We want to explicit about the string types.
typedef std::basic_string<LChar> Latin1String;
typedef std::basic_string<UChar> UTF16String;
typedef std::basic_string<UTF8Char> UTF8String;

// We want to explicit about the string view types.
typedef std::basic_string_view<LChar, Latin1CharTrait> Latin1StringView;
typedef std::basic_string_view<UChar> UTF16StringView;
typedef std::basic_string_view<UTF8Char> UTF8StringView;

}

#endif  // WEBF_TYPE_H
