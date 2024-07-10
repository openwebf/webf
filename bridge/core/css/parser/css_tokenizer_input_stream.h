// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_TOKENIZER_INPUT_STREAM_H
#define WEBF_CSS_TOKENIZER_INPUT_STREAM_H

#include <cstdint>
#include "foundation/webf_malloc.h"
#include "foundation/string_view.h"
#include "bindings/qjs/atomic_string.h"

namespace webf {

class CSSTokenizerInputStream {
  USING_FAST_MALLOC(CSSTokenizerInputStream);

 public:
  explicit CSSTokenizerInputStream(const AtomicString& input)
      : string_length_(input.length()),
//        string_ref_(input.Impl()),
        string_(input.ToStringView()) {};

  double GetDouble(unsigned start, unsigned end) const;

  // Like GetDouble(), but only for the case where the number matches
  // [0-9]+ (no decimal point, no exponent, no sign), and is faster.
  double GetNaturalNumberAsDouble(unsigned start, unsigned end) const;

  template <bool characterPredicate(char16_t )>
  unsigned SkipWhilePredicate(unsigned offset) {
    if (string_.Is8Bit()) {
      const char* characters8 = string_.Characters8();
      while ((offset_ + offset) < string_length_ &&
             characterPredicate(characters8[offset_ + offset])) {
        ++offset;
      }
    } else {
      const char16_t * characters16 = string_.Characters16();
      while ((offset_ + offset) < string_length_ &&
             characterPredicate(characters16[offset_ + offset])) {
        ++offset;
      }
    }
    return offset;
  }


  StringView Peek() const {
    return StringView(string_, offset_, length() - offset_);
  }
  void Advance(unsigned offset = 1) { offset_ += offset; }

  unsigned length() const { return string_length_; }
  uint32_t Offset() const { return offset_; }
  void Restore(uint32_t offset) { offset_ = offset; }

  StringView RangeAt(unsigned start, unsigned length) const {
    assert(start + length <= string_length_);
    return StringView(string_, start, length);
  }


  // Gets the char in the stream replacing NUL characters with a unicode
  // replacement character. Will return (NUL) kEndOfFileMarker when at the
  // end of the stream.
  char16_t NextInputChar() const {
    if (offset_ >= string_length_) {
      return '\0';
    }
    char16_t result = string_[offset_];
    return result ? result : 0xFFFD;
  }


  // Gets the char at lookaheadOffset from the current stream position. Will
  // return NUL (kEndOfFileMarker) if the stream position is at the end.
  // NOTE: This may *also* return NUL if there's one in the input! Never
  // compare the return value to '\0'.
  char16_t PeekWithoutReplacement(unsigned lookahead_offset) const {
    if ((offset_ + lookahead_offset) >= string_length_) {
      return '\0';
    }
    return string_[offset_ + lookahead_offset];
  }

  void AdvanceUntilNonWhitespace();

  void PushBack(char16_t cc) {
    --offset_;
    assert(NextInputChar() == cc);
  }



 private:
  uint32_t offset_ = 0;
  const uint32_t string_length_;
  // Purely to hold on to the reference. Must be destroyed after the StringView
  // (i.e., be higher up in the list of members), or the StringView destructor
  // may DCHECK as it thinks the reference is dangling.
//  const scoped_refptr<StringImpl> string_ref_;
  StringView string_;
};

double CSSTokenizerInputStream::GetNaturalNumberAsDouble(unsigned start,
                                                         unsigned end) const {
  assert(start <= end && ((offset_ + end) <= string_length_));

  // If this is an integer that is exactly representable in double
  // (10^14 is at most 47 bits of mantissa), we don't need all the
  // complicated rounding machinery of CharactersToDouble(),
  // and can do with a much faster variant.
  if (start < end && string_.Is8Bit() && end - start <= 14) {
    const char* ptr = string_.Characters8() + offset_ + start;
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

#endif  // WEBF_CSS_TOKENIZER_INPUT_STREAM_H
