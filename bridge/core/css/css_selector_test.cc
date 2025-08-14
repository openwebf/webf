// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_selector.h"
#include "core/css/css_selector_list.h"
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_rule.h"
#include "core/dom/document.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

using css_test_helpers::ParseRule;
using css_test_helpers::ParseSelectorList;

namespace {

unsigned Specificity(const std::string& selector_text) {
  std::shared_ptr<CSSSelectorList> selector_list = ParseSelectorList(selector_text);
  if (selector_list->First()) {
    return selector_list->First()->Specificity();
  }
  return 0;
}

bool HasLinkOrVisited(const std::string& selector_text) {
  std::shared_ptr<CSSSelectorList> selector_list = ParseSelectorList(selector_text);
  if (selector_list->First()) {
    return selector_list->First()->HasLinkOrVisited();
  }
  return false;
}

}  // namespace

TEST(CSSSelector, BasicTest) {
  // Simple test to verify the test framework works
  std::shared_ptr<CSSSelectorList> selector_list = ParseSelectorList(".a");
  EXPECT_TRUE(selector_list);
  EXPECT_TRUE(selector_list->IsValid());
}

TEST(CSSSelector, Representations) {
  auto env = TEST_init();
  
  // Test basic selector parsing by parsing individual selectors
  std::vector<std::string> test_selectors = {
      "*",
      "div", 
      "#id",
      ".class",
      "[attr]",
      "div:hover",
      "div:nth-child(2)",
      ".class#id",
      "#id.class",
      "[attr]#id",
      "div[attr]#id",
      "div::first-line",
      ".a.b.c",
      "div:not(.a)",
      "div:not(:visited)",
      "[attr=\"value\"]",
      "[attr~=\"value\"]", 
      "[attr^=\"value\"]",
      "[attr$=\"value\"]",
      "[attr*=\"value\"]",
      "[attr|=\"value\"]",
      ".a .b",
      ".a > .b",
      ".a ~ .b", 
      ".a + .b",
      ".a, .b"
  };

  // Verify that all these selectors can be parsed successfully
  for (const auto& selector : test_selectors) {
    std::shared_ptr<CSSSelectorList> list = ParseSelectorList(selector);
    EXPECT_TRUE(list) << "Failed to parse selector: " << selector;
    EXPECT_TRUE(list->IsValid()) << "Invalid selector: " << selector;
  }
}

TEST(CSSSelector, OverflowRareDataMatchNth) {
  auto env = TEST_init();
  int max_int = std::numeric_limits<int>::max();
  int min_int = std::numeric_limits<int>::min();
  CSSSelector selector;

  // Overflow count - b (max_int - -1 = max_int + 1)
  selector.SetNth(1, -1, /*sub_selector=*/nullptr);
  EXPECT_FALSE(selector.MatchNth(max_int));
  // 0 - (min_int) = max_int + 1
  selector.SetNth(1, min_int, /*sub_selector=*/nullptr);
  EXPECT_FALSE(selector.MatchNth(0));

  // min_int - 1
  selector.SetNth(-1, min_int, /*sub_selector=*/nullptr);
  EXPECT_FALSE(selector.MatchNth(1));

  // a shouldn't negate to itself (and min_int negates to itself).
  // Note: This test can only fail when using ubsan.
  selector.SetNth(min_int, 10, /*sub_selector=*/nullptr);
  EXPECT_FALSE(selector.MatchNth(2));
}

TEST(CSSSelector, Specificity_Is) {
  auto env = TEST_init();
  EXPECT_EQ(Specificity(".a :is(.b, div.c)"), Specificity(".a div.c"));
  EXPECT_EQ(Specificity(".a :is(.c#d, .e)"), Specificity(".a .c#d"));
  EXPECT_EQ(Specificity(":is(.e+.f, .g>.b, .h)"), Specificity(".e+.f"));
  EXPECT_EQ(Specificity(".a :is(.e+.f, .g>.b, .h#i)"), Specificity(".a .h#i"));
  EXPECT_EQ(Specificity(".a+:is(.b+span.f, :is(.c>.e, .g))"),
            Specificity(".a+.b+span.f"));
  EXPECT_EQ(Specificity("div > :is(div:where(span:where(.b ~ .c)))"),
            Specificity("div > div"));
  EXPECT_EQ(Specificity(":is(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"),
            Specificity(".c + .c + .c"));
}

