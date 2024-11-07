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

#ifndef WEBF_CORE_HTML_PARSER_HTML_PARSER_IDIOMS_H_
#define WEBF_CORE_HTML_PARSER_HTML_PARSER_IDIOMS_H_

#include <string>
#include <vector>
#include "core/base/compiler_specific.h"
#include "core/dom/qualified_name.h"
#include "foundation/decimal.h"

namespace webf {

// https://infra.spec.whatwg.org/#split-on-ascii-whitespace
std::vector<std::string> SplitOnASCIIWhitespace(const std::string&);

// An implementation of the HTML specification's algorithm to convert a number
// to a string for number and range types.
std::string SerializeForNumberType(const Decimal&);
std::string SerializeForNumberType(double);

// Convert the specified string to a decimal/double. If the conversion fails,
// the return value is fallback value or NaN if not specified. Leading or
// trailing illegal characters cause failure, as does passing an empty string.
// The double* parameter may be 0 to check if the string can be parsed without
// getting the result.
Decimal ParseToDecimalForNumberType(
    const std::string&,
    const Decimal& fallback_value = Decimal::Nan());
double ParseToDoubleForNumberType(
    const std::string&,
    double fallback_value = std::numeric_limits<double>::quiet_NaN());

// Space characters as defined by the HTML specification.
template <typename CharType>
inline bool IsHTMLSpace(CharType character) {
  // Histogram from Apple's page load test combined with some ad hoc browsing
  // some other test suites.
  //
  //     82%: 216330 non-space characters, all > U+0020
  //     11%:  30017 plain space characters, U+0020
  //      5%:  12099 newline characters, U+000A
  //      2%:   5346 tab characters, U+0009
  //
  // No other characters seen. No U+000C or U+000D, and no other control
  // characters. Accordingly, we check for non-spaces first, then space, then
  // newline, then tab, then the other characters.

  return character <= ' ' &&
         (character == ' ' || character == '\n' || character == '\t' ||
          character == '\r' || character == '\f');
}

template <typename CharType>
ALWAYS_INLINE bool IsHTMLSpecialWhitespace(CharType character) {
  return character <= '\r' && (character == '\r' || character == '\n' ||
                               character == '\t' || character == '\f');
}

template <typename CharType>
inline bool IsComma(CharType character) {
  return character == ',';
}

template <typename CharType>
inline bool IsColon(CharType character) {
  return character == ':';
}

template <typename CharType>
inline bool IsHTMLSpaceOrComma(CharType character) {
  return IsComma(character) || IsHTMLSpace(character);
}

inline bool IsHTMLLineBreak(char16_t character) {
  return character <= '\r' && (character == '\n' || character == '\r');
}

template <typename CharType>
inline bool IsNotHTMLSpace(CharType character) {
  return !IsHTMLSpace<CharType>(character);
}

template <typename CharType>
inline bool IsHTMLSpaceNotLineBreak(CharType character) {
  return IsHTMLSpace<CharType>(character) && !IsHTMLLineBreak(character);
}

}

#endif  // WEBF_CORE_HTML_PARSER_HTML_PARSER_IDIOMS_H_
