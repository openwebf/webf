// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/css_if_parser.h"

#include "gtest/gtest.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"

namespace webf {

class CSSIfParserTest : public ::testing::Test {
 public:
  bool ParseQuery(const std::string& string) {
    auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
    CSSIfParser parser(*context);
    CSSTokenizer tokenizer(string);
    CSSParserTokenStream stream(tokenizer);
    auto if_test = parser.ConsumeIfCondition(stream);
    return if_test != nullptr;
  }
};

TEST_F(CSSIfParserTest, ConsumeValidCondition) {
  // WebF currently only supports supports() conditions
  const char* valid_tests[] = {
      "supports(transform-origin: 5% 5%)",
      "supports(not (transform-origin: 10em 10em 10em))",
      "supports(display: table-cell)",
      "supports((display: table-cell))",
      "supports((display: table-cell) and (display: list-item))",
      "not (supports(display: table-cell))",
      "(supports(display: table-cell)) and (supports(color: red))",
      "supports(display: table-cell) or supports(color: red)",
  };

  for (const char* test : valid_tests) {
    EXPECT_TRUE(ParseQuery(test)) << "Failed to parse: " << test;
  }
}

TEST_F(CSSIfParserTest, ConsumeInvalidCondition) {
  const char* invalid_parse_time_tests[] = {
      "invalid",
      "supports(invalid) and invalid",
      "invalid or supports(invalid)",
  };

  for (const char* test : invalid_parse_time_tests) {
    EXPECT_FALSE(ParseQuery(test)) << "Should not parse: " << test;
  }
}

// Note: media() and style() conditions are not yet supported in WebF
// These tests are commented out until support is added
/*
TEST_F(CSSIfParserTest, MediaConditions) {
  const char* media_tests[] = {
      "media(screen)",
      "media(screen and (color))",
      "media(all and (min-width:500px))",
  };

  for (const char* test : media_tests) {
    EXPECT_TRUE(ParseQuery(test)) << "Failed to parse: " << test;
  }
}

TEST_F(CSSIfParserTest, StyleConditions) {
  const char* style_tests[] = {
      "style(--x)",
      "style(--x: var(--y))",
      "style((--y: green) and (--x: 3))",
  };

  for (const char* test : style_tests) {
    EXPECT_TRUE(ParseQuery(test)) << "Failed to parse: " << test;
  }
}
*/

}  // namespace webf