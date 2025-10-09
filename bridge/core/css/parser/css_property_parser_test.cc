// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/css_property_parser.h"
#include "core/css/css_grid_integer_repeat_value.h"
#include "core/css/css_image_set_value.h"
#include "core/css/css_repeat_style_value.h"
#include "core/css/css_value_list.h"
#include "core/css/parser/css_parser.h"
#include "css_value_keywords.h"
#include "gtest/gtest.h"

namespace webf {

static int ComputeNumberOfTracks(const CSSValueList* value_list) {
  int number_of_tracks = 0;
  for (auto& value : *value_list) {
    if (value->IsGridLineNamesValue()) {
      continue;
    }
    if (auto* repeat_value = DynamicTo<cssvalue::CSSGridIntegerRepeatValue>(*value)) {
      number_of_tracks += repeat_value->Repetitions() * ComputeNumberOfTracks(repeat_value);
      continue;
    }
    ++number_of_tracks;
  }
  return number_of_tracks;
}

static std::shared_ptr<CSSParserContext> StrictCSSParserContext(SecureContextMode mode) {
  return std::make_shared<CSSParserContext>(kHTMLStandardMode);
}

TEST(CSSPropertyParserTest, GridTrackLimit1) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(999, 20px)"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 999);
}

TEST(CSSPropertyParserTest, GridTrackLimit2) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateRows, "repeat(999, 20px)"_s, StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 999);
}

TEST(CSSPropertyParserTest, GridTrackLimit3) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(1000000, 10%)"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit4) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateRows, "repeat(1000000, 10%)"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit5) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(1000000, [first] min-content [last])"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit6) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateRows, "repeat(1000000, [first] min-content [last])"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit7) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(1000001, auto)"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000001);
}

TEST(CSSPropertyParserTest, GridTrackLimit8) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateRows, "repeat(1000001, auto)"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000001);
}

TEST(CSSPropertyParserTest, GridTrackLimit9) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateColumns, "repeat(400000, 2em minmax(10px, max-content) 0.5fr)"_s,
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1200000);
}

TEST(CSSPropertyParserTest, GridTrackLimit10) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateRows, "repeat(400000, 2em minmax(10px, max-content) 0.5fr)"_s,
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1200000);
}

TEST(CSSPropertyParserTest, GridTrackLimit11) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateColumns, "repeat(600000, [first] 3vh 10% 2fr [nav] 10px auto 1fr 6em [last])"_s,
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 4200000);
}

TEST(CSSPropertyParserTest, GridTrackLimit12) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateRows, "repeat(600000, [first] 3vh 10% 2fr [nav] 10px auto 1fr 6em [last])"_s,
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 4200000);
}

TEST(CSSPropertyParserTest, GridTrackLimit13) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(100000000000000000000, 10% 1fr)"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 10000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit14) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateRows, "repeat(100000000000000000000, 10% 1fr)"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 10000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit15) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateColumns, "repeat(100000000000000000000, 10% 5em 1fr auto auto 15px min-content)"_s,
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 9999997);
}

