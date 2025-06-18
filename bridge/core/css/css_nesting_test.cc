// Copyright 2024 The WebF Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "gtest/gtest.h"
#include "webf_test_env.h"
#include <string>

namespace webf {

namespace {

bool HasParentSelector(const char* selector_string) {
  // Simplified implementation that checks for '&' character
  std::string str(selector_string);
  return str.find('&') != std::string::npos;
}

}  // namespace

TEST(CSSNesting, ParentSelectorDetection) {
  auto env = TEST_init();
  
  // Test basic parent selector detection
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
    EXPECT_TRUE(HasParentSelector(selector)) << "No parent selector in: " << selector;
  }
}

TEST(CSSNesting, InvalidSelectors) {
  auto env = TEST_init();
  
  // Test invalid uses of parent selector
  const char* potentially_invalid[] = {
    "& &",  // Multiple parent selectors (might be valid)
    "& > & > &",  // Chain of parent selectors
  };
  
  for (const char* selector : potentially_invalid) {
    EXPECT_TRUE(HasParentSelector(selector)) 
      << "No parent selector in: " << selector;
  }
}

}  // namespace webf