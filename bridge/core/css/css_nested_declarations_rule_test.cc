/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "core/css/css_nested_declarations_rule.h"
#include "core/css/style_rule_nested_declarations.h"
#include "core/css/parser/css_parser.h"
#include "core/css/css_style_sheet.h"
#include "core/css/style_rule.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_nesting_type.h"
#include "core/base/containers/span.h"

namespace webf {

class CSSNestedDeclarationsRuleTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Use test infrastructure to create parser context
    parser_context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }
  
  void TearDown() override {
    // Clean up parser context
    parser_context_.reset();
  }

  std::shared_ptr<CSSParserContext> parser_context_;
};

TEST_F(CSSNestedDeclarationsRuleTest, BasicNestedDeclarations) {
  // Create a simple StyleRule for testing nested declarations
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  // Create a simple selector - universal selector (*)
  std::vector<CSSSelector> selectors;
  selectors.emplace_back();  // Default constructor creates a universal selector
  selectors.back().SetLastInSelectorList(true);
  
  auto style_rule = StyleRule::Create(tcb::span<CSSSelector>(selectors), properties);
  auto nested_rule = std::make_shared<StyleRuleNestedDeclarations>(CSSNestingType::kNesting, style_rule);
  
  // Verify the nested declarations rule
  EXPECT_EQ(nested_rule->NestingType(), CSSNestingType::kNesting);
  EXPECT_TRUE(nested_rule->IsNestedDeclarationsRule());
  EXPECT_NE(nested_rule->InnerStyleRule(), nullptr);
}

TEST_F(CSSNestedDeclarationsRuleTest, ScopeNestedDeclarations) {
  // Create a StyleRule for testing scope nested declarations
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  // Create a simple selector - universal selector (*)
  std::vector<CSSSelector> selectors;
  selectors.emplace_back();  // Default constructor creates a universal selector
  selectors.back().SetLastInSelectorList(true);
  
  auto style_rule = StyleRule::Create(tcb::span<CSSSelector>(selectors), properties);
  auto nested_rule = std::make_shared<StyleRuleNestedDeclarations>(CSSNestingType::kScope, style_rule);
  
  // Verify the scope nested declarations rule
  EXPECT_EQ(nested_rule->NestingType(), CSSNestingType::kScope);
  EXPECT_TRUE(nested_rule->IsNestedDeclarationsRule());
  EXPECT_NE(nested_rule->InnerStyleRule(), nullptr);
}

// TODO: Add proper test with CSSStyleSheet once the test infrastructure supports it
// TEST_F(CSSNestedDeclarationsRuleTest, CSSOMInterface) {
//   // This test requires a proper CSSStyleSheet parent which needs ExecutionContext
//   // Currently skipped due to test infrastructure limitations
// }

}  // namespace webf