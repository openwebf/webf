/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include <cstring>
#include "core/css/css_primitive_value.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/style_rule.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"
#include "test/webf_test_env.h"

namespace webf {

class CSSParserShorthandTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }
  
  void TearDown() override {
    context_.reset();
    env_.reset();
  }

  std::unique_ptr<WebFTestEnv> env_;
  std::shared_ptr<CSSParserContext> context_;
};

// Test that margin shorthand works properly
TEST_F(CSSParserShorthandTest, MarginShorthand) {
  const char* css = "p { margin: 10px; }";
  
  auto sheet = std::make_shared<StyleSheetContents>(context_);
  CSSParser::ParseSheet(context_, sheet, String::FromUTF8(css));
  
  ASSERT_EQ(sheet->ChildRules().size(), 1u);
  auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
  ASSERT_NE(rule, nullptr);
  
  const CSSPropertyValueSet& props = rule->Properties();
  
  // Shorthand should expand to longhands
  EXPECT_NE(props.GetPropertyCSSValue(CSSPropertyID::kMarginTop), nullptr);
  EXPECT_NE(props.GetPropertyCSSValue(CSSPropertyID::kMarginRight), nullptr);
  EXPECT_NE(props.GetPropertyCSSValue(CSSPropertyID::kMarginBottom), nullptr);
  EXPECT_NE(props.GetPropertyCSSValue(CSSPropertyID::kMarginLeft), nullptr);
  
  // Check string representation
  String margin_value = props.GetPropertyValue(CSSPropertyID::kMargin);
  EXPECT_FALSE(margin_value.IsEmpty()) << "Margin shorthand should have a value";
  
  // All margins should be "10px"
  auto* top_value = props.GetPropertyCSSValue(CSSPropertyID::kMarginTop);
  ASSERT_NE(top_value, nullptr);
  ASSERT_NE(*top_value, nullptr);
  const auto* top_primitive = DynamicTo<CSSPrimitiveValue>(top_value->get());
  ASSERT_NE(top_primitive, nullptr);
  EXPECT_EQ(top_primitive->CustomCSSText(), "10px");
}

// Test margin with different values
TEST_F(CSSParserShorthandTest, MarginShorthandMultipleValues) {
  struct TestCase {
    const char* css;
    const char* expected_top;
    const char* expected_right;
    const char* expected_bottom;
    const char* expected_left;
  };
  
  TestCase test_cases[] = {
    {"p { margin: 10px; }", "10px", "10px", "10px", "10px"},
    {"p { margin: 10px 20px; }", "10px", "20px", "10px", "20px"},
    {"p { margin: 10px 20px 30px; }", "10px", "20px", "30px", "20px"},
    {"p { margin: 10px 20px 30px 40px; }", "10px", "20px", "30px", "40px"},
  };
  
  for (const auto& test : test_cases) {
    auto sheet = std::make_shared<StyleSheetContents>(context_);
    CSSParser::ParseSheet(context_, sheet, String::FromUTF8(test.css));
    
    ASSERT_EQ(sheet->ChildRules().size(), 1u) << "Failed for: " << test.css;
    auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
    ASSERT_NE(rule, nullptr);
    
    const CSSPropertyValueSet& props = rule->Properties();
    
    // Check each longhand
    auto* top = props.GetPropertyCSSValue(CSSPropertyID::kMarginTop);
    auto* right = props.GetPropertyCSSValue(CSSPropertyID::kMarginRight);
    auto* bottom = props.GetPropertyCSSValue(CSSPropertyID::kMarginBottom);
    auto* left = props.GetPropertyCSSValue(CSSPropertyID::kMarginLeft);
    
    ASSERT_NE(top, nullptr) << "Failed for: " << test.css;
    ASSERT_NE(right, nullptr) << "Failed for: " << test.css;
    ASSERT_NE(bottom, nullptr) << "Failed for: " << test.css;
    ASSERT_NE(left, nullptr) << "Failed for: " << test.css;
    
    const auto* top_primitive = DynamicTo<CSSPrimitiveValue>(top->get());
    ASSERT_NE(top_primitive, nullptr) << "Failed for: " << test.css;
    EXPECT_EQ(top_primitive->CustomCSSText(), test.expected_top) << "Failed for: " << test.css;

    const auto* right_primitive = DynamicTo<CSSPrimitiveValue>(right->get());
    ASSERT_NE(right_primitive, nullptr) << "Failed for: " << test.css;
    EXPECT_EQ(right_primitive->CustomCSSText(), test.expected_right) << "Failed for: " << test.css;

    const auto* bottom_primitive = DynamicTo<CSSPrimitiveValue>(bottom->get());
    ASSERT_NE(bottom_primitive, nullptr) << "Failed for: " << test.css;
    EXPECT_EQ(bottom_primitive->CustomCSSText(), test.expected_bottom) << "Failed for: " << test.css;

    const auto* left_primitive = DynamicTo<CSSPrimitiveValue>(left->get());
    ASSERT_NE(left_primitive, nullptr) << "Failed for: " << test.css;
    EXPECT_EQ(left_primitive->CustomCSSText(), test.expected_left) << "Failed for: " << test.css;
  }
}

// Test that GetPropertyValue works for shorthands
TEST_F(CSSParserShorthandTest, GetPropertyValueForShorthands) {
  struct TestCase {
    const char* css;
    CSSPropertyID shorthand;
    bool expect_non_empty;
  };
  
  TestCase test_cases[] = {
    {"p { margin: 10px; }", CSSPropertyID::kMargin, true},
    {"p { padding: 5px 10px; }", CSSPropertyID::kPadding, true},
    {"p { border: 1px solid red; }", CSSPropertyID::kBorder, true},
    {"p { background: red; }", CSSPropertyID::kBackground, true},
  };
  
  for (const auto& test : test_cases) {
    auto sheet = std::make_shared<StyleSheetContents>(context_);
    CSSParser::ParseSheet(context_, sheet, String::FromUTF8(test.css));
    
    ASSERT_EQ(sheet->ChildRules().size(), 1u) << "Failed for: " << test.css;
    auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
    ASSERT_NE(rule, nullptr);
    
    const CSSPropertyValueSet& props = rule->Properties();
    String value = props.GetPropertyValue(test.shorthand);
    
    if (test.expect_non_empty) {
      EXPECT_FALSE(value.IsEmpty()) << "Failed for: " << test.css;
    }
  }
}

}  // namespace webf
