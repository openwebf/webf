// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser_idioms.h"
#include "foundation/ascii_types.h"
#include "css_tokenizer_input_stream.h"

namespace webf {

void ConsumeSingleWhitespaceIfNext(CSSTokenizerInputStream& input) {
  // We check for \r\n and HTML spaces since we don't do preprocessing
  char next = input.PeekWithoutReplacement(0);
  if (next == '\r' && input.PeekWithoutReplacement(1) == '\n') {
    input.Advance(2);
  } else if (IsHTMLSpace(next)) {
    input.Advance();
  }
}

//// https://drafts.csswg.org/css-syntax/#consume-an-escaped-code-point
int32_t ConsumeEscape(CSSTokenizerInputStream& input) {
  char cc = input.NextInputChar();
  input.Advance();
  assert(!IsCSSNewLine(cc));
  if (IsASCIIHexDigit(cc)) {
    unsigned consumed_hex_digits = 1;
    std::string hex_chars;
    hex_chars.append(std::string(1, (char) cc));
    while (consumed_hex_digits < 6 &&
           IsASCIIHexDigit(input.PeekWithoutReplacement(0))) {
      cc = input.NextInputChar();
      input.Advance();
      hex_chars.append(std::string(1, char(cc)));
      consumed_hex_digits++;
    }
    ConsumeSingleWhitespaceIfNext(input);
    int32_t code_point = std::stoi(hex_chars);
    if (code_point == 0 || (0xD800 <= code_point && code_point <= 0xDFFF) ||
        code_point > 0x10FFFF) {
      return kReplacementCharacter;
    }
    return code_point;
  }

  if (cc == kEndOfFileMarker) {
    return kReplacementCharacter;
  }
  return cc;
}

//// http://www.w3.org/TR/css3-syntax/#consume-a-name
std::string ConsumeName(CSSTokenizerInputStream& input) {
  std::string result;
  while (true) {
    char cc = input.NextInputChar();
    input.Advance();
    if (IsNameCodePoint(cc)) {
      result.append(std::string(1, (char) cc));
      continue;
    }
    if (TwoCharsAreValidEscape(cc, input.PeekWithoutReplacement(0))) {
      result.append(std::string(1, (char) ConsumeEscape(input)));
      continue;
    }
    input.PushBack(cc);
    return result;
  }
}

// https://drafts.csswg.org/css-syntax/#would-start-an-identifier
bool NextCharsAreIdentifier(char first, const CSSTokenizerInputStream& input) {
  char second = input.PeekWithoutReplacement(0);
  if (IsNameStartCodePoint(first) || TwoCharsAreValidEscape(first, second)) {
    return true;
  }

  if (first == '-') {
    return IsNameStartCodePoint(second) || second == '-' ||
           TwoCharsAreValidEscape(second, input.PeekWithoutReplacement(1));
  }

  return false;
}

}  // namespace webf