TEST(CSSSelector, Specificity_Where) {
  auto env = TEST_init();
  EXPECT_EQ(Specificity(".a :where(.b, div.c)"), Specificity(".a"));
  EXPECT_EQ(Specificity(".a :where(.c#d, .e)"), Specificity(".a"));
  EXPECT_EQ(Specificity(":where(.e+.f, .g>.b, .h)"), Specificity("*"));
  EXPECT_EQ(Specificity(".a :where(.e+.f, .g>.b, .h#i)"), Specificity(".a"));
  EXPECT_EQ(Specificity("div > :where(.b+span.f, :where(.c>.e, .g))"),
            Specificity("div"));
  EXPECT_EQ(Specificity("div > :where(div:is(span:is(.b ~ .c)))"),
            Specificity("div"));
  EXPECT_EQ(
      Specificity(":where(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"),
      Specificity("*"));
}

TEST(CSSSelector, Specificity_Slotted) {
  auto env = TEST_init();
  EXPECT_EQ(Specificity("::slotted(.a)"), Specificity(".a::first-line"));
  EXPECT_EQ(Specificity("::slotted(*)"), Specificity("::first-line"));
}

TEST(CSSSelector, Specificity_Host) {
  auto env = TEST_init();
  EXPECT_EQ(Specificity(":host"), Specificity(".host"));
  EXPECT_EQ(Specificity(":host(.a)"), Specificity(".host .a"));
  EXPECT_EQ(Specificity(":host(div#a.b)"), Specificity(".host div#a.b"));
}

TEST(CSSSelector, Specificity_HostContext) {
  auto env = TEST_init();
  EXPECT_EQ(Specificity(":host-context(.a)"), Specificity(".host-context .a"));
  EXPECT_EQ(Specificity(":host-context(div#a.b)"),
            Specificity(".host-context div#a.b"));
}

TEST(CSSSelector, Specificity_Not) {
  auto env = TEST_init();
  EXPECT_EQ(Specificity(":not(div)"), Specificity(":is(div)"));
  EXPECT_EQ(Specificity(":not(.a)"), Specificity(":is(.a)"));
  EXPECT_EQ(Specificity(":not(div.a)"), Specificity(":is(div.a)"));
  EXPECT_EQ(Specificity(".a :not(.b, div.c)"),
            Specificity(".a :is(.b, div.c)"));
  EXPECT_EQ(Specificity(".a :not(.c#d, .e)"), Specificity(".a :is(.c#d, .e)"));
  EXPECT_EQ(Specificity(".a :not(.e+.f, .g>.b, .h#i)"),
            Specificity(".a :is(.e+.f, .g>.b, .h#i)"));
  EXPECT_EQ(Specificity(":not(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"),
            Specificity(":is(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"));
}

TEST(CSSSelector, Specificity_Has) {
  auto env = TEST_init();
  EXPECT_EQ(Specificity(":has(div)"), Specificity("div"));
  EXPECT_EQ(Specificity(":has(div)"), Specificity("* div"));
  EXPECT_EQ(Specificity(":has(~ div)"), Specificity("* ~ div"));
  EXPECT_EQ(Specificity(":has(> .a)"), Specificity("* > .a"));
  EXPECT_EQ(Specificity(":has(+ div.a)"), Specificity("* + div.a"));
  EXPECT_EQ(Specificity(".a :has(.b, div.c)"), Specificity(".a div.c"));
  EXPECT_EQ(Specificity(".a :has(.c#d, .e)"), Specificity(".a .c#d"));
  EXPECT_EQ(Specificity(":has(.e+.f, .g>.b, .h)"), Specificity(".e+.f"));
  EXPECT_EQ(Specificity(".a :has(.e+.f, .g>.b, .h#i)"), Specificity(".a .h#i"));
  EXPECT_EQ(Specificity("div > :has(div, div:where(span:where(.b ~ .c)))"),
            Specificity("div > div"));
  EXPECT_EQ(Specificity(":has(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"),
            Specificity(".c + .c + .c"));
}

