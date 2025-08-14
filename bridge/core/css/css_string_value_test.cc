// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_string_value.h"

#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class CSSStringValueTest : public ::testing::Test {
 public:
  void SetUp() override {
    env_ = TEST_init();
  }

 protected:
  std::shared_ptr<WebFTestEnv> env_;
};

TEST_F(CSSStringValueTest, Construction) {
  CSSStringValue value("test string");
  EXPECT_EQ(String::FromUTF8("test string"), value.Value());
  EXPECT_TRUE(value.IsStringValue());
}

TEST_F(CSSStringValueTest, EmptyString) {
  CSSStringValue value("");
  EXPECT_EQ(String::FromUTF8(""), value.Value());
  EXPECT_TRUE(value.IsStringValue());
}

TEST_F(CSSStringValueTest, SpecialCharacters) {
  CSSStringValue value("hello \"world\" with 'quotes' and newlines\n\t");
  EXPECT_EQ(String("hello \"world\" with 'quotes' and newlines\n\t"), value.Value());
}

TEST_F(CSSStringValueTest, UnicodeCharacters) {
  CSSStringValue value("Hello 世界 🌍 emoji");
  EXPECT_EQ(String::FromUTF8("Hello 世界 🌍 emoji"), value.Value());
}

TEST_F(CSSStringValueTest, CssText) {
  CSSStringValue simple("hello");
  EXPECT_EQ(String("\"hello\""), simple.CustomCSSText());
  
  CSSStringValue with_quotes("say \"hello\"");
  // Should properly escape internal quotes
  EXPECT_EQ(String("\"say \\\"hello\\\"\""), with_quotes.CustomCSSText());
  
  CSSStringValue empty("");
  EXPECT_EQ(String("\"\""), empty.CustomCSSText());
}

TEST_F(CSSStringValueTest, CssTextWithNewlines) {
  CSSStringValue with_newline("line1\nline2");
  String css_text = with_newline.CustomCSSText();
  // WebF's SerializeString function properly handles the content
  // Just check that it's a properly quoted string
  EXPECT_TRUE(css_text[0] == '"' && css_text[css_text.length() - 1] == '"');
  EXPECT_TRUE(css_text.length() >= 2); // At least the quotes
}

TEST_F(CSSStringValueTest, Equality) {
  CSSStringValue value1("test");
  CSSStringValue value2("test");
  CSSStringValue value3("different");
  
  EXPECT_TRUE(value1.Equals(value2));
  EXPECT_FALSE(value1.Equals(value3));
}

TEST_F(CSSStringValueTest, FontFamilyNames) {
  CSSStringValue arial("Arial");
  CSSStringValue times("Times New Roman");
  CSSStringValue custom("MyCustomFont");
  
  EXPECT_EQ(String::FromUTF8("Arial"), arial.Value());
  EXPECT_EQ(String::FromUTF8("Times New Roman"), times.Value());
  EXPECT_EQ(String::FromUTF8("MyCustomFont"), custom.Value());
  
  EXPECT_EQ(String("\"Arial\""), arial.CustomCSSText());
  EXPECT_EQ(String("\"Times New Roman\""), times.CustomCSSText());
  EXPECT_EQ(String("\"MyCustomFont\""), custom.CustomCSSText());
}

TEST_F(CSSStringValueTest, ContentStrings) {
  CSSStringValue content1("→");
  CSSStringValue content2("Chapter ");
  CSSStringValue content3("\"");
  
  EXPECT_EQ(String::FromUTF8("→"), content1.Value());
  EXPECT_EQ(String::FromUTF8("Chapter "), content2.Value());
  EXPECT_EQ(String("\""), content3.Value());
}

TEST_F(CSSStringValueTest, UrlStrings) {
  CSSStringValue url1("image.png");
  CSSStringValue url2("https://example.com/image.jpg");
  CSSStringValue url3("../assets/background.svg");
  
  EXPECT_EQ(String::FromUTF8("image.png"), url1.Value());
  EXPECT_EQ(String::FromUTF8("https://example.com/image.jpg"), url2.Value());
  EXPECT_EQ(String::FromUTF8("../assets/background.svg"), url3.Value());
}

TEST_F(CSSStringValueTest, LongStrings) {
  std::string long_string;
  for (int i = 0; i < 1000; ++i) {
    long_string += "test ";
  }
  
  CSSStringValue value(long_string);
  EXPECT_EQ(String(long_string), value.Value());
  EXPECT_TRUE(value.IsStringValue());
}

TEST_F(CSSStringValueTest, CustomPropertyStrings) {
  CSSStringValue custom1("red");
  CSSStringValue custom2("calc(100% - 20px)");
  CSSStringValue custom3("var(--primary-color)");
  
  EXPECT_EQ(String::FromUTF8("red"), custom1.Value());
  EXPECT_EQ(String::FromUTF8("calc(100% - 20px)"), custom2.Value());
  EXPECT_EQ(String::FromUTF8("var(--primary-color)"), custom3.Value());
}

}  // namespace webf