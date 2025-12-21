/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 * Based on Chromium's css_property_parser_test.cc
 */

#include "gtest/gtest.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/style_rule.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_value_list.h"
#include "test/webf_test_env.h"

namespace webf {

class CSSPropertyParserSimpleTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }
  
  void TearDown() override {
    context_.reset();
    env_.reset();
  }

  // Helper to parse a single property value
  std::shared_ptr<const CSSValue> ParsePropertyValue(CSSPropertyID property, 
                                                     const std::string& value) {
    auto props = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
    ExecutingContext* exec_context = env_->page()->executingContext();
    CSSParser::ParseValue(props.get(), property, value, false, exec_context);
    
    auto* value_ptr = props->GetPropertyCSSValue(property);
    if (!value_ptr || !*value_ptr) {
      return nullptr;
    }
    return *value_ptr;
  }

  // Helper to check if parsing succeeds
  bool CanParseValue(CSSPropertyID property, const std::string& value) {
    auto props = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
    // Use the ExecutingContext from the test environment for proper URL parsing
    ExecutingContext* exec_context = env_->page()->executingContext();
    auto result = CSSParser::ParseValue(props.get(), property, value, false, exec_context);
    
    // For shorthands, check if parsing succeeded rather than looking for the value
    if (result != MutableCSSPropertyValueSet::kParseError) {
      return true;
    }
    
    // For longhands, also try the original method
    return ParsePropertyValue(property, value) != nullptr;
  }

  std::unique_ptr<WebFTestEnv> env_;
  std::shared_ptr<CSSParserContext> context_;
};

// Test color parsing
TEST_F(CSSPropertyParserSimpleTest, ParseColors) {
  // Named colors
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "red"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "blue"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "transparent"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "currentColor"));
  
  // Hex colors
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "#fff"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "#ffffff"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundColor, "#ff0000"));
  
  // RGB/RGBA
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "rgb(255, 0, 0)"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "rgba(255, 0, 0, 0.5)"));
  
  // Invalid colors
  EXPECT_FALSE(CanParseValue(CSSPropertyID::kColor, "invalidcolor"));
}

// Test length parsing
TEST_F(CSSPropertyParserSimpleTest, ParseLengths) {
  // Absolute lengths
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "10px"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "1in"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "2.54cm"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kHeight, "100px"));
  
  // Relative lengths
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "2em"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "1.5rem"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "100vh"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "50vw"));
  
  // Percentages
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "50%"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "100%"));
  
  // Zero
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "0"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "0px"));
  
  // Keywords
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "auto"));
  
  // Invalid lengths
  EXPECT_FALSE(CanParseValue(CSSPropertyID::kWidth, "10"));  // Missing unit
  EXPECT_FALSE(CanParseValue(CSSPropertyID::kWidth, "px"));  // Missing number
}

// Test display values
TEST_F(CSSPropertyParserSimpleTest, ParseDisplay) {
  // Basic display values
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kDisplay, "block"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kDisplay, "inline"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kDisplay, "inline-block"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kDisplay, "none"));
  
  // Flexbox
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kDisplay, "flex"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kDisplay, "inline-flex"));
  
  // Grid
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kDisplay, "grid"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kDisplay, "inline-grid"));
  
  // Invalid values
  EXPECT_FALSE(CanParseValue(CSSPropertyID::kDisplay, "invalid-display"));
}

// Test position values
TEST_F(CSSPropertyParserSimpleTest, ParsePosition) {
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kPosition, "static"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kPosition, "relative"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kPosition, "absolute"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kPosition, "fixed"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kPosition, "sticky"));
  
  EXPECT_FALSE(CanParseValue(CSSPropertyID::kPosition, "invalid-position"));
}

// Test font properties
TEST_F(CSSPropertyParserSimpleTest, ParseFontProperties) {
  // Font family
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontFamily, "Arial"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontFamily, "\"Times New Roman\""));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontFamily, "Arial, sans-serif"));
  
  // Font size
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontSize, "12px"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontSize, "1.5em"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontSize, "large"));
  
  // Font weight
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontWeight, "normal"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontWeight, "bold"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontWeight, "400"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontWeight, "700"));
  
  // Font style
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontStyle, "normal"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFontStyle, "italic"));
}

// Test background properties
TEST_F(CSSPropertyParserSimpleTest, ParseBackgroundProperties) {
  // Background color
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundColor, "red"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundColor, "#ff0000"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundColor, "transparent"));
  
  // Background image
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundImage, "none"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundImage, "url(image.png)"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundImage, "url(你好👋.png)"));
  
  // Background position
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundPosition, "center"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundPosition, "top left"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundPosition, "50% 50%"));
  
  // Background size
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundSize, "cover"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundSize, "contain"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundSize, "100px 200px"));
  
  // Background repeat
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundRepeat, "repeat"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBackgroundRepeat, "no-repeat"));
}