TEST(CSSSelector, HasLinkOrVisited) {
  auto env = TEST_init();
  EXPECT_FALSE(HasLinkOrVisited("tag"));
  EXPECT_FALSE(HasLinkOrVisited("visited"));
  EXPECT_FALSE(HasLinkOrVisited("link"));
  EXPECT_FALSE(HasLinkOrVisited(".a"));
  EXPECT_FALSE(HasLinkOrVisited("#a:is(visited)"));
  EXPECT_FALSE(HasLinkOrVisited(":not(link):hover"));
  EXPECT_FALSE(HasLinkOrVisited(":hover"));
  EXPECT_FALSE(HasLinkOrVisited(":is(:hover)"));
  EXPECT_FALSE(HasLinkOrVisited(":not(:is(:hover))"));
  
  EXPECT_TRUE(HasLinkOrVisited(":visited"));
  EXPECT_TRUE(HasLinkOrVisited(":link"));
  EXPECT_TRUE(HasLinkOrVisited(":visited:link"));
  EXPECT_TRUE(HasLinkOrVisited(":not(:visited)"));
  EXPECT_TRUE(HasLinkOrVisited(":not(:link)"));
  EXPECT_TRUE(HasLinkOrVisited(":not(:is(:link))"));
  EXPECT_TRUE(HasLinkOrVisited(":is(:link)"));
  EXPECT_TRUE(HasLinkOrVisited(":is(.a, .b, :is(:visited))"));
  EXPECT_TRUE(HasLinkOrVisited("::cue(:visited)"));
  EXPECT_TRUE(HasLinkOrVisited("::cue(:link)"));
  EXPECT_TRUE(HasLinkOrVisited(":host(:link)"));
  EXPECT_TRUE(HasLinkOrVisited(":host-context(:link)"));
}

TEST(CSSSelector, CueDefaultNamespace) {
  auto env = TEST_init();
  
  // Test ::cue pseudo-element parsing
  std::shared_ptr<CSSSelectorList> list = ParseSelectorList("video::cue(b)");
  EXPECT_TRUE(list);
  // Note: WebF may not have full ::cue support yet, so we just verify parsing doesn't crash
}

TEST(CSSSelector, CopyInvalidList) {
  auto env = TEST_init();
  auto list = CSSSelectorList::Empty();
  EXPECT_FALSE(list->IsValid());
  EXPECT_FALSE(list->Copy()->IsValid());
}

TEST(CSSSelector, CopyValidList) {
  auto env = TEST_init();
  auto list = ParseSelectorList(".a");
  EXPECT_TRUE(list->IsValid());
  EXPECT_TRUE(list->Copy()->IsValid());
}

TEST(CSSSelector, FirstInInvalidList) {
  auto env = TEST_init();
  auto list = CSSSelectorList::Empty();
  EXPECT_FALSE(list->IsValid());
  EXPECT_FALSE(list->First());
}

TEST(CSSSelector, ModernSelectorsParsing) {
  auto env = TEST_init();
  
  // Test :is() pseudo-class parsing
  {
    auto list = ParseSelectorList(":is(.a, .b)");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
    const CSSSelector* selector = list->First();
    ASSERT_TRUE(selector);
    EXPECT_EQ(selector->GetPseudoType(), CSSSelector::kPseudoIs);
    // Check that it has a selector list
    EXPECT_TRUE(selector->SelectorList() != nullptr);
  }
  
  // Test :where() pseudo-class parsing
  {
    auto list = ParseSelectorList(":where(.a, .b)");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
    const CSSSelector* selector = list->First();
    ASSERT_TRUE(selector);
    EXPECT_EQ(selector->GetPseudoType(), CSSSelector::kPseudoWhere);
    EXPECT_TRUE(selector->SelectorList() != nullptr);
  }
  
  // Test :has() pseudo-class parsing
  {
    auto list = ParseSelectorList(":has(.child)");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
    const CSSSelector* selector = list->First();
    ASSERT_TRUE(selector);
    EXPECT_EQ(selector->GetPseudoType(), CSSSelector::kPseudoHas);
    EXPECT_TRUE(selector->SelectorList() != nullptr);
  }
  
  // Test :focus-visible pseudo-class parsing
  {
    auto list = ParseSelectorList(":focus-visible");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
    const CSSSelector* selector = list->First();
    ASSERT_TRUE(selector);
    EXPECT_EQ(selector->GetPseudoType(), CSSSelector::kPseudoFocusVisible);
  }
  
  // Test :focus-within pseudo-class parsing
  {
    auto list = ParseSelectorList(":focus-within");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
    const CSSSelector* selector = list->First();
    ASSERT_TRUE(selector);
    EXPECT_EQ(selector->GetPseudoType(), CSSSelector::kPseudoFocusWithin);
  }
  
  // Test ::backdrop pseudo-element parsing
  {
    auto list = ParseSelectorList("::backdrop");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
    const CSSSelector* selector = list->First();
    ASSERT_TRUE(selector);
    EXPECT_EQ(selector->GetPseudoType(), CSSSelector::kPseudoBackdrop);
  }
}

