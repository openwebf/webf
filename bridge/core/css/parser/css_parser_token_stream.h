//
// Created by 谢作兵 on 12/06/24.
//

#ifndef WEBF_CSS_PARSER_TOKEN_STREAM_H
#define WEBF_CSS_PARSER_TOKEN_STREAM_H

#include "foundation/macros.h"
#include "css_tokenizer.h"
#include "css_parser_token.h"
#include "css_parser_token_range.h"

namespace webf {

namespace detail {

template <typename...>
bool IsTokenTypeOneOf(CSSParserTokenType t) {
  return false;
}

template <CSSParserTokenType Head, CSSParserTokenType... Tail>
bool IsTokenTypeOneOf(CSSParserTokenType t) {
  return t == Head || IsTokenTypeOneOf<Tail...>(t);
}

}  // namespace detail

class CSSParserTokenStream {
  WEBF_DISALLOW_NEW();

 public:

  class BlockGuard {
    WEBF_STACK_ALLOCATED();

   public:
    explicit BlockGuard(CSSParserTokenStream& stream)
        : stream_(stream), boundaries_(stream.boundaries_) {
      const CSSParserToken next = stream.ConsumeInternal();
      assert(next.GetBlockType()== CSSParserToken::kBlockStart);
      // Boundaries do not apply within blocks.
      stream.boundaries_ = FlagForTokenType(kEOFToken);
    }
    void SkipToEndOfBlock() {
      assert(!skipped_to_end_of_block_);
      stream_.EnsureLookAhead();
      stream_.UncheckedSkipToEndOfBlock();
      skipped_to_end_of_block_ = true;
    }


    ~BlockGuard() {
      if (!skipped_to_end_of_block_) {
        SkipToEndOfBlock();
      }
      stream_.boundaries_ = boundaries_;
    }

   private:
    CSSParserTokenStream& stream_;
    bool skipped_to_end_of_block_ = false;
    uint64_t boundaries_;
  };

  void UncheckedSkipToEndOfBlock();

  explicit CSSParserTokenStream(CSSTokenizer& tokenizer)
      : tokenizer_(tokenizer), next_(kEOFToken) {};


  static constexpr uint64_t FlagForTokenType(CSSParserTokenType token_type) {
    return 1ull << static_cast<uint64_t>(token_type);
  }

  inline const CSSParserToken& Peek() {
    EnsureLookAhead();
    return next_;
  }


  inline bool AtEnd() {
    EnsureLookAhead();
    return UncheckedAtEnd();
  }

  inline bool UncheckedAtEnd() const {
    assert(HasLookAhead());
    return (boundaries_ & FlagForTokenType(next_.GetType())) ||
           next_.GetBlockType() == CSSParserToken::kBlockEnd;
  }

  inline void EnsureLookAhead() {
    if (!HasLookAhead()) {
      has_look_ahead_ = true;
      next_ = tokenizer_.TokenizeSingle();
    }
  }

  inline bool HasLookAhead() const { return has_look_ahead_; }

  // Get the index of the character in the original string to be consumed next.
  uint32_t Offset() const { return offset_; }  // Get the index of the starting character of the look-ahead token.
  uint32_t LookAheadOffset() const {
    assert(HasLookAhead());
    return tokenizer_.PreviousOffset();
  }


  inline const CSSParserToken& UncheckedPeek() const {
    assert(HasLookAhead());
    return next_;
  }

  void ConsumeWhitespace();
  CSSParserToken ConsumeIncludingWhitespace();
  void UncheckedConsumeComponentValue();


  inline const CSSParserToken& Consume() {
    EnsureLookAhead();
    return UncheckedConsume();
  }

  const CSSParserToken& UncheckedConsume() {
    assert(HasLookAhead());
    assert(next_.GetBlockType() != CSSParserToken::kBlockStart);
    assert(next_.GetBlockType() != CSSParserToken::kBlockEnd);
    has_look_ahead_ = false;
    offset_ = tokenizer_.Offset();
    return next_;
  }

