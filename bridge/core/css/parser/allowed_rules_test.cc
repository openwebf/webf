// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/parser/allowed_rules.h"
#include "gtest/gtest.h"

namespace webf {

TEST(AllowedRulesTest, QualifiedRuleStyle) {
  AllowedRules allowed = {QualifiedRuleType::kStyle};

  EXPECT_TRUE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));

  allowed.Remove(QualifiedRuleType::kStyle);
  EXPECT_EQ(AllowedRules(), allowed);
}

TEST(AllowedRulesTest, QualifiedRuleKeyframe) {
  AllowedRules allowed = {QualifiedRuleType::kKeyframe};

  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_TRUE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));

  allowed.Remove(QualifiedRuleType::kKeyframe);
  EXPECT_EQ(AllowedRules(), allowed);
}

TEST(AllowedRulesTest, QualifiedRuleMultiple) {
  AllowedRules allowed = {QualifiedRuleType::kStyle,
                          QualifiedRuleType::kKeyframe};

  EXPECT_TRUE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_TRUE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));

  allowed.Remove(QualifiedRuleType::kStyle);
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_TRUE(allowed.Has(QualifiedRuleType::kKeyframe));
  allowed.Remove(QualifiedRuleType::kKeyframe);
  EXPECT_EQ(AllowedRules(), allowed);
}

TEST(AllowedRulesTest, InitNone) {
  AllowedRules allowed;

  for (int i = 0; i < static_cast<int>(QualifiedRuleType::kCount); ++i) {
    EXPECT_FALSE(allowed.Has(static_cast<QualifiedRuleType>(i)));
  }

  // WebF uses kCSSAtRuleIDCount instead of CSSAtRuleID::kCount
  for (int i = 0; i < static_cast<int>(kCSSAtRuleIDCount); ++i) {
    EXPECT_FALSE(allowed.Has(static_cast<CSSAtRuleID>(i)));
  }
}

TEST(AllowedRulesTest, CSSAtRuleID) {
  AllowedRules allowed = {CSSAtRuleID::kCSSAtRuleViewTransition};

  EXPECT_TRUE(allowed.Has(CSSAtRuleID::kCSSAtRuleViewTransition));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));

  allowed.Remove(CSSAtRuleID::kCSSAtRuleViewTransition);
  EXPECT_EQ(AllowedRules(), allowed);
}

TEST(AllowedRulesTest, CSSAtRuleIDRuleMultiple) {
  AllowedRules allowed = {CSSAtRuleID::kCSSAtRuleMedia,
                          CSSAtRuleID::kCSSAtRuleSupports};

  EXPECT_TRUE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_TRUE(allowed.Has(CSSAtRuleID::kCSSAtRuleSupports));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleContainer));

  allowed.Remove(CSSAtRuleID::kCSSAtRuleMedia);
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_TRUE(allowed.Has(CSSAtRuleID::kCSSAtRuleSupports));

  allowed.Remove(CSSAtRuleID::kCSSAtRuleSupports);
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleSupports));

  EXPECT_EQ(AllowedRules(), allowed);
}

TEST(AllowedRulesTest, Mixed) {
  AllowedRules allowed = AllowedRules{QualifiedRuleType::kStyle} |
                         AllowedRules{CSSAtRuleID::kCSSAtRuleMedia,
                                      CSSAtRuleID::kCSSAtRuleSupports};

  EXPECT_TRUE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_TRUE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_TRUE(allowed.Has(CSSAtRuleID::kCSSAtRuleSupports));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleContainer));

  allowed.Remove(CSSAtRuleID::kCSSAtRuleMedia);
  EXPECT_TRUE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_TRUE(allowed.Has(CSSAtRuleID::kCSSAtRuleSupports));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleContainer));

  allowed.Remove(QualifiedRuleType::kStyle);
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_TRUE(allowed.Has(CSSAtRuleID::kCSSAtRuleSupports));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleContainer));

  allowed.Remove(CSSAtRuleID::kCSSAtRuleSupports);
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kStyle));
  EXPECT_FALSE(allowed.Has(QualifiedRuleType::kKeyframe));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleSupports));
  EXPECT_FALSE(allowed.Has(CSSAtRuleID::kCSSAtRuleContainer));

  EXPECT_EQ(AllowedRules(), allowed);
}

// Additional WebF tests to ensure our implementation works correctly
TEST(AllowedRulesTest, EdgeCases) {
  // Test with first and last at-rule IDs
  // WebF uses kCSSAtRuleInvalid instead of kCSSAtRuleUnknown
  AllowedRules rules = {CSSAtRuleID::kCSSAtRuleInvalid,
                        static_cast<CSSAtRuleID>(kCSSAtRuleIDCount - 1)};
  
  EXPECT_TRUE(rules.Has(CSSAtRuleID::kCSSAtRuleInvalid));
  EXPECT_TRUE(rules.Has(static_cast<CSSAtRuleID>(kCSSAtRuleIDCount - 1)));
  
  // Test removing all qualified rules
  AllowedRules all_qualified = {QualifiedRuleType::kStyle, QualifiedRuleType::kKeyframe};
  all_qualified.Remove(QualifiedRuleType::kStyle);
  all_qualified.Remove(QualifiedRuleType::kKeyframe);
  EXPECT_EQ(AllowedRules(), all_qualified);
}

TEST(AllowedRulesTest, BitwiseOperations) {
  AllowedRules a = {CSSAtRuleID::kCSSAtRuleMedia};
  AllowedRules b = {CSSAtRuleID::kCSSAtRuleSupports};
  AllowedRules c = {QualifiedRuleType::kStyle};
  
  // Test OR operation
  AllowedRules combined = a | b | c;
  EXPECT_TRUE(combined.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_TRUE(combined.Has(CSSAtRuleID::kCSSAtRuleSupports));
  EXPECT_TRUE(combined.Has(QualifiedRuleType::kStyle));
  
  // Test that original objects are unchanged
  EXPECT_TRUE(a.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_FALSE(a.Has(CSSAtRuleID::kCSSAtRuleSupports));
  EXPECT_FALSE(a.Has(QualifiedRuleType::kStyle));
}

TEST(AllowedRulesTest, CopyAndAssignment) {
  // Create using OR operation since we can't mix types in initializer list
  AllowedRules original = AllowedRules{CSSAtRuleID::kCSSAtRuleMedia} | 
                          AllowedRules{QualifiedRuleType::kStyle};
  
  // Test copy constructor
  AllowedRules copy(original);
  EXPECT_EQ(original, copy);
  
  // Test assignment operator
  AllowedRules assigned;
  assigned = original;
  EXPECT_EQ(original, assigned);
  
  // Ensure modifications to copy don't affect original
  copy.Remove(CSSAtRuleID::kCSSAtRuleMedia);
  EXPECT_TRUE(original.Has(CSSAtRuleID::kCSSAtRuleMedia));
  EXPECT_FALSE(copy.Has(CSSAtRuleID::kCSSAtRuleMedia));
}

}  // namespace webf