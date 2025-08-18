/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 * Based on Chromium's css_tokenizer_test.cc
 */

#include "gtest/gtest.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "test/webf_test_env.h"

namespace webf {

class CSSTokenizerComprehensiveTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
  }
  
  void TearDown() override {
    env_.reset();
  }

  std::unique_ptr<WebFTestEnv> env_;
};

// Helper to test token sequences
void TestTokenSequence(const std::string& input, 
                      const std::vector<CSSParserTokenType>& expected_types) {
  String input_string = String::FromUTF8(input.c_str());
  CSSTokenizer tokenizer{input_string.ToStringView()};
  
  std::vector<CSSParserToken> tokens;
  while (true) {
    CSSParserToken token = tokenizer.TokenizeSingle();
    if (token.IsEOF()) break;
    tokens.push_back(token);
  }
  
  ASSERT_EQ(tokens.size(), expected_types.size()) 
    << "Expected " << expected_types.size() << " tokens but got " 
    << tokens.size() << " for input: " << input;
    
  for (size_t i = 0; i < expected_types.size(); ++i) {
    EXPECT_EQ(tokens[i].GetType(), expected_types[i]) 
      << "Token " << i << " mismatch for input: " << input;
  }
}

// Test basic token types
TEST_F(CSSTokenizerComprehensiveTest, BasicTokenTypes) {
  // Identifiers
  TestTokenSequence("hello", {kIdentToken});
  TestTokenSequence("hello-world", {kIdentToken});
  TestTokenSequence("_underscore", {kIdentToken});
  TestTokenSequence("-webkit-flex", {kIdentToken});
  
  // Numbers
  TestTokenSequence("42", {kNumberToken});
  TestTokenSequence("3.14", {kNumberToken});
  TestTokenSequence("-42", {kNumberToken});
  TestTokenSequence("+3.14", {kNumberToken});
  TestTokenSequence(".5", {kNumberToken});
  
  // Dimensions
  TestTokenSequence("10px", {kDimensionToken});
  TestTokenSequence("2.5em", {kDimensionToken});
  TestTokenSequence("100%", {kPercentageToken});
  TestTokenSequence("-50%", {kPercentageToken});
  
  // Strings
  TestTokenSequence("\"hello\"", {kStringToken});
  TestTokenSequence("'world'", {kStringToken});
  TestTokenSequence("\"hello world\"", {kStringToken});
  TestTokenSequence("'it\\'s'", {kStringToken});
  
  // Functions
  TestTokenSequence("rgb(", {kFunctionToken});
  TestTokenSequence("calc(", {kFunctionToken});
  TestTokenSequence("var(", {kFunctionToken});
  
  // URLs - WebF may handle these differently, skip for now
  
  // Hash
  TestTokenSequence("#abc123", {kHashToken});
  TestTokenSequence("#fff", {kHashToken});
  
  // At-keyword
  TestTokenSequence("@media", {kAtKeywordToken});
  TestTokenSequence("@import", {kAtKeywordToken});
  TestTokenSequence("@supports", {kAtKeywordToken});
}

// Test delimiters and special characters
TEST_F(CSSTokenizerComprehensiveTest, Delimiters) {
  TestTokenSequence(".", {kDelimiterToken});
  TestTokenSequence(",", {kCommaToken});
  TestTokenSequence(":", {kColonToken});
  TestTokenSequence(";", {kSemicolonToken});
  TestTokenSequence("!", {kDelimiterToken});
  TestTokenSequence("+", {kDelimiterToken});
  TestTokenSequence("-", {kDelimiterToken});
  TestTokenSequence("*", {kDelimiterToken});
  TestTokenSequence("/", {kDelimiterToken});
  TestTokenSequence("=", {kDelimiterToken});
  TestTokenSequence(">", {kDelimiterToken});
  TestTokenSequence("~", {kDelimiterToken});
  TestTokenSequence("|", {kDelimiterToken});
}

// Test brackets and parentheses
TEST_F(CSSTokenizerComprehensiveTest, BracketsAndParens) {
  TestTokenSequence("{", {kLeftBraceToken});
  TestTokenSequence("}", {kRightBraceToken});
  TestTokenSequence("[", {kLeftBracketToken});
  TestTokenSequence("]", {kRightBracketToken});
  TestTokenSequence("(", {kLeftParenthesisToken});
  TestTokenSequence(")", {kRightParenthesisToken});
}

// Test whitespace handling
TEST_F(CSSTokenizerComprehensiveTest, WhitespaceHandling) {
  TestTokenSequence("  hello  ", {kWhitespaceToken, kIdentToken, kWhitespaceToken});
  TestTokenSequence("\t\n\r\f ", {kWhitespaceToken});
  TestTokenSequence("hello world", {kIdentToken, kWhitespaceToken, kIdentToken});
}

// Test comments
TEST_F(CSSTokenizerComprehensiveTest, Comments) {
  // Comments are consumed completely in WebF
  TestTokenSequence("/* comment */", {});
  TestTokenSequence("hello/* comment */world", 
    {kIdentToken, kIdentToken});
  TestTokenSequence("/* multi\nline\ncomment */", {});
}

