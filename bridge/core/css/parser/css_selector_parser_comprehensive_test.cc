/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 * Based on Chromium's css_selector_parser_test.cc
 */

#include "gtest/gtest.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/style_rule.h"
#include "core/css/css_selector_list.h"
#include "core/css/css_selector.h"
#include "test/webf_test_env.h"

namespace webf {

class CSSSelectorParserComprehensiveTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Don't create a new test environment for each test
    // This might be causing resource exhaustion
    // env_ = TEST_init();
    context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }
  
  void TearDown() override {
    // Reset in the correct order to avoid any dangling references
    context_.reset();
    // env_.reset();
  }

  // Helper to parse a selector and check if it's valid
  bool IsValidSelector(const std::string& selector) {
    auto sheet = std::make_shared<StyleSheetContents>(context_);
    String css = String::FromUTF8(selector.c_str()) + String::FromUTF8(" { }");
    CSSParser::ParseSheet(context_, sheet, css);
    
    if (sheet->ChildRules().empty()) {
      return false;
    }
    
    auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
    return rule != nullptr && rule->FirstSelector() != nullptr;
  }

  // Helper to get selector text
  String GetSelectorText(const String& selector) {
    auto sheet = std::make_shared<StyleSheetContents>(context_);
    String css = selector + String::FromUTF8(" { }");
    CSSParser::ParseSheet(context_, sheet, css);
    
    if (sheet->ChildRules().empty()) {
      return String::EmptyString();
    }
    
    auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
    if (!rule) {
      return String::EmptyString();
    }
    
    return rule->SelectorsText();
  }

  // Helper to count selectors in a selector list
  size_t CountSelectors(const std::string& selector_list) {
    auto sheet = std::make_shared<StyleSheetContents>(context_);
    std::string css = selector_list + " { }";
    CSSParser::ParseSheet(context_, sheet, String::FromUTF8(css.c_str()));
    
    if (sheet->ChildRules().empty()) {
      return 0;
    }
    
    auto* rule = DynamicTo<StyleRule>(sheet->ChildRules()[0].get());
    if (!rule) {
      return 0;
    }
    
    // Count selectors by looking for commas in the selector text
    String selectors_text = rule->SelectorsText();
    if (selectors_text.IsEmpty()) {
      return 0;
    }
    
    // Defensive limit to prevent infinite loops
    if (selectors_text.length() > 10000) {
      return 0;
    }
    
    size_t count = 1;
    for (size_t i = 0; i < selectors_text.length(); i++) {
      if (selectors_text[i] == ',') {
        count++;
      }
    }
    return count;
  }

  // std::unique_ptr<WebFTestEnv> env_;
  std::shared_ptr<CSSParserContext> context_;
};

// Test type selectors
TEST_F(CSSSelectorParserComprehensiveTest, TypeSelectors) {
  // Basic element selectors
  EXPECT_TRUE(IsValidSelector("div"));
  EXPECT_TRUE(IsValidSelector("p"));
  EXPECT_TRUE(IsValidSelector("body"));
  EXPECT_TRUE(IsValidSelector("html"));
  EXPECT_TRUE(IsValidSelector("span"));
  EXPECT_TRUE(IsValidSelector("a"));
  EXPECT_TRUE(IsValidSelector("h1"));
  
  // Custom elements
  EXPECT_TRUE(IsValidSelector("my-element"));
  EXPECT_TRUE(IsValidSelector("custom-tag"));
  
  // Case sensitivity (CSS is case-insensitive for HTML)
  EXPECT_TRUE(IsValidSelector("DIV"));
  EXPECT_TRUE(IsValidSelector("Div"));
  
  // Invalid type selectors
  EXPECT_FALSE(IsValidSelector("123"));  // Can't start with number
  EXPECT_FALSE(IsValidSelector("-123"));  // Can't start with hyphen-number
}

// Test universal selector
TEST_F(CSSSelectorParserComprehensiveTest, UniversalSelector) {
  EXPECT_TRUE(IsValidSelector("*"));
  EXPECT_EQ(GetSelectorText(String::FromUTF8("*")), "*");
}