  // Consume tokens until one of these is true:
  //
  //  - EOF is reached.
  //  - The next token would signal a premature end of the current block
  //    (an unbalanced } or similar).
  //  - The next token is of any of the given types, except if it occurs
  //    within a block.
  //
  // The range of tokens that we consume is returned. So e.g., if we ask
  // to stop at semicolons, and the rest of the input looks like
  // “.foo { color; } bar ; baz”, we would return “.foo { color; } bar ”
  // and stop there (the semicolon would remain in the lookahead slot).
  //
  // Invalidates any ranges created by previous calls to
  // ConsumeUntilPeekedTypeIs().
  template <CSSParserTokenType... Types>
  CSSParserTokenRange ConsumeUntilPeekedTypeIs() {
    EnsureLookAhead();

    // Check if the existing lookahead token already marks the end;
    // if so, try to exit as soon as possible. (This is a fairly common
    // case, because some places call ConsumeUntilPeekedTypeIs() just to
    // ignore garbage after a declaration, and there usually is no such
    // garbage.)
    if (next_.IsEOF() || TokenMarksEnd<Types...>(next_)) {
      return CSSParserTokenRange(std::span<CSSParserToken>{});
    }

    buffer_.shrink_to_fit();

    // Process the lookahead token.
    buffer_.push_back(next_);
    unsigned nesting_level = 0;
    if (next_.GetBlockType() == CSSParserToken::kBlockStart) {
      nesting_level++;
    }

    // Add tokens to our return vector until we see either EOF or we meet the
    // return condition. (The termination condition is within the loop.)
    while (true) {
      buffer_.push_back(tokenizer_.TokenizeSingle());
      if (buffer_.back().IsEOF() ||
          (nesting_level == 0 && TokenMarksEnd<Types...>(buffer_.back()))) {
        // Undo the token we just pushed; it goes into the lookahead slot
        // instead.
        next_ = buffer_.back();
        buffer_.pop_back();
        offset_ = tokenizer_.PreviousOffset();
        break;
      } else if (buffer_.back().GetBlockType() == CSSParserToken::kBlockStart) {
        nesting_level++;
      } else if (buffer_.back().GetBlockType() == CSSParserToken::kBlockEnd) {
        nesting_level--;
      }
    }
    return CSSParserTokenRange(buffer_);
  }