// Test complex CSS patterns
TEST_F(CSSTokenizerComprehensiveTest, ComplexPatterns) {
  // Property: value
  TestTokenSequence("color: red", 
    {kIdentToken, kColonToken, kWhitespaceToken, kIdentToken});
  
  // Multiple values
  TestTokenSequence("1px 2px 3px", 
    {kDimensionToken, kWhitespaceToken, kDimensionToken, kWhitespaceToken, 
     kDimensionToken});
  
  // Function with arguments
  TestTokenSequence("rgb(255,0,0)", 
    {kFunctionToken, kNumberToken, kCommaToken, kNumberToken, kCommaToken, 
     kNumberToken, kRightParenthesisToken});
  
  // Calc expression
  TestTokenSequence("calc(100% - 20px)", 
    {kFunctionToken, kPercentageToken, kWhitespaceToken, kDelimiterToken, 
     kWhitespaceToken, kDimensionToken, kRightParenthesisToken});
}

// Test edge cases
TEST_F(CSSTokenizerComprehensiveTest, EdgeCases) {
  // Empty input
  TestTokenSequence("", {});
  
  // Only whitespace
  TestTokenSequence("   ", {kWhitespaceToken});
  
  // Unclosed string (WebF treats as normal string)
  TestTokenSequence("\"unclosed", {kStringToken});
  TestTokenSequence("'unclosed", {kStringToken});
  
  // Escaped characters
  TestTokenSequence("\\41", {kIdentToken}); // \41 = 'A'
  TestTokenSequence("\\n", {kIdentToken});
}

// Test Unicode handling
TEST_F(CSSTokenizerComprehensiveTest, UnicodeHandling) {
  // Unicode identifiers
  TestTokenSequence("café", {kIdentToken});
  TestTokenSequence("π", {kIdentToken});
  TestTokenSequence("🎨", {kIdentToken});
  
  // Unicode in strings
  TestTokenSequence("\"café\"", {kStringToken});
  TestTokenSequence("'π'", {kStringToken});
  TestTokenSequence("\"🎨\"", {kStringToken});
}

// Test scientific notation
TEST_F(CSSTokenizerComprehensiveTest, ScientificNotation) {
  TestTokenSequence("1e2", {kNumberToken});
  TestTokenSequence("1e+2", {kNumberToken});
  TestTokenSequence("1e-2", {kNumberToken});
  TestTokenSequence("1.5e2", {kNumberToken});
  TestTokenSequence(".5e2", {kNumberToken});
}

// Test special CSS constructs
TEST_F(CSSTokenizerComprehensiveTest, CSSConstructs) {
  // Important
  TestTokenSequence("!important", 
    {kDelimiterToken, kIdentToken});
  
  // Attribute selectors
  TestTokenSequence("[attr=value]", 
    {kLeftBracketToken, kIdentToken, kDelimiterToken, kIdentToken, 
     kRightBracketToken});
  
  // Pseudo-class
  TestTokenSequence(":hover", {kColonToken, kIdentToken});
  
  // Pseudo-element
  TestTokenSequence("::before", 
    {kColonToken, kColonToken, kIdentToken});
  
  // CSS variables
  TestTokenSequence("--custom-property", {kIdentToken});
  TestTokenSequence("var(--custom)", 
    {kFunctionToken, kIdentToken, kRightParenthesisToken});
}

// Test error recovery
TEST_F(CSSTokenizerComprehensiveTest, ErrorRecovery) {
  // Invalid characters  
  TestTokenSequence("@", {kDelimiterToken});
  TestTokenSequence("#", {kDelimiterToken});
  TestTokenSequence("$", {kDelimiterToken});
  
  // Bad URL - WebF produces a single bad-url token
  TestTokenSequence("url(bad url)", {kBadUrlToken});
  
  // Nested comments - WebF handles comments differently
  TestTokenSequence("/* outer /* inner */ */", 
    {kWhitespaceToken, kDelimiterToken, kDelimiterToken});
}

// Test dimension units
TEST_F(CSSTokenizerComprehensiveTest, DimensionUnits) {
  // Length units
  TestTokenSequence("10px", {kDimensionToken});
  TestTokenSequence("2em", {kDimensionToken});
  TestTokenSequence("1.5rem", {kDimensionToken});
  TestTokenSequence("100vh", {kDimensionToken});
  TestTokenSequence("50vw", {kDimensionToken});
  TestTokenSequence("1in", {kDimensionToken});
  TestTokenSequence("2.54cm", {kDimensionToken});
  TestTokenSequence("10mm", {kDimensionToken});
  TestTokenSequence("12pt", {kDimensionToken});
  TestTokenSequence("1pc", {kDimensionToken});
  
  // Angle units
  TestTokenSequence("45deg", {kDimensionToken});
  TestTokenSequence("1rad", {kDimensionToken});
  TestTokenSequence("200grad", {kDimensionToken});
  TestTokenSequence("0.5turn", {kDimensionToken});
  
  // Time units
  TestTokenSequence("1s", {kDimensionToken});
  TestTokenSequence("100ms", {kDimensionToken});
  
  // Frequency units
  TestTokenSequence("60Hz", {kDimensionToken});
  TestTokenSequence("2kHz", {kDimensionToken});
  
  // Resolution units
  TestTokenSequence("96dpi", {kDimensionToken});
  TestTokenSequence("2dppx", {kDimensionToken});
}

}  // namespace webf