// Test class selectors
TEST_F(CSSSelectorParserComprehensiveTest, ClassSelectors) {
  // Basic class selectors
  EXPECT_TRUE(IsValidSelector(".class"));
  EXPECT_TRUE(IsValidSelector(".my-class"));
  EXPECT_TRUE(IsValidSelector(".className"));
  EXPECT_TRUE(IsValidSelector("._underscore"));
  EXPECT_TRUE(IsValidSelector(".-hyphen"));
  
  // Multiple classes
  EXPECT_TRUE(IsValidSelector(".class1.class2"));
  EXPECT_TRUE(IsValidSelector(".class1.class2.class3"));
  
  // Type with class
  EXPECT_TRUE(IsValidSelector("div.class"));
  EXPECT_TRUE(IsValidSelector("p.class1.class2"));
  
  // Invalid class selectors
  EXPECT_FALSE(IsValidSelector("."));  // Missing class name
  EXPECT_FALSE(IsValidSelector(".123"));  // Can't start with number
}

// Test ID selectors
TEST_F(CSSSelectorParserComprehensiveTest, IDSelectors) {
  // Basic ID selectors
  EXPECT_TRUE(IsValidSelector("#id"));
  EXPECT_TRUE(IsValidSelector("#my-id"));
  EXPECT_TRUE(IsValidSelector("#myId"));
  EXPECT_TRUE(IsValidSelector("#_underscore"));
  EXPECT_TRUE(IsValidSelector("#-hyphen"));
  
  // Type with ID
  EXPECT_TRUE(IsValidSelector("div#id"));
  EXPECT_TRUE(IsValidSelector("p#my-id"));
  
  // ID with class
  EXPECT_TRUE(IsValidSelector("#id.class"));
  EXPECT_TRUE(IsValidSelector("div#id.class"));
  
  // Invalid ID selectors
  EXPECT_FALSE(IsValidSelector("#"));  // Missing ID
  EXPECT_FALSE(IsValidSelector("#123"));  // Can't start with number
}

// Test attribute selectors
TEST_F(CSSSelectorParserComprehensiveTest, AttributeSelectors) {
  // Presence
  EXPECT_TRUE(IsValidSelector("[attr]"));
  EXPECT_TRUE(IsValidSelector("[data-attr]"));
  EXPECT_TRUE(IsValidSelector("div[attr]"));
  
  // Exact match
  EXPECT_TRUE(IsValidSelector("[attr=value]"));
  EXPECT_TRUE(IsValidSelector("[attr=\"value\"]"));
  EXPECT_TRUE(IsValidSelector("[attr='value']"));
  EXPECT_TRUE(IsValidSelector("[attr=\"value with spaces\"]"));
  
  // Substring matches
  EXPECT_TRUE(IsValidSelector("[attr~=value]"));  // Word
  EXPECT_TRUE(IsValidSelector("[attr|=value]"));  // Prefix
  EXPECT_TRUE(IsValidSelector("[attr^=value]"));  // Begins with
  EXPECT_TRUE(IsValidSelector("[attr$=value]"));  // Ends with
  EXPECT_TRUE(IsValidSelector("[attr*=value]"));  // Contains
  
  // Case sensitivity
  EXPECT_TRUE(IsValidSelector("[attr=value i]"));  // Case-insensitive
  EXPECT_TRUE(IsValidSelector("[attr=value I]"));
  EXPECT_TRUE(IsValidSelector("[attr=value s]"));  // Case-sensitive
  EXPECT_TRUE(IsValidSelector("[attr=value S]"));
  
  // Multiple attributes
  EXPECT_TRUE(IsValidSelector("[attr1][attr2]"));
  EXPECT_TRUE(IsValidSelector("[attr1=value1][attr2=value2]"));
  
  // Complex selectors with attributes
  EXPECT_TRUE(IsValidSelector("div.class[attr]#id"));
  EXPECT_TRUE(IsValidSelector("input[type=\"text\"][required]"));
  
  // Invalid attribute selectors
  EXPECT_FALSE(IsValidSelector("[]"));  // Empty
  EXPECT_FALSE(IsValidSelector("[=value]"));  // Missing attribute
  EXPECT_FALSE(IsValidSelector("[attr=]"));  // Missing value (but empty string is valid)
  EXPECT_TRUE(IsValidSelector("[attr=\"\"]"));  // Empty string is valid
}

