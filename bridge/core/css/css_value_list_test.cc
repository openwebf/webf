/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2010 Apple Inc. All rights
 * reserved.
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

#include "core/css/css_value_list.h"

#include "core/css/css_identifier_value.h"
#include "core/css/css_string_value.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class CSSValueListTest : public ::testing::Test {
 public:
  void SetUp() override {
    env_ = TEST_init();
  }

  void TearDown() override {
    env_ = nullptr;
  }

 protected:
  std::shared_ptr<WebFTestEnv> env_;
};

TEST_F(CSSValueListTest, CreateCommaSeparated) {
  auto list = CSSValueList::CreateCommaSeparated();
  ASSERT_TRUE(list);
  EXPECT_EQ(0u, list->length());
  EXPECT_TRUE(list->IsValueList());
}

TEST_F(CSSValueListTest, CreateSpaceSeparated) {
  auto list = CSSValueList::CreateSpaceSeparated();
  ASSERT_TRUE(list);
  EXPECT_EQ(0u, list->length());
  EXPECT_TRUE(list->IsValueList());
}

TEST_F(CSSValueListTest, CreateSlashSeparated) {
  auto list = CSSValueList::CreateSlashSeparated();
  ASSERT_TRUE(list);
  EXPECT_EQ(0u, list->length());
  EXPECT_TRUE(list->IsValueList());
}

TEST_F(CSSValueListTest, AppendAndAccess) {
  auto list = CSSValueList::CreateCommaSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  list->Append(red);
  list->Append(blue);
  
  EXPECT_EQ(2u, list->length());
  EXPECT_EQ(red, list->Item(0));
  EXPECT_EQ(blue, list->Item(1));
  EXPECT_EQ(red, list->First());
  EXPECT_EQ(blue, list->Last());
}

TEST_F(CSSValueListTest, ItemOutOfBounds) {
  auto list = CSSValueList::CreateCommaSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  list->Append(red);
  
  EXPECT_EQ(red, list->Item(0));
  EXPECT_EQ(nullptr, list->Item(1));
  EXPECT_EQ(nullptr, list->Item(999));
}

TEST_F(CSSValueListTest, Iterator) {
  auto list = CSSValueList::CreateSpaceSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  auto green = CSSIdentifierValue::Create(CSSValueID::kGreen);
  
  list->Append(red);
  list->Append(blue);
  list->Append(green);
  
  size_t count = 0;
  for (auto it = list->begin(); it != list->end(); ++it) {
    EXPECT_TRUE(*it);
    count++;
  }
  EXPECT_EQ(3u, count);
  
  // Test const iterator
  count = 0;
  for (auto it = list->begin(); it != list->end(); ++it) {
    count++;
  }
  EXPECT_EQ(3u, count);
}

TEST_F(CSSValueListTest, HasValue) {
  auto list = CSSValueList::CreateCommaSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  auto green = CSSIdentifierValue::Create(CSSValueID::kGreen);
  
  list->Append(red);
  list->Append(blue);
  
  EXPECT_TRUE(list->HasValue(red));
  EXPECT_TRUE(list->HasValue(blue));
  EXPECT_FALSE(list->HasValue(green));
}

TEST_F(CSSValueListTest, RemoveAll) {
  auto list = CSSValueList::CreateCommaSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  list->Append(red);
  list->Append(blue);
  list->Append(red); // Add red again
  
  EXPECT_EQ(3u, list->length());
  EXPECT_TRUE(list->RemoveAll(red));
  EXPECT_EQ(1u, list->length());
  EXPECT_EQ(blue, list->First());
  EXPECT_FALSE(list->HasValue(red));
  
  // Try to remove non-existent value
  EXPECT_FALSE(list->RemoveAll(red));
  EXPECT_EQ(1u, list->length());
}

TEST_F(CSSValueListTest, Equality) {
  auto list1 = CSSValueList::CreateCommaSeparated();
  auto list2 = CSSValueList::CreateCommaSeparated();
  auto list3 = CSSValueList::CreateSpaceSeparated();
  
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  // Empty lists
  EXPECT_TRUE(list1->Equals(*list2));
  
  // Same content, same separator
  list1->Append(red);
  list1->Append(blue);
  list2->Append(red);
  list2->Append(blue);
  EXPECT_TRUE(list1->Equals(*list2));
  
  // Same content, different separator
  list3->Append(red);
  list3->Append(blue);
  EXPECT_FALSE(list1->Equals(*list3));
}

TEST_F(CSSValueListTest, Copy) {
  auto original = CSSValueList::CreateCommaSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  original->Append(red);
  original->Append(blue);
  
  auto copy = original->Copy();
  ASSERT_TRUE(copy);
  EXPECT_TRUE(original->Equals(*copy));
  EXPECT_EQ(original->length(), copy->length());
  EXPECT_EQ(original->Item(0), copy->Item(0));
  EXPECT_EQ(original->Item(1), copy->Item(1));
}

TEST_F(CSSValueListTest, CssTextCommaSeparated) {
  auto list = CSSValueList::CreateCommaSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  list->Append(red);
  list->Append(blue);
  
  String css_text = list->CustomCSSText();
  EXPECT_EQ(String::FromUTF8("red, blue"), css_text);
}

TEST_F(CSSValueListTest, CssTextSpaceSeparated) {
  auto list = CSSValueList::CreateSpaceSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  list->Append(red);
  list->Append(blue);
  
  String css_text = list->CustomCSSText();
  EXPECT_EQ(String::FromUTF8("red blue"), css_text);
}

TEST_F(CSSValueListTest, CssTextSlashSeparated) {
  auto list = CSSValueList::CreateSlashSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  list->Append(red);
  list->Append(blue);
  
  String css_text = list->CustomCSSText();
  EXPECT_EQ(String::FromUTF8("red / blue"), css_text);
}

TEST_F(CSSValueListTest, CssTextEmpty) {
  auto list = CSSValueList::CreateCommaSeparated();
  String css_text = list->CustomCSSText();
  EXPECT_EQ(String::FromUTF8(""), css_text);
}

TEST_F(CSSValueListTest, CssTextSingleValue) {
  auto list = CSSValueList::CreateCommaSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  list->Append(red);
  
  String css_text = list->CustomCSSText();
  EXPECT_EQ(String::FromUTF8("red"), css_text);
}

TEST_F(CSSValueListTest, MixedValueTypes) {
  auto list = CSSValueList::CreateSpaceSeparated();
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto font_name = std::make_shared<CSSStringValue>("Arial"_s);
  
  list->Append(red);
  list->Append(font_name);
  
  EXPECT_EQ(2u, list->length());
  EXPECT_EQ(red, list->Item(0));
  EXPECT_EQ(font_name, list->Item(1));
}

TEST_F(CSSValueListTest, FontFamily) {
  auto list = CSSValueList::CreateCommaSeparated();
  auto arial = std::make_shared<CSSStringValue>("Arial"_s);
  auto helvetica = std::make_shared<CSSStringValue>("Helvetica"_s);
  auto sans_serif = CSSIdentifierValue::Create(CSSValueID::kSansSerif);
  
  list->Append(arial);
  list->Append(helvetica);
  list->Append(sans_serif);
  
  EXPECT_EQ(3u, list->length());
  String css_text = list->CustomCSSText();
  EXPECT_EQ("\"Arial\", \"Helvetica\", sans-serif"_s, css_text);
}

}  // namespace webf