TEST(CSSPropertyParserTest, GridTrackLimit16) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateRows, "repeat(100000000000000000000, 10% 5em 1fr auto auto 15px min-content)"_s,
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 9999997);
}
//
// static int GetGridPositionInteger(const CSSValue& value) {
//  const auto& list = To<CSSValueList>(value);
//  DCHECK_EQ(list.length(), static_cast<size_t>(1));
//  const auto& primitive_value = To<CSSPrimitiveValue>(*list.Item(0));
//  DCHECK(primitive_value.IsNumber());
//  return primitive_value.ComputeInteger(CSSToLengthConversionData());
//}
//
// TEST(CSSPropertyParserTest, GridPositionLimit1) {
//  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
//      CSSPropertyID::kGridColumnStart, "999",
//      StrictCSSParserContext(SecureContextMode::kSecureContext));
//  DCHECK(value);
//  EXPECT_EQ(GetGridPositionInteger(*value), 999);
//}
//
// TEST(CSSPropertyParserTest, GridPositionLimit2) {
//  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
//      CSSPropertyID::kGridColumnEnd, "1000000",
//      StrictCSSParserContext(SecureContextMode::kSecureContext));
//  DCHECK(value);
//  EXPECT_EQ(GetGridPositionInteger(*value), 1000000);
//}
//
// TEST(CSSPropertyParserTest, GridPositionLimit3) {
//  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
//      CSSPropertyID::kGridRowStart, "1000001",
//      StrictCSSParserContext(SecureContextMode::kSecureContext));
//  DCHECK(value);
//  EXPECT_EQ(GetGridPositionInteger(*value), 1000001);
//}
//
// TEST(CSSPropertyParserTest, GridPositionLimit4) {
//  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
//      CSSPropertyID::kGridRowEnd, "5000000000",
//      StrictCSSParserContext(SecureContextMode::kSecureContext));
//  DCHECK(value);
//  EXPECT_EQ(GetGridPositionInteger(*value), 10000000);
//}
//
// TEST(CSSPropertyParserTest, GridPositionLimit5) {
//  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
//      CSSPropertyID::kGridColumnStart, "-999",
//      StrictCSSParserContext(SecureContextMode::kSecureContext));
//  DCHECK(value);
//  EXPECT_EQ(GetGridPositionInteger(*value), -999);
//}
//
// TEST(CSSPropertyParserTest, GridPositionLimit6) {
//  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
//      CSSPropertyID::kGridColumnEnd, "-1000000",
//      StrictCSSParserContext(SecureContextMode::kSecureContext));
//  DCHECK(value);
//  EXPECT_EQ(GetGridPositionInteger(*value), -1000000);
//}
//
// TEST(CSSPropertyParserTest, GridPositionLimit7) {
//  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
//      CSSPropertyID::kGridRowStart, "-1000001",
//      StrictCSSParserContext(SecureContextMode::kSecureContext));
//  DCHECK(value);
//  EXPECT_EQ(GetGridPositionInteger(*value), -1000001);
//}
//
// TEST(CSSPropertyParserTest, GridPositionLimit8) {
//  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
//      CSSPropertyID::kGridRowEnd, "-5000000000",
//      StrictCSSParserContext(SecureContextMode::kSecureContext));
//  DCHECK(value);
//  EXPECT_EQ(GetGridPositionInteger(*value), -10000000);
//}

TEST(CSSPropertyParserTest, ColorFunction) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kBackgroundColor, "rgba(255, 255, 255, 1)"_s,
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_TRUE(value);
  cssvalue::CSSColor css_color = To<cssvalue::CSSColor>(*value);
  WEBF_LOG(VERBOSE) << css_color.CustomCSSText();

  EXPECT_EQ(Color::kWhite, To<cssvalue::CSSColor>(*value).Value());
}

TEST(CSSPropertyParserTest, IncompleteColor) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kBackgroundColor, "rgba(123 45"_s, StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_FALSE(value);
}

TEST(CSSPropertyParserTest, DeclarationLastWinsIgnoresImportantInSameBlock) {
  auto ctx = StrictCSSParserContext(SecureContextMode::kSecureContext);
  auto set = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  bool ok = CSSParser::ParseDeclarationList(ctx, set.get(),
                                            "color: red !important; color: blue;"_s);
  ASSERT_TRUE(ok);
  ASSERT_EQ(1u, set->PropertyCount());
  auto prop = set->PropertyAt(0);
  EXPECT_EQ(CSSPropertyID::kColor, prop.Id());
  EXPECT_EQ("blue", set->GetPropertyValue(CSSPropertyID::kColor));
  EXPECT_FALSE(prop.PropertyMetadata().important_);
}

TEST(CSSPropertyParserTest, Hex8Color) {
  // Ensure 8-digit hex colors (#RRGGBBAA) are parsed.
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kBackgroundColor, "#DADADA00"_s, StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_TRUE(value);
  const cssvalue::CSSColor& css_color = To<cssvalue::CSSColor>(*value);
  const Color& c = css_color.Value();
  EXPECT_EQ(c.Red(), 0xDA);
  EXPECT_EQ(c.Green(), 0xDA);
  EXPECT_EQ(c.Blue(), 0xDA);
  EXPECT_EQ(c.AlphaAsInteger(), 0x00);
}

