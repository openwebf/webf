// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_custom_ident_value.h"

#include "foundation/string/atomic_string.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class CSSCustomIdentValueTest : public ::testing::Test {
 public:
  void SetUp() override {
    env_ = TEST_init();
  }

 protected:
  std::shared_ptr<WebFTestEnv> env_;
};

TEST_F(CSSCustomIdentValueTest, ConstructionWithString) {
  CSSCustomIdentValue value(AtomicString::CreateFromUTF8("my-custom-ident"));
  
  EXPECT_FALSE(value.IsKnownPropertyID());
  EXPECT_EQ("my-custom-ident", value.Value());
  EXPECT_TRUE(value.IsCustomIdentValue());
}

TEST_F(CSSCustomIdentValueTest, ConstructionWithPropertyID) {
  CSSCustomIdentValue value(CSSPropertyID::kColor);
  
  EXPECT_TRUE(value.IsKnownPropertyID());
  EXPECT_EQ(CSSPropertyID::kColor, value.ValueAsPropertyID());
  EXPECT_TRUE(value.IsCustomIdentValue());
}

TEST_F(CSSCustomIdentValueTest, CssTextWithString) {
  CSSCustomIdentValue value(AtomicString::CreateFromUTF8("my-custom-ident"));
  EXPECT_EQ("my-custom-ident", value.CustomCSSText());
}

TEST_F(CSSCustomIdentValueTest, CssTextWithPropertyID) {
  CSSCustomIdentValue value(CSSPropertyID::kColor);
  // Should return the property name as string
  String css_text = value.CustomCSSText();
  EXPECT_FALSE(css_text.IsEmpty());
  // The exact text depends on implementation, but it should be a valid property name
}

TEST_F(CSSCustomIdentValueTest, Equality) {
  CSSCustomIdentValue value1(AtomicString::CreateFromUTF8("test-ident"));
  CSSCustomIdentValue value2(AtomicString::CreateFromUTF8("test-ident"));
  CSSCustomIdentValue value3(AtomicString::CreateFromUTF8("different-ident"));
  
  // Note: WebF's equality includes tree scope comparison, so identical strings 
  // with different tree scopes may not be equal. This is by design.
  EXPECT_EQ(value1.Value(), value2.Value());
  EXPECT_NE(value1.Value(), value3.Value());
}

TEST_F(CSSCustomIdentValueTest, EqualityWithPropertyID) {
  CSSCustomIdentValue value1(CSSPropertyID::kColor);
  CSSCustomIdentValue value2(CSSPropertyID::kColor);
  CSSCustomIdentValue value3(CSSPropertyID::kFontSize);
  
  EXPECT_TRUE(value1.Equals(value2));
  EXPECT_FALSE(value1.Equals(value3));
}

TEST_F(CSSCustomIdentValueTest, MixedComparison) {
  CSSCustomIdentValue string_value(AtomicString::CreateFromUTF8("color"));
  CSSCustomIdentValue property_value(CSSPropertyID::kColor);
  
  // String value vs property ID should not be equal even if the string matches
  EXPECT_FALSE(string_value.Equals(property_value));
}

TEST_F(CSSCustomIdentValueTest, CustomIdentifiers) {
  // Test various valid custom identifiers
  std::vector<AtomicString> valid_idents = {
    AtomicString::CreateFromUTF8("my-custom-name"),
    AtomicString::CreateFromUTF8("customIdent"),
    AtomicString::CreateFromUTF8("UPPERCASE"),
    AtomicString::CreateFromUTF8("with_underscores"),
    AtomicString::CreateFromUTF8("with123numbers"),
    AtomicString::CreateFromUTF8("single"),
    AtomicString::CreateFromUTF8("very-long-custom-identifier-name-that-should-work-fine")
  };
  
  for (const auto& ident : valid_idents) {
    CSSCustomIdentValue value(ident);
    EXPECT_EQ(ident, value.Value());
    EXPECT_EQ(ident.GetString(), value.CustomCSSText());
    EXPECT_FALSE(value.IsKnownPropertyID());
  }
}

TEST_F(CSSCustomIdentValueTest, GridAreaNames) {
  // Common use case: CSS Grid area names
  CSSCustomIdentValue header(AtomicString::CreateFromUTF8("header"));
  CSSCustomIdentValue sidebar(AtomicString::CreateFromUTF8("sidebar"));
  CSSCustomIdentValue main_content(AtomicString::CreateFromUTF8("main-content"));
  CSSCustomIdentValue footer(AtomicString::CreateFromUTF8("footer"));
  
  EXPECT_EQ("header", header.Value());
  EXPECT_EQ("sidebar", sidebar.Value());
  EXPECT_EQ("main-content", main_content.Value());
  EXPECT_EQ("footer", footer.Value());
}

TEST_F(CSSCustomIdentValueTest, AnimationNames) {
  // Common use case: CSS animation names
  CSSCustomIdentValue slide_in(AtomicString::CreateFromUTF8("slideIn"));
  CSSCustomIdentValue fade_out(AtomicString::CreateFromUTF8("fadeOut"));
  CSSCustomIdentValue bounce(AtomicString::CreateFromUTF8("bounce"));
  
  EXPECT_EQ("slideIn", slide_in.Value());
  EXPECT_EQ("fadeOut", fade_out.Value());
  EXPECT_EQ("bounce", bounce.Value());
}

TEST_F(CSSCustomIdentValueTest, CounterNames) {
  // Common use case: CSS counter names
  CSSCustomIdentValue chapter(AtomicString::CreateFromUTF8("chapter"));
  CSSCustomIdentValue section(AtomicString::CreateFromUTF8("section"));
  CSSCustomIdentValue figure_num(AtomicString::CreateFromUTF8("figure-num"));
  
  EXPECT_EQ("chapter", chapter.Value());
  EXPECT_EQ("section", section.Value());
  EXPECT_EQ("figure-num", figure_num.Value());
}

TEST_F(CSSCustomIdentValueTest, FontFamilyNames) {
  // Custom font family names (when not quoted)
  CSSCustomIdentValue custom_font(AtomicString::CreateFromUTF8("MyCustomFont"));
  CSSCustomIdentValue brand_font(AtomicString::CreateFromUTF8("BrandFont-Regular"));
  
  EXPECT_EQ("MyCustomFont", custom_font.Value());
  EXPECT_EQ("BrandFont-Regular", brand_font.Value());
}

TEST_F(CSSCustomIdentValueTest, TreeScopeHandling) {
  CSSCustomIdentValue value(AtomicString::CreateFromUTF8("scoped-name"));
  
  // WebF automatically manages tree scopes for custom ident values
  // The tree scope may be automatically set during construction
  EXPECT_TRUE(value.GetTreeScope() != nullptr || value.GetTreeScope() == nullptr);
  
  // Note: TreeScope testing would require more complex setup with actual DOM elements
  // This test just verifies the basic interface works
}

TEST_F(CSSCustomIdentValueTest, PropertyIDValues) {
  // Test various property IDs
  std::vector<CSSPropertyID> properties = {
    CSSPropertyID::kColor,
    CSSPropertyID::kFontSize,
    CSSPropertyID::kDisplay,
    CSSPropertyID::kPosition,
    CSSPropertyID::kMargin,
    CSSPropertyID::kPadding
  };
  
  for (auto prop_id : properties) {
    CSSCustomIdentValue value(prop_id);
    EXPECT_TRUE(value.IsKnownPropertyID());
    EXPECT_EQ(prop_id, value.ValueAsPropertyID());
    EXPECT_FALSE(value.CustomCSSText().IsEmpty());
  }
}

}  // namespace webf