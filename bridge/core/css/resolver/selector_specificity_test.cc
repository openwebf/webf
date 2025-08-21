/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 * Based on Chromium CSS selector specificity tests
 */

#include "gtest/gtest.h"
#include "webf_test_env.h"
#include "core/css/css_test_helpers.h"
#include "core/css/css_selector_list.h"

namespace webf {

// Based on blink/renderer/core/css/css_selector_test.cc
// Helper function to calculate specificity
static unsigned Specificity(const std::string& selector_text) {
  std::shared_ptr<CSSSelectorList> selector_list = css_test_helpers::ParseSelectorList(String::FromUTF8(selector_text));
  if (selector_list && selector_list->First()) {
    return selector_list->First()->Specificity();
  }
  return 0;
}

// Test basic selector specificity
TEST(SelectorSpecificityTest, BasicSpecificity) {
  // Universal selector
  EXPECT_EQ(Specificity("*"), 0x000000);
  
  // Type selectors
  EXPECT_EQ(Specificity("div"), 0x000001);
  EXPECT_EQ(Specificity("h1"), 0x000001);
  EXPECT_EQ(Specificity("p"), 0x000001);
  
  // Class selectors
  EXPECT_EQ(Specificity(".class"), 0x000100);
  EXPECT_EQ(Specificity(".foo"), 0x000100);
  
  // ID selectors
  EXPECT_EQ(Specificity("#id"), 0x010000);
  EXPECT_EQ(Specificity("#foo"), 0x010000);
  
  // Attribute selectors
  EXPECT_EQ(Specificity("[attr]"), 0x000100);
  EXPECT_EQ(Specificity("[attr=value]"), 0x000100);
  EXPECT_EQ(Specificity("[attr~=value]"), 0x000100);
  EXPECT_EQ(Specificity("[attr|=value]"), 0x000100);
  EXPECT_EQ(Specificity("[attr^=value]"), 0x000100);
  EXPECT_EQ(Specificity("[attr$=value]"), 0x000100);
  EXPECT_EQ(Specificity("[attr*=value]"), 0x000100);
}

// Test pseudo-class specificity
TEST(SelectorSpecificityTest, PseudoClassSpecificity) {
  // Pseudo-classes count as class selectors
  EXPECT_EQ(Specificity(":hover"), 0x000100);
  EXPECT_EQ(Specificity(":focus"), 0x000100);
  EXPECT_EQ(Specificity(":active"), 0x000100);
  EXPECT_EQ(Specificity(":visited"), 0x000100);
  EXPECT_EQ(Specificity(":link"), 0x000100);
  EXPECT_EQ(Specificity(":first-child"), 0x000100);
  EXPECT_EQ(Specificity(":last-child"), 0x000100);
  EXPECT_EQ(Specificity(":nth-child(2)"), 0x000100);
  EXPECT_EQ(Specificity(":nth-of-type(2n+1)"), 0x000100);
}

// Test pseudo-element specificity
TEST(SelectorSpecificityTest, PseudoElementSpecificity) {
  // Pseudo-elements count as type selectors
  EXPECT_EQ(Specificity("::before"), 0x000001);
  EXPECT_EQ(Specificity("::after"), 0x000001);
  EXPECT_EQ(Specificity("::first-line"), 0x000001);
  EXPECT_EQ(Specificity("::first-letter"), 0x000001);
  
  // Legacy single-colon syntax
  EXPECT_EQ(Specificity(":before"), 0x000001);
  EXPECT_EQ(Specificity(":after"), 0x000001);
  EXPECT_EQ(Specificity(":first-line"), 0x000001);
  EXPECT_EQ(Specificity(":first-letter"), 0x000001);
}

// Test combined selector specificity
TEST(SelectorSpecificityTest, CombinedSpecificity) {
  // Type + class
  EXPECT_EQ(Specificity("div.class"), 0x000101);
  
  // Type + ID
  EXPECT_EQ(Specificity("div#id"), 0x010001);
  
  // ID + class
  EXPECT_EQ(Specificity("#id.class"), 0x010100);
  
  // Type + ID + class
  EXPECT_EQ(Specificity("div#id.class"), 0x010101);
  
  // Multiple classes
  EXPECT_EQ(Specificity(".a.b"), 0x000200);
  EXPECT_EQ(Specificity(".a.b.c"), 0x000300);
  
  // Type + attribute
  EXPECT_EQ(Specificity("div[attr]"), 0x000101);
  
  // Type + pseudo-class
  EXPECT_EQ(Specificity("div:hover"), 0x000101);
  
  // Type + pseudo-element
  EXPECT_EQ(Specificity("div::before"), 0x000002);
}

// Test descendant combinator specificity
TEST(SelectorSpecificityTest, DescendantCombinatorSpecificity) {
  // Descendant
  EXPECT_EQ(Specificity("div p"), 0x000002);
  EXPECT_EQ(Specificity(".a .b"), 0x000200);
  EXPECT_EQ(Specificity("#a #b"), 0x020000);
  
  // Child
  EXPECT_EQ(Specificity("div > p"), 0x000002);
  EXPECT_EQ(Specificity(".a > .b"), 0x000200);
  
  // Adjacent sibling
  EXPECT_EQ(Specificity("div + p"), 0x000002);
  EXPECT_EQ(Specificity(".a + .b"), 0x000200);
  
  // General sibling
  EXPECT_EQ(Specificity("div ~ p"), 0x000002);
  EXPECT_EQ(Specificity(".a ~ .b"), 0x000200);
}

// Test complex selector specificity
TEST(SelectorSpecificityTest, ComplexSpecificity) {
  EXPECT_EQ(Specificity("#header .nav li:hover"), 0x010201);
  EXPECT_EQ(Specificity("body #content .article p:first-child"), 0x010202);
  EXPECT_EQ(Specificity("ul#nav li.active a"), 0x010103);
  EXPECT_EQ(Specificity("div.container > p.text:nth-child(2)"), 0x000302);
}

// Test :is() pseudo-class specificity (based on css_selector_test.cc)
TEST(SelectorSpecificityTest, IsSpecificity) {
  // :is() takes the specificity of its most specific argument
  EXPECT_EQ(Specificity(".a :is(.b, div.c)"), Specificity(".a div.c"));
  EXPECT_EQ(Specificity(".a :is(.c#d, .e)"), Specificity(".a .c#d"));
  EXPECT_EQ(Specificity(":is(.e+.f, .g>.b, .h)"), Specificity(".e+.f"));
  EXPECT_EQ(Specificity(".a :is(.e+.f, .g>.b, .h#i)"), Specificity(".a .h#i"));
  EXPECT_EQ(Specificity(".a+:is(.b+span.f, :is(.c>.e, .g))"), Specificity(".a+.b+span.f"));
  EXPECT_EQ(Specificity("div > :is(div:where(span:where(.b ~ .c)))"), Specificity("div > div"));
  EXPECT_EQ(Specificity(":is(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"), 
            Specificity(".c + .c + .c"));
}

// Test :where() pseudo-class specificity (based on css_selector_test.cc)
TEST(SelectorSpecificityTest, WhereSpecificity) {
  // :where() always has 0 specificity
  EXPECT_EQ(Specificity(".a :where(.b, div.c)"), Specificity(".a"));
  EXPECT_EQ(Specificity(".a :where(.c#d, .e)"), Specificity(".a"));
  EXPECT_EQ(Specificity(":where(.e+.f, .g>.b, .h)"), Specificity("*"));
  EXPECT_EQ(Specificity(".a :where(.e+.f, .g>.b, .h#i)"), Specificity(".a"));
  EXPECT_EQ(Specificity("div > :where(.b+span.f, :where(.c>.e, .g))"), Specificity("div"));
  EXPECT_EQ(Specificity("div > :where(div:is(span:is(.b ~ .c)))"), Specificity("div"));
  EXPECT_EQ(Specificity(":where(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"), 
            Specificity("*"));
}

// Test :not() pseudo-class specificity (based on css_selector_test.cc)
TEST(SelectorSpecificityTest, NotSpecificity) {
  // :not() has the specificity of its argument
  EXPECT_EQ(Specificity(":not(div)"), Specificity(":is(div)"));
  EXPECT_EQ(Specificity(":not(.a)"), Specificity(":is(.a)"));
  EXPECT_EQ(Specificity(":not(div.a)"), Specificity(":is(div.a)"));
  EXPECT_EQ(Specificity(".a :not(.b, div.c)"), Specificity(".a :is(.b, div.c)"));
  EXPECT_EQ(Specificity(".a :not(.c#d, .e)"), Specificity(".a :is(.c#d, .e)"));
  EXPECT_EQ(Specificity(".a :not(.e+.f, .g>.b, .h#i)"), 
            Specificity(".a :is(.e+.f, .g>.b, .h#i)"));
  EXPECT_EQ(Specificity(":not(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"),
            Specificity(":is(.c + .c + .c, .b + .c:not(span), .b + .c + .e)"));
}

}  // namespace webf