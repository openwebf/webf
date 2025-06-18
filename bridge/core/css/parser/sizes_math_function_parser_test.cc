// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/sizes_math_function_parser.h"

#include "gtest/gtest.h"
#include "core/css/media_values.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/css_primitive_value.h"
#include "core/platform/text/writing_mode.h"
#include "core/style/scoped_css_name.h"
#include <algorithm>

namespace webf {

namespace {
// |float| has roughly 7 digits of precision.
const double epsilon = 1e-6;
}  // namespace

struct SizesCalcTestCase {
  const char* input;
  const float output;
  const bool valid;
};

#define EXPECT_APPROX_EQ(expected, actual)            \
  {                                                   \
    double actual_error = actual - expected;          \
    double allowed_error = expected * epsilon;        \
    EXPECT_LE(abs(actual_error), abs(allowed_error)); \
  }

// Test MediaValues implementation
class TestMediaValues : public MediaValues {
 public:
  TestMediaValues(float viewport_width = 500.0f, 
                  float viewport_height = 643.0f,
                  float font_size = 16.0f)
      : MediaValues(),
        viewport_width_(viewport_width),
        viewport_height_(viewport_height),
        font_size_(font_size) {}

  // CSSLengthResolver overrides (MediaValues extends CSSLengthResolver)
  float EmFontSize(float zoom) const override { return font_size_ * zoom; }
  float RemFontSize(float zoom) const override { return font_size_ * zoom; }
  float ExFontSize(float zoom) const override { return font_size_ * 0.5f * zoom; }
  float RexFontSize(float zoom) const override { return font_size_ * 0.5f * zoom; }
  float ChFontSize(float zoom) const override { return font_size_ * 0.5f * zoom; }
  float RchFontSize(float zoom) const override { return font_size_ * 0.5f * zoom; }
  float IcFontSize(float zoom) const override { return font_size_ * zoom; }
  float RicFontSize(float zoom) const override { return font_size_ * zoom; }
  float LineHeight(float zoom) const override { return font_size_ * 1.2f * zoom; }
  float RootLineHeight(float zoom) const override { return font_size_ * 1.2f * zoom; }
  float CapFontSize(float zoom) const override { return font_size_ * 0.8f * zoom; }
  float RcapFontSize(float zoom) const override { return font_size_ * 0.8f * zoom; }
  
  // Container sizes
  double ContainerWidth() const override { return viewport_width_; }
  double ContainerHeight() const override { return viewport_height_; }
  double ContainerWidth(const ScopedCSSName&) const override { return viewport_width_; }
  double ContainerHeight(const ScopedCSSName&) const override { return viewport_height_; }
  
  // Other required virtuals
  WritingMode GetWritingMode() const override { 
    return WritingMode::kHorizontalTb; 
  }
  void ReferenceTreeScope() const override {}
  
  // MediaValues required overrides
  double ViewportWidth() const override { return viewport_width_; }
  double ViewportHeight() const override { return viewport_height_; }
  double SmallViewportWidth() const override { return viewport_width_; }
  double SmallViewportHeight() const override { return viewport_height_; }
  double LargeViewportWidth() const override { return viewport_width_; }
  double LargeViewportHeight() const override { return viewport_height_; }
  double DynamicViewportWidth() const override { return viewport_width_; }
  double DynamicViewportHeight() const override { return viewport_height_; }
  int DeviceWidth() const override { return viewport_width_; }
  int DeviceHeight() const override { return viewport_height_; }
  float DevicePixelRatio() const override { return 1.0f; }
  bool DeviceSupportsHDR() const override { return false; }
  int ColorBitsPerComponent() const override { return 8; }
  int MonochromeBitsPerComponent() const override { return 0; }
  bool InvertedColors() const override { return false; }
  bool ThreeDEnabled() const override { return false; }
  const std::string MediaType() const override { return "screen"; }
  bool Resizable() const override { return true; }
  bool StrictMode() const override { return true; }
  Document* GetDocument() const override { return nullptr; }
  bool HasValues() const override { return true; }

 // Note: In WebF, ComputeLengthImpl is not virtual, so we can't override it.
 // The MediaValues base class should handle unit conversions using the virtual
 // methods we've already implemented (EmFontSize, ViewportWidth, etc.)

