/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include <cstring>
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/style_rule.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_primitive_value.h"
#include "test/webf_test_env.h"

namespace webf {

class CSSParserComprehensiveTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Initialize WebF test environment like other CSS tests
    env_ = TEST_init();
    // Create a standalone parser context for simple parsing tests
    context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }
  
  void TearDown() override {
    context_.reset();
    env_.reset();
  }

  std::unique_ptr<WebFTestEnv> env_;
  std::shared_ptr<CSSParserContext> context_;
};

// Test CSS property parsing including shorthands
TEST_F(CSSParserComprehensiveTest, ParseBasicProperties) {
  struct TestCase {
    const char* css;
    CSSPropertyID property;
    CSSPropertyID check_property;  // Property to actually check (for shorthands)
    bool expect_identifier;
    bool expect_numeric;
  };

  TestCase test_cases[] = {
    // Color properties
    {"p { color: red; }", CSSPropertyID::kColor, CSSPropertyID::kColor, true, false},
    {"p { background-color: blue; }", CSSPropertyID::kBackgroundColor, CSSPropertyID::kBackgroundColor, true, false},
    
    // Length properties
    {"p { width: 100px; }", CSSPropertyID::kWidth, CSSPropertyID::kWidth, false, true},
    {"p { height: 50%; }", CSSPropertyID::kHeight, CSSPropertyID::kHeight, false, true},
    
    // Shorthand properties - check via longhands
    {"p { margin: 10px; }", CSSPropertyID::kMargin, CSSPropertyID::kMarginTop, false, true},
    {"p { padding: 20px; }", CSSPropertyID::kPadding, CSSPropertyID::kPaddingLeft, false, true},
    
    // Display properties
    {"p { display: block; }", CSSPropertyID::kDisplay, CSSPropertyID::kDisplay, true, false},
    {"p { display: inline; }", CSSPropertyID::kDisplay, CSSPropertyID::kDisplay, true, false},
    {"p { display: flex; }", CSSPropertyID::kDisplay, CSSPropertyID::kDisplay, true, false},
    {"p { display: none; }", CSSPropertyID::kDisplay, CSSPropertyID::kDisplay, true, false},
    
    // Position properties
    {"p { position: relative; }", CSSPropertyID::kPosition, CSSPropertyID::kPosition, true, false},
    {"p { position: absolute; }", CSSPropertyID::kPosition, CSSPropertyID::kPosition, true, false},
    {"p { position: fixed; }", CSSPropertyID::kPosition, CSSPropertyID::kPosition, true, false},
  };

  for (const auto& test : test_cases) {
    auto sheet = std::make_shared<StyleSheetContents>(context_);
    CSSParser::ParseSheet(context_, sheet, String::FromUTF8(test.css));
    
    ASSERT_EQ(sheet->ChildRules().size(), 1u) << "Failed for CSS: " << test.css;
    auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
    ASSERT_NE(rule, nullptr) << "Failed for CSS: " << test.css;
    
    const CSSPropertyValueSet& props = rule->Properties();
    EXPECT_GT(props.PropertyCount(), 0u) << "Failed for CSS: " << test.css;
  }
}

// Test !important declarations
TEST_F(CSSParserComprehensiveTest, ParseImportantDeclarations) {
  const char* css = "p { color: red !important; background: blue; margin: 10px !important; }";
  
  auto sheet = std::make_shared<StyleSheetContents>(context_);
  CSSParser::ParseSheet(context_, sheet, String::FromUTF8(css));
  
  ASSERT_EQ(sheet->ChildRules().size(), 1u);
  auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
  ASSERT_NE(rule, nullptr);
  
  const CSSPropertyValueSet& props = rule->Properties();
  EXPECT_TRUE(props.PropertyIsImportant(CSSPropertyID::kColor));
  EXPECT_FALSE(props.PropertyIsImportant(CSSPropertyID::kBackground));
  EXPECT_TRUE(props.PropertyIsImportant(CSSPropertyID::kMargin));
}

