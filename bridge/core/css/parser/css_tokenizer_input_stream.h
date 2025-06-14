// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_TOKENIZER_INPUT_STREAM_H
#define WEBF_CSS_TOKENIZER_INPUT_STREAM_H

#include <cstdint>
#include "foundation/macros.h"
#include "foundation/string_view.h"

namespace webf {

class CSSTokenizerInputStream {
  USING_FAST_MALLOC(CSSTokenizerInputStream);

 public:
  explicit CSSTokenizerInputStream(const std::string& input) : string_length_(input.length()), string_(input){};
  explicit CSSTokenizerInputStream(std::string&& input)
      : string_length_(input.length()), string_impl_(std::move(input)), string_(string_impl_){};

  explicit CSSTokenizerInputStream(const std::string_view input) : string_length_(input.length()), string_(input) {}

  CSSTokenizerInputStream(const CSSTokenizerInputStream&) = delete;
  CSSTokenizerInputStream& operator=(const CSSTokenizerInputStream&) = delete;

  // Gets the char in the stream replacing NUL characters with a unicode
  // replacement character. Will return (NUL) kEndOfFileMarker when at the
  // end of the stream.
  [[nodiscard]] char NextInputChar() const {
    if (offset_ >= string_length_) {
      return '\0';
    }
    char result = string_[offset_];
    return result ? result : 0xFF;
  }

  // Gets the char at lookaheadOffset from the current stream position. Will
  // return NUL (kEndOfFileMarker) if the stream position is at the end.
  // NOTE: This may *also* return NUL if there's one in the input! Never
  // compare the return value to '\0'.
  [[nodiscard]] char PeekWithoutReplacement(unsigned lookahead_offset) const {
    if ((offset_ + lookahead_offset) >= string_length_) {
      return '\0';
    }
    return string_[offset_ + lookahead_offset];
  }

  [[nodiscard]] std::string_view Peek() const { return {string_.data() + offset_, string_.size() - offset_}; }

  void Advance(unsigned offset = 1) { offset_ += offset; }
  void PushBack(char cc) {
    --offset_;
    assert(NextInputChar() == cc);
  }

  double GetDouble(unsigned start, unsigned end) const;

  // Like GetDouble(), but only for the case where the number matches
  // [0-9]+ (no decimal point, no exponent, no sign), and is faster.
  double GetNaturalNumberAsDouble(unsigned start, unsigned end) const;

  template <bool characterPredicate(char)>
  unsigned SkipWhilePredicate(unsigned offset) {
    const char* characters8 = string_.data();
    while ((offset_ + offset) < string_length_ && characterPredicate(characters8[offset_ + offset])) {
      ++offset;
    }
    return offset;
  }

  void AdvanceUntilNonWhitespace();

  [[nodiscard]] unsigned length() const { return string_length_; }
  [[nodiscard]] uint32_t Offset() const { return offset_; }
  void Restore(uint32_t offset) { offset_ = offset; }

  [[nodiscard]] std::string_view RangeFrom(unsigned start) const {
    return {string_.data() + start, string_.size() - start};
  }

  [[nodiscard]] std::string_view RangeAt(unsigned start, unsigned length) const {
    assert(start + length <= string_length_);
    return {string_.data() + start, length};
  }

  void Restore(size_t offset) { offset_ = offset; }

 private:
  uint32_t offset_ = 0;
  const uint32_t string_length_;
  std::string string_impl_;
  std::string_view string_;
};

}  // namespace webf

#endif  // WEBF_CSS_TOKENIZER_INPUT_STREAM_H
