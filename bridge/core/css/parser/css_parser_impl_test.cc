// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "gtest/gtest.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_parser_observer.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/parser/css_parser_impl.h"

namespace webf {

class TestCSSParserObserver : public CSSParserObserver {
 public:
  void StartRuleHeader(StyleRule::RuleType rule_type,
                       unsigned offset) override {
    rule_type_ = rule_type;
    rule_header_start_ = offset;
  }
  void EndRuleHeader(unsigned offset) override { rule_header_end_ = offset; }

  void ObserveSelector(unsigned start_offset, unsigned end_offset) override {}
  void StartRuleBody(unsigned offset) override { rule_body_start_ = offset; }
  void EndRuleBody(unsigned offset) override { rule_body_end_ = offset; }
  void ObserveProperty(unsigned start_offset,
                       unsigned end_offset,
                       bool is_important,
                       bool is_parsed) override {
    property_start_ = start_offset;
  }
  void ObserveComment(unsigned start_offset, unsigned end_offset) override {}
  void ObserveErroneousAtRule(
      unsigned start_offset,
      CSSAtRuleID id,
      const std::vector<CSSPropertyID>& invalid_properties) override {}

  StyleRule::RuleType rule_type_ = StyleRule::RuleType::kStyle;
  unsigned property_start_ = 0;
  unsigned rule_header_start_ = 0;
  unsigned rule_header_end_ = 0;
  unsigned rule_body_start_ = 0;
  unsigned rule_body_end_ = 0;
};


TEST(CSSParserImplTest, AtImportOffsets) {
  std::string sheet_text = "@import 'test.css';";
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto style_sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, style_sheet,
                                             test_css_parser_observer);
  EXPECT_EQ(style_sheet->ImportRules().size(), 1u);
  EXPECT_EQ(test_css_parser_observer.rule_type_, StyleRule::RuleType::kImport);
  EXPECT_EQ(test_css_parser_observer.rule_header_start_, 18u);
  EXPECT_EQ(test_css_parser_observer.rule_header_end_, 18u);
  EXPECT_EQ(test_css_parser_observer.rule_body_start_, 18u);
  EXPECT_EQ(test_css_parser_observer.rule_body_end_, 18u);
}


TEST(CSSParserImplTest, AtMediaOffsets) {
  std::string sheet_text = "@media screen { }";
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto style_sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, style_sheet,
                                             test_css_parser_observer);
  EXPECT_EQ(style_sheet->ChildRules().size(), 1u);
  EXPECT_EQ(test_css_parser_observer.rule_type_, StyleRule::RuleType::kMedia);
  EXPECT_EQ(test_css_parser_observer.rule_header_start_, 7u);
  EXPECT_EQ(test_css_parser_observer.rule_header_end_, 14u);
  EXPECT_EQ(test_css_parser_observer.rule_body_start_, 15u);
  EXPECT_EQ(test_css_parser_observer.rule_body_end_, 16u);
}


TEST(CSSParserImplTest, AtFontFaceOffsets) {
  std::string sheet_text = "@font-face { }";
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto style_sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, style_sheet,
                                             test_css_parser_observer);
  EXPECT_EQ(style_sheet->ChildRules().size(), 1u);
  EXPECT_EQ(test_css_parser_observer.rule_type_,
            StyleRule::RuleType::kFontFace);
  EXPECT_EQ(test_css_parser_observer.rule_header_start_, 11u);
  EXPECT_EQ(test_css_parser_observer.rule_header_end_, 11u);
  EXPECT_EQ(test_css_parser_observer.rule_body_start_, 11u);
  EXPECT_EQ(test_css_parser_observer.rule_body_end_, 11u);
}


TEST(CSSParserImplTest, DirectNesting) {
  std::string sheet_text = ".element { color: green; &.other { color: red; margin-left: 10px; }}";

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
                                             test_css_parser_observer);

  ASSERT_EQ(1u, sheet->ChildRules().size());
  StyleRule* parent = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
  ASSERT_NE(nullptr, parent);
  EXPECT_EQ("color: green;", parent->Properties().AsText());
  EXPECT_EQ(".element", parent->SelectorsText());

  ASSERT_EQ(1u, parent->ChildRules()->size());
  const StyleRule* child =
      DynamicTo<StyleRule>((*parent->ChildRules())[0].get());
  ASSERT_NE(nullptr, child);
  EXPECT_EQ("color: red; margin-left: 10px;", child->Properties().AsText());
  EXPECT_EQ("&.other", child->SelectorsText());
}


