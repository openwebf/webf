// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_property_value_set.h"

#include "core/css/css_identifier_value.h"
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_rule.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class CSSPropertyValueSetTest : public ::testing::Test {
 public:
  void SetUp() override {
    env_ = TEST_init();
    document_ = env_->page()->executingContext()->document();
  }

 protected:
  std::shared_ptr<WebFTestEnv> env_;
  Document* document_;
};

TEST_F(CSSPropertyValueSetTest, BasicPropertyAccess) {
  // Create a mutable property set and manually add properties
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  // Add some properties manually using the API
  auto color_value = CSSIdentifierValue::Create(CSSValueID::kRed);
  properties->SetLonghandProperty(CSSPropertyID::kColor, color_value);
  
  EXPECT_EQ(1u, properties->PropertyCount());
  EXPECT_EQ("red", properties->GetPropertyValue(CSSPropertyID::kColor));
}

TEST_F(CSSPropertyValueSetTest, MultipleProperties) {
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto block = CSSIdentifierValue::Create(CSSValueID::kBlock);
  auto absolute = CSSIdentifierValue::Create(CSSValueID::kAbsolute);
  
  properties->SetLonghandProperty(CSSPropertyID::kColor, red);
  properties->SetLonghandProperty(CSSPropertyID::kDisplay, block);
  properties->SetLonghandProperty(CSSPropertyID::kPosition, absolute);
  
  EXPECT_EQ(3u, properties->PropertyCount());
  EXPECT_EQ("red", properties->GetPropertyValue(CSSPropertyID::kColor));
  EXPECT_EQ("block", properties->GetPropertyValue(CSSPropertyID::kDisplay));
  EXPECT_EQ("absolute", properties->GetPropertyValue(CSSPropertyID::kPosition));
}

TEST_F(CSSPropertyValueSetTest, PropertyRemoval) {
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  properties->SetLonghandProperty(CSSPropertyID::kColor, red);
  properties->SetLonghandProperty(CSSPropertyID::kBackgroundColor, blue);
  
  EXPECT_EQ(2u, properties->PropertyCount());
  
  // Remove a property
  bool removed = properties->RemoveProperty(CSSPropertyID::kColor);
  EXPECT_TRUE(removed);
  EXPECT_EQ(1u, properties->PropertyCount());
  EXPECT_EQ("", properties->GetPropertyValue(CSSPropertyID::kColor));
  EXPECT_EQ("blue", properties->GetPropertyValue(CSSPropertyID::kBackgroundColor));
}

TEST_F(CSSPropertyValueSetTest, PropertyUpdate) {
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  properties->SetLonghandProperty(CSSPropertyID::kColor, red);
  EXPECT_EQ("red", properties->GetPropertyValue(CSSPropertyID::kColor));
  
  // Update the same property
  properties->SetLonghandProperty(CSSPropertyID::kColor, blue);
  EXPECT_EQ("blue", properties->GetPropertyValue(CSSPropertyID::kColor));
  EXPECT_EQ(1u, properties->PropertyCount()); // Should still be 1 property
}

TEST_F(CSSPropertyValueSetTest, HasProperty) {
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  properties->SetLonghandProperty(CSSPropertyID::kColor, red);
  
  EXPECT_TRUE(properties->HasProperty(CSSPropertyID::kColor));
  EXPECT_FALSE(properties->HasProperty(CSSPropertyID::kFontSize));
  EXPECT_FALSE(properties->HasProperty(CSSPropertyID::kMargin));
}

TEST_F(CSSPropertyValueSetTest, Clear) {
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto blue = CSSIdentifierValue::Create(CSSValueID::kBlue);
  
  properties->SetLonghandProperty(CSSPropertyID::kColor, red);
  properties->SetLonghandProperty(CSSPropertyID::kBackgroundColor, blue);
  
  EXPECT_EQ(2u, properties->PropertyCount());
  
  properties->Clear();
  
  EXPECT_EQ(0u, properties->PropertyCount());
  EXPECT_FALSE(properties->HasProperty(CSSPropertyID::kColor));
  EXPECT_FALSE(properties->HasProperty(CSSPropertyID::kBackgroundColor));
}

TEST_F(CSSPropertyValueSetTest, PropertyIteration) {
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto block = CSSIdentifierValue::Create(CSSValueID::kBlock);
  
  properties->SetLonghandProperty(CSSPropertyID::kColor, red);
  properties->SetLonghandProperty(CSSPropertyID::kDisplay, block);
  
  std::set<CSSPropertyID> found_properties;
  for (unsigned i = 0; i < properties->PropertyCount(); ++i) {
    auto property = properties->PropertyAt(i);
    found_properties.insert(property.Id());
    EXPECT_TRUE(property.Value() != nullptr);
  }
  
  EXPECT_EQ(2u, found_properties.size());
  EXPECT_TRUE(found_properties.count(CSSPropertyID::kColor) > 0);
  EXPECT_TRUE(found_properties.count(CSSPropertyID::kDisplay) > 0);
}

TEST_F(CSSPropertyValueSetTest, IsEmpty) {
  auto properties = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  
  EXPECT_TRUE(properties->IsEmpty());
  
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  properties->SetLonghandProperty(CSSPropertyID::kColor, red);
  
  EXPECT_FALSE(properties->IsEmpty());
  
  properties->RemoveProperty(CSSPropertyID::kColor);
  EXPECT_TRUE(properties->IsEmpty());
}

TEST_F(CSSPropertyValueSetTest, CopyFrom) {
  auto source = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  auto red = CSSIdentifierValue::Create(CSSValueID::kRed);
  auto block = CSSIdentifierValue::Create(CSSValueID::kBlock);
  
  source->SetLonghandProperty(CSSPropertyID::kColor, red);
  source->SetLonghandProperty(CSSPropertyID::kDisplay, block);
  
  auto dest = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  dest->MergeAndOverrideOnConflict(source.get());
  
  EXPECT_EQ(2u, dest->PropertyCount());
  EXPECT_EQ("red", dest->GetPropertyValue(CSSPropertyID::kColor));
  EXPECT_EQ("block", dest->GetPropertyValue(CSSPropertyID::kDisplay));
}

// Note: The following tests are commented out because they require CSS parsing
// which is not fully implemented in WebF's test environment

/*
TEST_F(CSSPropertyValueSetTest, CustomProperties) {
  // Requires CSS parsing
}

TEST_F(CSSPropertyValueSetTest, MixedStandardAndCustomProperties) {
  // Requires CSS parsing
}

TEST_F(CSSPropertyValueSetTest, ImportantProperties) {
  // Requires CSS parsing
}

TEST_F(CSSPropertyValueSetTest, ShorthandProperties) {
  // Requires CSS parsing
}

TEST_F(CSSPropertyValueSetTest, ComplexValues) {
  // Requires CSS parsing
}

TEST_F(CSSPropertyValueSetTest, CSSWideKeywords) {
  // Requires CSS parsing
}

TEST_F(CSSPropertyValueSetTest, CalcValues) {
  // Requires CSS parsing
}

TEST_F(CSSPropertyValueSetTest, VariableReferences) {
  // Requires CSS parsing
}
*/

}  // namespace webf