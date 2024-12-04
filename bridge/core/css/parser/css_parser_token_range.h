// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_TOKEN_RANGE_H
#define WEBF_CSS_PARSER_TOKEN_RANGE_H

#include <algorithm>
#include <cassert>
#include <span>
#include <utility>
#include <vector>
#include "core/base/containers/span.h"
#include "css_parser_token.h"

namespace webf {

extern const CSSParserToken& g_static_eof_token;

// A CSSParserTokenRange is an iterator over a subrange of a vector of
// CSSParserTokens. Accessing outside of the range will return an endless stream
// of EOF tokens. This class refers to half-open intervals [first, last).
class CSSParserTokenRange {
  WEBF_DISALLOW_NEW();

 public:
  CSSParserTokenRange(const std::vector<CSSParserToken>& vector)
      : first_(vector.data()), last_(vector.data() + vector.size()) {}
  explicit CSSParserTokenRange(tcb::span<CSSParserToken> tokens)
      : first_(tokens.data()), last_(tokens.data() + tokens.size()) {}

  // This should be called on a range with tokens returned by that range.
  CSSParserTokenRange MakeSubRange(const CSSParserToken* first, const CSSParserToken* last) const;

  bool AtEnd() const { return first_ == last_; }
  const CSSParserToken* end() const { return last_; }
  uint32_t size() const { return static_cast<uint32_t>(last_ - first_); }

  const CSSParserToken& Peek(uint32_t offset = 0) const {
    if (first_ + offset >= last_) {
      return g_static_eof_token;
    }
    return *(first_ + offset);
  }

  tcb::span<const CSSParserToken> RemainingSpan() const { return {first_, last_}; }

  const CSSParserToken& Consume() {
    if (first_ == last_) {
      return g_static_eof_token;
    }
    return *first_++;
  }

  const CSSParserToken& ConsumeIncludingWhitespace() {
    const CSSParserToken& result = Consume();
    ConsumeWhitespace();
    return result;
  }

  // The returned range doesn't include the brackets
  CSSParserTokenRange ConsumeBlock();

  void ConsumeComponentValue();

  void ConsumeWhitespace() {
    while (Peek().GetType() == kWhitespaceToken) {
      ++first_;
    }
  }

  std::string Serialize() const;

  const CSSParserToken* begin() const { return first_; }

  static void InitStaticEOFToken();

 private:
  CSSParserTokenRange(const CSSParserToken* first, const CSSParserToken* last) : first_(first), last_(last) {}

  const CSSParserToken* first_;
  const CSSParserToken* last_;
};

// An auxiliary class that can recover the exact string used for a set of
// tokens. It stores per-token offsets (such as from
// CSSTokenizer::TokenizeToEOFWithOffsets()) and a pointer to the original
// string (which must live for at least as long as this class), and from that,
// it can give you the exact string that a given token range came from.
class CSSParserTokenOffsets {
 public:
  template <uint32_t InlineBuffer>
  CSSParserTokenOffsets(const std::vector<CSSParserToken>& vector, std::vector<size_t> offsets, std::string_view string)
      : first_(&vector.front()), offsets_(std::move(offsets)), string_(string) {
    assert(vector.size() + 1 == offsets_.size());
  }
  CSSParserTokenOffsets(tcb::span<const CSSParserToken> tokens, std::vector<size_t> offsets, std::string_view string)
      : first_(tokens.data()), offsets_(std::move(offsets)), string_(string) {
    assert(tokens.size() + 1 == offsets_.size());
  }

  uint32_t OffsetFor(const CSSParserToken* token) const {
    assert(token >= first_);
    assert(token < first_ + offsets_.size() - 1);
    uint32_t token_index = static_cast<uint32_t>(token - first_);
    return offsets_[token_index];
  }

  std::string_view StringForTokens(const CSSParserToken* begin, const CSSParserToken* end) const {
    uint32_t begin_offset = OffsetFor(begin);
    uint32_t end_offset = OffsetFor(end);
    return std::string_view(string_.data() + begin_offset, end_offset - begin_offset);
  }

 private:
  const CSSParserToken* first_;
  std::vector<size_t> offsets_;
  std::string_view string_;
};

bool NeedsInsertedComment(const CSSParserToken& a, const CSSParserToken& b);

}  // namespace webf

#endif  // WEBF_CSS_PARSER_TOKEN_RANGE_H
