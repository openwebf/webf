/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 * Based on Chromium CSS cascade tests
 */

#include "../../../foundation/string/atomic_string_table.h"
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "bindings/qjs/exception_state.h"
#include "core/css/css_style_sheet.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/resolver/style_resolver.h"
#include "core/css/resolver/style_cascade.h"
#include "core/css/rule_set.h"
#include "core/css/style_engine.h"
#include "core/css/style_recalc_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/html/html_body_element.h"
#include "core/html/html_head_element.h"
#include "core/html/html_style_element.h"
#include "core/platform/graphics/color.h"
#include "core/style/computed_style.h"
#include "foundation/logging.h"
#include "gtest/gtest.h"
#include "test/webf_test_env.h"
#include "third_party/quickjs/quickjs.h"

namespace webf {

class StyleCascadeTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = env_->page()->executingContext();
    context_->EnableBlinkEngine();
    document_ = context_->document();
  }

  void TearDown() override {
    env_ = nullptr;
    context_ = nullptr;
    document_ = nullptr;
  }

  Document* GetDocument() { return document_; }
  ExecutingContext* GetExecutingContext() { return context_; }
  StyleEngine& GetStyleEngine() { return document_->GetStyleEngine(); }

  std::shared_ptr<MutableCSSPropertyValueSet> ComputeWinningProperties(Element& element) {
    StyleResolver& resolver = GetStyleEngine().EnsureStyleResolver();
    StyleResolverState state(*GetDocument(), element);
    ElementRuleCollector collector(state, SelectorChecker::kResolvingStyle);
    resolver.CollectAllRules(state, collector, /*include_smil_properties*/ false);
    collector.SortAndTransferMatchedRules();

    StyleCascade cascade(state);
    for (const auto& entry : collector.GetMatchResult().GetMatchedProperties()) {
      if (entry.is_inline_style) {
        cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
      } else {
        cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
      }
    }

    return cascade.ExportWinningPropertySet();
  }

 private:
  std::unique_ptr<WebFTestEnv> env_;
  ExecutingContext* context_ = nullptr;
  Document* document_ = nullptr;
};

