//
// Created by 谢作兵 on 12/06/24.
//

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
