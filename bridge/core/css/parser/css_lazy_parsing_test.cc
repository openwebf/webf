// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/style_rule.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/parser/css_parser.h"
#include "gtest/gtest.h"

namespace webf {

#if defined(__SSE2__) || defined(__ARM_NEON__)

class CSSLazyParsingTest : public testing::Test {
 public:
  bool HasParsedProperties(StyleRule* rule) { return rule->HasParsedProperties(); }

  StyleRule* RuleAt(StyleSheetContents* sheet, size_t index) {
    return To<StyleRule>(sheet->ChildRules()[index].get());
  }

 protected:
  std::shared_ptr<StyleSheetContents> cached_contents_;
};

TEST_F(CSSLazyParsingTest, Simple) {
  for (const bool fast_path : {false, true}) {
    //    ScopedCSSLazyParsingFastPathForTest fast_path_enabled(fast_path);
    auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
    auto style_sheet = std::make_shared<StyleSheetContents>(context);

    std::string sheet_text = "body { background-color: red; }/*padding1234567890*/";
    CSSParser::ParseSheet(context, style_sheet, sheet_text, CSSDeferPropertyParsing::kYes);
    StyleRule* rule = RuleAt(style_sheet.get(), 0);
    EXPECT_FALSE(HasParsedProperties(rule));
    rule->Properties();
    EXPECT_TRUE(HasParsedProperties(rule));
  }
}

TEST_F(CSSLazyParsingTest, LazyParseBeforeAfter) {
  for (const bool fast_path : {false, true}) {
    auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
    auto style_sheet = std::make_shared<StyleSheetContents>(context);

    std::string sheet_text =
        "p::before { content: 'foo' } p .class::after { content: 'bar' } "
        "/*padding1234567890*/";
    CSSParser::ParseSheet(context, style_sheet, sheet_text, CSSDeferPropertyParsing::kYes);

    EXPECT_FALSE(HasParsedProperties(RuleAt(style_sheet.get(), 0)));
    EXPECT_FALSE(HasParsedProperties(RuleAt(style_sheet.get(), 1)));
  }
}

TEST_F(CSSLazyParsingTest, NoLazyParsingForNestedRules) {
  for (const bool fast_path : {false, true}) {
    auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
    auto style_sheet = std::make_shared<StyleSheetContents>(context);

    std::string sheet_text = "body { & div { color: red; } color: green; }";
    CSSParser::ParseSheet(context, style_sheet, sheet_text, CSSDeferPropertyParsing::kYes);
    StyleRule* rule = RuleAt(style_sheet.get(), 0);
    EXPECT_TRUE(HasParsedProperties(rule));
    EXPECT_EQ("color: green;", rule->Properties().AsText());
    EXPECT_TRUE(HasParsedProperties(rule));
  }
}

#endif  // SIMD

}  // namespace webf