// Based on blink/web_tests/css1/cascade/cascade_order.html
// Test that later declarations override earlier ones
TEST_F(StyleCascadeTest, LaterDeclarationsWin) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Ensure body exists
  ASSERT_NE(GetDocument()->body(), nullptr) << "Document should have a body";
  
  // Create style element and set its content before appending
  auto* style_element = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  style_element->setTextContent(AtomicString::CreateFromUTF8("p { color: blue; } p { color: purple; }"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(style_element, ASSERT_NO_EXCEPTION());
  
  // Verify the style element has a sheet
  auto* sheet = style_element->sheet();
  ASSERT_NE(sheet, nullptr) << "Style element should have a sheet";
  ASSERT_NE(sheet->Contents(), nullptr) << "Sheet should have contents";
  ASSERT_EQ(sheet->Contents()->RuleCount(), 2u) << "Sheet should have 2 rules";
  
  // Create a p element
  auto* p = GetDocument()->createElement(AtomicString::CreateFromUTF8("p"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(p, ASSERT_NO_EXCEPTION());
  
  // WebF’s production pipeline exports winning declared values (not ComputedStyle).
  auto property_set = ComputeWinningProperties(*p);
  ASSERT_NE(property_set, nullptr);

  String color_text = property_set->GetPropertyValue(CSSPropertyID::kColor);
  Color color;
  ASSERT_TRUE(CSSParser::ParseColor(color, color_text, true /*strict*/));
  
  // Purple is rgb(128, 0, 128)
  EXPECT_EQ(color.Red(), 128);
  EXPECT_EQ(color.Green(), 0);
  EXPECT_EQ(color.Blue(), 128);
}

// Test selector specificity ordering
TEST_F(StyleCascadeTest, SpecificityOrdering) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Create style element with different specificity selectors
  auto* style_element = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  style_element->setTextContent(AtomicString::CreateFromUTF8("li { color: purple; } ul li { color: blue; } ul li#gre { color: green; }"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(style_element, ASSERT_NO_EXCEPTION());
  
  // Create test elements
  auto* ul = GetDocument()->createElement(AtomicString::CreateFromUTF8("ul"), ASSERT_NO_EXCEPTION());
  auto* li1 = GetDocument()->createElement(AtomicString::CreateFromUTF8("li"), ASSERT_NO_EXCEPTION());
  ul->appendChild(li1, ASSERT_NO_EXCEPTION());
  
  auto* li2 = GetDocument()->createElement(AtomicString::CreateFromUTF8("li"), ASSERT_NO_EXCEPTION());
  li2->setId(AtomicString::CreateFromUTF8("gre"), ASSERT_NO_EXCEPTION());
  
  // Verify ID was set
  EXPECT_EQ(li2->id().GetString(), "gre");
  EXPECT_TRUE(li2->HasID()) << "Element should have ID after setId";
  
  ul->appendChild(li2, ASSERT_NO_EXCEPTION());
  
  GetDocument()->body()->appendChild(ul, ASSERT_NO_EXCEPTION());

  // Check li1 - should be blue (ul li has higher specificity than li)
  auto property_set1 = ComputeWinningProperties(*li1);
  ASSERT_NE(property_set1, nullptr);
  String color_text1 = property_set1->GetPropertyValue(CSSPropertyID::kColor);
  Color color1;
  ASSERT_TRUE(CSSParser::ParseColor(color1, color_text1, true /*strict*/));
  
  // Blue is rgb(0, 0, 255)
  EXPECT_EQ(color1.Red(), 0);
  EXPECT_EQ(color1.Green(), 0);
  EXPECT_EQ(color1.Blue(), 255);
  
  // Check li2 - should be green (ul li#gre has highest specificity)
  auto property_set2 = ComputeWinningProperties(*li2);
  ASSERT_NE(property_set2, nullptr);
  String color_text2 = property_set2->GetPropertyValue(CSSPropertyID::kColor);
  Color color2;
  ASSERT_TRUE(CSSParser::ParseColor(color2, color_text2, true /*strict*/));
  
  // Green is rgb(0, 128, 0)
  EXPECT_EQ(color2.Red(), 0);
  EXPECT_EQ(color2.Green(), 128);
  EXPECT_EQ(color2.Blue(), 0);
}

// Test !important declarations
TEST_F(StyleCascadeTest, DISABLED_ImportantDeclarations) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Create style element with !important
  auto* style_element = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  style_element->setTextContent(AtomicString::CreateFromUTF8("p { color: green !important; } p { color: red; } p#id1 { color: purple; }"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(style_element, ASSERT_NO_EXCEPTION());
  
  // Test 1: Normal paragraph
  auto* p1 = GetDocument()->createElement(AtomicString::CreateFromUTF8("p"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(p1, ASSERT_NO_EXCEPTION());
  
  // Test 2: Paragraph with ID
  auto* p2 = GetDocument()->createElement(AtomicString::CreateFromUTF8("p"), ASSERT_NO_EXCEPTION());
  p2->setId(AtomicString::CreateFromUTF8("id1"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(p2, ASSERT_NO_EXCEPTION());
  
  // Create style resolver
  StyleResolver* resolver = GetStyleEngine().GetStyleResolver();
  ASSERT_NE(resolver, nullptr);
  
  // Check p1 - should be green due to !important
  StyleRecalcContext context1{};
  auto computed_style1 = resolver->ResolveStyle(p1, context1);
  ASSERT_NE(computed_style1, nullptr);
  Color color1 = computed_style1->Color();
  // Green is rgb(0, 128, 0)
  EXPECT_EQ(color1.Red(), 0);
  EXPECT_EQ(color1.Green(), 128);
  EXPECT_EQ(color1.Blue(), 0);
  
  // Check p2 - should also be green (!important beats ID selector)
  StyleRecalcContext context2{};
  auto computed_style2 = resolver->ResolveStyle(p2, context2);
  ASSERT_NE(computed_style2, nullptr);
  Color color2 = computed_style2->Color();
  EXPECT_EQ(color2.Red(), 0);
  EXPECT_EQ(color2.Green(), 128);
  EXPECT_EQ(color2.Blue(), 0);
}

// Test inline style specificity
TEST_F(StyleCascadeTest, DISABLED_InlineStyleSpecificity) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Create style element
  auto* style_element = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  style_element->setTextContent(AtomicString::CreateFromUTF8("p { color: red; } p.test { color: green; } p#id1 { color: purple; }"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(style_element, ASSERT_NO_EXCEPTION());
  
  // Create paragraph with inline style
  auto* p = GetDocument()->createElement(AtomicString::CreateFromUTF8("p"), ASSERT_NO_EXCEPTION());
  p->setClassName(AtomicString::CreateFromUTF8("test"), ASSERT_NO_EXCEPTION());
  p->setId(AtomicString::CreateFromUTF8("id1"), ASSERT_NO_EXCEPTION());
  p->setAttribute(AtomicString::CreateFromUTF8("style"), AtomicString::CreateFromUTF8("color: blue"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(p, ASSERT_NO_EXCEPTION());
  
  // Create style resolver
  StyleResolver* resolver = GetStyleEngine().GetStyleResolver();
  ASSERT_NE(resolver, nullptr);
  
  StyleRecalcContext context{};
  auto computed_style = resolver->ResolveStyle(p, context);
  
  ASSERT_NE(computed_style, nullptr);
  
  // Check the color - inline style should win
  Color color = computed_style->Color();
  // Blue is rgb(0, 0, 255)
  EXPECT_EQ(color.Red(), 0);
  EXPECT_EQ(color.Green(), 0);
  EXPECT_EQ(color.Blue(), 255);
}

// Test cascade order with multiple stylesheets
TEST_F(StyleCascadeTest, MultipleStylesheets) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Create first style element
  auto* style1 = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  style1->setTextContent(AtomicString::CreateFromUTF8("p { color: red; }"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(style1, ASSERT_NO_EXCEPTION());
  
  // Create second style element
  auto* style2 = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  style2->setTextContent(AtomicString::CreateFromUTF8("p { color: blue; }"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(style2, ASSERT_NO_EXCEPTION());
  
  // Create test element
  auto* p = GetDocument()->createElement(AtomicString::CreateFromUTF8("p"), ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(p, ASSERT_NO_EXCEPTION());

  auto property_set = ComputeWinningProperties(*p);
  ASSERT_NE(property_set, nullptr);
  String color_text = property_set->GetPropertyValue(CSSPropertyID::kColor);
  Color color;
  ASSERT_TRUE(CSSParser::ParseColor(color, color_text, true /*strict*/));

  // Check the color - later stylesheet should win
  // Blue is rgb(0, 0, 255)
  EXPECT_EQ(color.Red(), 0);
  EXPECT_EQ(color.Green(), 0);
  EXPECT_EQ(color.Blue(), 255);
}

}  // namespace webf
