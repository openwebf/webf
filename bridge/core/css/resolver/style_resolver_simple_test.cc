/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_resolver.h"
#include "core/style/computed_style.h"
#include "gtest/gtest.h"

namespace webf {

// Simple tests that don't require WebF test environment setup

TEST(StyleResolverSimpleTest, InitialStyleValues) {
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  
  // Test initial values
  EXPECT_EQ(initial_style.Display(), EDisplay::kInline);
  EXPECT_EQ(initial_style.Position(), EPosition::kStatic);
  EXPECT_EQ(initial_style.GetDirection(), TextDirection::kLtr);
  EXPECT_EQ(initial_style.GetWritingMode(), WritingMode::kHorizontalTb);
  EXPECT_EQ(initial_style.OverflowX(), EOverflow::kVisible);
  EXPECT_EQ(initial_style.OverflowY(), EOverflow::kVisible);
  EXPECT_EQ(initial_style.Opacity(), 1.0f);
  EXPECT_TRUE(initial_style.HasAutoZIndex());
}

TEST(StyleResolverSimpleTest, ComputedStyleBuilder) {
  ComputedStyleBuilder builder;
  
  // Set some properties
  builder.SetDisplay(EDisplay::kFlex);
  builder.SetPosition(EPosition::kRelative);
  builder.SetOpacity(0.5f);
  builder.SetZIndex(100);
  builder.SetHasAutoZIndex(false);
  
  auto style = builder.TakeStyle();
  ASSERT_NE(style, nullptr);
  
  // Verify properties were set
  EXPECT_EQ(style->Display(), EDisplay::kFlex);
  EXPECT_EQ(style->Position(), EPosition::kRelative);
  EXPECT_EQ(style->Opacity(), 0.5f);
  EXPECT_EQ(style->ZIndex(), 100);
  EXPECT_FALSE(style->HasAutoZIndex());
}

TEST(StyleResolverSimpleTest, ComputedStyleBuilderFromExisting) {
  // Create a base style
  ComputedStyleBuilder base_builder;
  base_builder.SetDisplay(EDisplay::kBlock);
  base_builder.SetColor(Color(255, 0, 0));
  base_builder.SetFontSize(20);
  auto base_style = base_builder.TakeStyle();
  
  // Create a new builder from the existing style
  ComputedStyleBuilder derived_builder(*base_style);
  derived_builder.SetDisplay(EDisplay::kFlex); // Override display
  
  auto derived_style = derived_builder.TakeStyle();
  ASSERT_NE(derived_style, nullptr);
  
  // Verify inherited and overridden properties
  EXPECT_EQ(derived_style->Display(), EDisplay::kFlex); // Overridden
  EXPECT_EQ(derived_style->Color(), Color(255, 0, 0)); // Inherited
  EXPECT_EQ(derived_style->GetFontSize(), 20); // Inherited
}

TEST(StyleResolverSimpleTest, ComputedStyleClone) {
  ComputedStyleBuilder builder;
  builder.SetDisplay(EDisplay::kGrid);
  builder.SetPosition(EPosition::kFixed);
  builder.SetBackgroundColor(Color(0, 255, 0));
  auto original = builder.TakeStyle();
  
  auto cloned = original->Clone();
  ASSERT_NE(cloned, nullptr);
  
  // Verify cloned values
  EXPECT_EQ(cloned->Display(), EDisplay::kGrid);
  EXPECT_EQ(cloned->Position(), EPosition::kFixed);
  EXPECT_EQ(cloned->BackgroundColor(), Color(0, 255, 0));
  
  // Verify they are different objects
  EXPECT_NE(cloned.get(), original.get());
}

TEST(StyleResolverSimpleTest, InheritedVsNonInheritedProperties) {
  ComputedStyleBuilder builder1;
  builder1.SetColor(Color(255, 0, 0));
  builder1.SetFontSize(16);
  builder1.SetDirection(TextDirection::kRtl);
  builder1.SetDisplay(EDisplay::kBlock);
  builder1.SetPosition(EPosition::kAbsolute);
  auto style1 = builder1.TakeStyle();
  
  ComputedStyleBuilder builder2;
  builder2.SetColor(Color(255, 0, 0));
  builder2.SetFontSize(16);
  builder2.SetDirection(TextDirection::kRtl);
  builder2.SetDisplay(EDisplay::kFlex);
  builder2.SetPosition(EPosition::kRelative);
  auto style2 = builder2.TakeStyle();
  
  // Inherited properties are the same
  EXPECT_TRUE(style1->InheritedEqual(*style2));
  
  // Non-inherited properties are different
  EXPECT_FALSE(style1->NonInheritedEqual(*style2));
}

}  // namespace webf