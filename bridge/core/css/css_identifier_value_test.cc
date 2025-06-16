// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_identifier_value.h"

#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class CSSIdentifierValueTest : public ::testing::Test {
 public:
  void SetUp() override {
    env_ = TEST_init();
  }

 protected:
  std::shared_ptr<WebFTestEnv> env_;
};

TEST_F(CSSIdentifierValueTest, Create) {
  auto value = CSSIdentifierValue::Create(CSSValueID::kRed);
  ASSERT_TRUE(value);
  EXPECT_EQ(CSSValueID::kRed, value->GetValueID());
  EXPECT_TRUE(value->IsIdentifierValue());
}

TEST_F(CSSIdentifierValueTest, CreateWithDifferentValues) {
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  auto none = CSSIdentifierValue::Create(CSSValueID::kNone);
  auto auto_value = CSSIdentifierValue::Create(CSSValueID::kAuto);
  
  EXPECT_EQ(CSSValueID::kRed, red->GetValueID());
  EXPECT_EQ(CSSValueID::kBlue, blue->GetValueID());
  EXPECT_EQ(CSSValueID::kNone, none->GetValueID());
  EXPECT_EQ(CSSValueID::kAuto, auto_value->GetValueID());
}

TEST_F(CSSIdentifierValueTest, Equality) {
  auto red1 = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto red2 = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  EXPECT_TRUE(red1->Equals(*red2));
  EXPECT_FALSE(red1->Equals(*blue));
}

TEST_F(CSSIdentifierValueTest, CssText) {
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto none = CSSIdentifierValue::Create(CSSValueID::kNone);
  auto auto_value = CSSIdentifierValue::Create(CSSValueID::kAuto);
  
  EXPECT_EQ("red", red->CustomCSSText());
  EXPECT_EQ("none", none->CustomCSSText());
  EXPECT_EQ("auto", auto_value->CustomCSSText());
}

TEST_F(CSSIdentifierValueTest, DisplayValues) {
  auto block = CSSIdentifierValue::Create(CSSValueID::kBlock);
  auto inline_val = CSSIdentifierValue::Create(CSSValueID::kInline);
  auto flex = CSSIdentifierValue::Create(CSSValueID::kFlex);
  auto grid = CSSIdentifierValue::Create(CSSValueID::kGrid);
  
  EXPECT_EQ("block", block->CustomCSSText());
  EXPECT_EQ("inline", inline_val->CustomCSSText());
  EXPECT_EQ("flex", flex->CustomCSSText());
  EXPECT_EQ("grid", grid->CustomCSSText());
}

TEST_F(CSSIdentifierValueTest, PositionValues) {
  auto absolute = CSSIdentifierValue::Create(CSSValueID::kAbsolute);
  auto relative = CSSIdentifierValue::Create(CSSValueID::kRelative);
  auto fixed = CSSIdentifierValue::Create(CSSValueID::kFixed);
  auto sticky = CSSIdentifierValue::Create(CSSValueID::kSticky);
  
  EXPECT_EQ("absolute", absolute->CustomCSSText());
  EXPECT_EQ("relative", relative->CustomCSSText());
  EXPECT_EQ("fixed", fixed->CustomCSSText());
  EXPECT_EQ("sticky", sticky->CustomCSSText());
}

TEST_F(CSSIdentifierValueTest, BorderStyleValues) {
  auto solid = CSSIdentifierValue::Create(CSSValueID::kSolid);
  auto dotted = CSSIdentifierValue::Create(CSSValueID::kDotted);
  auto dashed = CSSIdentifierValue::Create(CSSValueID::kDashed);
  auto double_border = CSSIdentifierValue::Create(CSSValueID::kDouble);
  
  EXPECT_EQ("solid", solid->CustomCSSText());
  EXPECT_EQ("dotted", dotted->CustomCSSText());
  EXPECT_EQ("dashed", dashed->CustomCSSText());
  EXPECT_EQ("double", double_border->CustomCSSText());
}

TEST_F(CSSIdentifierValueTest, FontWeightValues) {
  auto normal = CSSIdentifierValue::Create(CSSValueID::kNormal);
  auto bold = CSSIdentifierValue::Create(CSSValueID::kBold);
  auto lighter = CSSIdentifierValue::Create(CSSValueID::kLighter);
  auto bolder = CSSIdentifierValue::Create(CSSValueID::kBolder);
  
  EXPECT_EQ("normal", normal->CustomCSSText());
  EXPECT_EQ("bold", bold->CustomCSSText());
  EXPECT_EQ("lighter", lighter->CustomCSSText());
  EXPECT_EQ("bolder", bolder->CustomCSSText());
}

TEST_F(CSSIdentifierValueTest, TextAlignValues) {
  auto left = CSSIdentifierValue::Create(CSSValueID::kLeft);
  auto right = CSSIdentifierValue::Create(CSSValueID::kRight);
  auto center = CSSIdentifierValue::Create(CSSValueID::kCenter);
  auto justify = CSSIdentifierValue::Create(CSSValueID::kJustify);
  
  EXPECT_EQ("left", left->CustomCSSText());
  EXPECT_EQ("right", right->CustomCSSText());
  EXPECT_EQ("center", center->CustomCSSText());
  EXPECT_EQ("justify", justify->CustomCSSText());
}

}  // namespace webf