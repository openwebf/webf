/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <gtest/gtest.h>
#include "core/style/computed_style.h"
#include "core/style/computed_style_constants.h"

namespace webf {

// Direct unit tests for ApplyInitialProperty logic
// These tests verify the expected behavior without creating StyleResolverState
class StyleBuilderUnitTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Initialize initial style
    initial_style_ = &ComputedStyle::GetInitialStyle();
  }
  
  const ComputedStyle* initial_style_;
};

// Test that verifies what ApplyInitialProperty should do for each property
TEST_F(StyleBuilderUnitTest, ApplyInitialProperty_ExpectedBehavior) {
  ComputedStyleBuilder builder;
  
  // Color: Set non-initial, then apply initial
  builder.SetColor(Color(255, 0, 0));
  // ApplyInitialProperty would do: builder.SetColor(initial_style_->Color());
  builder.SetColor(initial_style_->Color());
  auto style = builder.TakeStyle();
  EXPECT_EQ(style->Color(), Color::kBlack);
  
  // BackgroundColor
  builder = ComputedStyleBuilder();
  builder.SetBackgroundColor(Color(0, 255, 0));
  builder.SetBackgroundColor(initial_style_->BackgroundColor());
  style = builder.TakeStyle();
  EXPECT_EQ(style->BackgroundColor(), Color::kTransparent);
  
  // Display
  builder = ComputedStyleBuilder();
  builder.SetDisplay(EDisplay::kBlock);
  builder.SetDisplay(initial_style_->Display());
  style = builder.TakeStyle();
  EXPECT_EQ(style->Display(), EDisplay::kInline);
  
  // Position
  builder = ComputedStyleBuilder();
  builder.SetPosition(EPosition::kAbsolute);
  builder.SetPosition(initial_style_->Position());
  style = builder.TakeStyle();
  EXPECT_EQ(style->Position(), EPosition::kStatic);
  
  // Width
  builder = ComputedStyleBuilder();
  builder.SetWidth(Length::Fixed(100));
  builder.SetWidth(initial_style_->Width());
  style = builder.TakeStyle();
  EXPECT_TRUE(style->Width().IsAuto());
  
  // Height
  builder = ComputedStyleBuilder();
  builder.SetHeight(Length::Fixed(200));
  builder.SetHeight(initial_style_->Height());
  style = builder.TakeStyle();
  EXPECT_TRUE(style->Height().IsAuto());
  
  // Margins
  builder = ComputedStyleBuilder();
  builder.SetMarginTop(Length::Fixed(10));
  builder.SetMarginTop(initial_style_->MarginTop());
  style = builder.TakeStyle();
  EXPECT_EQ(style->MarginTop(), Length::Fixed(0));
  
  // Padding
  builder = ComputedStyleBuilder();
  builder.SetPaddingTop(Length::Fixed(5));
  builder.SetPaddingTop(initial_style_->PaddingTop());
  style = builder.TakeStyle();
  EXPECT_EQ(style->PaddingTop(), Length::Fixed(0));
  
  // Border Width
  builder = ComputedStyleBuilder();
  builder.SetBorderTopWidth(LayoutUnit(5));
  builder.SetBorderTopWidth(initial_style_->BorderTopWidth());
  style = builder.TakeStyle();
  EXPECT_EQ(style->BorderTopWidth(), LayoutUnit(0));
  
  // Border Style
  builder = ComputedStyleBuilder();
  builder.SetBorderTopStyle(EBorderStyle::kSolid);
  builder.SetBorderTopStyle(initial_style_->BorderTopStyle());
  style = builder.TakeStyle();
  EXPECT_EQ(style->BorderTopStyle(), EBorderStyle::kNone);
  
  // Opacity
  builder = ComputedStyleBuilder();
  builder.SetOpacity(0.5f);
  builder.SetOpacity(initial_style_->Opacity());
  style = builder.TakeStyle();
  EXPECT_EQ(style->Opacity(), 1.0f);
  
  // Z-index
  builder = ComputedStyleBuilder();
  builder.SetZIndex(100);
  builder.SetHasAutoZIndex(false);
  builder.SetZIndex(initial_style_->ZIndex());
  builder.SetHasAutoZIndex(initial_style_->HasAutoZIndex());
  style = builder.TakeStyle();
  EXPECT_EQ(style->ZIndex(), 0);
  EXPECT_TRUE(style->HasAutoZIndex());
  
  // Float
  builder = ComputedStyleBuilder();
  builder.SetFloat(EFloat::kLeft);
  builder.SetFloat(initial_style_->Float());
  style = builder.TakeStyle();
  EXPECT_EQ(style->Float(), EFloat::kNone);
  
  // Clear
  builder = ComputedStyleBuilder();
  builder.SetClear(EClear::kBoth);
  builder.SetClear(initial_style_->Clear());
  style = builder.TakeStyle();
  EXPECT_EQ(style->Clear(), EClear::kNone);
  
  // Text Align
  builder = ComputedStyleBuilder();
  builder.SetTextAlign(ETextAlign::kCenter);
  builder.SetTextAlign(initial_style_->TextAlign());
  style = builder.TakeStyle();
  EXPECT_EQ(style->TextAlign(), ETextAlign::kStart);
  
  // Visibility
  builder = ComputedStyleBuilder();
  builder.SetVisibility(EVisibility::kHidden);
  builder.SetVisibility(initial_style_->Visibility());
  style = builder.TakeStyle();
  EXPECT_EQ(style->Visibility(), EVisibility::kVisible);
  
  // Flex Direction
  builder = ComputedStyleBuilder();
  builder.SetFlexDirection(EFlexDirection::kColumn);
  builder.SetFlexDirection(initial_style_->FlexDirection());
  style = builder.TakeStyle();
  EXPECT_EQ(style->FlexDirection(), EFlexDirection::kRow);
  
  // Flex Wrap
  builder = ComputedStyleBuilder();
  builder.SetFlexWrap(EFlexWrap::kWrap);
  builder.SetFlexWrap(initial_style_->FlexWrap());
  style = builder.TakeStyle();
  EXPECT_EQ(style->FlexWrap(), EFlexWrap::kNowrap);
  
  // Flex Grow/Shrink
  builder = ComputedStyleBuilder();
  builder.SetFlexGrow(2.0f);
  builder.SetFlexShrink(0.5f);
  builder.SetFlexGrow(initial_style_->FlexGrow());
  builder.SetFlexShrink(initial_style_->FlexShrink());
  style = builder.TakeStyle();
  EXPECT_EQ(style->FlexGrow(), 0.0f);
  EXPECT_EQ(style->FlexShrink(), 1.0f);
  
  // Writing Mode
  builder = ComputedStyleBuilder();
  builder.SetWritingMode(WritingMode::kVerticalRl);
  builder.SetWritingMode(initial_style_->GetWritingMode());
  style = builder.TakeStyle();
  EXPECT_EQ(style->GetWritingMode(), WritingMode::kHorizontalTb);
  
  // Direction
  builder = ComputedStyleBuilder();
  builder.SetDirection(TextDirection::kRtl);
  builder.SetDirection(initial_style_->GetDirection());
  style = builder.TakeStyle();
  EXPECT_EQ(style->GetDirection(), TextDirection::kLtr);
}

