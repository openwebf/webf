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
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(999, 20px)",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 999);
}

TEST(CSSPropertyParserTest, GridTrackLimit2) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateRows, "repeat(999, 20px)", StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 999);
}

TEST(CSSPropertyParserTest, GridTrackLimit3) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(1000000, 10%)",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit4) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateRows, "repeat(1000000, 10%)",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit5) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(1000000, [first] min-content [last])",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit6) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateRows, "repeat(1000000, [first] min-content [last])",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit7) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(1000001, auto)",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000001);
}

TEST(CSSPropertyParserTest, GridTrackLimit8) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateRows, "repeat(1000001, auto)",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1000001);
}

TEST(CSSPropertyParserTest, GridTrackLimit9) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateColumns, "repeat(400000, 2em minmax(10px, max-content) 0.5fr)",
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1200000);
}

TEST(CSSPropertyParserTest, GridTrackLimit10) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateRows, "repeat(400000, 2em minmax(10px, max-content) 0.5fr)",
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 1200000);
}

TEST(CSSPropertyParserTest, GridTrackLimit11) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateColumns, "repeat(600000, [first] 3vh 10% 2fr [nav] 10px auto 1fr 6em [last])",
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 4200000);
}

TEST(CSSPropertyParserTest, GridTrackLimit12) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateRows, "repeat(600000, [first] 3vh 10% 2fr [nav] 10px auto 1fr 6em [last])",
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 4200000);
}

TEST(CSSPropertyParserTest, GridTrackLimit13) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateColumns, "repeat(100000000000000000000, 10% 1fr)",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 10000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit14) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kGridTemplateRows, "repeat(100000000000000000000, 10% 1fr)",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 10000000);
}

TEST(CSSPropertyParserTest, GridTrackLimit15) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateColumns, "repeat(100000000000000000000, 10% 5em 1fr auto auto 15px min-content)",
      StrictCSSParserContext(SecureContextMode::kSecureContext));
  EXPECT_EQ(ComputeNumberOfTracks(To<CSSValueList>(value.get())), 9999997);
}

TEST(CSSPropertyParserTest, GridTrackLimit16) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kGridTemplateRows, "repeat(100000000000000000000, 10% 5em 1fr auto auto 15px min-content)",
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
      CSSParser::ParseSingleValue(CSSPropertyID::kBackgroundColor, "rgba(255, 255, 255, 1)",
                                  StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_TRUE(value);
  cssvalue::CSSColor css_color = To<cssvalue::CSSColor>(*value);
  WEBF_LOG(VERBOSE) << css_color.CustomCSSText();

  EXPECT_EQ(Color::kWhite, To<cssvalue::CSSColor>(*value).Value());
}

TEST(CSSPropertyParserTest, IncompleteColor) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kBackgroundColor, "rgba(123 45", StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_FALSE(value);
}

void TestImageSetParsing(const std::string& testValue, const std::string& expectedCssText) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kBackgroundImage, testValue, StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_NE(value, nullptr);

  const CSSValueList* val_list = To<CSSValueList>(value.get());
  ASSERT_EQ(val_list->length(), 1U);

  const CSSImageSetValue& image_set_value = To<CSSImageSetValue>(*val_list->First());
  EXPECT_EQ(expectedCssText, image_set_value.CssText());
}

TEST(CSSPropertyParserTest, ImageSetDefaultResolution) {
  TestImageSetParsing("image-set(url(foo))", "image-set(url(\"foo\") 1x)");
}

TEST(CSSPropertyParserTest, ImageSetResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) 3x)", "image-set(url(\"foo\") 3x)");
}

TEST(CSSPropertyParserTest, ImageSetResolutionUnitDppx) {
  TestImageSetParsing("image-set(url(foo) 3dppx)", "image-set(url(\"foo\") 3dppx)");
}

TEST(CSSPropertyParserTest, ImageSetResolutionUnitDpi) {
  TestImageSetParsing("image-set(url(foo) 96dpi)", "image-set(url(\"foo\") 96dpi)");
}

TEST(CSSPropertyParserTest, ImageSetResolutionUnitDpcm) {
  TestImageSetParsing("image-set(url(foo) 37dpcm)", "image-set(url(\"foo\") 37dpcm)");
}

