//
// Created by 谢作兵 on 12/06/24.
//

#include "css_tokenizer_input_stream.h"
#include "css_parser_idioms.h"
#include "core/platform/text/string_to_number.h"

namespace webf {


void CSSTokenizerInputStream::AdvanceUntilNonWhitespace() {
  // Using HTML space here rather than CSS space since we don't do preprocessing
  if (string_.Is8Bit()) {
    const char* characters = string_.Characters8();
    while (offset_ < string_length_ && IsHTMLSpace(characters[offset_])) {
      ++offset_;
    }
  } else {
    const char16_t * characters = string_.Characters16();
    while (offset_ < string_length_ && IsHTMLSpace(characters[offset_])) {
      ++offset_;
    }
  }
};

double CSSTokenizerInputStream::GetDouble(unsigned start, unsigned end) const {
  assert(start <= end && ((offset_ + end) <= string_length_));
  bool is_result_ok = false;
  double result = 0.0;
  if (start < end) {
    if (string_.Is8Bit()) {
      result = CharactersToDouble(string_.Characters8() + offset_ + start,
                                  end - start, &is_result_ok);
    } else {
      result = CharactersToDouble(string_.Characters16() + offset_ + start,
                                  end - start, &is_result_ok);
    }
  }
  // FIXME: It looks like callers ensure we have a valid number
  return is_result_ok ? result : 0.0;
}
}  // namespace webf