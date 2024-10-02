// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_tokenizer_input_stream.h"
#include "css_parser_idioms.h"
#include "core/platform/text/string_to_number.h"

namespace webf {

void CSSTokenizerInputStream::AdvanceUntilNonWhitespace() {
  // Using HTML space here rather than CSS space since we don't do preprocessing
  const char* characters = string_.data();
  while (offset_ < string_length_ && IsHTMLSpace(characters[offset_])) {
    ++offset_;
  }
}

double CSSTokenizerInputStream::GetDouble(unsigned start, unsigned end) const {
  assert(start <= end && ((offset_ + end) <= string_length_));
  bool is_result_ok = false;
  double result = 0.0;
  if (start < end) {
    result = CharactersToDouble(string_.data() + offset_ + start,
                                end - start, &is_result_ok);
  }
  return is_result_ok ? result : 0.0;
}

double CSSTokenizerInputStream::GetNaturalNumberAsDouble(unsigned int start, unsigned int end) const {
  assert(start <= end && ((offset_ + end) <= string_length_));

  // If this is an integer that is exactly representable in double
  // (10^14 is at most 47 bits of mantissa), we don't need all the
  // complicated rounding machinery of CharactersToDouble(),
  // and can do with a much faster variant.
  if (start < end && end - start <= 14) {
    const char* ptr = string_.data() + offset_ + start;
    double result = ptr[0] - '0';
    for (unsigned i = 1; i < end - start; ++i) {
      result = result * 10 + (ptr[i] - '0');
    }
    return result;
  } else {
    // Otherwise, just fall back to the slow path.
    return GetDouble(start, end);
  }
}

}  // namespace webf