TEST(CSSPropertyParserTest, ImageSetZeroResolution) {
  TestImageSetParsing("image-set(url(foo) 0x)", "image-set(url(\"foo\") 0x)");
}

TEST(CSSPropertyParserTest, ImageSetCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(1x))", "image-set(url(\"foo\") calc(1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcNegativerResolution) {
  TestImageSetParsing("image-set(url(foo) calc(-1x))", "image-set(url(\"foo\") calc(-1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetAddCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(2x + 3x))", "image-set(url(\"foo\") calc(5dppx))");
}

TEST(CSSPropertyParserTest, ImageSetSubCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(2x - 1x))", "image-set(url(\"foo\") calc(1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetMultCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(2x * 3))", "image-set(url(\"foo\") calc(6dppx))");
}

TEST(CSSPropertyParserTest, ImageSetMultCalcNegativeResolution) {
  TestImageSetParsing("image-set(url(foo) calc(1 * -1x))", "image-set(url(\"foo\") calc(-1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetMultCalcNegativeNumberResolution) {
  TestImageSetParsing("image-set(url(foo) calc(-1 * 1x))", "image-set(url(\"foo\") calc(-1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetDivCalcResolutionUnitX) {
  TestImageSetParsing("image-set(url(foo) calc(6x / 3))", "image-set(url(\"foo\") calc(2dppx))");
}

TEST(CSSPropertyParserTest, ImageSetAddCalcResolutionUnitDpiWithX) {
  TestImageSetParsing("image-set(url(foo) calc(96dpi + 2x))", "image-set(url(\"foo\") calc(3dppx))");
}

TEST(CSSPropertyParserTest, ImageSetAddCalcResolutionUnitDpiWithDpi) {
  TestImageSetParsing("image-set(url(foo) calc(96dpi + 96dpi))", "image-set(url(\"foo\") calc(2dppx))");
}

TEST(CSSPropertyParserTest, ImageSetSubCalcResolutionUnitDpiFromX) {
  TestImageSetParsing("image-set(url(foo) calc(2x - 96dpi))", "image-set(url(\"foo\") calc(1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcResolutionUnitDppx) {
  TestImageSetParsing("image-set(url(foo) calc(2dppx * 3))", "image-set(url(\"foo\") calc(6dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcResolutionUnitDpi) {
  TestImageSetParsing("image-set(url(foo) calc(32dpi * 3))", "image-set(url(\"foo\") calc(1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcResolutionUnitDpcm) {
  TestImageSetParsing("image-set(url(foo) calc(1dpcm * 37.79532))", "image-set(url(\"foo\") calc(1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcMaxInf) {
  TestImageSetParsing("image-set(url(foo) calc(1 * max(INFinity * 3x, 0dpcm)))",
                      "image-set(url(\"foo\") calc(infinity * 1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcMinInf) {
  TestImageSetParsing("image-set(url(foo) calc(1 * min(inFInity * 4x, 0dpi)))", "image-set(url(\"foo\") calc(0dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcMinMaxNan) {
  TestImageSetParsing("image-set(url(foo) calc(1dppx * max(0, min(10, NaN))))",
                      "image-set(url(\"foo\") calc(NaN * 1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcClamp) {
  TestImageSetParsing("image-set(url(foo) calc(1dppx * clamp(-Infinity, 0, infinity)))",
                      "image-set(url(\"foo\") calc(0dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcClampLeft) {
  TestImageSetParsing("image-set(url(foo) calc(1dppx * clamp(0, -Infinity, infinity)))",
                      "image-set(url(\"foo\") calc(0dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcClampRight) {
  TestImageSetParsing("image-set(url(foo) calc(1dppx * clamp(-Infinity, infinity, 0)))",
                      "image-set(url(\"foo\") calc(0dppx))");
}

TEST(CSSPropertyParserTest, ImageSetCalcClampNan) {
  TestImageSetParsing(
      "image-set(url(foo) calc(1 * clamp(-INFINITY*0dppx, 0dppx, "
      "infiniTY*0dppx)))",
      "image-set(url(\"foo\") calc(NaN * 1dppx))");
}

TEST(CSSPropertyParserTest, ImageSetUrlFunction) {
  TestImageSetParsing("image-set(url('foo') 1x)", "image-set(url(\"foo\") 1x)");
}

TEST(CSSPropertyParserTest, ImageSetUrlFunctionEmptyStrUrl) {
  TestImageSetParsing("image-set(url('') 1x)", "image-set(url(\"\") 1x)");
}

TEST(CSSPropertyParserTest, ImageSetUrlFunctionNoQuotationMarks) {
  TestImageSetParsing("image-set(url(foo) 1x)", "image-set(url(\"foo\") 1x)");
}

TEST(CSSPropertyParserTest, ImageSetNoUrlFunction) {
  TestImageSetParsing("image-set('foo' 1x)", "image-set(url(\"foo\") 1x)");
}

TEST(CSSPropertyParserTest, ImageSetEmptyStrUrl) {
  TestImageSetParsing("image-set('' 1x)", "image-set(url(\"\") 1x)");
}

TEST(CSSPropertyParserTest, ImageSetLinearGradient) {
  TestImageSetParsing("image-set(linear-gradient(red, blue) 1x)", "image-set(linear-gradient(red, blue) 1x)");
}

TEST(CSSPropertyParserTest, ImageSetRepeatingLinearGradient) {
  TestImageSetParsing("image-set(repeating-linear-gradient(red, blue 25%) 1x)",
                      "image-set(repeating-linear-gradient(red, blue 25%) 1x)");
}

TEST(CSSPropertyParserTest, ImageSetRadialGradient) {
  TestImageSetParsing("image-set(radial-gradient(red, blue) 1x)", "image-set(radial-gradient(red, blue) 1x)");
}

TEST(CSSPropertyParserTest, ImageSetRepeatingRadialGradient) {
  TestImageSetParsing("image-set(repeating-radial-gradient(red, blue 25%) 1x)",
                      "image-set(repeating-radial-gradient(red, blue 25%) 1x)");
}

TEST(CSSPropertyParserTest, ImageSetConicGradient) {
  TestImageSetParsing("image-set(conic-gradient(red, blue) 1x)", "image-set(conic-gradient(red, blue) 1x)");
}

TEST(CSSPropertyParserTest, ImageSetRepeatingConicGradient) {
  TestImageSetParsing("image-set(repeating-conic-gradient(red, blue 25%) 1x)",
                      "image-set(repeating-conic-gradient(red, blue 25%) 1x)");
}

TEST(CSSPropertyParserTest, ImageSetType) {
  TestImageSetParsing("image-set(url('foo') 1x type('image/png'))", "image-set(url(\"foo\") 1x type(\"image/png\"))");
}

void TestImageSetParsingFailure(const std::string& testValue) {
  std::shared_ptr<const CSSValue> value = CSSParser::ParseSingleValue(
      CSSPropertyID::kBackgroundImage, testValue, StrictCSSParserContext(SecureContextMode::kSecureContext));
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
  ASSERT_TRUE(CSSParser::ParseSingleValue(CSSPropertyID::kColor, "light-dark(#000000, #ffffff)", context));
  ASSERT_TRUE(CSSParser::ParseSingleValue(CSSPropertyID::kColor, "light-dark(red, green)", context));
  // light-dark() is only valid for background-image in UA sheets.
  ASSERT_FALSE(CSSParser::ParseSingleValue(CSSPropertyID::kBackgroundImage, "light-dark(url(light.png), url(dark.png))",
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
    EXPECT_EQ(!!CSSParser::ParseSingleValue(CSSPropertyID::kColor, test.value, ua_context), test.valid);
  }
}

TEST(CSSPropertyParserTest, UALightDarkColorSerialization) {
  auto ua_context = std::make_shared<CSSParserContext>(kUASheetMode);
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(CSSPropertyID::kColor, "light-dark(red,#aaa)", ua_context);
  ASSERT_TRUE(value);
  EXPECT_EQ("light-dark(red, rgb(170, 170, 170))", value->CssText());
}

namespace {

bool ParseCSSValue(CSSPropertyID property_id,
                   const std::string& value,
                   std::shared_ptr<const CSSParserContext> context) {
  CSSTokenizer tokenizer(value);
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
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);

  std::shared_ptr<const CSSValue> value =
      CSSPropertyParser::ParseSingleValue(CSSPropertyID::kMarginLeft, stream, context);
  ASSERT_TRUE(value);
  EXPECT_TRUE(value->IsRevertValue());
}

TEST(CSSPropertyParserTest, ParseRevertLayer) {
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);

  std::string string = " revert-layer";
  CSSTokenizer tokenizer(string);
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

void TestRepeatStyleParsing(const std::string& testValue,
                            const std::string& expectedCssText,
                            const CSSPropertyID& propID) {
  std::shared_ptr<const CSSValue> value =
      CSSParser::ParseSingleValue(propID, testValue, StrictCSSParserContext(SecureContextMode::kSecureContext));
  ASSERT_NE(value, nullptr);

  const CSSValueList* val_list = To<CSSValueList>(value.get());
  ASSERT_EQ(val_list->length(), 1U);

  const CSSRepeatStyleValue& repeat_style_value = To<CSSRepeatStyleValue>(*val_list->First());
  EXPECT_EQ(expectedCssText, repeat_style_value.CssText());
}

void TestRepeatStylesParsing(const std::string& testValue, const std::string& expectedCssText) {
  TestRepeatStyleParsing(testValue, expectedCssText, CSSPropertyID::kBackgroundRepeat);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatX1) {
  TestRepeatStylesParsing("repeat-x", "repeat-x");
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatX2) {
  TestRepeatStylesParsing("repeat no-repeat", "repeat-x");
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatY1) {
  TestRepeatStylesParsing("repeat-y", "repeat-y");
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatY2) {
  TestRepeatStylesParsing("no-repeat repeat", "repeat-y");
}

TEST(CSSPropertyParserTest, RepeatStyleRepeat1) {
  TestRepeatStylesParsing("repeat", "repeat");
}

TEST(CSSPropertyParserTest, RepeatStyleRepeat2) {
  TestRepeatStylesParsing("repeat repeat", "repeat");
}

TEST(CSSPropertyParserTest, RepeatStyleNoRepeat1) {
  TestRepeatStylesParsing("no-repeat", "no-repeat");
}

TEST(CSSPropertyParserTest, RepeatStyleNoRepeat2) {
  TestRepeatStylesParsing("no-repeat no-repeat", "no-repeat");
}

TEST(CSSPropertyParserTest, RepeatStyleSpace1) {
  TestRepeatStylesParsing("space", "space");
}

TEST(CSSPropertyParserTest, RepeatStyleSpace2) {
  TestRepeatStylesParsing("space space", "space");
}

TEST(CSSPropertyParserTest, RepeatStyleRound1) {
  TestRepeatStylesParsing("round", "round");
}

TEST(CSSPropertyParserTest, RepeatStyleRound2) {
  TestRepeatStylesParsing("round round", "round");
}

TEST(CSSPropertyParserTest, RepeatStyle2Val) {
  TestRepeatStylesParsing("round space", "round space");
}

void TestRepeatStyleViaShorthandParsing(const std::string& testValue,
                                        const std::string& expectedCssText,
                                        const CSSPropertyID& propID) {
  auto style = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  CSSParser::ParseValue(style.get(), propID, testValue, false /* important */);
  ASSERT_NE(style, nullptr);
  WEBF_LOG(VERBOSE) << "style text" << style->AsText();
  EXPECT_TRUE(style->AsText().find(expectedCssText) != std::string::npos);
}

void TestRepeatStyleViaShorthandsParsing(const std::string& testValue, const std::string& expectedCssText) {
  TestRepeatStyleViaShorthandParsing(testValue, expectedCssText, CSSPropertyID::kBackground);
}

TEST(CSSPropertyParserTest, RepeatStyleRepeatXViaShorthand) {
  TestRepeatStyleViaShorthandsParsing("url(foo) repeat no-repeat", "repeat-x");
}

TEST(CSSPropertyParserTest, RepeatStyleRoundViaShorthand) {
  TestRepeatStyleViaShorthandsParsing("url(foo) round round", "round");
}

TEST(CSSPropertyParserTest, RepeatStyle2ValViaShorthand) {
  TestRepeatStyleViaShorthandsParsing("url(foo) space repeat", "space repeat");
}

}  // namespace webf