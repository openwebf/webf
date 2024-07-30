// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_TOKENIZER_H
#define WEBF_CSS_TOKENIZER_H

#include "foundation/macros.h"
#include "css_tokenizer_input_stream.h"
#include "css_parser_token.h"

namespace webf {

class CSSParserToken;

class CSSTokenizer {
  WEBF_DISALLOW_NEW();

 public:
  // The overload with const String& holds on to a reference to the string.
  // (Most places, we probably don't need to do that, but fixing that would
  // require manual inspection.)
  explicit CSSTokenizer(const std::string&, uint32_t offset = 0);
  CSSTokenizer(const CSSTokenizer&) = delete;
  CSSTokenizer& operator=(const CSSTokenizer&) = delete;

  // The CSSParserTokens in the result may hold references to the CSSTokenizer
  // object, or the string data referenced by the CSSTokenizer. Do not use the
  // tokens after the CSSTokenizer or its underlying String goes out of scope.
  std::vector<CSSParserToken> TokenizeToEOF();
  size_t TokenCount();

  // Like TokenizeToEOF(), but also returns the start byte for each token.
  // There's an extra offset at the very end that returns the end byte
  // of the last token, i.e., the length of the input string.
  // This matches the convention CSSParserTokenOffsets expects.
  //
  // See the warning about holding a reference in TokenizeToEOF().
  std::pair<std::vector<CSSParserToken>, std::vector<size_t>> TokenizeToEOFWithOffsets();

  [[nodiscard]] uint32_t Offset() const { return input_.Offset(); }
  [[nodiscard]] uint32_t PreviousOffset() const { return prev_offset_; }
  [[nodiscard]] StringView StringRangeFrom(size_t start) const;
  [[nodiscard]] StringView StringRangeAt(size_t start, size_t length) const;
  [[nodiscard]] const std::vector<std::string>& StringPool() const { return string_pool_; }
  CSSParserToken TokenizeSingle();
  CSSParserToken TokenizeSingleWithComments();

  // If you want the returned CSSParserTokens' Value() to be valid beyond
  // the destruction of CSSTokenizer, you'll need to call PersistString()
  // to some longer-lived tokenizer (escaped string tokens may have
  // StringViews that refer to the string pool). The tokenizer
  // (*this, not the destination) is in an undefined state after this;
  // all you can do is destroy it.
  void PersistStrings(CSSTokenizer& destination);

  // Skips to the given offset, which _must_ be exactly the end of
  // the current block. Does _not_ return a new token for lookahead
  // (because the only caller in question does not want that).
  //
  // Leaves PreviousOffset() in an undefined state.
  void SkipToEndOfBlock(size_t offset) {
    assert(offset > input_.Offset());
    // Undo block stack mutation.
    block_stack_.pop_back();
    input_.Restore(offset);
  }

  // See documentation near CSSParserTokenStream.
  CSSParserToken Restore(const CSSParserToken& next, uint32_t offset) {
    // Undo block stack mutation.
    if (next.GetBlockType() == CSSParserToken::BlockType::kBlockStart) {
      block_stack_.pop_back();
    } else if (next.GetBlockType() == CSSParserToken::BlockType::kBlockEnd) {
      static_assert(kLeftParenthesisToken == (kRightParenthesisToken - 1));
      static_assert(kLeftBracketToken == (kRightBracketToken - 1));
      static_assert(kLeftBraceToken == (kRightBraceToken - 1));
      block_stack_.push_back(
          static_cast<CSSParserTokenType>(next.GetType() - 1));
    }
    input_.Restore(offset);
    // Produce the post-restore lookahead token.
    return TokenizeSingle();
  }

 private:
  template <bool SkipComments, bool StoreOffset>
  inline CSSParserToken NextToken();

  char16_t Consume();
  void Reconsume(char16_t);

  CSSParserToken ConsumeNumericToken();
  CSSParserToken ConsumeIdentLikeToken();
  CSSParserToken ConsumeNumber();
  CSSParserToken ConsumeStringTokenUntil(char16_t);
  CSSParserToken ConsumeUnicodeRange();
  CSSParserToken ConsumeUrlToken();

  void ConsumeBadUrlRemnants();
  void ConsumeSingleWhitespaceIfNext();
  void ConsumeUntilCommentEndFound();

  bool ConsumeIfNext(char16_t);
  StringView ConsumeName();
  int32_t ConsumeEscape();

  bool NextTwoCharsAreValidEscape();
  bool NextCharsAreNumber(char16_t);
  bool NextCharsAreNumber();
  bool NextCharsAreIdentifier(char16_t);
  bool NextCharsAreIdentifier();

  CSSParserToken BlockStart(CSSParserTokenType);
  CSSParserToken BlockStart(CSSParserTokenType block_type,
                            CSSParserTokenType,
                            StringView);
  CSSParserToken BlockEnd(CSSParserTokenType, CSSParserTokenType start_type);

  CSSParserToken WhiteSpace(char16_t);
  CSSParserToken LeftParenthesis(char16_t);
  CSSParserToken RightParenthesis(char16_t);
  CSSParserToken LeftBracket(char16_t);
  CSSParserToken RightBracket(char16_t);
  CSSParserToken LeftBrace(char16_t);
  CSSParserToken RightBrace(char16_t);
  CSSParserToken PlusOrFullStop(char16_t);
  CSSParserToken Comma(char16_t);
  CSSParserToken HyphenMinus(char16_t);
  CSSParserToken Asterisk(char16_t);
  CSSParserToken LessThan(char16_t);
  CSSParserToken Colon(char16_t);
  CSSParserToken SemiColon(char16_t);
  CSSParserToken Hash(char16_t);
  CSSParserToken CircumflexAccent(char16_t);
  CSSParserToken DollarSign(char16_t);
  CSSParserToken VerticalLine(char16_t);
  CSSParserToken Tilde(char16_t);
  CSSParserToken CommercialAt(char16_t);
  CSSParserToken ReverseSolidus(char16_t);
  CSSParserToken AsciiDigit(char16_t);
  CSSParserToken LetterU(char16_t);
  CSSParserToken NameStart(char16_t);
  CSSParserToken StringStart(char16_t);
  CSSParserToken EndOfFile(char16_t);

  StringView RegisterString(const std::string&);

  friend class CSSParserTokenStream;

  CSSTokenizerInputStream input_;

  uint32_t prev_offset_ = 0;
  uint32_t token_count_ = 0;
  std::vector<CSSParserTokenType> block_stack_;
  // We only allocate strings when escapes are used.
  std::vector<std::string> string_pool_;
  bool unicode_ranges_allowed_ = false;
};

}  // namespace webf

#endif  // WEBF_CSS_TOKENIZER_H
