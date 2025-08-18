// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/parser/sizes_attribute_parser.h"
#include "core/css/media_values.h"
#include "core/platform/text/writing_mode.h"
#include "core/style/scoped_css_name.h"
#include "gtest/gtest.h"

namespace webf {

// Simple MediaValues implementation for testing
class TestMediaValues : public MediaValues {
 public:
  TestMediaValues() : MediaValues() {}
  
  // Implement required virtual methods from MediaValues
  int DeviceWidth() const override { return 1920; }
  int DeviceHeight() const override { return 1080; }
  float DevicePixelRatio() const override { return 1.0f; }
  bool DeviceSupportsHDR() const override { return false; }
  int ColorBitsPerComponent() const override { return 8; }
  int MonochromeBitsPerComponent() const override { return 0; }
  bool InvertedColors() const override { return false; }
  bool ThreeDEnabled() const override { return false; }
  const String MediaType() const override { return String::FromUTF8("screen"); }
  bool Resizable() const override { return true; }
  bool StrictMode() const override { return true; }
  Document* GetDocument() const override { return nullptr; }
  bool HasValues() const override { return true; }
  
  // Implement required virtual methods from CSSLengthResolver
  // Font-relative sizes
  float EmFontSize(float zoom) const override { return 16.0f * zoom; }
  float RemFontSize(float zoom) const override { return 16.0f * zoom; }
  float ExFontSize(float zoom) const override { return 8.0f * zoom; }
  float RexFontSize(float zoom) const override { return 8.0f * zoom; }
  float ChFontSize(float zoom) const override { return 8.0f * zoom; }
  float RchFontSize(float zoom) const override { return 8.0f * zoom; }
  float IcFontSize(float zoom) const override { return 16.0f * zoom; }
  float RicFontSize(float zoom) const override { return 16.0f * zoom; }
  float LineHeight(float zoom) const override { return 20.0f * zoom; }
  float RootLineHeight(float zoom) const override { return 20.0f * zoom; }
  float CapFontSize(float zoom) const override { return 12.0f * zoom; }
  float RcapFontSize(float zoom) const override { return 12.0f * zoom; }
  
  // Viewport sizes
  double ViewportWidth() const override { return 1920.0; }
  double ViewportHeight() const override { return 1080.0; }
  double SmallViewportWidth() const override { return 1920.0; }
  double SmallViewportHeight() const override { return 1080.0; }
  double LargeViewportWidth() const override { return 1920.0; }
  double LargeViewportHeight() const override { return 1080.0; }
  double DynamicViewportWidth() const override { return 1920.0; }
  double DynamicViewportHeight() const override { return 1080.0; }
  double ContainerWidth() const override { return 1920.0; }
  double ContainerHeight() const override { return 1080.0; }
  double ContainerWidth(const ScopedCSSName&) const override { return 1920.0; }
  double ContainerHeight(const ScopedCSSName&) const override { return 1080.0; }
  WritingMode GetWritingMode() const override { return WritingMode::kHorizontalTb; }
  void ReferenceTreeScope() const override {}
};

class SizesAttributeParserTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Create a simple MediaValues for testing
    media_values_ = std::make_unique<TestMediaValues>();
  }

  std::unique_ptr<TestMediaValues> media_values_;
};

TEST_F(SizesAttributeParserTest, Basic) {
  SizesAttributeParser parser(media_values_.get(), "100px"_s, nullptr, nullptr);
  EXPECT_FALSE(parser.IsAuto());
  EXPECT_EQ(100.0f, parser.Size());
}

TEST_F(SizesAttributeParserTest, Auto) {
  SizesAttributeParser parser(media_values_.get(), "auto"_s, nullptr, nullptr);
  EXPECT_TRUE(parser.IsAuto());
}

TEST_F(SizesAttributeParserTest, Empty) {
  SizesAttributeParser parser(media_values_.get(), ""_s, nullptr, nullptr);
  EXPECT_FALSE(parser.IsAuto());
  // Should return default size
  EXPECT_GT(parser.Size(), 0.0f);
}

TEST_F(SizesAttributeParserTest, InvalidUnit) {
  SizesAttributeParser parser(media_values_.get(), "100em"_s, nullptr, nullptr);
  EXPECT_FALSE(parser.IsAuto());
  // Should return default size since em is not yet supported
  EXPECT_GT(parser.Size(), 0.0f);
}

TEST_F(SizesAttributeParserTest, Whitespace) {
  SizesAttributeParser parser(media_values_.get(), "  100px  "_s, nullptr, nullptr);
  EXPECT_FALSE(parser.IsAuto());
  EXPECT_EQ(100.0f, parser.Size());
}

}  // namespace webf