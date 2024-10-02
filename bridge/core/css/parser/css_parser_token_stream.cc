// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser_token_stream.h"

namespace webf {

std::string_view CSSParserTokenStream::StringRangeAt(size_t start, size_t length) const {
  return tokenizer_.StringRangeAt(start, length);
}

std::string_view CSSParserTokenStream::RemainingText() const {
  size_t start = HasLookAhead() ? LookAheadOffset() : Offset();
  return tokenizer_.StringRangeFrom(start);
}

void CSSParserTokenStream::ConsumeWhitespace() {
  while (Peek().GetType() == kWhitespaceToken) {
    UncheckedConsume();
  }
}

CSSParserToken CSSParserTokenStream::ConsumeIncludingWhitespace() {
  CSSParserToken result = Consume();
  ConsumeWhitespace();
  return result;
}

CSSParserToken CSSParserTokenStream::ConsumeIncludingWhitespaceRaw() {
  CSSParserToken result = ConsumeRaw();
  ConsumeWhitespace();
  return result;
}

bool CSSParserTokenStream::ConsumeCommentOrNothing() {
  assert(!HasLookAhead());
  const auto token = tokenizer_.TokenizeSingleWithComments();
  if (token.GetType() != kCommentToken) {
    next_ = token;
    has_look_ahead_ = true;
    return false;
  }

  has_look_ahead_ = false;
  offset_ = tokenizer_.Offset();
  return true;
}

void CSSParserTokenStream::UncheckedConsumeComponentValue() {
  assert(HasLookAhead());

  // Have to use internal consume/peek in here because they can read past
  // start/end of blocks
  unsigned nesting_level = 0;
  do {
    const CSSParserToken& token = UncheckedConsumeInternal();
    if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      nesting_level++;
    } else if (token.GetBlockType() == CSSParserToken::kBlockEnd) {
      nesting_level--;
    }
  } while (!PeekInternal().IsEOF() && nesting_level);
}


void CSSParserTokenStream::UncheckedSkipToEndOfBlock() {
  assert(HasLookAhead());

  // Process and consume the lookahead token.
  has_look_ahead_ = false;
  unsigned nesting_level = 1;
  if (next_.GetBlockType() == CSSParserToken::kBlockStart) {
    nesting_level++;
  } else if (next_.GetBlockType() == CSSParserToken::kBlockEnd) {
    nesting_level--;
  }

  // Skip tokens until we see EOF or the closing brace.
  while (nesting_level != 0) {
    CSSParserToken token = tokenizer_.TokenizeSingle();
    if (token.IsEOF()) {
      break;
    } else if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      nesting_level++;
    } else if (token.GetBlockType() == CSSParserToken::kBlockEnd) {
      nesting_level--;
    }
  }
  offset_ = tokenizer_.Offset();
}

CSSParserTokenRange CSSParserTokenStream::ConsumeComponentValue() {
  EnsureLookAhead();

  buffer_.clear();
  buffer_.shrink_to_fit();

  if (AtEnd()) {
    return {std::vector<CSSParserToken>()};
  }

  unsigned nesting_level = 0;
  do {
    buffer_.push_back(UncheckedConsumeInternal());
    if (buffer_.back().GetBlockType() == CSSParserToken::kBlockStart) {
      nesting_level++;
    } else if (buffer_.back().GetBlockType() == CSSParserToken::kBlockEnd) {
      nesting_level--;
    }
  } while (!PeekInternal().IsEOF() && nesting_level);

  return {buffer_};
}

}  // namespace webf
