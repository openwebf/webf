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
  CSSStringValue value("test string"_s);
  EXPECT_EQ(String::FromUTF8("test string"), value.Value());
  EXPECT_TRUE(value.IsStringValue());
}

TEST_F(CSSStringValueTest, EmptyString) {
  CSSStringValue value(String::EmptyString());
  EXPECT_EQ(String::FromUTF8(""), value.Value());
  EXPECT_TRUE(value.IsStringValue());
}

TEST_F(CSSStringValueTest, SpecialCharacters) {
  CSSStringValue value("hello \"world\" with 'quotes' and newlines\n\t"_s);
  EXPECT_EQ("hello \"world\" with 'quotes' and newlines\n\t"_s, value.Value());
}

TEST_F(CSSStringValueTest, UnicodeCharacters) {
  CSSStringValue value("Hello 世界 🌍 emoji"_s);
  EXPECT_EQ(String::FromUTF8("Hello 世界 🌍 emoji"), value.Value());
}

TEST_F(CSSStringValueTest, CssText) {
  CSSStringValue simple("hello"_s);
  EXPECT_EQ("\"hello\""_s, simple.CustomCSSText());
  
  CSSStringValue with_quotes("say \"hello\""_s);
  // Should properly escape internal quotes
  EXPECT_EQ("\"say \\\"hello\\\"\""_s, with_quotes.CustomCSSText());
  
  CSSStringValue empty(String::EmptyString());
  EXPECT_EQ("\"\""_s, empty.CustomCSSText());
}

TEST_F(CSSStringValueTest, CssTextWithNewlines) {
  CSSStringValue with_newline("line1\nline2"_s);
  String css_text = with_newline.CustomCSSText();
  // WebF's SerializeString function properly handles the content
  // Just check that it's a properly quoted string
  EXPECT_TRUE(css_text[0] == '"' && css_text[css_text.length() - 1] == '"');
  EXPECT_TRUE(css_text.length() >= 2); // At least the quotes
}

TEST_F(CSSStringValueTest, Equality) {
  CSSStringValue value1("test"_s);
  CSSStringValue value2("test"_s);
  CSSStringValue value3("different"_s);
  
  EXPECT_TRUE(value1.Equals(value2));
  EXPECT_FALSE(value1.Equals(value3));
}

TEST_F(CSSStringValueTest, FontFamilyNames) {
  CSSStringValue arial("Arial"_s);
  CSSStringValue times("Times New Roman"_s);
  CSSStringValue custom("MyCustomFont"_s);
  
  EXPECT_EQ(String::FromUTF8("Arial"), arial.Value());
  EXPECT_EQ(String::FromUTF8("Times New Roman"), times.Value());
  EXPECT_EQ(String::FromUTF8("MyCustomFont"), custom.Value());
  
  EXPECT_EQ("\"Arial\""_s, arial.CustomCSSText());
  EXPECT_EQ("\"Times New Roman\""_s, times.CustomCSSText());
  EXPECT_EQ("\"MyCustomFont\""_s, custom.CustomCSSText());
}

TEST_F(CSSStringValueTest, ContentStrings) {
  CSSStringValue content1("→"_s);
  CSSStringValue content2("Chapter "_s);
  CSSStringValue content3("\""_s);
  
  EXPECT_EQ(String::FromUTF8("→"), content1.Value());
  EXPECT_EQ(String::FromUTF8("Chapter "), content2.Value());
  EXPECT_EQ("\""_s, content3.Value());
}

TEST_F(CSSStringValueTest, UrlStrings) {
  CSSStringValue url1("image.png"_s);
  CSSStringValue url2("https://example.com/image.jpg"_s);
  CSSStringValue url3("../assets/background.svg"_s);
  
  EXPECT_EQ(String::FromUTF8("image.png"), url1.Value());
  EXPECT_EQ(String::FromUTF8("https://example.com/image.jpg"), url2.Value());
  EXPECT_EQ(String::FromUTF8("../assets/background.svg"), url3.Value());
}

TEST_F(CSSStringValueTest, LongStrings) {
  std::string long_string;
  for (int i = 0; i < 1000; ++i) {
    long_string += "test ";
  }
  
  CSSStringValue value(String::FromUTF8(long_string.c_str()));
  EXPECT_EQ(String::FromUTF8(long_string.c_str()), value.Value());
  EXPECT_TRUE(value.IsStringValue());
}

TEST_F(CSSStringValueTest, CustomPropertyStrings) {
  CSSStringValue custom1("red"_s);
  CSSStringValue custom2("calc(100% - 20px)"_s);
  CSSStringValue custom3("var(--primary-color)"_s);
  
  EXPECT_EQ(String::FromUTF8("red"), custom1.Value());
  EXPECT_EQ(String::FromUTF8("calc(100% - 20px)"), custom2.Value());
  EXPECT_EQ(String::FromUTF8("var(--primary-color)"), custom3.Value());
}

}  // namespace webf