TEST(CSSParserImplTest, RuleNotStartingWithAmpersand) {
  std::string sheet_text = ".element { color: green;  .outer & { color: red; }}";

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
                                             test_css_parser_observer);

  ASSERT_EQ(1u, sheet->ChildRules().size());
  StyleRule* parent = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
  ASSERT_NE(nullptr, parent);
  EXPECT_EQ("color: green;", parent->Properties().AsText());
  EXPECT_EQ(".element", parent->SelectorsText());

  ASSERT_NE(nullptr, parent->ChildRules());
  ASSERT_EQ(1u, parent->ChildRules()->size());
  const StyleRule* child =
      DynamicTo<StyleRule>((*parent->ChildRules())[0].get());
  ASSERT_NE(nullptr, child);
  EXPECT_EQ("color: red;", child->Properties().AsText());
  EXPECT_EQ(".outer &", child->SelectorsText());
}

TEST(CSSParserImplTest, ImplicitDescendantSelectors) {
  std::string sheet_text =
      ".element { color: green; .outer, .outer2 { color: red; }}";

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
                                             test_css_parser_observer);

  ASSERT_EQ(1u, sheet->ChildRules().size());
  StyleRule* parent = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
  ASSERT_NE(nullptr, parent);
  EXPECT_EQ("color: green;", parent->Properties().AsText());
  EXPECT_EQ(".element", parent->SelectorsText());

  ASSERT_NE(nullptr, parent->ChildRules());
  ASSERT_EQ(1u, parent->ChildRules()->size());
  const StyleRule* child =
      DynamicTo<StyleRule>((*parent->ChildRules())[0].get());
  ASSERT_NE(nullptr, child);
  EXPECT_EQ("color: red;", child->Properties().AsText());
  EXPECT_EQ("& .outer, & .outer2", child->SelectorsText());
}

TEST(CSSParserImplTest, NestedRelativeSelector) {
  std::string sheet_text = ".element { color: green; > .inner { color: red; }}";
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
                                             test_css_parser_observer);

  ASSERT_EQ(1u, sheet->ChildRules().size());
  StyleRule* parent = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
  ASSERT_NE(nullptr, parent);
  EXPECT_EQ("color: green;", parent->Properties().AsText());
  EXPECT_EQ(".element", parent->SelectorsText());

  ASSERT_NE(nullptr, parent->ChildRules());
  ASSERT_EQ(1u, parent->ChildRules()->size());
  const StyleRule* child =
      DynamicTo<StyleRule>((*parent->ChildRules())[0].get());
  ASSERT_NE(nullptr, child);
  EXPECT_EQ("color: red;", child->Properties().AsText());
  EXPECT_EQ("& > .inner", child->SelectorsText());
}

TEST(CSSParserImplTest, NestingAtTopLevelIsLegalThoughIsMatchesNothing) {
  std::string sheet_text = "&.element { color: orchid; }";

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
                                             test_css_parser_observer);

  ASSERT_EQ(1u, sheet->ChildRules().size());
  const StyleRule* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
  EXPECT_EQ("color: orchid;", rule->Properties().AsText());
  EXPECT_EQ("&.element", rule->SelectorsText());
}


TEST(CSSParserImplTest, ErrorRecoveryEatsOnlyFirstDeclaration) {
  // Note the colon after the opening bracket.
  std::string sheet_text = R"CSS(
    .element {:
      color: orchid;
      background-color: plum;
      accent-color: hotpink;
    }
    )CSS";

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
                                             test_css_parser_observer);

  ASSERT_EQ(1u, sheet->ChildRules().size());
  const StyleRule* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
  EXPECT_EQ("background-color: plum; accent-color: hotpink;",
            rule->Properties().AsText());
  EXPECT_EQ(".element", rule->SelectorsText());
}

