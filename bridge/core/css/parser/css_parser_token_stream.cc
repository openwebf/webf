// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser_token_stream.h"

namespace webf {

CSSParserToken CSSParserTokenStream::ConsumeIncludingWhitespace() {
  CSSParserToken result = Consume();
  ConsumeWhitespace();
  return result;
}

void CSSParserTokenStream::ConsumeWhitespace() {
  while (Peek().GetType() == kWhitespaceToken) {
    UncheckedConsume();
  }
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

}  // namespace webf
