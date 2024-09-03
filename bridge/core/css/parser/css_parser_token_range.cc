// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser_token_range.h"

namespace webf {

DEFINE_GLOBAL(CSSParserToken, g_static_eof_token);

void CSSParserTokenRange::InitStaticEOFToken() {
  new ((void*)&g_static_eof_token) CSSParserToken(kEOFToken);
}


CSSParserTokenRange CSSParserTokenRange::MakeSubRange(const webf::CSSParserToken* first,
                                                      const webf::CSSParserToken* last) const {
  if (first == &g_static_eof_token) {
    first = last_;
  }
  if (last == &g_static_eof_token) {
    last = last_;
  }
  assert(first < last);
  return CSSParserTokenRange(first, last);
}

CSSParserTokenRange CSSParserTokenRange::ConsumeBlock() {
  assert(Peek().GetBlockType() == CSSParserToken::kBlockStart);
  const CSSParserToken* start = &Peek() + 1;
  unsigned nesting_level = 0;
  do {
    const CSSParserToken& token = Consume();
    if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      nesting_level++;
    } else if (token.GetBlockType() == CSSParserToken::kBlockEnd) {
      nesting_level--;
    }
  } while (nesting_level && first_ < last_);

  if (nesting_level) {
    return MakeSubRange(start, first_);  // Ended at EOF
  }
  return MakeSubRange(start, first_ - 1);
}

void CSSParserTokenRange::ConsumeComponentValue() {
  unsigned nesting_level = 0;
  do {
    const CSSParserToken& token = Consume();
    if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      nesting_level++;
    } else if (token.GetBlockType() == CSSParserToken::kBlockEnd) {
      nesting_level--;
    }
  } while (nesting_level && first_ < last_);
}


// https://www.w3.org/TR/css-syntax-3/#serialization
bool NeedsInsertedComment(const CSSParserToken& a, const CSSParserToken& b) {
  CSSParserTokenType at = a.GetType();
  CSSParserTokenType bt = b.GetType();

  // Row 1–7 of the table.
  if (at == kIdentToken || at == kAtKeywordToken || at == kHashToken ||
      at == kDimensionToken || at == kNumberToken ||
      (at == kDelimiterToken &&
       (a.Delimiter() == '#' || a.Delimiter() == '-'))) {
    if (at == kIdentToken && bt == kLeftParenthesisToken) {
      return true;
    }
    if (at == kNumberToken && bt == kDelimiterToken) {
      if (b.Delimiter() == '-') {
        return false;
      }
      if (b.Delimiter() == '%') {
        return true;
      }
    }
    return bt == kIdentToken || bt == kFunctionToken || bt == kUrlToken ||
           bt == kBadUrlToken || bt == kNumberToken || bt == kPercentageToken ||
           bt == kDimensionToken || bt == kCDCToken ||
           (bt == kDelimiterToken && b.Delimiter() == '-');
  }

  // Row 8.
  if (at == kDelimiterToken && a.Delimiter() == '@') {
    return bt == kIdentToken || bt == kFunctionToken || bt == kUrlToken ||
           bt == kBadUrlToken || bt == kCDCToken ||
           (bt == kDelimiterToken && b.Delimiter() == '-');
  }

  // Rows 9 and 10.
  if (at == kDelimiterToken && (a.Delimiter() == '.' || a.Delimiter() == '+')) {
    return bt == kNumberToken || bt == kPercentageToken ||
           bt == kDimensionToken;
  }

  // Final row (all other cases are false).
  return at == kDelimiterToken && bt == kDelimiterToken &&
         a.Delimiter() == '/' && b.Delimiter() == '*';
}


std::string CSSParserTokenRange::Serialize() const {
  std::string result;
  for (const CSSParserToken* it = first_; it != last_; ++it) {
    if (it != first_ && NeedsInsertedComment(*(it - 1), *it)) {
      result += "/**/";
    }
    it->Serialize(result);
  }
  return result;
}


}  // namespace webf