// Regression coverage for parsing length second component in background-position.
TEST_F(CSSPropertyParserSimpleTest, BackgroundPositionWithLength) {
  auto props = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  ExecutingContext* exec_context = env_->page()->executingContext();

  auto result = CSSParser::ParseValue(props.get(), CSSPropertyID::kBackgroundPosition, "50% 6px"_s, false,
                                      exec_context);
  ASSERT_NE(result, MutableCSSPropertyValueSet::kParseError);

  const auto* value_x = props->GetPropertyCSSValue(CSSPropertyID::kBackgroundPositionX);
  ASSERT_TRUE(value_x && *value_x);
  ASSERT_TRUE((*value_x)->IsNumericLiteralValue());
  EXPECT_TRUE(To<CSSNumericLiteralValue>(value_x->get())->IsPercentage());
  EXPECT_EQ("50%", To<CSSNumericLiteralValue>(value_x->get())->CustomCSSText());

  const auto* value_y = props->GetPropertyCSSValue(CSSPropertyID::kBackgroundPositionY);
  ASSERT_TRUE(value_y && *value_y);
  ASSERT_TRUE((*value_y)->IsNumericLiteralValue());
  EXPECT_TRUE(To<CSSNumericLiteralValue>(value_y->get())->IsPx());
  EXPECT_EQ("6px", To<CSSNumericLiteralValue>(value_y->get())->CustomCSSText());
}

// Test border properties
TEST_F(CSSPropertyParserSimpleTest, ParseBorderProperties) {
  // Border width
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopWidth, "thin"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopWidth, "medium"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopWidth, "thick"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopWidth, "1px"));
  
  // Border style
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopStyle, "none"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopStyle, "solid"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopStyle, "dashed"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopStyle, "dotted"));
  
  // Border color
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopColor, "red"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopColor, "#ff0000"));
  
  // Border radius
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopLeftRadius, "5px"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kBorderTopLeftRadius, "50%"));
}

// Test margin and padding
TEST_F(CSSPropertyParserSimpleTest, ParseSpacing) {
  // Margin
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kMarginTop, "10px"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kMarginTop, "auto"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kMarginTop, "-10px"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kMarginRight, "2em"));
  
  // Padding (no negative values)
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kPaddingTop, "10px"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kPaddingLeft, "5%"));
  EXPECT_FALSE(CanParseValue(CSSPropertyID::kPaddingTop, "-10px"));
}

// Test transform properties
TEST_F(CSSPropertyParserSimpleTest, ParseTransform) {
  // Basic transforms
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransform, "none"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransform, "translateX(10px)"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransform, "scale(2)"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransform, "rotate(45deg)"));
  
  // Transform origin
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransformOrigin, "center"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransformOrigin, "top left"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransformOrigin, "50% 50%"));
}

// Test transition properties
TEST_F(CSSPropertyParserSimpleTest, ParseTransition) {
  // Transition property
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionProperty, "none"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionProperty, "all"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionProperty, "width"));
  
  // Transition duration
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionDuration, "0s"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionDuration, "1s"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionDuration, "100ms"));
  
  // Transition timing function
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionTimingFunction, "ease"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionTimingFunction, "linear"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionTimingFunction, "ease-in-out"));
  
  // Transition delay
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionDelay, "0s"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTransitionDelay, "0.5s"));
}

// Test overflow properties
TEST_F(CSSPropertyParserSimpleTest, ParseOverflow) {
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOverflow, "visible"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOverflow, "hidden"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOverflow, "scroll"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOverflow, "auto"));
  
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOverflowX, "hidden"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOverflowY, "scroll"));
}

// Test opacity
TEST_F(CSSPropertyParserSimpleTest, ParseOpacity) {
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOpacity, "0"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOpacity, "0.5"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOpacity, "1"));
  
  // Out of range values might still parse
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOpacity, "1.5"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kOpacity, "-0.5"));
}

// Test z-index
TEST_F(CSSPropertyParserSimpleTest, ParseZIndex) {
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kZIndex, "auto"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kZIndex, "0"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kZIndex, "10"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kZIndex, "-10"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kZIndex, "999"));
}

// Test flexbox properties
TEST_F(CSSPropertyParserSimpleTest, ParseFlexbox) {
  // Flex direction
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexDirection, "row"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexDirection, "column"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexDirection, "row-reverse"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexDirection, "column-reverse"));
  
  // Flex wrap
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexWrap, "nowrap"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexWrap, "wrap"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexWrap, "wrap-reverse"));
  
  // Justify content
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kJustifyContent, "flex-start"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kJustifyContent, "center"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kJustifyContent, "space-between"));
  
  // Align items
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kAlignItems, "flex-start"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kAlignItems, "center"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kAlignItems, "stretch"));
  
  // Flex properties
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexGrow, "0"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexGrow, "1"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexShrink, "0"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexShrink, "1"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexBasis, "auto"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kFlexBasis, "100px"));
}

// Test text properties
TEST_F(CSSPropertyParserSimpleTest, ParseTextProperties) {
  // Text align
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextAlign, "left"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextAlign, "right"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextAlign, "center"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextAlign, "justify"));
  
  // Text decoration
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextDecorationLine, "none"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextDecorationLine, "underline"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextDecorationLine, "line-through"));
  
  // Text transform
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextTransform, "none"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextTransform, "uppercase"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextTransform, "lowercase"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kTextTransform, "capitalize"));
  
  // Line height
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kLineHeight, "normal"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kLineHeight, "1.5"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kLineHeight, "20px"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kLineHeight, "150%"));
}

// Test CSS variables
TEST_F(CSSPropertyParserSimpleTest, ParseCSSVariables) {
  // Variable references
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "var(--main-color)"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "var(--base-width)"));
  
  // Variable with fallback
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kColor, "var(--main-color, red)"));
  EXPECT_TRUE(CanParseValue(CSSPropertyID::kWidth, "var(--width, 100px)"));
}

}  // namespace webf