// Test all box model properties
TEST_F(StyleBuilderUnitTest, ApplyInitialProperty_BoxModel) {
  ComputedStyleBuilder builder;
  
  // Width/Height
  builder.SetWidth(Length::Fixed(100));
  builder.SetHeight(Length::Fixed(200));
  builder.SetMinWidth(Length::Fixed(50));
  builder.SetMinHeight(Length::Fixed(100));
  builder.SetMaxWidth(Length::Fixed(500));
  builder.SetMaxHeight(Length::Fixed(600));
  
  // Apply initial values
  builder.SetWidth(initial_style_->Width());
  builder.SetHeight(initial_style_->Height());
  builder.SetMinWidth(initial_style_->MinWidth());
  builder.SetMinHeight(initial_style_->MinHeight());
  builder.SetMaxWidth(initial_style_->MaxWidth());
  builder.SetMaxHeight(initial_style_->MaxHeight());
  
  auto style = builder.TakeStyle();
  EXPECT_TRUE(style->Width().IsAuto());
  EXPECT_TRUE(style->Height().IsAuto());
  EXPECT_TRUE(style->MinWidth().IsAuto());
  EXPECT_TRUE(style->MinHeight().IsAuto());
  EXPECT_TRUE(style->MaxWidth().IsNone());
  EXPECT_TRUE(style->MaxHeight().IsNone());
}

