// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_property_name.h"
#include "core/css/properties/css_property.h"
#include "core/css/properties/longhand.h"
#include "core/dom/document.h"
#include "foundation/string/wtf_string.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class CSSPropertyNameTest : public ::testing::Test {
 public:
  void SetUp() override {
    env_ = TEST_init();
  }

 protected:
  std::shared_ptr<WebFTestEnv> env_;
};

TEST_F(CSSPropertyNameTest, IdStandardProperty) {
  CSSPropertyName name(CSSPropertyID::kFontSize);
  EXPECT_EQ(CSSPropertyID::kFontSize, name.Id());
}

TEST_F(CSSPropertyNameTest, IdCustomProperty) {
  CSSPropertyName name(AtomicString::CreateFromUTF8("--x"));
  EXPECT_EQ(CSSPropertyID::kVariable, name.Id());
  EXPECT_TRUE(name.IsCustomProperty());
}

TEST_F(CSSPropertyNameTest, GetNameStandardProperty) {
  CSSPropertyName name(CSSPropertyID::kFontSize);
  EXPECT_EQ(AtomicString::CreateFromUTF8("font-size"), name.ToAtomicString());
}

TEST_F(CSSPropertyNameTest, GetNameCustomProperty) {
  CSSPropertyName name(AtomicString::CreateFromUTF8("--x"));
  EXPECT_EQ(AtomicString::CreateFromUTF8("--x"), name.ToAtomicString());
}

TEST_F(CSSPropertyNameTest, OperatorEquals) {
  EXPECT_EQ(CSSPropertyName(AtomicString::CreateFromUTF8("--x")),
            CSSPropertyName(AtomicString::CreateFromUTF8("--x")));
  EXPECT_EQ(CSSPropertyName(CSSPropertyID::kColor),
            CSSPropertyName(CSSPropertyID::kColor));
  EXPECT_NE(CSSPropertyName(AtomicString::CreateFromUTF8("--x")),
            CSSPropertyName(AtomicString::CreateFromUTF8("--y")));
  EXPECT_NE(CSSPropertyName(CSSPropertyID::kColor),
            CSSPropertyName(CSSPropertyID::kFontSize));
  EXPECT_NE(CSSPropertyName(AtomicString::CreateFromUTF8("--x")),
            CSSPropertyName(CSSPropertyID::kColor));
}

TEST_F(CSSPropertyNameTest, From) {
  // Test From method using execution context
  auto opt_color = CSSPropertyName::From(env_->page()->executingContext(), "color"_s);
  ASSERT_TRUE(opt_color.has_value());
  EXPECT_EQ(opt_color->Id(), CSSPropertyID::kColor);
  
  auto opt_custom = CSSPropertyName::From(env_->page()->executingContext(), "--x"_s);
  ASSERT_TRUE(opt_custom.has_value());
  EXPECT_EQ(opt_custom->Id(), CSSPropertyID::kVariable);
  EXPECT_TRUE(opt_custom->IsCustomProperty());
}

TEST_F(CSSPropertyNameTest, IsCustomPropertyMethod) {
  CSSPropertyName standard_prop(CSSPropertyID::kColor);
  CSSPropertyName custom_prop(AtomicString::CreateFromUTF8("--custom"));
  
  EXPECT_FALSE(standard_prop.IsCustomProperty());
  EXPECT_TRUE(custom_prop.IsCustomProperty());
}

TEST_F(CSSPropertyNameTest, StandardPropertyNames) {
  // Test a variety of standard CSS properties
  std::vector<CSSPropertyID> test_properties = {
    CSSPropertyID::kColor,
    CSSPropertyID::kFontSize,
    CSSPropertyID::kMargin,
    CSSPropertyID::kPadding,
    CSSPropertyID::kDisplay,
    CSSPropertyID::kPosition,
    CSSPropertyID::kWidth,
    CSSPropertyID::kHeight,
    CSSPropertyID::kBackgroundColor,
    CSSPropertyID::kBorderWidth
  };
  
  for (CSSPropertyID prop_id : test_properties) {
    CSSPropertyName name(prop_id);
    EXPECT_EQ(name.Id(), prop_id);
    EXPECT_FALSE(name.IsCustomProperty());
    // Note: IsEmpty and IsDeleted are private methods in WebF's implementation
  }
}

TEST_F(CSSPropertyNameTest, CustomPropertyVariations) {
  // Test various custom property names
  std::vector<std::string> custom_names = {
    "--x",
    "--my-color", 
    "--very-long-custom-property-name",
    "--123",
    "--CamelCase",
    "--with_underscores"
  };
  
  for (const std::string& name_str : custom_names) {
    AtomicString atomic_name = AtomicString::CreateFromUTF8(name_str.c_str());
    CSSPropertyName name(atomic_name);
    
    EXPECT_EQ(name.Id(), CSSPropertyID::kVariable);
    EXPECT_TRUE(name.IsCustomProperty());
    EXPECT_EQ(name.ToAtomicString(), atomic_name);
    // Note: IsEmpty and IsDeleted are private methods in WebF's implementation
  }
}

}  // namespace webf