 private:
  float viewport_width_;
  float viewport_height_;
  float font_size_;
};

class SizesMathFunctionParserTest : public ::testing::Test {
 protected:
  void TestSizesCalc(const SizesCalcTestCase& test_case,
                     float viewport_width = 500.0f,
                     float viewport_height = 643.0f,
                     float font_size = 16.0f) {
    TestMediaValues media_values(viewport_width, viewport_height, font_size);
    CSSTokenizer tokenizer(test_case.input);
    CSSParserTokenStream stream(tokenizer);
    SizesMathFunctionParser calc_parser(stream, &media_values);
    
    EXPECT_EQ(test_case.valid, calc_parser.IsValid());
    if (calc_parser.IsValid()) {
      EXPECT_APPROX_EQ(test_case.output, calc_parser.Result());
    }
  }
};

TEST_F(SizesMathFunctionParserTest, BasicLength) {
  SizesCalcTestCase test_cases[] = {
      {"calc(500px)", 500, true},
      {"calc(50vw)", 250, true},
      {"calc(50vh)", 321.5, true},
      {"calc(50vmin)", 250, true},
      {"calc(50vmax)", 321.5, true},
      {"calc(50px*2)", 100, true},
      {"calc(50px/2)", 25, true},
      {"calc(50px+50px)", 100, true},
      {"calc(50px-50px)", 0, true},
      {"calc(50px-60px)", -10, true},
      {"calc(50px-100px)", -50, true},
      {"calc(100px*0.5)", 50, true},
  };

  for (const auto& test_case : test_cases) {
    TestSizesCalc(test_case);
  }
}

TEST_F(SizesMathFunctionParserTest, ComplexExpressions) {
  SizesCalcTestCase test_cases[] = {
      {"calc(50vw+50vw)", 500, true},
      {"calc(50vw+1vw)", 255, true},
      {"calc(50vw-1vw)", 245, true},
      {"calc(50vw*1)", 250, true},
      {"calc(50vw/1)", 250, true},
      {"calc(50vw/2)", 125, true},
      {"calc(50vw*2)", 500, true},
      {"calc(50vw*2.5)", 625, true},
      {"calc(50vw*0.5)", 125, true},
      {"calc(0.5*50vw)", 125, true},
      {"calc(50vw+30px)", 280, true},
      {"calc(50vw-30px)", 220, true},
      {"calc(30px+50vw)", 280, true},
      {"calc(30px-50vw)", -220, true},
      {"calc(50vw*2 + 30px)", 530, true},
      {"calc(50vw/2 + 30px)", 155, true},
      {"calc(50vw+30px*2)", 310, true},
      {"calc(50vw-30px/2)", 235, true},
  };

  for (const auto& test_case : test_cases) {
    TestSizesCalc(test_case);
  }
}

TEST_F(SizesMathFunctionParserTest, InvalidExpressions) {
  SizesCalcTestCase test_cases[] = {
      {"calc(NaN)", 0, false},
      {"calc(50vw/0)", 0, false},
      {"calc(50vw/0px)", 0, false},
      {"calc(50vw/0%)", 0, false},
      {"calc(50vw/0vw)", 0, false},
      {"calc(30px 30px)", 0, false},
      {"calc(30px,30px)", 0, false},
      {"calc(1 2)", 0, false},
      {"calc(1,2)", 0, false},
  };

  for (const auto& test_case : test_cases) {
    TestSizesCalc(test_case);
  }
}

TEST_F(SizesMathFunctionParserTest, FontRelativeUnits) {
  SizesCalcTestCase test_cases[] = {
      {"calc(1em)", 16, true},
      {"calc(2em)", 32, true},
      {"calc(0.5em)", 8, true},
      {"calc(1rem)", 16, true},
      {"calc(2rem)", 32, true},
      {"calc(0.5rem)", 8, true},
  };

  for (const auto& test_case : test_cases) {
    TestSizesCalc(test_case, 500, 643, 16);
  }
}

TEST_F(SizesMathFunctionParserTest, NestedCalc) {
  SizesCalcTestCase test_cases[] = {
      {"calc(calc(50px))", 50, true},
      {"calc(calc(50px)*2)", 100, true},
      {"calc(calc(50px) + calc(50px))", 100, true},
      {"calc(2*calc(50px))", 100, true},
      {"calc(calc(calc(50px)))", 50, true},
  };

  for (const auto& test_case : test_cases) {
    TestSizesCalc(test_case);
  }
}

}  // namespace webf