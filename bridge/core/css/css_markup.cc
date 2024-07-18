/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "css_markup.h"

namespace webf {

static void SerializeCharacterAsCodePoint(int32_t c, std::string& append_to) {
  char s[10];
  snprintf(s, 10, "\\%x ", c);

  append_to.append(s);
}

static void SerializeCharacter(int32_t c, std::string& append_to) {
  append_to.append(std::string(2, '\\'));
  append_to.append(std::string(1, (char) c));
}

/**
 * How many 16-bit code units are used to encode this Unicode code point? (1 or 2)
 * The result is not defined if c is not a Unicode code point (U+0000..U+10ffff).
 * @param c 32-bit code point
 * @return 1 or 2
 * @stable ICU 2.4
 */
#define U16_LENGTH(c) ((uint32_t)(c)<=0xffff ? 1 : 2)

void SerializeIdentifier(const std::string& identifier,
                         std::string& append_to,
                         bool skip_start_checks) {
  bool is_first = !skip_start_checks;
  bool is_second = false;
  bool is_first_char_hyphen = false;
  unsigned index = 0;
  while (index < identifier.length()) {
    char c = identifier.at(index);
    if (c == 0) {
      // Check for lone surrogate which characterStartingAt does not return.
      c = identifier[index];
    }

    index += U16_LENGTH(c);

    if (c == 0) {
      append_to.append(std::string(1, (char)0xfffd));
    } else if (c <= 0x1f || c == 0x7f ||
               (0x30 <= c && c <= 0x39 &&
                (is_first || (is_second && is_first_char_hyphen)))) {
      SerializeCharacterAsCodePoint(c, append_to);
    } else if (c == 0x2d && is_first && index == identifier.length()) {
      SerializeCharacter(c, append_to);
    } else if (0x80 <= c || c == 0x2d || c == 0x5f ||
               (0x30 <= c && c <= 0x39) || (0x41 <= c && c <= 0x5a) ||
               (0x61 <= c && c <= 0x7a)) {
      append_to.append(std::string(1, c));
    } else {
      SerializeCharacter(c, append_to);
    }

    if (is_first) {
      is_first = false;
      is_second = true;
      is_first_char_hyphen = (c == 0x2d);
    } else if (is_second) {
      is_second = false;
    }
  }
}

void SerializeString(const std::string& string, std::string& append_to) {
  append_to.append(1, '\"');

  unsigned index = 0;
  while (index < string.length()) {
    int32_t c = string.at(index);
    index += U16_LENGTH(c);

    if (c <= 0x1f || c == 0x7f) {
      SerializeCharacterAsCodePoint(c, append_to);
    } else if (c == 0x22 || c == 0x5c) {
      SerializeCharacter(c, append_to);
    } else {
      append_to.append(1, c);
    }
  }

  append_to.append(1, '\"');
}

std::string SerializeString(const std::string& string) {
  std::string builder;
  SerializeString(string, builder);
  return builder;
}

std::string SerializeURI(const std::string& string) {
  return "url(" + SerializeString(string) + ")";
}

std::string SerializeFontFamily(const AtomicString& string) {
  // Some <font-family> values are serialized without quotes.
  // See https://github.com/w3c/csswg-drafts/issues/5846
//  return (css_parsing_utils::IsCSSWideKeyword(string) ||
//          css_parsing_utils::IsDefaultKeyword(string) ||
//          FontFamily::InferredTypeFor(string) ==
//              FontFamily::Type::kGenericFamily ||
//          !IsCSSTokenizerIdentifier(string))
//             ? SerializeString(string)
//             : string;
}

}

