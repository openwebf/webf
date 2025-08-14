/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "core/css/parser/css_parser.h"
#include "core/css/css_style_sheet.h"
#include "core/css/style_rule.h"
#include "core/css/style_rule_counter_style.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser_context.h"

namespace webf {

class CSSCounterStyleTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Use test infrastructure to create parser context
    parser_context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }

  std::shared_ptr<CSSParserContext> parser_context_;
};

TEST_F(CSSCounterStyleTest, ParseBasicCounterStyle) {
  const char* css_text = R"CSS(
    @counter-style thumbs {
      system: cyclic;
      symbols: "\1F44D";
      suffix: " ";
    }
  )CSS";

  auto sheet = std::make_shared<StyleSheetContents>(parser_context_);
  CSSParser::ParseSheet(parser_context_, sheet, String::FromUTF8(css_text));
  
  // Should successfully parse the @counter-style rule
  EXPECT_EQ(sheet->ChildRules().size(), 1u);
  
  if (sheet->ChildRules().size() > 0) {
    auto rule = sheet->ChildRules()[0];
    EXPECT_TRUE(rule->IsCounterStyleRule());
    
    if (rule->IsCounterStyleRule()) {
      auto counter_style_rule = std::static_pointer_cast<StyleRuleCounterStyle>(rule);
      EXPECT_EQ(counter_style_rule->GetName().GetString(), "thumbs");
    }
  }
}

TEST_F(CSSCounterStyleTest, ParseCounterStyleWithExtends) {
  const char* css_text = R"CSS(
    @counter-style decimal-parentheses {
      system: extends decimal;
      prefix: "(";
      suffix: ") ";
    }
  )CSS";

  auto sheet = std::make_shared<StyleSheetContents>(parser_context_);
  CSSParser::ParseSheet(parser_context_, sheet, String::FromUTF8(css_text));
  
  // Should successfully parse the @counter-style rule
  EXPECT_EQ(sheet->ChildRules().size(), 1u);
  
  if (sheet->ChildRules().size() > 0) {
    auto rule = sheet->ChildRules()[0];
    EXPECT_TRUE(rule->IsCounterStyleRule());
    
    if (rule->IsCounterStyleRule()) {
      auto counter_style_rule = std::static_pointer_cast<StyleRuleCounterStyle>(rule);
      EXPECT_EQ(counter_style_rule->GetName().GetString(), "decimal-parentheses");
    }
  }
}

TEST_F(CSSCounterStyleTest, ParseCounterStyleWithAdditive) {
  const char* css_text = R"CSS(
    @counter-style roman {
      system: additive;
      range: 1 3999;
      additive-symbols: 1000 M, 900 CM, 500 D, 400 CD, 
                       100 C, 90 XC, 50 L, 40 XL,
                       10 X, 9 IX, 5 V, 4 IV, 1 I;
    }
  )CSS";

  auto sheet = std::make_shared<StyleSheetContents>(parser_context_);
  CSSParser::ParseSheet(parser_context_, sheet, String::FromUTF8(css_text));
  
  // Should successfully parse the @counter-style rule
  EXPECT_EQ(sheet->ChildRules().size(), 1u);
  
  if (sheet->ChildRules().size() > 0) {
    auto rule = sheet->ChildRules()[0];
    EXPECT_TRUE(rule->IsCounterStyleRule());
    
    if (rule->IsCounterStyleRule()) {
      auto counter_style_rule = std::static_pointer_cast<StyleRuleCounterStyle>(rule);
      EXPECT_EQ(counter_style_rule->GetName().GetString(), "roman");
    }
  }
}

}  // namespace webf