TEST(CSSParserImplTest, NestedEmptySelectorCrash) {
  std::string sheet_text = "y{ :is() {} }";

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  TestCSSParserObserver test_css_parser_observer;
  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
                                             test_css_parser_observer);

  // We only really care that it doesn't crash.
}
//
//TEST(CSSParserImplTest, NestedRulesInsideMediaQueries) {
//  std::string sheet_text = R"CSS(
//    .element {
//      color: green;
//      @media (width < 1000px) {
//        color: navy;
//        font-size: 12px;
//        & + #foo { color: red; }
//      }
//    }
//    )CSS";
//
//  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
//  auto sheet = std::make_shared<StyleSheetContents>(context);
//  TestCSSParserObserver test_css_parser_observer;
//  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
//                                             test_css_parser_observer);
//
//  ASSERT_EQ(1u, sheet->ChildRules().size());
//  StyleRule* parent = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
//  ASSERT_NE(nullptr, parent);
//  EXPECT_EQ("color: green;", parent->Properties().AsText());
//  EXPECT_EQ(".element", parent->SelectorsText());
//
//  ASSERT_NE(nullptr, parent->ChildRules());
//  ASSERT_EQ(1u, parent->ChildRules()->size());
//  const StyleRuleMedia* media_query =
//      DynamicTo<StyleRuleMedia>((*parent->ChildRules())[0].get());
//  ASSERT_NE(nullptr, media_query);
//
//  ASSERT_EQ(2u, media_query->ChildRules().size());
//
//  // Implicit & {} rule around the properties.
//  const StyleRule* child0 =
//      DynamicTo<StyleRule>(media_query->ChildRules()[0].get());
//  ASSERT_NE(nullptr, child0);
//  EXPECT_EQ("color: navy; font-size: 12px;", child0->Properties().AsText());
//  EXPECT_EQ("&", child0->SelectorsText());
//
//  const StyleRule* child1 =
//      DynamicTo<StyleRule>(media_query->ChildRules()[1].get());
//  ASSERT_NE(nullptr, child1);
//  EXPECT_EQ("color: red;", child1->Properties().AsText());
//  EXPECT_EQ("& + #foo", child1->SelectorsText());
//}
//
//TEST(CSSParserImplTest, ObserveNestedMediaQuery) {
//  std::string sheet_text = R"CSS(
//    .element {
//      color: green;
//      @media (width < 1000px) {
//        color: navy;
//      }
//    }
//    )CSS";
//
//  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
//  auto sheet = std::make_shared<StyleSheetContents>(context);
//  TestCSSParserObserver test_css_parser_observer;
//  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
//                                             test_css_parser_observer);
//
//  EXPECT_EQ(test_css_parser_observer.rule_type_, StyleRule::RuleType::kStyle);
//  EXPECT_EQ(test_css_parser_observer.rule_header_start_, 67u);
//  EXPECT_EQ(test_css_parser_observer.rule_header_end_, 67u);
//  EXPECT_EQ(test_css_parser_observer.rule_body_start_, 67u);
//  EXPECT_EQ(test_css_parser_observer.rule_body_end_, 101u);
//}
//
//TEST(CSSParserImplTest, ObserveNestedLayer) {
//  std::string sheet_text = R"CSS(
//    .element {
//      color: green;
//      @layer foo {
//        color: navy;
//      }
//    }
//    )CSS";
//
//  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
//  auto sheet = std::make_shared<StyleSheetContents>(context);
//  TestCSSParserObserver test_css_parser_observer;
//  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
//                                             test_css_parser_observer);
//
//  EXPECT_EQ(test_css_parser_observer.rule_type_, StyleRule::RuleType::kStyle);
//  EXPECT_EQ(test_css_parser_observer.rule_header_start_, 54u);
//  EXPECT_EQ(test_css_parser_observer.rule_header_end_, 54u);
//  EXPECT_EQ(test_css_parser_observer.rule_body_start_, 54u);
//  EXPECT_EQ(test_css_parser_observer.rule_body_end_, 88u);
//}
//
//TEST(CSSParserImplTest, NestedIdent) {
//  std::string sheet_text = "div { p:hover { } }";
//  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
//  auto sheet = std::make_shared<StyleSheetContents>(context);
//  TestCSSParserObserver test_css_parser_observer;
//  CSSParserImpl::ParseStyleSheetForInspector(sheet_text, context, sheet,
//                                             test_css_parser_observer);
//  // 'p:hover { }' should be reported both as a failed declaration,
//  // and as a style rule (at the same location).
//  EXPECT_EQ(test_css_parser_observer.property_start_, 6u);
//  EXPECT_EQ(test_css_parser_observer.rule_header_start_, 6u);
//}
//
//TEST(CSSParserImplTest, RemoveImportantAnnotationIfPresent) {
//  struct TestCase {
//    std::string input;
//    std::string expected_text;
//    bool expected_is_important;
//  };
//  static const TestCase test_cases[] = {
//      {"", "", false},
//      {"!important", "", true},
//      {" !important", "", true},
//      {"!", "!", false},
//      {"1px", "1px", false},
//      {"2px!important", "2px", true},
//      {"3px !important", "3px ", true},
//      {"4px ! important", "4px ", true},
//      {"5px !important ", "5px ", true},
//      {"6px !!important", "6px !", true},
//      {"7px !important !important", "7px !important ", true},
//      {"8px important", "8px important", false},
//  };
//  for (auto current_case : test_cases) {
//    CSSTokenizer tokenizer(current_case.input);
//    CSSParserTokenStream stream(tokenizer);
//    CSSTokenizedValue tokenized_value =
//        CSSParserImpl::ConsumeRestrictedPropertyValue(stream);
//    SCOPED_TRACE(current_case.input);
//    bool is_important =
//        CSSParserImpl::RemoveImportantAnnotationIfPresent(tokenized_value);
//    EXPECT_EQ(is_important, current_case.expected_is_important);
//    EXPECT_EQ(tokenized_value.text, current_case.expected_text);
//  }
//}

}