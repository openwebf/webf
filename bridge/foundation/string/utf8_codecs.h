/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_UTF8_CODECS_H
#define WEBF_UTF8_CODECS_H

#include <string_view>
#include <string>
#include <foundation/string/string_view.h>

#include "string_types.h"

namespace webf {

struct UTF8Codecs {
  // Check if the input fit in Latin1 range.
  // returns:
  // * -1 if you cannot fit in
  // * >=0 is the char count
  static int64_t FitsInLatin1Range(const UTF8StringView& input) {
    const auto* bytes = reinterpret_cast<const unsigned char*>(input.data());
    const size_t n = input.size();
    size_t i = 0;
    int64_t count = 0;

    while (i < n) {
      const unsigned char b0 = bytes[i];

      if (b0 < 0x80) {
        // ASCII
        ++i;
        ++count;
        continue;
      }

      // If it's 3 or 4 bytes, code point will be >= 0x800 -> not in Latin-1
      if ((b0 & 0xF8) == 0xF0 || (b0 & 0xF0) == 0xE0) {
        return -1;
      }

      // Must be 2-byte sequence (110xxxxx)
      if ((b0 & 0xE0) == 0xC0) {
        if (i + 1 >= n) return -1; // missing continuation

        const unsigned char b1 = bytes[i + 1];
        if ((b1 & 0xC0) != 0x80) return -1; // invalid continuation

        // Decode code point
        const uint32_t cp = ((b0 & 0x1F) << 6) | (b1 & 0x3F);

        // Overlong check and Latin-1 bound
        if (cp < 0x80 || cp > 0xFF) return -1;

        i += 2;
        ++count;
        continue;
      }

      // Any other leading byte pattern is invalid
      return -1;
    }

    return count;
  }

  // Check if the input UTF16 string is actually a latin1 string as well.
  static bool UTF16IsLatin1(const UTF16StringView& input) {
    UChar acc = 0;
    for (UChar c : input) acc |= c;
    return (acc & 0xFF00) == 0;
  }
  
  // Decode a UTF-8 byte sequence into UTF-16 (UChar = char16_t).
  // Invalid sequences are replaced with U+FFFD.
  static UTF16String Decode(const UTF8StringView& input) {
    std::u16string out;
    out.reserve(input.size()); // worst case ASCII -> 1:1

    const auto* bytes = reinterpret_cast<const unsigned char*>(input.data());
    const size_t n = input.size();
    size_t i = 0;

    auto emit_replacement = [&]() {
      out.push_back(static_cast<UChar>(0xFFFD));
    };

    while (i < n) {
      uint32_t cp = 0;
      const unsigned char b0 = bytes[i];

      if (b0 < 0x80) {
        // 1-byte (ASCII)
        out.push_back(static_cast<UChar>(b0));
        ++i;
        continue;
      }

      int needed = 0;
      uint32_t min_cp = 0;

      if ((b0 & 0xE0) == 0xC0) {        // 110xxxxx
        needed = 1;
        cp = b0 & 0x1F;
        min_cp = 0x80;
      } else if ((b0 & 0xF0) == 0xE0) { // 1110xxxx
        needed = 2;
        cp = b0 & 0x0F;
        min_cp = 0x800;
      } else if ((b0 & 0xF8) == 0xF0) { // 11110xxx
        needed = 3;
        cp = b0 & 0x07;
        min_cp = 0x10000;
      } else {
        // Invalid leading byte
        emit_replacement();
        ++i;
        continue;
      }

      // Check that continuation bytes exist
      if (i + static_cast<size_t>(needed) >= n) {
        emit_replacement();
        ++i; // consume the leading byte and continue
        continue;
      }

      bool ok = true;
      for (int k = 1; k <= needed; ++k) {
        unsigned char bx = bytes[i + k];
        if ((bx & 0xC0) != 0x80) {
          ok = false;
          break;
        }
        cp = (cp << 6) | (bx & 0x3F);
      }

      if (!ok) {
        emit_replacement();
        ++i; // consume the leading byte and continue
        continue;
      }

      // Move index past this sequence
      i += (1 + needed);

      // Check for overlong encodings and invalid ranges
      if (cp < min_cp || cp > 0x10FFFF || (cp >= 0xD800 && cp <= 0xDFFF)) {
        emit_replacement();
        continue;
      }

      if (cp <= 0xFFFF) {
        out.push_back(static_cast<UChar>(cp));
      } else {
        // Encode as UTF-16 surrogate pair
        cp -= 0x10000;
        auto high = static_cast<UChar>(0xD800 + ((cp >> 10) & 0x3FF));
        auto low = static_cast<UChar>(0xDC00 + (cp & 0x3FF));
        out.push_back(high);
        out.push_back(low);
      }
    }

    return out;
  }