// Test pseudo-class selectors
TEST_F(CSSSelectorParserComprehensiveTest, PseudoClassSelectors) {
  // Link pseudo-classes
  EXPECT_TRUE(IsValidSelector(":link"));
  EXPECT_TRUE(IsValidSelector(":visited"));
  EXPECT_TRUE(IsValidSelector(":hover"));
  EXPECT_TRUE(IsValidSelector(":active"));
  EXPECT_TRUE(IsValidSelector(":focus"));
  
  // Structural pseudo-classes
  EXPECT_TRUE(IsValidSelector(":root"));
  EXPECT_TRUE(IsValidSelector(":first-child"));
  EXPECT_TRUE(IsValidSelector(":last-child"));
  EXPECT_TRUE(IsValidSelector(":only-child"));
  EXPECT_TRUE(IsValidSelector(":first-of-type"));
  EXPECT_TRUE(IsValidSelector(":last-of-type"));
  EXPECT_TRUE(IsValidSelector(":only-of-type"));
  EXPECT_TRUE(IsValidSelector(":empty"));
  
  // nth pseudo-classes
  EXPECT_TRUE(IsValidSelector(":nth-child(1)"));
  EXPECT_TRUE(IsValidSelector(":nth-child(2n)"));
  EXPECT_TRUE(IsValidSelector(":nth-child(2n+1)"));
  EXPECT_TRUE(IsValidSelector(":nth-child(odd)"));
  EXPECT_TRUE(IsValidSelector(":nth-child(even)"));
  EXPECT_TRUE(IsValidSelector(":nth-last-child(1)"));
  EXPECT_TRUE(IsValidSelector(":nth-of-type(2)"));
  EXPECT_TRUE(IsValidSelector(":nth-last-of-type(2)"));
  
  // UI state pseudo-classes
  EXPECT_TRUE(IsValidSelector(":enabled"));
  EXPECT_TRUE(IsValidSelector(":disabled"));
  EXPECT_TRUE(IsValidSelector(":checked"));
  EXPECT_TRUE(IsValidSelector(":indeterminate"));
  EXPECT_TRUE(IsValidSelector(":default"));
  EXPECT_TRUE(IsValidSelector(":required"));
  EXPECT_TRUE(IsValidSelector(":optional"));
  EXPECT_TRUE(IsValidSelector(":valid"));
  EXPECT_TRUE(IsValidSelector(":invalid"));
  EXPECT_TRUE(IsValidSelector(":in-range"));
  EXPECT_TRUE(IsValidSelector(":out-of-range"));
  EXPECT_TRUE(IsValidSelector(":read-only"));
  EXPECT_TRUE(IsValidSelector(":read-write"));
  
  // Negation pseudo-class
  EXPECT_TRUE(IsValidSelector(":not(p)"));
  EXPECT_TRUE(IsValidSelector(":not(.class)"));
  EXPECT_TRUE(IsValidSelector(":not([attr])"));
  EXPECT_TRUE(IsValidSelector(":not(:hover)"));
  
  // :is() and :where()
  EXPECT_TRUE(IsValidSelector(":is(div, p)"));
  EXPECT_TRUE(IsValidSelector(":where(div, p)"));
  EXPECT_TRUE(IsValidSelector(":is(.class1, .class2)"));
  
  // :has() (if supported)
  EXPECT_TRUE(IsValidSelector(":has(p)"));
  EXPECT_TRUE(IsValidSelector(":has(> p)"));
  EXPECT_TRUE(IsValidSelector(":has(+ p)"));
  
  // Language pseudo-class
  EXPECT_TRUE(IsValidSelector(":lang(en)"));
  EXPECT_TRUE(IsValidSelector(":lang(en-US)"));
  
  // Invalid pseudo-classes
  EXPECT_FALSE(IsValidSelector(":"));  // Missing name
  EXPECT_FALSE(IsValidSelector(":invalid-pseudo"));  // Unknown pseudo-class
  EXPECT_FALSE(IsValidSelector(":nth-child()"));  // Missing argument
}

