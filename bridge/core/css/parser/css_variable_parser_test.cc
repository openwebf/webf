// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/css_variable_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_tokenizer.h"
#include "gtest/gtest.h"

namespace webf {

namespace {

std::vector<CSSParserToken> Parse(const char* input) {
  std::string string(input);
  CSSTokenizer tokenizer(string);
  return tokenizer.TokenizeToEOF();
}

}  // namespace

const char* valid_variable_reference_value[] = {
    // clang-format off
    "var(--x)",
    "A var(--x)",
    "var(--x) A",

    // {} as the whole value:
    "{ var(--x) }",
    "{ A var(--x) }",
    "{ var(--x) A }",
    "{ var(--x) A",
    "{ var(--x)",
    "{ var(--x) []",

    // {} inside another block:
    "var(--x) [{}]",
    "[{}] var(--x)",
    "foo({}) var(--x)",
    "var(--x) foo({})",
    // clang-format on
};

const char* invalid_variable_reference_value[] = {
    // clang-format off
    "var(--x) {}",
    "{} var(--x)",
    "A { var(--x) }",
    "{ var(--x) } A",
    "[] { var(--x) }",
    "{ var(--x) } []",
    "{}{ var(--x) }",
    "{ var(--x) }{}",
    // clang-format on
};

class ValidVariableReferenceTest : public testing::Test, public testing::WithParamInterface<const char*> {
 public:
  ValidVariableReferenceTest() = default;
};

INSTANTIATE_TEST_SUITE_P(All, ValidVariableReferenceTest, testing::ValuesIn(valid_variable_reference_value));

TEST_P(ValidVariableReferenceTest, ContainsValidVariableReferences) {
  SCOPED_TRACE(GetParam());
  std::vector<CSSParserToken> tokens = Parse(GetParam());
  CSSParserTokenRange range(tokens);
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  EXPECT_TRUE(CSSVariableParser::ContainsValidVariableReferences(range, context->GetExecutingContext()));
}

TEST_P(ValidVariableReferenceTest, ParseUniversalSyntaxValue) {
  SCOPED_TRACE(GetParam());
  std::shared_ptr<const CSSParserContext> context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  EXPECT_NE(nullptr,
            CSSVariableParser::ParseUniversalSyntaxValue(GetParam(), context, /* is_animation_tainted */ false));
}

class InvalidVariableReferenceTest : public testing::Test, public testing::WithParamInterface<const char*> {
 public:
  InvalidVariableReferenceTest() = default;
};

INSTANTIATE_TEST_SUITE_P(All, InvalidVariableReferenceTest, testing::ValuesIn(invalid_variable_reference_value));

TEST_P(InvalidVariableReferenceTest, ContainsValidVariableReferences) {
  SCOPED_TRACE(GetParam());
  std::vector<CSSParserToken> tokens = Parse(GetParam());
  CSSParserTokenRange range(tokens);
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  EXPECT_FALSE(CSSVariableParser::ContainsValidVariableReferences(range, context->GetExecutingContext()));
}

TEST_P(InvalidVariableReferenceTest, ParseUniversalSyntaxValue) {
  SCOPED_TRACE(GetParam());
  std::shared_ptr<const CSSParserContext> context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  EXPECT_NE(nullptr,
            CSSVariableParser::ParseUniversalSyntaxValue(GetParam(), context, /* is_animation_tainted */ false));
}

class CustomPropertyDeclarationTest : public testing::Test, public testing::WithParamInterface<const char*> {
 public:
  CustomPropertyDeclarationTest() = default;
};

// Although these are invalid as var()-containing <declaration-value>s
// in a standard property, they are valid in custom property declarations.
INSTANTIATE_TEST_SUITE_P(All, CustomPropertyDeclarationTest, testing::ValuesIn(invalid_variable_reference_value));

TEST_P(CustomPropertyDeclarationTest, ParseDeclarationValue) {
  SCOPED_TRACE(GetParam());
  std::vector<CSSParserToken> tokens = Parse(GetParam());
  CSSParserTokenRange range(tokens);
  CSSTokenizedValue tokenized_value = {range, /* text */ ""};
  std::shared_ptr<const CSSParserContext> context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  EXPECT_NE(nullptr,
            CSSVariableParser::ParseDeclarationValue(tokenized_value, /* is_animation_tainted */ false, context));
}

}  // namespace webf
