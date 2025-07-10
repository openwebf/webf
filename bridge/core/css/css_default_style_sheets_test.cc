/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_default_style_sheets.h"
#include "core/css/style_sheet_contents.h"
#include "gtest/gtest.h"

namespace webf {

TEST(CSSDefaultStyleSheetsTest, InitializesSuccessfully) {
  CSSDefaultStyleSheets::Init();
  EXPECT_TRUE(CSSDefaultStyleSheets::IsInitialized());
}

TEST(CSSDefaultStyleSheetsTest, ReturnsValidDefaultHTMLStyle) {
  auto html_style = CSSDefaultStyleSheets::DefaultHTMLStyle();
  EXPECT_NE(nullptr, html_style);
  // The stylesheet should have been parsed and contain rules
  EXPECT_GT(html_style->RuleCount(), 0u);
}

TEST(CSSDefaultStyleSheetsTest, ReturnsValidQuirksStyle) {
  auto quirks_style = CSSDefaultStyleSheets::QuirksStyle();
  EXPECT_NE(nullptr, quirks_style);
  // The quirks stylesheet should have been parsed and contain rules
  EXPECT_GT(quirks_style->RuleCount(), 0u);
}

TEST(CSSDefaultStyleSheetsTest, ReturnsValidSVGStyle) {
  auto svg_style = CSSDefaultStyleSheets::DefaultSVGStyle();
  EXPECT_NE(nullptr, svg_style);
  // SVG stylesheet is currently empty but should be valid
  EXPECT_EQ(0u, svg_style->RuleCount());
}

TEST(CSSDefaultStyleSheetsTest, ResetWorks) {
  CSSDefaultStyleSheets::Init();
  EXPECT_TRUE(CSSDefaultStyleSheets::IsInitialized());
  
  CSSDefaultStyleSheets::Reset();
  EXPECT_FALSE(CSSDefaultStyleSheets::IsInitialized());
  
  // After reset, we should still be able to get stylesheets (they will re-initialize)
  auto html_style = CSSDefaultStyleSheets::DefaultHTMLStyle();
  EXPECT_NE(nullptr, html_style);
  EXPECT_TRUE(CSSDefaultStyleSheets::IsInitialized());
}

}  // namespace webf