TEST(CSSPropertyParserTest, Hex4Color) {
  // Ensure 4-digit hex colors (#RGBA) are parsed.
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kBackgroundColor, "#1A2B"_s, StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_TRUE(value);
  const cssvalue::CSSColor& css_color = To<cssvalue::CSSColor>(*value);
  const Color& c = css_color.Value();
  // #1A2B => R=0x11, G=0xAA, B=0x22, A=0xBB
  EXPECT_EQ(c.Red(), 0x11);
  EXPECT_EQ(c.Green(), 0xAA);
  EXPECT_EQ(c.Blue(), 0x22);
  EXPECT_EQ(c.AlphaAsInteger(), 0xBB);
}

void TestImageSetParsing(const String& testValue, const String& expectedCssText) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kBackgroundImage, testValue, StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_NE(value, nullptr);

  const CSSValueList* val_list = To<CSSValueList>(value.get());
  ASSERT_EQ(val_list->length(), 1U);

  const CSSImageSetValue& image_set_value = To<CSSImageSetValue>(*val_list->First());
  EXPECT_EQ(expectedCssText, image_set_value.CssText());
}

TEST(CSSPropertyParserTest, ImageSetDefaultResolution) {
  TestImageSetParsing("image-set(url(foo))"_s, "image-set(url(\"foo\") 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) 3x)"_s, "image-set(url(\"foo\") 3x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetResolutionUnitDppx) {
  TestImageSetParsing("image-set(url(foo) 3dppx)"_s, "image-set(url(\"foo\") 3dppx)"_s);
}

TEST(CSSPropertyParserTest, ImageSetResolutionUnitDpi) {
  TestImageSetParsing("image-set(url(foo) 96dpi)"_s, "image-set(url(\"foo\") 96dpi)"_s);
}

TEST(CSSPropertyParserTest, ImageSetResolutionUnitDpcm) {
  TestImageSetParsing("image-set(url(foo) 37dpcm)"_s, "image-set(url(\"foo\") 37dpcm)"_s);
}

TEST(CSSPropertyParserTest, ImageSetZeroResolution) {
  TestImageSetParsing("image-set(url(foo) 0x)"_s, "image-set(url(\"foo\") 0x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(1x))"_s, "image-set(url(\"foo\") calc(1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcNegativerResolution) {
  TestImageSetParsing("image-set(url(foo) calc(-1x))"_s, "image-set(url(\"foo\") calc(-1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetAddCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(2x + 3x))"_s, "image-set(url(\"foo\") calc(5dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetSubCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(2x - 1x))"_s, "image-set(url(\"foo\") calc(1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetMultCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(2x * 3))"_s, "image-set(url(\"foo\") calc(6dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetMultCalcNegativeResolution) {
  TestImageSetParsing("image-set(url(foo) calc(1 * -1x))"_s, "image-set(url(\"foo\") calc(-1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetMultCalcNegativeNumberResolution) {
  TestImageSetParsing("image-set(url(foo) calc(-1 * 1x))"_s, "image-set(url(\"foo\") calc(-1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetDivCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(6x / 3))"_s, "image-set(url(\"foo\") calc(2dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetAddCalcResolutionUnitDpiWithX) {
  TestImageSetParsing("image-set(url(foo) calc(96dpi + 2x))"_s, "image-set(url(\"foo\") calc(3dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetAddCalcResolutionUnitDpiWithDpi) {
  TestImageSetParsing("image-set(url(foo) calc(96dpi + 96dpi))"_s, "image-set(url(\"foo\") calc(2dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetSubCalcResolutionUnitDpiFromX) {
  TestImageSetParsing("image-set(url(foo) calc(2x - 96dpi))"_s, "image-set(url(\"foo\") calc(1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcResolutionUnitDppx) {
  TestImageSetParsing("image-set(url(foo) calc(2dppx * 3))"_s, "image-set(url(\"foo\") calc(6dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcResolutionUnitDpi) {
  TestImageSetParsing("image-set(url(foo) calc(32dpi * 3))"_s, "image-set(url(\"foo\") calc(1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcResolutionUnitDpcm) {
  TestImageSetParsing("image-set(url(foo) calc(1dpcm * 37.79532))"_s, "image-set(url(\"foo\") calc(1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcMaxInf) {
  TestImageSetParsing("image-set(url(foo) calc(1 * max(INFinity * 3x, 0dpcm)))"_s,
                      "image-set(url(\"foo\") calc(infinity * 1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcMinInf) {
  TestImageSetParsing("image-set(url(foo) calc(1 * min(inFInity * 4x, 0dpi)))"_s, "image-set(url(\"foo\") calc(0dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcMinMaxNan) {
  TestImageSetParsing("image-set(url(foo) calc(1dppx * max(0, min(10, NaN))))"_s,
                      "image-set(url(\"foo\") calc(NaN * 1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcClamp) {
  TestImageSetParsing("image-set(url(foo) calc(1dppx * clamp(-Infinity, 0, infinity)))"_s,
                      "image-set(url(\"foo\") calc(0dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcClampLeft) {
  TestImageSetParsing("image-set(url(foo) calc(1dppx * clamp(0, -Infinity, infinity)))"_s,
                      "image-set(url(\"foo\") calc(0dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcClampRight) {
  TestImageSetParsing("image-set(url(foo) calc(1dppx * clamp(-Infinity, infinity, 0)))"_s,
                      "image-set(url(\"foo\") calc(0dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetCalcClampNan) {
  TestImageSetParsing(
      "image-set(url(foo) calc(1 * clamp(-INFINITY*0dppx, 0dppx, "
      "infiniTY*0dppx)))"_s,
      "image-set(url(\"foo\") calc(NaN * 1dppx))"_s);
}

TEST(CSSPropertyParserTest, ImageSetUrlFunction) {
  TestImageSetParsing("image-set(url('foo') 1x)"_s, "image-set(url(\"foo\") 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetUrlFunctionEmptyStrUrl) {
  TestImageSetParsing("image-set(url('') 1x)"_s, "image-set(url(\"\") 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetUrlFunctionNoQuotationMarks) {
  TestImageSetParsing("image-set(url(foo) 1x)"_s, "image-set(url(\"foo\") 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetNoUrlFunction) {
  TestImageSetParsing("image-set('foo' 1x)"_s, "image-set(url(\"foo\") 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetEmptyStrUrl) {
  TestImageSetParsing("image-set('' 1x)"_s, "image-set(url(\"\") 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetLinearGradient) {
  TestImageSetParsing("image-set(linear-gradient(red, blue) 1x)"_s, "image-set(linear-gradient(red, blue) 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetRepeatingLinearGradient) {
  TestImageSetParsing("image-set(repeating-linear-gradient(red, blue 25%) 1x)"_s,
                      "image-set(repeating-linear-gradient(red, blue 25%) 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetRadialGradient) {
  TestImageSetParsing("image-set(radial-gradient(red, blue) 1x)"_s, "image-set(radial-gradient(red, blue) 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetRepeatingRadialGradient) {
  TestImageSetParsing("image-set(repeating-radial-gradient(red, blue 25%) 1x)"_s,
                      "image-set(repeating-radial-gradient(red, blue 25%) 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetConicGradient) {
  TestImageSetParsing("image-set(conic-gradient(red, blue) 1x)"_s, "image-set(conic-gradient(red, blue) 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetRepeatingConicGradient) {
  TestImageSetParsing("image-set(repeating-conic-gradient(red, blue 25%) 1x)"_s,
                      "image-set(repeating-conic-gradient(red, blue 25%) 1x)"_s);
}

TEST(CSSPropertyParserTest, ImageSetType) {
  TestImageSetParsing("image-set(url('foo') 1x type('image/png'))"_s, "image-set(url(\"foo\") 1x type(\"image/png\"))"_s);
}

void TestImageSetParsingFailure(const std::string& testValue) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kBackgroundImage, String::FromUTF8(testValue.c_str()), StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_EQ(value, nullptr);
}

TEST(CSSPropertyParserTest, ImageSetEmpty) {
  TestImageSetParsingFailure("image-set()");
}

TEST(CSSPropertyParserTest, ImageSetMissingUrl) {
  TestImageSetParsingFailure("image-set(1x)");
}

TEST(CSSPropertyParserTest, ImageSetNegativeResolution) {
  TestImageSetParsingFailure("image-set(url(foo) -1x)");
}

TEST(CSSPropertyParserTest, ImageSetOnlyOneGradientColor) {
  TestImageSetParsingFailure("image-set(linear-gradient(red) 1x)");
}

TEST(CSSPropertyParserTest, ImageSetAddCalcMissingUnit1) {
  TestImageSetParsingFailure("image-set(url(foo) calc(2 + 3x))");
}

TEST(CSSPropertyParserTest, ImageSetAddCalcMissingUnit2) {
  TestImageSetParsingFailure("image-set(url(foo) calc(2x + 3))");
}

TEST(CSSPropertyParserTest, ImageSetSubCalcMissingUnit1) {
  TestImageSetParsingFailure("image-set(url(foo) calc(2 - 1x))");
}

TEST(CSSPropertyParserTest, ImageSetSubCalcMissingUnit2) {
  TestImageSetParsingFailure("image-set(url(foo) calc(2x - 1))");
}

TEST(CSSPropertyParserTest, ImageSetMultCalcDoubleX) {
  TestImageSetParsingFailure("image-set(url(foo) calc(2x * 3x))");
}

TEST(CSSPropertyParserTest, ImageSetDivCalcDoubleX) {
  TestImageSetParsingFailure("image-set(url(foo) calc(6x / 3x))");
}

TEST(CSSPropertyParserTest, LightDarkAuthor) {
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  ASSERT_TRUE(CSSParser::ParseSingleValue(CSSPropertyID::kColor, "light-dark(#000000, #ffffff)"_s, context));
  ASSERT_TRUE(CSSParser::ParseSingleValue(CSSPropertyID::kColor, "light-dark(red, green)"_s, context));
  // light-dark() is only valid for background-image in UA sheets.
  ASSERT_FALSE(CSSParser::ParseSingleValue(CSSPropertyID::kBackgroundImage, "light-dark(url(light.png), url(dark.png))"_s,
                                           context));
}

TEST(CSSPropertyParserTest, UALightDarkColor) {
  auto ua_context = std::make_shared<CSSParserContext>(kUASheetMode);

  const struct {
    const char* value;
    bool valid;
  } tests[] = {
      {"light-dark()", false},
      {"light-dark(#feedab)", false},
      {"light-dark(red blue)", false},
      {"light-dark(red,,blue)", false},
      {"light-dark(red, blue)", true},
      {"light-dark(#000000, #ffffff)", true},
      {"light-dark(rgb(0, 0, 0), hsl(180, 75%, 50%))", true},
      {"light-dark(rgba(0, 0, 0, 0.5), hsla(180, 75%, 50%, "
       "0.7))",
       true},
      {"light-dark(ff0000, green)", false},
  };

  for (const auto& test : tests) {
    EXPECT_EQ(!!CSSParser::ParseSingleValue(CSSPropertyID::kColor, String::FromUTF8(test.value), ua_context), test.valid);
  }
}

TEST(CSSPropertyParserTest, UALightDarkColorSerialization) {
  auto ua_context = std::make_shared<CSSParserContext>(kUASheetMode);
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kColor, "light-dark(red,#aaa)"_s, ua_context);
  ASSERT_TRUE(value);
  EXPECT_EQ("light-dark(red, rgb(170, 170, 170))", value->CssText());
}

namespace {

bool ParseCSSValue(CSSPropertyID property_id,
                   const std::string& value,
                   std::shared_ptr<const CSSParserContext> context) {
  String value_str = String::FromUTF8(value.c_str());
  CSSTokenizer tokenizer(value_str);
  CSSParserTokenStream stream(tokenizer);
  std::vector<CSSPropertyValue> parsed_properties;
  parsed_properties.reserve(64);
  return CSSPropertyParser::ParseValue(property_id, /*allow_important_annotation=*/false, stream, context,
                                       parsed_properties, StyleRule::RuleType::kStyle);
}

}  // namespace

TEST(CSSPropertyParserTest, ParseRevert) {
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);

  std::string string = " revert";
  String string_str = String::FromUTF8(string.c_str());
  CSSTokenizer tokenizer(string_str);
  CSSParserTokenStream stream(tokenizer);

  std::shared_ptr<const CSSValue> value =
      CSSPropertyParser::ParseSingleValue(CSSPropertyID::kMarginLeft, stream, context);
  ASSERT_TRUE(value);
  EXPECT_TRUE(value->IsRevertValue());
}

TEST(CSSPropertyParserTest, ParseRevertLayer) {
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);

  std::string string = " revert-layer";
  String string_str = String::FromUTF8(string.c_str());
  CSSTokenizer tokenizer(string_str);
  CSSParserTokenStream stream(tokenizer);

  std::shared_ptr<const CSSValue> value =
      CSSPropertyParser::ParseSingleValue(CSSPropertyID::kMarginLeft, stream, context);
  ASSERT_TRUE(value);
  EXPECT_TRUE(value->IsRevertLayerValue());
}

// anchor() and anchor-size() shouldn't parse when the feature is disabled.
TEST(CSSPropertyParserTest, AnchorPositioningDisabled) {
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);

  EXPECT_FALSE(ParseCSSValue(CSSPropertyID::kTop, "anchor(--foo top)", context));
  EXPECT_FALSE(ParseCSSValue(CSSPropertyID::kBottom, "anchor(--foo bottom)", context));
  EXPECT_FALSE(ParseCSSValue(CSSPropertyID::kWidth, "anchor-size(--foo width)", context));
  EXPECT_FALSE(ParseCSSValue(CSSPropertyID::kHeight, "anchor-size(--foo height)", context));
}

void TestRepeatStyleParsing(const String& testValue, const String& expectedCssText, const CSSPropertyID& propID) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(propID, testValue, StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_NE(value, nullptr);

  const CSSValueList* val_list = To<CSSValueList>(value.get());
  ASSERT_EQ(val_list->length(), 1U);

  const CSSRepeatStyleValue& repeat_style_value = To<CSSRepeatStyleValue>(*val_list->First());
  EXPECT_EQ(expectedCssText, repeat_style_value.CssText());
}

void TestRepeatStylesParsing(const String& testValue, const String& expectedCssText) {
  TestRepeatStyleParsing(testValue, expectedCssText, CSSPropertyID::kBackgroundRepeat);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatX1) {
  TestRepeatStylesParsing("repeat-x"_s, "repeat-x"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatX2) {
  TestRepeatStylesParsing("repeat no-repeat"_s, "repeat-x"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatY1) {
  TestRepeatStylesParsing("repeat-y"_s, "repeat-y"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatY2) {
  TestRepeatStylesParsing("no-repeat repeat"_s, "repeat-y"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeat1) {
  TestRepeatStylesParsing("repeat"_s, "repeat"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeat2) {
  TestRepeatStylesParsing("repeat repeat"_s, "repeat"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleNoRepeat1) {
  TestRepeatStylesParsing("no-repeat"_s, "no-repeat"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleNoRepeat2) {
  TestRepeatStylesParsing("no-repeat no-repeat"_s, "no-repeat"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleSpace1) {
  TestRepeatStylesParsing("space"_s, "space"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleSpace2) {
  TestRepeatStylesParsing("space space"_s, "space"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleRound1) {
  TestRepeatStylesParsing("round"_s, "round"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleRound2) {
  TestRepeatStylesParsing("round round"_s, "round"_s);
}

TEST(CSSPropertyParserTest, RepeatStyle2Val) {
  TestRepeatStylesParsing("round space"_s, "round space"_s);
}

void TestRepeatStyleViaShorthandParsing(const String& testValue,
                                        const String& expectedCssText,
                                        const CSSPropertyID& propID) {
  auto style = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  CSSParser::ParseValue(style.get(), propID, testValue, false /* important */);
  ASSERT_NE(style, nullptr);
  WEBF_LOG(VERBOSE) << "style text" << style->AsText();
  EXPECT_TRUE(style->AsText().Find(expectedCssText) != kNotFound);
}

void TestRepeatStyleViaShorthandsParsing(const String& testValue, const String& expectedCssText) {
  TestRepeatStyleViaShorthandParsing(testValue, expectedCssText, CSSPropertyID::kBackground);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatXViaShorthand) {
  TestRepeatStyleViaShorthandsParsing("url(foo) repeat no-repeat"_s, "repeat-x"_s);
}

TEST(CSSPropertyParserTest, RepeatStyleRoundViaShorthand) {
  TestRepeatStyleViaShorthandsParsing("url(foo) round round"_s, "round"_s);
}

TEST(CSSPropertyParserTest, RepeatStyle2ValViaShorthand) {
  TestRepeatStyleViaShorthandsParsing("url(foo) space repeat"_s, "space repeat"_s);
}

}  // namespace webf
