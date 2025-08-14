/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "core/css/css_layer_block_rule.h"
#include "core/css/css_layer_statement_rule.h"
#include "core/css/parser/css_parser.h"
#include "core/css/css_style_sheet.h"
#include "core/css/style_rule.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser_context.h"

namespace webf {

class CSSLayerRuleTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Use test infrastructure to create parser context
    // Force a fresh context each time to avoid state pollution
    parser_context_.reset();
    parser_context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }
  
  void TearDown() override {
    // Clean up parser context
    parser_context_.reset();
  }

  std::shared_ptr<CSSParserContext> parser_context_;
};

TEST_F(CSSLayerRuleTest, ParseLayerBlockRule) {
  const char* css_text = R"CSS(
    @layer utilities {
      .button {
        padding: 4px;
      }
    }
  )CSS";

  fprintf(stderr, "DEBUG: Starting ParseLayerBlockRule test\n");
  auto sheet = std::make_shared<StyleSheetContents>(parser_context_);
  fprintf(stderr, "DEBUG: About to call CSSParser::ParseSheet\n");
  CSSParser::ParseSheet(parser_context_, sheet, String::FromUTF8(css_text));
  fprintf(stderr, "DEBUG: CSSParser::ParseSheet completed\n");
  
  // Should successfully parse the @layer block rule
  EXPECT_EQ(sheet->ChildRules().size(), 1u);
  
  if (sheet->ChildRules().size() > 0) {
    auto rule = sheet->ChildRules()[0];
    EXPECT_TRUE(rule->IsLayerBlockRule());
    
    if (rule->IsLayerBlockRule()) {
      auto layer_rule = std::static_pointer_cast<StyleRuleLayerBlock>(rule);
      EXPECT_EQ(layer_rule->GetNameAsString(), "utilities");
    }
  }
}

TEST_F(CSSLayerRuleTest, ParseLayerStatementRule) {
  const char* css_text = R"CSS(
    @layer base, layout, utilities;
  )CSS";

  auto sheet = std::make_shared<StyleSheetContents>(parser_context_);
  CSSParser::ParseSheet(parser_context_, sheet, String::FromUTF8(css_text));
  
  // Should successfully parse the @layer statement rule
  EXPECT_EQ(sheet->ChildRules().size(), 1u);
  
  if (sheet->ChildRules().size() > 0) {
    auto rule = sheet->ChildRules()[0];
    EXPECT_TRUE(rule->IsLayerStatementRule());
    
    if (rule->IsLayerStatementRule()) {
      auto layer_statement = std::static_pointer_cast<StyleRuleLayerStatement>(rule);
      auto names = layer_statement->GetNamesAsStrings();
      EXPECT_EQ(names.size(), 3u);
      if (names.size() >= 3) {
        EXPECT_EQ(names[0], "base");
        EXPECT_EQ(names[1], "layout");
        EXPECT_EQ(names[2], "utilities");
      }
    }
  }
}

}  // namespace webf