/*
 * Copyright (C) 2013 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_IDIOMS_H
#define WEBF_CSS_PARSER_IDIOMS_H
#include "bindings/qjs/atomic_string.h"

namespace webf {

class CSSTokenizerInputStream;


// TODO: ---------------这个处理本来在html_parser_idioms中[start]--------------------
const char kEndOfFileMarker = 0;
// https://html.spec.whatwg.org/C/#parse-error-unexpected-null-character
const char16_t kReplacementCharacter = 0xFFFD;

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
// TODO: ---------------这个处理本来在html_parser_idioms中[end]--------------------

// Space characters as defined by the CSS specification.
// http://www.w3.org/TR/css3-syntax/#whitespace
inline bool IsCSSSpace(char16_t c) {
  return c == ' ' || c == '\t' || c == '\n';
}

inline bool IsCSSNewLine(char16_t cc) {
  // We check \r and \f here, since we have no preprocessing stage
  return (cc == '\r' || cc == '\n' || cc == '\f');
}

// https://drafts.csswg.org/css-syntax/#name-start-code-point
template <typename CharacterType>
bool IsNameStartCodePoint(CharacterType c) {
  return IsASCIIAlpha(c) || c == '_' || !IsASCII(c);
}

// https://drafts.csswg.org/css-syntax/#name-code-point
template <typename CharacterType>
bool IsNameCodePoint(CharacterType c) {
  return IsNameStartCodePoint(c) || IsASCIIDigit(c) || c == '-';
}

// https://drafts.csswg.org/css-syntax/#check-if-two-code-points-are-a-valid-escape
inline bool TwoCharsAreValidEscape(char16_t first, char16_t second) {
  return first == '\\' && !IsCSSNewLine(second);
}

// Consumes a single whitespace, if the stream is currently looking at a
// whitespace. Note that \r\n counts as a single whitespace, as we don't do
// input preprocessing as a separate step.
//
// See https://drafts.csswg.org/css-syntax-3/#input-preprocessing
void ConsumeSingleWhitespaceIfNext(CSSTokenizerInputStream&);

// https://drafts.csswg.org/css-syntax/#consume-an-escaped-code-point
int32_t ConsumeEscape(CSSTokenizerInputStream&);

// http://www.w3.org/TR/css3-syntax/#consume-a-name
AtomicString ConsumeName(CSSTokenizerInputStream&);

// https://drafts.csswg.org/css-syntax/#would-start-an-identifier
bool NextCharsAreIdentifier(char16_t, const CSSTokenizerInputStream&);

}  // namespace webf

#endif  // WEBF_CSS_PARSER_IDIOMS_H