  // Encode a UTF-16 unit sequence into UTF-8 string
  // Invalid sequences are replaced with U+FFFD
  static UTF8String EncodeUTF16(const UTF16StringView& input) {
    std::string out;
    out.reserve(input.size() * 3); // rough upper bound for typical text

    // Precomputed UTF-8 for U+FFFD (EF BF BD) to avoid recursive lambda.
    auto emit_replacement_utf8 = [&]() {
      out.push_back(static_cast<char>(0xEF));
      out.push_back(static_cast<char>(0xBF));
      out.push_back(static_cast<char>(0xBD));
    };

    auto emit_utf8 = [&](uint32_t cp) {
      if (cp <= 0x7F) {
        out.push_back(static_cast<char>(cp));
      } else if (cp <= 0x7FF) {
        out.push_back(static_cast<char>(0xC0 | (cp >> 6)));
        out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
      } else if (cp <= 0xFFFF) {
        out.push_back(static_cast<char>(0xE0 | (cp >> 12)));
        out.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F)));
        out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
      } else if (cp <= 0x10FFFF) {
        out.push_back(static_cast<char>(0xF0 | (cp >> 18)));
        out.push_back(static_cast<char>(0x80 | ((cp >> 12) & 0x3F)));
        out.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F)));
        out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
      } else {
        // Out of Unicode range: emit replacement character U+FFFD
        emit_replacement_utf8();
      }
    };

    const size_t n = input.size();
    for (size_t i = 0; i < n; ++i) {
      auto u = static_cast<uint32_t>(input[i]);

      // Handle surrogate pairs
      if (u >= 0xD800 && u <= 0xDBFF) { // high surrogate
        if (i + 1 < n) {
          auto u2 = static_cast<uint32_t>(input[i + 1]);
          if (u2 >= 0xDC00 && u2 <= 0xDFFF) { // low surrogate
            uint32_t cp = 0x10000 + (((u - 0xD800) << 10) | (u2 - 0xDC00));
            emit_utf8(cp);
            ++i; // consumed low surrogate
            continue;
          }
        }
        // Lone high surrogate -> replacement
        emit_utf8(0xFFFD);
        continue;
      }

      if (u >= 0xDC00 && u <= 0xDFFF) {
        // Lone low surrogate -> replacement
        emit_utf8(0xFFFD);
        continue;
      }

      // BMP code point
      emit_utf8(u);
    }

    return out;
  }

  // Encode a Latin1 char sequence into UTF-8 string
  static UTF8String EncodeLatin1(const Latin1StringView& input) {
    std::string out;
    out.reserve(input.size() * 2); // worst case for Latin-1 -> UTF-8

    const auto* bytes = reinterpret_cast<const unsigned char*>(input.data());
    const size_t n = input.size();

    for (size_t i = 0; i < n; ++i) {
      const unsigned char b = bytes[i];
      if (b < 0x80) {
        // ASCII maps 1:1
        out.push_back(static_cast<char>(b));
      } else {
        // Latin-1 byte 0x80..0xFF -> U+0080..U+00FF (2-byte UTF-8)
        out.push_back(static_cast<char>(0xC0 | (b >> 6)));
        out.push_back(static_cast<char>(0x80 | (b & 0x3F)));
      }
    }

    return out;
  }

  // Encode StringView
  static UTF8String Encode(const StringView& input) {
    if (input.Is8Bit()) {
      return EncodeLatin1({input.Characters8(), input.length()});
    }

    return EncodeUTF16({input.Characters16(), input.length()});
  }
};

}  // namespace webf

#endif  // WEBF_UTF8_CODECS_H
