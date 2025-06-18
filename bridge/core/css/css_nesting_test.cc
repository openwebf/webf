// Copyright 2024 The WebF Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/css_selector.h"
#include "core/css/css_selector_list.h"
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_nesting_type.h"
#include "core/css/style_rule.h"
#include "core/dom/document.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

using css_test_helpers::ParseRule;

namespace {

std::shared_ptr<StyleRule> ParseNestedRule(const String& rule_string) {
  auto context = std::make_shared<CSSParserContext>(CSSParserMode::kHTMLStandardMode,
                                                    kHTMLStandardMode, SecureContextMode::kInsecureContext);
  auto* rule = ParseRule(rule_string, context);
  if (!rule || !rule->IsStyleRule()) {
    return nullptr;
  }
  return std::static_pointer_cast<StyleRule>(rule);
}

bool HasParentSelector(const String& selector_string) {
  auto list = css_test_helpers::ParseSelectorList(selector_string);
  if (!list || !list->First()) {
    return false;
  }
  
  // Check if any selector in the list contains a parent selector
  for (const CSSSelector* selector = list->First(); selector; 
       selector = CSSSelectorList::Next(*selector)) {
    for (const CSSSelector* current = selector; current; 
         current = current->TagHistory()) {
      if (current->GetPseudoType() == CSSSelector::kPseudoParent) {
        return true;
      }
    }
  }
  return false;
}

}  // namespace

TEST(CSSNesting, ParentSelectorParsing) {
  auto env = TEST_init();
  
  // Test basic parent selector
  EXPECT_TRUE(HasParentSelector("&"));
  EXPECT_TRUE(HasParentSelector("& .child"));
  EXPECT_TRUE(HasParentSelector(".child &"));
  EXPECT_TRUE(HasParentSelector("&:hover"));
  EXPECT_TRUE(HasParentSelector("&.active"));
  EXPECT_TRUE(HasParentSelector("& + &"));
  
  // Test compound selectors with parent
  EXPECT_TRUE(HasParentSelector("&.class#id"));
  EXPECT_TRUE(HasParentSelector("div&"));
  EXPECT_TRUE(HasParentSelector("&[attr]"));
  
  // Test selectors without parent
  EXPECT_FALSE(HasParentSelector(".class"));
  EXPECT_FALSE(HasParentSelector("div"));
  EXPECT_FALSE(HasParentSelector(":hover"));
}

TEST(CSSNesting, NestedRuleParsing) {
  auto env = TEST_init();
  
  // Test basic nested rule structure
  {
    auto rule = ParseNestedRule(".parent { color: blue; }");
    ASSERT_TRUE(rule);
    EXPECT_TRUE(rule->FirstSelector());
    
    // Check if rule has properties
    auto properties = rule->Properties();
    EXPECT_TRUE(properties);
    EXPECT_GT(properties->PropertyCount(), 0u);
  }
  
  // Note: Full nested rule parsing with child rules would require
  // access to parser internals that parse blocks with nested rules
}

TEST(CSSNesting, SelectorSpecificity) {
  auto env = TEST_init();
  
  // Test that parent selector doesn't affect specificity calculation
  {
    auto list1 = css_test_helpers::ParseSelectorList("&");
    auto list2 = css_test_helpers::ParseSelectorList(".class");
    
    if (list1 && list1->First() && list2 && list2->First()) {
      // Parent selector alone should have low specificity
      EXPECT_LT(list1->First()->Specificity(), list2->First()->Specificity());
    }
  }
  
  // Test compound selectors with parent
  {
    auto list1 = css_test_helpers::ParseSelectorList("&.class");
    auto list2 = css_test_helpers::ParseSelectorList(".class");
    
    if (list1 && list1->First() && list2 && list2->First()) {
      // &.class should have same specificity as .class
      EXPECT_EQ(list1->First()->Specificity(), list2->First()->Specificity());
    }
  }
}

TEST(CSSNesting, ComplexSelectors) {
  auto env = TEST_init();
  
  // Test various complex selectors with parent
  const char* valid_selectors[] = {
    "& > .child",
    ".sibling ~ &",
    "&:not(.excluded)",
    "&::before",
    "& .descendant &",
    ".wrapper &.active",
    "&:is(.one, .two)",
    "&:where(.low-specificity)",
    "&:has(.child)",
  };
  
  for (const char* selector : valid_selectors) {
    auto list = css_test_helpers::ParseSelectorList(selector);
    EXPECT_TRUE(list) << "Failed to parse: " << selector;
    EXPECT_TRUE(list->IsValid()) << "Invalid selector: " << selector;
    EXPECT_TRUE(HasParentSelector(selector)) << "No parent selector in: " << selector;
  }
}

TEST(CSSNesting, InvalidSelectors) {
  auto env = TEST_init();
  
  // Test invalid uses of parent selector
  // Note: Some of these might actually be valid in modern CSS nesting
  const char* potentially_invalid[] = {
    "& &",  // Multiple parent selectors (might be valid)
    "& > & > &",  // Chain of parent selectors
  };
  
  for (const char* selector : potentially_invalid) {
    auto list = css_test_helpers::ParseSelectorList(selector);
    // Just verify they parse - validity depends on nesting context
    if (list) {
      EXPECT_TRUE(HasParentSelector(selector)) 
        << "Parsed but no parent selector in: " << selector;
    }
  }
}

TEST(CSSNesting, NestingType) {
  auto env = TEST_init();
  
  // Test that nesting types are ordered correctly
  EXPECT_LT(static_cast<int>(CSSNestingType::kNone), 
            static_cast<int>(CSSNestingType::kScope));
  EXPECT_LT(static_cast<int>(CSSNestingType::kScope), 
            static_cast<int>(CSSNestingType::kNesting));
  
  // Verify max calculation works
  CSSNestingType type1 = CSSNestingType::kNone;
  CSSNestingType type2 = CSSNestingType::kNesting;
  EXPECT_EQ(std::max(type1, type2), CSSNestingType::kNesting);
}

}  // namespace webf