// Test pseudo-element selectors
TEST_F(CSSSelectorParserComprehensiveTest, PseudoElementSelectors) {
  // Standard pseudo-elements (double colon)
  EXPECT_TRUE(IsValidSelector("::before"));
  EXPECT_TRUE(IsValidSelector("::after"));
  EXPECT_TRUE(IsValidSelector("::first-line"));
  EXPECT_TRUE(IsValidSelector("::first-letter"));
  EXPECT_TRUE(IsValidSelector("::selection"));
  EXPECT_TRUE(IsValidSelector("::placeholder"));
  EXPECT_TRUE(IsValidSelector("::marker"));
  
  // Legacy single colon syntax (for compatibility)
  EXPECT_TRUE(IsValidSelector(":before"));
  EXPECT_TRUE(IsValidSelector(":after"));
  EXPECT_TRUE(IsValidSelector(":first-line"));
  EXPECT_TRUE(IsValidSelector(":first-letter"));
  
  // With type selector
  EXPECT_TRUE(IsValidSelector("p::before"));
  EXPECT_TRUE(IsValidSelector("div::after"));
  
  // With other selectors
  EXPECT_TRUE(IsValidSelector("p.class::before"));
  EXPECT_TRUE(IsValidSelector("#id::after"));
  
  // Invalid pseudo-elements
  EXPECT_FALSE(IsValidSelector("::"));  // Missing name
  EXPECT_FALSE(IsValidSelector("::invalid-pseudo"));  // Unknown pseudo-element
}

// Test combinators
TEST_F(CSSSelectorParserComprehensiveTest, Combinators) {
  // Descendant combinator (space)
  EXPECT_TRUE(IsValidSelector("div p"));
  EXPECT_TRUE(IsValidSelector("body div span"));
  EXPECT_TRUE(IsValidSelector(".class1 .class2"));
  
  // Child combinator (>)
  EXPECT_TRUE(IsValidSelector("div > p"));
  EXPECT_TRUE(IsValidSelector("body > div > span"));
  EXPECT_TRUE(IsValidSelector(".parent > .child"));
  
  // Adjacent sibling combinator (+)
  EXPECT_TRUE(IsValidSelector("div + p"));
  EXPECT_TRUE(IsValidSelector("h1 + h2"));
  EXPECT_TRUE(IsValidSelector(".class1 + .class2"));
  
  // General sibling combinator (~)
  EXPECT_TRUE(IsValidSelector("div ~ p"));
  EXPECT_TRUE(IsValidSelector("h1 ~ p"));
  EXPECT_TRUE(IsValidSelector(".class1 ~ .class2"));
  
  // Complex combinations
  EXPECT_TRUE(IsValidSelector("div > p + span"));
  EXPECT_TRUE(IsValidSelector("body > div.class > p#id"));
  EXPECT_TRUE(IsValidSelector("div:hover > p::before"));
  
  // Multiple spaces (should be treated as single descendant)
  EXPECT_TRUE(IsValidSelector("div    p"));
  EXPECT_TRUE(IsValidSelector("div\n\t p"));
  
  // Invalid combinators
  EXPECT_FALSE(IsValidSelector("> p"));  // Missing left side
  EXPECT_FALSE(IsValidSelector("p >"));  // Missing right side
  EXPECT_FALSE(IsValidSelector("+ p"));  // Missing left side
  EXPECT_FALSE(IsValidSelector("~ p"));  // Missing left side
}

// Test selector lists (comma-separated)
TEST_F(CSSSelectorParserComprehensiveTest, SelectorLists) {
  // Basic lists
  EXPECT_TRUE(IsValidSelector("div, p"));
  EXPECT_TRUE(IsValidSelector("h1, h2, h3"));
  EXPECT_TRUE(IsValidSelector(".class1, .class2, .class3"));
  
  // Count selectors
  EXPECT_EQ(CountSelectors("div"), 1u);
  EXPECT_EQ(CountSelectors("div, p"), 2u);
  EXPECT_EQ(CountSelectors("h1, h2, h3, h4, h5, h6"), 6u);
  
  // Complex selectors in lists
  EXPECT_TRUE(IsValidSelector("div > p, span + a"));
  EXPECT_TRUE(IsValidSelector("p:hover, a:focus"));
  EXPECT_TRUE(IsValidSelector("#id1, .class1, [attr1]"));
  
  // Whitespace handling
  EXPECT_TRUE(IsValidSelector("div,p"));  // No space
  EXPECT_TRUE(IsValidSelector("div , p"));  // Extra spaces
  EXPECT_TRUE(IsValidSelector("div\n,\np"));  // Newlines
  
  // Invalid lists
  EXPECT_FALSE(IsValidSelector("div,"));  // Trailing comma
  EXPECT_FALSE(IsValidSelector(",p"));  // Leading comma
  EXPECT_FALSE(IsValidSelector("div,,p"));  // Double comma
}