  // Restarts
  // ========
  //
  // CSSParserTokenStream has limited restart capabilities through the
  // Save and Restore functions.
  //
  // Saving the stream is allowed under the condition that the lookahead token
  // is present. (See HasLookAhead). This avoids having to store whether or not
  // we have a lookahead token.
  //
  // Restoring the stream is allowed under the following conditions:
  //
  //  1. The lookahead token is present (at the time of Restore). This is
  //     important for undoing mutations to the tokenizer's block stack (see
  //     CSSTokenizer::Restore).
  //  2. The Save/Restore pair does not cross a BlockGuard.
  //  3. The Save/Restore pair does not cross a Boundary. (See section below).
  //     This limitation avoids having to store the boundary.
  //
  //
  // Restoring
  // =========
  //
  // Suppose that we had a short string to tokenize.
  //
  //  - The '^' indicates the position of the tokenizer (CSSTokenizer).
  //  - The 'offset' indicates the value of CSSParserTokenStream::offset_.
  //
  // These values temporarily go out of sync when producing lookahead values,
  // because doing so moves the position of the tokenizer only. The stream
  // offset does not catch up until the lookahead is Consumed.
  //
  // The initial state looks like this:
  //
  //   span:hover { X }  [offset=0]
  //   ^
  // Ensuring lookahead moves the tokenizer position (but not the stream
  // offset):
  //
  //   span:hover { X }  [offset=0, lookahead=span]
  //       ^
  // Consuming that lookahead token makes the offset catch up:
  //
  //   span:hover { X }  [offset=4]
  //       ^
  // Ensure lookahead again:
  //
  //   span:hover { X }  [offset=4, lookahead=:]
  //        ^
  // Consuming again:
  //
  //   span:hover { X }  [offset=5]
  //        ^
  // Now suppose that we had saved the stream state earlier,
  // at [offset=0, lookahead=span] (keeping in mind that having lookahead is
  // a prerequisite for saving the stream). We can restore to that position,
  // provided that we first ensure lookahead:
  //
  //   span:hover { X }  [offset=5, lookahead=hover]
  //             ^
  // The restore process will then do two things. First, rewind the tokenizer's
  // position to that of the saved stream offset (0):
  //
  //   span:hover { X }  [offset=5, lookahead=hover]
  //   ^
  // Then, set the stream offset to that rewound tokenizer position (0),
  // and recreate the lookahead from that point:
  //
  //   span:hover { X }  [offset=0, lookahead=span]
  //       ^
  // Now that the restore is finished, we have exactly the same state as when
  // it was saved: [offset=0, lookahead=span].
  //
  //
  // Blocks
  // ======
  //
  // Suppose instead that we want to restore to offset=0 in this state:
  //
  //   span:hover { X }  [offset=11, lookahead={]
  //               ^
  // Now we have a problem, because producing the lookahead token for '{'
  // modified the block stack of the CSSTokenizer. This is why the restore
  // process requires a lookahead token: we inspect the block type of that
  // lookahead token to *undo* the mutation before the rest of the restore
  // process.
  //
  //  - If the lookahead token has BlockType::kBlockStart,
  //    then we simply pop the recently pushed token type from the stack.
  //  - If the lookahead token has BlockType::kBlockEnd,
  //    then we push the matching token type to the stack to restore the
  //    recently popped token type.
  //
  // Note that it's not possible to Consume past a block-start or block-end:
  // a BlockGuard is required to enter blocks, which also ensures that we always
  // consume the entire block. Note also that block-end tokens are treated as
  // EOF (see UncheckedAtEnd): it is therefore not possible to escape the
  // current block during a BlockGuard. For these reasons, we only ever need to
  // undo at most one mutation to the block stack: the block stack mutation
  // caused by the "final" lookahead before the restore process.
  //
  // Boundaries
  // ==========
  //
  // The state may be saved and restored during a Boundary, but the boundary
  // conditions must be the same during the call to Restore as they were
  // during the call to Save. For example, can you use a boundary that's
  // created and destroyed between the Save/Restore calls:
  //
  //  State s = stream.Save();
  //  {
  //    CSSParserTokenStream::Boundary boundary(...);
  //    ConsumeSomething(stream);
  //  }
  //  stream.Restore(s);
  //
  // Or you can use a boundary that exists during both Save and Restore calls:
  //
  //  CSSParserTokenStream::Boundary boundary(...);
  //  State s = stream.Save();
  //  ConsumeSomething(stream);
  //  stream.Restore(s);
  //
  // However, a Save/Restore pair must not cross the boundary. The following
  // will trigger a DCHECK:
  //
  //  State s = stream.Save();
  //  ConsumeSomething(stream);
  //  {
  //    CSSParserTokenStream::Boundary boundary(...);
  //    stream.Restore(s);
  //  }

  using State = uint32_t;

  State Save() const {
    assert(has_look_ahead_);
    return offset_;
  }

  void Restore(State state) {
    assert(has_look_ahead_);
    if (offset_ == state) {
      // No rewind needed, so we don't need to re-tokenize.
      // This happens especially often in MathFunctionParser
      // due to its design; it would perhaps be better to fix that
      // and other callers (it's cheaper never to rewind than to
      // test that rewind isn't needed), but this saves
      // quite a bit of time in total, so the test is generally
      // worth it.
      return;
    }
    offset_ = state;
    next_ = tokenizer_.Restore(next_, offset_);
  }



 private:
  std::vector<CSSParserToken> buffer_;
  CSSTokenizer& tokenizer_;
  CSSParserToken next_;
  uint32_t offset_ = 0;
  bool has_look_ahead_ = false;
  uint64_t boundaries_ = FlagForTokenType(kEOFToken);



  template <CSSParserTokenType... EndTypes>
  inline bool TokenMarksEnd(const CSSParserToken& token) {
    return (boundaries_ & FlagForTokenType(token.GetType())) ||
           token.GetBlockType() == CSSParserToken::kBlockEnd ||
           detail::IsTokenTypeOneOf<EndTypes...>(token.GetType());
  }

  const CSSParserToken& PeekInternal() {
    EnsureLookAhead();
    return UncheckedPeekInternal();
  }

  const CSSParserToken& UncheckedPeekInternal() const {
    assert(HasLookAhead());
    return next_;
  }

  const CSSParserToken& ConsumeInternal() {
    EnsureLookAhead();
    return UncheckedConsumeInternal();
  }

  const CSSParserToken& UncheckedConsumeInternal() {
    assert(HasLookAhead());
    has_look_ahead_ = false;
    offset_ = tokenizer_.Offset();
    return next_;
  }
};

}  // namespace webf

#endif  // WEBF_CSS_PARSER_TOKEN_STREAM_H