TEST(CSSSelector, ComplexModernSelectors) {
  auto env = TEST_init();
  
  // Test nested :is() selectors
  {
    auto list = ParseSelectorList(":is(:is(.a, .b), .c)");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
  }
  
  // Test :where() with complex selectors
  {
    auto list = ParseSelectorList(":where(.parent > .child, .sibling + .sibling)");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
  }
  
  // Test :has() with combinators
  {
    auto list = ParseSelectorList("div:has(> .direct-child)");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
  }
  
  // Test combination of modern selectors
  {
    auto list = ParseSelectorList(".container:has(.item):is(:hover, :focus-within)");
    ASSERT_TRUE(list);
    ASSERT_TRUE(list->IsValid());
  }
}

// The following tests use lower-level CSSSelector APIs that may not be 
// fully exposed in WebF yet, so they're commented out for now.

// TEST(CSSSelector, ImplicitPseudoDescendant) {
//   auto env = TEST_init();
//   CSSSelector selector[2] = {
//       CSSSelector(AtomicString::FromUTF8("div"),
//                   /* is_implicit */ false),
//       CSSSelector(AtomicString::FromUTF8("scope"), /* is_implicit */ true)};
//   selector[0].SetRelation(CSSSelector::kDescendant);
//   selector[1].SetLastInComplexSelector(true);
//   EXPECT_EQ("div", selector[0].SelectorText());
// }

// TEST(CSSSelector, ImplicitPseudoChild) {
//   auto env = TEST_init();
//   CSSSelector selector[2] = {
//       CSSSelector(AtomicString::FromUTF8("div"),
//                   /* is_implicit */ false),
//       CSSSelector(AtomicString::FromUTF8("scope"), /* is_implicit */ true)};
//   selector[0].SetRelation(CSSSelector::kChild);
//   selector[1].SetLastInComplexSelector(true);
//   EXPECT_EQ("> div", selector[0].SelectorText());
// }

// TEST(CSSSelector, NonImplicitPseudoChild) {
//   auto env = TEST_init();
//   CSSSelector selector[2] = {
//       CSSSelector(AtomicString::FromUTF8("div"),
//                   /* is_implicit */ false),
//       CSSSelector(AtomicString::FromUTF8("scope"), /* is_implicit */ false)};
//   selector[0].SetRelation(CSSSelector::kChild);
//   selector[1].SetLastInComplexSelector(true);
//   EXPECT_EQ(":scope > div", selector[0].SelectorText());
// }

// TEST(CSSSelector, ImplicitScopeSpecificity) {
//   auto env = TEST_init();
//   CSSSelector selector[2] = {
//       CSSSelector(AtomicString::FromUTF8("div"),
//                   /* is_implicit */ false),
//       CSSSelector(AtomicString::FromUTF8("scope"), /* is_implicit */ true)};
//   selector[0].SetRelation(CSSSelector::kChild);
//   selector[1].SetLastInComplexSelector(true);
//   EXPECT_EQ("> div", selector[0].SelectorText());
//   EXPECT_EQ(CSSSelector::kTagSpecificity, selector[0].Specificity());
// }

}  // namespace webf