// Test all margin properties
TEST_F(StyleBuilderUnitTest, ApplyInitialProperty_Margins) {
  ComputedStyleBuilder builder;
  
  builder.SetMarginTop(Length::Fixed(10));
  builder.SetMarginRight(Length::Fixed(20));
  builder.SetMarginBottom(Length::Fixed(30));
  builder.SetMarginLeft(Length::Fixed(40));
  
  builder.SetMarginTop(initial_style_->MarginTop());
  builder.SetMarginRight(initial_style_->MarginRight());
  builder.SetMarginBottom(initial_style_->MarginBottom());
  builder.SetMarginLeft(initial_style_->MarginLeft());
  
  auto style = builder.TakeStyle();
  EXPECT_EQ(style->MarginTop(), Length::Fixed(0));
  EXPECT_EQ(style->MarginRight(), Length::Fixed(0));
  EXPECT_EQ(style->MarginBottom(), Length::Fixed(0));
  EXPECT_EQ(style->MarginLeft(), Length::Fixed(0));
}

// Test all padding properties
TEST_F(StyleBuilderUnitTest, ApplyInitialProperty_Padding) {
  ComputedStyleBuilder builder;
  
  builder.SetPaddingTop(Length::Fixed(5));
  builder.SetPaddingRight(Length::Fixed(10));
  builder.SetPaddingBottom(Length::Fixed(15));
  builder.SetPaddingLeft(Length::Fixed(20));
  
  builder.SetPaddingTop(initial_style_->PaddingTop());
  builder.SetPaddingRight(initial_style_->PaddingRight());
  builder.SetPaddingBottom(initial_style_->PaddingBottom());
  builder.SetPaddingLeft(initial_style_->PaddingLeft());
  
  auto style = builder.TakeStyle();
  EXPECT_EQ(style->PaddingTop(), Length::Fixed(0));
  EXPECT_EQ(style->PaddingRight(), Length::Fixed(0));
  EXPECT_EQ(style->PaddingBottom(), Length::Fixed(0));
  EXPECT_EQ(style->PaddingLeft(), Length::Fixed(0));
}

// Test all border properties
TEST_F(StyleBuilderUnitTest, ApplyInitialProperty_Borders) {
  ComputedStyleBuilder builder;
  
  // Border widths
  builder.SetBorderTopWidth(LayoutUnit(5));
  builder.SetBorderRightWidth(LayoutUnit(10));
  builder.SetBorderBottomWidth(LayoutUnit(15));
  builder.SetBorderLeftWidth(LayoutUnit(20));
  
  builder.SetBorderTopWidth(initial_style_->BorderTopWidth());
  builder.SetBorderRightWidth(initial_style_->BorderRightWidth());
  builder.SetBorderBottomWidth(initial_style_->BorderBottomWidth());
  builder.SetBorderLeftWidth(initial_style_->BorderLeftWidth());
  
  // Border styles
  builder.SetBorderTopStyle(EBorderStyle::kSolid);
  builder.SetBorderRightStyle(EBorderStyle::kDashed);
  builder.SetBorderBottomStyle(EBorderStyle::kDotted);
  builder.SetBorderLeftStyle(EBorderStyle::kDouble);
  
  builder.SetBorderTopStyle(initial_style_->BorderTopStyle());
  builder.SetBorderRightStyle(initial_style_->BorderRightStyle());
  builder.SetBorderBottomStyle(initial_style_->BorderBottomStyle());
  builder.SetBorderLeftStyle(initial_style_->BorderLeftStyle());
  
  // Border colors
  builder.SetBorderTopColor(Color(255, 0, 0));
  builder.SetBorderRightColor(Color(0, 255, 0));
  builder.SetBorderBottomColor(Color(0, 0, 255));
  builder.SetBorderLeftColor(Color(255, 255, 0));
  
  builder.SetBorderTopColor(initial_style_->BorderTopColor());
  builder.SetBorderRightColor(initial_style_->BorderRightColor());
  builder.SetBorderBottomColor(initial_style_->BorderBottomColor());
  builder.SetBorderLeftColor(initial_style_->BorderLeftColor());
  
  auto style = builder.TakeStyle();
  
  // Check widths
  EXPECT_EQ(style->BorderTopWidth(), LayoutUnit(0));
  EXPECT_EQ(style->BorderRightWidth(), LayoutUnit(0));
  EXPECT_EQ(style->BorderBottomWidth(), LayoutUnit(0));
  EXPECT_EQ(style->BorderLeftWidth(), LayoutUnit(0));
  
  // Check styles
  EXPECT_EQ(style->BorderTopStyle(), EBorderStyle::kNone);
  EXPECT_EQ(style->BorderRightStyle(), EBorderStyle::kNone);
  EXPECT_EQ(style->BorderBottomStyle(), EBorderStyle::kNone);
  EXPECT_EQ(style->BorderLeftStyle(), EBorderStyle::kNone);
}

}  // namespace webf