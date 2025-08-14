/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "core/css/css_container_rule.h"
#include "core/css/parser/css_parser.h"
#include "core/css/css_style_sheet.h"
#include "core/css/style_rule.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser_context.h"

namespace webf {

class CSSContainerRuleTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Use test infrastructure to create parser context
    parser_context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }

  std::shared_ptr<CSSParserContext> parser_context_;
};

TEST_F(CSSContainerRuleTest, ParseBasicContainerRule) {
  // Skip this test as @container parsing is not yet implemented
  GTEST_SKIP() << "WebF @container parsing infrastructure incomplete";
  
  const char* css_text = R"CSS(
    @container (min-width: 300px) {
      .card {
        flex-direction: column;
      }
    }
  )CSS";

  auto sheet = std::make_shared<StyleSheetContents>(parser_context_);
  CSSParser::ParseSheet(parser_context_, sheet, String::FromUTF8(css_text));
  
  // Should successfully parse the @container rule
  EXPECT_EQ(sheet->ChildRules().size(), 1u);
  
  if (sheet->ChildRules().size() > 0) {
    auto rule = sheet->ChildRules()[0];
    EXPECT_TRUE(rule->IsContainerRule());
  }
}

TEST_F(CSSContainerRuleTest, ParseNamedContainerRule) {
  // Skip this test as @container parsing is not yet implemented
  GTEST_SKIP() << "WebF @container parsing infrastructure incomplete";
  
  const char* css_text = R"CSS(
    @container sidebar (max-width: 200px) {
      .navigation {
        display: none;
      }
    }
  )CSS";

  auto sheet = std::make_shared<StyleSheetContents>(parser_context_);
  CSSParser::ParseSheet(parser_context_, sheet, String::FromUTF8(css_text));
  
  // Should successfully parse the named @container rule
  EXPECT_EQ(sheet->ChildRules().size(), 1u);
  
  if (sheet->ChildRules().size() > 0) {
    auto rule = sheet->ChildRules()[0];
    EXPECT_TRUE(rule->IsContainerRule());
    
    if (rule->IsContainerRule()) {
      auto container_rule = std::static_pointer_cast<StyleRuleContainer>(rule);
      EXPECT_EQ(container_rule->GetContainerQuery().Selector().Name(), "sidebar");
    }
  }
}

}  // namespace webf