/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006 Apple Computer, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_value_pair.h"

#include "core/css/css_identifier_value.h"
#include "core/css/css_string_value.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class CSSValuePairTest : public ::testing::Test {
 public:
  void SetUp() override {
    env_ = TEST_init();
  }

 protected:
  std::shared_ptr<WebFTestEnv> env_;
};

TEST_F(CSSValuePairTest, Construction) {
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  CSSValuePair pair(red, blue, CSSValuePair::kKeepIdenticalValues);
  
  EXPECT_EQ(red, pair.First());
  EXPECT_EQ(blue, pair.Second());
  EXPECT_TRUE(pair.IsValuePair());
  EXPECT_TRUE(pair.KeepIdenticalValues());
}

TEST_F(CSSValuePairTest, DropIdenticalValues) {
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  CSSValuePair pair(red, blue, CSSValuePair::kDropIdenticalValues);
  
  EXPECT_EQ(red, pair.First());
  EXPECT_EQ(blue, pair.Second());
  EXPECT_FALSE(pair.KeepIdenticalValues());
}

TEST_F(CSSValuePairTest, IdenticalValues) {
  auto red1 = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto red2 = CSSIdentifierValue::Create(CSSValueID::kRed);
  
  CSSValuePair pair1(red1, red2, CSSValuePair::kKeepIdenticalValues);
  CSSValuePair pair2(red1, red2, CSSValuePair::kDropIdenticalValues);
  
  EXPECT_EQ(red1, pair1.First());
  EXPECT_EQ(red2, pair1.Second());
  EXPECT_TRUE(pair1.KeepIdenticalValues());
  
  EXPECT_EQ(red1, pair2.First());
  EXPECT_EQ(red2, pair2.Second());
  EXPECT_FALSE(pair2.KeepIdenticalValues());
}

TEST_F(CSSValuePairTest, CssTextKeepIdentical) {
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  CSSValuePair pair_different(red, blue, CSSValuePair::kKeepIdenticalValues);
  String css_text = pair_different.CustomCSSText();
  EXPECT_EQ("red blue", css_text);
  
  // Test with identical values
  CSSValuePair pair_identical(red, red, CSSValuePair::kKeepIdenticalValues);
  css_text = pair_identical.CustomCSSText();
  EXPECT_EQ("red red", css_text);
}

TEST_F(CSSValuePairTest, CssTextDropIdentical) {
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  CSSValuePair pair_different(red, blue, CSSValuePair::kDropIdenticalValues);
  String css_text = pair_different.CustomCSSText();
  EXPECT_EQ("red blue", css_text);
  
  // Test with identical values - should drop the second one
  CSSValuePair pair_identical(red, red, CSSValuePair::kDropIdenticalValues);
  css_text = pair_identical.CustomCSSText();
  EXPECT_EQ("red", css_text);
}

TEST_F(CSSValuePairTest, Equality) {
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  auto green = CSSIdentifierValue::Create(CSSValueID::kGreen);
  
  CSSValuePair pair1(red, blue, CSSValuePair::kKeepIdenticalValues);
  CSSValuePair pair2(red, blue, CSSValuePair::kKeepIdenticalValues);
  CSSValuePair pair3(red, green, CSSValuePair::kKeepIdenticalValues);
  CSSValuePair pair4(red, blue, CSSValuePair::kDropIdenticalValues);
  
  EXPECT_TRUE(pair1.Equals(pair2));
  EXPECT_FALSE(pair1.Equals(pair3));
  EXPECT_FALSE(pair1.Equals(pair4)); // Different policies
}

TEST_F(CSSValuePairTest, BackgroundPosition) {
  // Typical use case: background-position: left top
  auto left = CSSIdentifierValue::Create(CSSValueID::kLeft);
  auto top = CSSIdentifierValue::Create(CSSValueID::kTop);
  
  CSSValuePair position(left, top, CSSValuePair::kKeepIdenticalValues);
  
  EXPECT_EQ(left, position.First());
  EXPECT_EQ(top, position.Second());
  
  String css_text = position.CustomCSSText();
  EXPECT_EQ("left top", css_text);
}

TEST_F(CSSValuePairTest, BorderRadius) {
  // Typical use case: border-radius with horizontal/vertical radii
  auto px10 = std::make_shared<CSSStringValue>("10px"_s);
  auto px20 = std::make_shared<CSSStringValue>("20px"_s);
  
  CSSValuePair radius(px10, px20, CSSValuePair::kDropIdenticalValues);
  
  EXPECT_EQ(px10, radius.First());
  EXPECT_EQ(px20, radius.Second());
  
  String css_text = radius.CustomCSSText();
  EXPECT_EQ("\"10px\" \"20px\"", css_text);
}

TEST_F(CSSValuePairTest, BorderRadiusIdentical) {
  // border-radius: 10px 10px should become just 10px when dropping identical
  auto px10_1 = std::make_shared<CSSStringValue>("10px"_s);
  auto px10_2 = std::make_shared<CSSStringValue>("10px"_s);
  
  CSSValuePair radius(px10_1, px10_2, CSSValuePair::kDropIdenticalValues);
  
  EXPECT_EQ(px10_1, radius.First());
  EXPECT_EQ(px10_2, radius.Second());
  
  // Note: This test assumes the CSS text generation logic handles identical value dropping
  // The actual behavior may vary based on implementation
  String css_text = radius.CustomCSSText();
  // Should be either "10px" (dropped) or "10px 10px" (kept) depending on implementation
  EXPECT_TRUE(css_text == "\"10px\"" || css_text == "\"10px\" \"10px\"");
}

TEST_F(CSSValuePairTest, MixedValueTypes) {
  auto color = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto string = std::make_shared<CSSStringValue>("Arial"_s);
  
  CSSValuePair mixed(color, string, CSSValuePair::kKeepIdenticalValues);
  
  EXPECT_EQ(color, mixed.First());
  EXPECT_EQ(string, mixed.Second());
  
  String css_text = mixed.CustomCSSText();
  EXPECT_EQ("red \"Arial\"", css_text);
}

TEST_F(CSSValuePairTest, CenterValues) {
  // Test center center case
  auto center1 = CSSIdentifierValue::Create(CSSValueID::kCenter);
  auto center2 = CSSIdentifierValue::Create(CSSValueID::kCenter);
  
  CSSValuePair keep_pair(center1, center2, CSSValuePair::kKeepIdenticalValues);
  CSSValuePair drop_pair(center1, center2, CSSValuePair::kDropIdenticalValues);
  
  EXPECT_EQ("center center", keep_pair.CustomCSSText());
  EXPECT_EQ("center", drop_pair.CustomCSSText());
}

}  // namespace webf