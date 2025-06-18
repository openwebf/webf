// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/at_rule_descriptor_parser.h"

#include "core/css/css_rule_list.h"
#include "core/css/css_style_sheet.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_rule.h"
#include "core/css/style_sheet_contents.h"
#include "gtest/gtest.h"

namespace webf {

class AtRuleDescriptorParserTest : public ::testing::Test {
 protected:
  std::shared_ptr<CSSParserContext> MakeContext() {
    return std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }

  std::shared_ptr<CSSStyleSheet> ParseSheet(const std::string& css_text) {
    auto context = MakeContext();
    return CSSParser::ParseSheet(context, nullptr, css_text);
  }
};

TEST_F(AtRuleDescriptorParserTest, ParseCounterStyleDescriptors) {
  // Test parsing @counter-style with various descriptors
  std::string css_text = R"CSS(
    @counter-style foo {
      system: symbolic;
      symbols: 'X' 'Y' 'Z';
      prefix: '<';
      suffix: '>';
      negative: '~';
      range: 0 infinite;
      pad: 3 'O';
      fallback: upper-alpha;
      speak-as: numbers;
    }
  )CSS";

  auto sheet = ParseSheet(css_text);
  ASSERT_TRUE(sheet);
  ASSERT_TRUE(sheet->cssRules());
  // Basic check that the rule was parsed
  EXPECT_GT(sheet->cssRules()->length(), 0u);
}

TEST_F(AtRuleDescriptorParserTest, ParseAdditiveCounterStyle) {
  // Test parsing @counter-style with additive system
  std::string css_text = R"CSS(
    @counter-style bar {
      system: additive;
      additive-symbols: 1 'I', 0 'O';
    }
  )CSS";

  auto sheet = ParseSheet(css_text);
  ASSERT_TRUE(sheet);
  ASSERT_TRUE(sheet->cssRules());
  EXPECT_GT(sheet->cssRules()->length(), 0u);
}

TEST_F(AtRuleDescriptorParserTest, ParseFontFaceBasicDescriptors) {
  // Test parsing basic @font-face descriptors
  std::string css_text = R"CSS(
    @font-face {
      font-family: 'MyFont';
      src: url('font.woff2') format('woff2'),
           url('font.woff') format('woff');
      font-weight: 400;
      font-style: normal;
      font-display: swap;
    }
  )CSS";

  auto sheet = ParseSheet(css_text);
  ASSERT_TRUE(sheet);
  ASSERT_TRUE(sheet->cssRules());
  EXPECT_GT(sheet->cssRules()->length(), 0u);
}

}  // namespace webf