# CSS Tokenizer Analysis: Function Token Handling

## Summary
WebF's CSS tokenizer IS correctly producing closing parenthesis tokens for functions. The issue is NOT in the tokenizer but in how some parsers are consuming function tokens.

## The Problem
Some WebF parsers (like `CSSSupportsParser::ConsumeFontFormatFn`) are incorrectly trying to use `ConsumeUntilPeekedTypeIs<kRightParenthesisToken>()` without first entering the function block with a BlockGuard.

## How Function Tokens Work

### Token Generation
When the tokenizer sees `rgb(`:
1. It creates a `kFunctionToken` with `BlockType=kBlockStart`
2. It pushes `kLeftParenthesisToken` onto the block stack
3. When it later sees `)`, it creates `kRightParenthesisToken` with `BlockType=kBlockEnd`

### Correct Consumption Pattern (Blink)
```cpp
bool CSSSupportsParser::ConsumeFontFormatFn(CSSParserTokenStream& stream) {
  if (stream.Peek().FunctionId() != CSSValueID::kFontFormat) {
    return false;
  }
  CSSParserTokenStream::RestoringBlockGuard guard(stream);  // Enters the function block
  stream.ConsumeWhitespace();
  
  // Parse function arguments
  // The closing ) is handled by the guard destructor
}
```

### Incorrect Pattern (Current WebF)
```cpp
CSSSupportsParser::Result CSSSupportsParser::ConsumeFontFormatFn(...) {
  // WRONG: Trying to consume until ) without entering the block
  auto format_block = stream.ConsumeUntilPeekedTypeIs<kRightParenthesisToken>();
  // This won't work because the ) is part of the block structure
}
```

## Why This Matters
- Function tokens are block-start tokens
- The closing parenthesis is a block-end token
- You must use BlockGuard or RestoringBlockGuard to enter/exit function blocks
- `ConsumeUntilPeekedTypeIs` cannot see block-end tokens

## Fix Required
Update WebF parsers that handle function tokens to use the proper BlockGuard pattern, matching Blink's implementation.