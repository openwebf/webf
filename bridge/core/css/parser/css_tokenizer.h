//
// Created by 谢作兵 on 12/06/24.
//

#ifndef WEBF_CSS_TOKENIZER_H
#define WEBF_CSS_TOKENIZER_H
#include "foundation/macros.h"
#include "bindings/qjs/atomic_string.h"
#include "css_tokenizer_input_stream.h"
#include "css_parser_token.h"

namespace webf {

class CSSTokenizerInputStream;
class CSSParserToken;

class CSSTokenizer {
  WEBF_DISALLOW_NEW();

 public:
  // The overload with const String& holds on to a reference to the string.
  // (Most places, we probably don't need to do that, but fixing that would
  // require manual inspection.)
  explicit CSSTokenizer(const AtomicString&, uint32_t offset = 0);
  CSSParserToken TokenizeSingle();
  // The CSSParserTokens in the result may hold references to the CSSTokenizer
  // object, or the string data referenced by the CSSTokenizer. Do not use the
  // tokens after the CSSTokenizer or its underlying String goes out of scope.
  std::vector<CSSParserToken> TokenizeToEOF();
  [[nodiscard]] uint32_t Offset() const { return input_.Offset(); }
  [[nodiscard]] uint32_t PreviousOffset() const { return prev_offset_; }

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
  CSSTokenizerInputStream input_;

  uint32_t prev_offset_ = 0;
  uint32_t token_count_ = 0;
  std::vector<CSSParserTokenType> block_stack_;
  // We only allocate strings when escapes are used.
  std::vector<AtomicString> string_pool_;
  bool unicode_ranges_allowed_ = false;

  char16_t Consume();

  template <bool SkipComments, bool StoreOffset>
  inline CSSParserToken NextToken();

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

  StringView RegisterString(const AtomicString&);


};

}  // namespace webf

#endif  // WEBF_CSS_TOKENIZER_H
