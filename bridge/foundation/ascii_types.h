/*
 * Copyright (c) 2013, Opera Software ASA. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of Opera Software ASA nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <cstring>
#include <cassert>
#include "macros.h"

#ifndef BRIDGE_FOUNDATION_ASCII_TYPES_H_
#define BRIDGE_FOUNDATION_ASCII_TYPES_H_

namespace webf {

template <typename CharType>
inline bool IsASCII(CharType c) {
  return !(c & ~0x7F);
}

template <typename CharType>
inline bool IsASCIIAlpha(CharType c) {
  return (c | 0x20) >= 'a' && (c | 0x20) <= 'z';
}

template <typename CharType>
inline bool IsASCIIDigit(CharType c) {
  return c >= '0' && c <= '9';
}

template <typename CharType>
inline bool IsASCIIHexDigit(CharType c) {
  return IsASCIIDigit(c) || ((c | 0x20) >= 'a' && (c | 0x20) <= 'f');
}

template <typename CharType>
inline bool IsASCIIAlphanumeric(CharType c) {
  return IsASCIIDigit(c) || IsASCIIAlpha(c);
}

template <typename CharType>
inline int ToASCIIHexValue(CharType c) {
  assert(IsASCIIHexDigit(c));
  return c < 'A' ? c - '0' : (c - 'A' + 10) & 0xF;
}

/*
 Statistics from a run of Apple's page load test for callers of IsASCIISpace:

 character          count
 ---------          -----
 non-spaces         689383
 20  space          294720
 0A  \n             89059
 09  \t             28320
 0D  \r             0
 0C  \f             0
 0B  \v             0
 */
template <typename CharType>
inline bool IsASCIISpace(CharType c) {
  return c <= ' ' && (c == ' ' || (c <= 0xD && c >= 0x9));
}

template <typename CharType>
inline bool IsASCIIUpper(CharType c) {
  return c >= 'A' && c <= 'Z';
}

template <typename CharacterType>
inline bool IsLowerASCII(const CharacterType* characters, size_t length) {
  bool contains_upper_case = false;
  for (size_t i = 0; i < length; i++) {
    contains_upper_case |= IsASCIIUpper(characters[i]);
  }
  return !contains_upper_case;
}

template <typename CharacterType>
inline bool IsASCIILower(CharacterType character) {
  return character >= 'a' && character <= 'z';
}

template <typename CharacterType>
inline CharacterType ToASCIIUpper(CharacterType character) {
  return character & ~(IsASCIILower(character) << 5);
}

extern const unsigned char kASCIICaseFoldTable[256];

template <typename CharType>
inline CharType ToASCIILower(CharType c) {
  return c | ((c >= 'A' && c <= 'Z') << 5);
}


inline unsigned char ToASCIILower(unsigned char c) {
  return kASCIICaseFoldTable[c];
}

inline char ToASCIILower(char c) {
  return static_cast<char>(kASCIICaseFoldTable[static_cast<unsigned char>(c)]);
}

inline bool IsASCIIAlphaCaselessEqual(char css_character, char character) {
  // This function compares a (preferably) constant ASCII
  // lowercase letter to any input character.
  DCHECK_GE(character, 'a');
  DCHECK_LE(character, 'z');
  if ((css_character | 0x20) == character) [[likely]] {
    return true;
  }
  return false;
}

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_ASCII_TYPES_H_