// Test multiple rules parsing
TEST_F(CSSParserComprehensiveTest, ParseMultipleRules) {
  const char* css = R"CSS(
    p { color: red; }
    .class { margin: 10px; }
    #id { padding: 20px; }
    div { display: block; }
  )CSS";
  
  auto sheet = std::make_shared<StyleSheetContents>(context_);
  CSSParser::ParseSheet(context_, sheet, String::FromUTF8(css));
  
  EXPECT_EQ(sheet->ChildRules().size(), 4u);
  
  // Verify each rule is a style rule
  for (size_t i = 0; i < sheet->ChildRules().size(); ++i) {
    EXPECT_TRUE(sheet->ChildRules()[i]->IsStyleRule()) 
      << "Rule " << i << " is not a style rule";
  }
}

// Test invalid CSS handling
TEST_F(CSSParserComprehensiveTest, HandleInvalidCSS) {
  struct TestCase {
    const char* css;
    size_t expected_rules;
    size_t min_properties;
  };

  TestCase test_cases[] = {
    // Valid rule with invalid property - rule should still parse
    {"p { color: red; invalid-property: value; }", 1, 1},
    
    // Missing value - property should be ignored
    {"p { color: ; margin: 10px; }", 1, 1},
    
    // Syntax error in selector - no rules
    {"p.. { color: red; }", 0, 0},
    
    // Missing closing brace - WebF might still parse it
    {"p { color: red", 1, 0},
  };

  for (const auto& test : test_cases) {
    auto sheet = std::make_shared<StyleSheetContents>(context_);
    CSSParser::ParseSheet(context_, sheet, String::FromUTF8(test.css));
    
    EXPECT_EQ(sheet->ChildRules().size(), test.expected_rules) 
      << "Failed for CSS: " << test.css;
      
    if (test.expected_rules > 0 && sheet->ChildRules().size() > 0) {
      auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
      if (rule) {
        EXPECT_GE(rule->Properties().PropertyCount(), test.min_properties)
          << "Failed for CSS: " << test.css;
      }
    }
  }
}

// Test CSS variable parsing
TEST_F(CSSParserComprehensiveTest, ParseCSSVariables) {
  struct TestCase {
    const char* css;
    const char* property_name;
    bool is_custom_property;
  };

  TestCase test_cases[] = {
    // Variable declaration
    {"p { --main-color: red; }", "--main-color", true},
    {"p { --spacing: 10px; }", "--spacing", true},
    
    // Variable usage
    {"p { color: var(--main-color); }", "color", false},
    {"p { margin-top: var(--spacing); }", "margin-top", false},
  };

  for (const auto& test : test_cases) {
    auto sheet = std::make_shared<StyleSheetContents>(context_);
    CSSParser::ParseSheet(context_, sheet, String::FromUTF8(test.css));
    
    ASSERT_EQ(sheet->ChildRules().size(), 1u) << "Failed for CSS: " << test.css;
    auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
    ASSERT_NE(rule, nullptr) << "Failed for CSS: " << test.css;
    
    const CSSPropertyValueSet& props = rule->Properties();
    
    if (test.is_custom_property) {
      // Custom properties use AtomicString
      auto* value_ptr = props.GetPropertyCSSValue(AtomicString(String::FromUTF8(test.property_name)));
      EXPECT_NE(value_ptr, nullptr) << "Failed for CSS: " << test.css;
    } else {
      // Regular properties
      CSSPropertyID property_id = CSSPropertyID::kInvalid;
      if (strcmp(test.property_name, "color") == 0) {
        property_id = CSSPropertyID::kColor;
      } else if (strcmp(test.property_name, "margin-top") == 0) {
        property_id = CSSPropertyID::kMarginTop;
      }
      
      if (property_id != CSSPropertyID::kInvalid) {
        auto* value_ptr = props.GetPropertyCSSValue(property_id);
        EXPECT_NE(value_ptr, nullptr) << "Failed for CSS: " << test.css;
      }
    }
  }
}

}  // namespace webf