// Test complex selectors
TEST_F(CSSSelectorParserComprehensiveTest, ComplexSelectors) {
  // Real-world examples
  EXPECT_TRUE(IsValidSelector("nav ul li a:hover"));
  EXPECT_TRUE(IsValidSelector(".container > .row > .col-md-6"));
  EXPECT_TRUE(IsValidSelector("input[type=\"checkbox\"]:checked + label"));
  EXPECT_TRUE(IsValidSelector("body:not(.no-js) .feature"));
  EXPECT_TRUE(IsValidSelector("#header nav > ul > li:first-child > a"));
  EXPECT_TRUE(IsValidSelector(".btn:not(:disabled):not(.disabled):active"));
  EXPECT_TRUE(IsValidSelector("article > h1 + p:first-of-type::first-letter"));
  
  // Very complex selectors
  EXPECT_TRUE(IsValidSelector(
    "body > main > article:nth-of-type(2n+1) > section.content > p:not(:empty)::first-line"));
  EXPECT_TRUE(IsValidSelector(
    ".nav-menu > li:hover > ul.submenu > li > a[href^=\"http\"]:not([target=\"_blank\"])"));
}

// Test namespace selectors (if supported)
TEST_F(CSSSelectorParserComprehensiveTest, NamespaceSelectors) {
  // Universal namespace - these work without namespace declarations
  EXPECT_TRUE(IsValidSelector("*|div"));
  EXPECT_TRUE(IsValidSelector("*|*"));
  
  // Specific namespace selectors require @namespace declarations
  // which cannot be easily tested with this simple test setup.
  // In a real stylesheet, you would need:
  // @namespace ns "http://example.com/ns";
  // @namespace svg "http://www.w3.org/2000/svg";
  // Then ns|div and svg|rect would be valid.
  
  // No namespace - this also works without declarations
  EXPECT_TRUE(IsValidSelector("|div"));
}

// Test edge cases and error recovery
TEST_F(CSSSelectorParserComprehensiveTest, EdgeCases) {
  // Empty selector (invalid)
  EXPECT_FALSE(IsValidSelector(""));
  EXPECT_FALSE(IsValidSelector("   "));  // Just whitespace
  
  // Unicode in selectors
  EXPECT_TRUE(IsValidSelector(".café"));
  EXPECT_TRUE(IsValidSelector("#π"));
  EXPECT_TRUE(IsValidSelector("[data-emoji=\"🎨\"]"));
  
  // Escaped characters
  EXPECT_TRUE(IsValidSelector(".class\\:name"));  // Escaped colon
  EXPECT_TRUE(IsValidSelector("#id\\#hash"));  // Escaped hash
  EXPECT_TRUE(IsValidSelector(".class\\.dot"));  // Escaped dot
  
  // Very long selectors
  std::string long_selector = "div";
  for (int i = 0; i < 100; ++i) {
    long_selector += " > div";
  }
  EXPECT_TRUE(IsValidSelector(long_selector));
  
  // Case preservation in attribute values
  EXPECT_EQ(GetSelectorText(String::FromUTF8("[attr=\"CaseSensitive\"]")), "[attr=\"CaseSensitive\"]"_s);
}

// Test specificity-related parsing
TEST_F(CSSSelectorParserComprehensiveTest, SpecificityRelated) {
  // These should all parse correctly, specificity calculation is separate
  EXPECT_TRUE(IsValidSelector("div"));  // 0,0,0,1
  EXPECT_TRUE(IsValidSelector(".class"));  // 0,0,1,0
  EXPECT_TRUE(IsValidSelector("#id"));  // 0,1,0,0
  EXPECT_TRUE(IsValidSelector("div.class#id"));  // 0,1,1,1
  EXPECT_TRUE(IsValidSelector("div.class1.class2"));  // 0,0,2,1
  EXPECT_TRUE(IsValidSelector(":not(#id)"));  // 0,1,0,0 (not doesn't add specificity, its arg does)
  EXPECT_TRUE(IsValidSelector(":is(.class1, #id)"));  // Highest specificity of arguments
}

}  // namespace webf