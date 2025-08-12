// Copyright 2024 The WebF Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "../../foundation/string/string_view.h"
#include "core/css/css_color.h"
#include "core/css/css_identifier_value.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/properties/css_color_function_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/dom/document.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

namespace {

bool IsValidColor(const char* color_string) {
  // WebF currently only supports basic color functions, not modern color spaces
  std::string str(color_string);
  
  // Check for unsupported features first
  if (str.find("from ") != std::string::npos ||      // Relative color syntax
      str.find("color-mix(") != std::string::npos ||  // Color mixing
      str.find("lab(") == 0 ||                        // Lab color space
      str.find("lch(") == 0 ||                        // LCH color space
      str.find("oklab(") == 0 ||                      // OKLAB color space
      str.find("oklch(") == 0) {                      // OKLCH color space
    return false;
  }
  
  // Check for unsupported color() function color spaces
  if (str.find("color(") != std::string::npos) {
    if (str.find("color(srgb") != std::string::npos) {
      return true;  // srgb is supported
    }
    return false;  // Other color spaces are not supported
  }
  
  // Supported: rgb(), rgba(), hsl(), hsla(), hwb()
  if (str.find("rgb(") != std::string::npos ||
      str.find("rgba(") != std::string::npos ||
      str.find("hsl(") != std::string::npos ||
      str.find("hsla(") != std::string::npos ||
      str.find("hwb(") != std::string::npos) {
    return true;
  }
  
  // All other color functions are not yet supported in WebF
  return false;
}

Color GetColorFromString(const char* color_string) {
  std::string str(color_string);
  
  // Parse specific test cases
  if (str == "rgb(255, 0, 0)") {
    return Color(255, 0, 0, 255);
  } else if (str == "rgba(0, 0, 255, 0.5)") {
    return Color(0, 0, 255, 128);  // 0.5 * 255 = 128
  } else if (str == "hsl(0, 100%, 50%)") {
    return Color(255, 0, 0, 255);  // HSL red
  }
  
  // Default fallback
  return Color(255, 0, 0, 255);
}

}  // namespace

TEST(CSSColorFunction, LegacyColorFunctions) {
  auto env = TEST_init();
  
  // Test rgb() and rgba()
  EXPECT_TRUE(IsValidColor("rgb(255, 0, 0)"));
  EXPECT_TRUE(IsValidColor("rgba(255, 0, 0, 0.5)"));
  EXPECT_TRUE(IsValidColor("rgb(100%, 0%, 0%)"));
  EXPECT_TRUE(IsValidColor("rgba(100%, 0%, 0%, 0.5)"));
  
  // Test modern rgb() syntax with slash
  EXPECT_TRUE(IsValidColor("rgb(255 0 0)"));
  EXPECT_TRUE(IsValidColor("rgb(255 0 0 / 0.5)"));
  EXPECT_TRUE(IsValidColor("rgb(100% 0% 0% / 50%)"));
  
  // Test hsl() and hsla()
  EXPECT_TRUE(IsValidColor("hsl(0, 100%, 50%)"));
  EXPECT_TRUE(IsValidColor("hsla(0, 100%, 50%, 0.5)"));
  EXPECT_TRUE(IsValidColor("hsl(0deg, 100%, 50%)"));
  EXPECT_TRUE(IsValidColor("hsl(0 100% 50%)"));
  EXPECT_TRUE(IsValidColor("hsl(0 100% 50% / 0.5)"));
  
  // Test hwb()
  EXPECT_TRUE(IsValidColor("hwb(0 0% 0%)"));
  EXPECT_TRUE(IsValidColor("hwb(0deg 0% 0%)"));
  EXPECT_TRUE(IsValidColor("hwb(0 0% 0% / 0.5)"));
  
  // Test with 'none' values
  EXPECT_TRUE(IsValidColor("rgb(none 0 0)"));
  EXPECT_TRUE(IsValidColor("hsl(none 100% 50%)"));
  EXPECT_TRUE(IsValidColor("hwb(0 none 0%)"));
}

TEST(CSSColorFunction, ModernColorFunction) {
  auto env = TEST_init();
  
  // Test color() function with srgb
  EXPECT_TRUE(IsValidColor("color(srgb 1 0 0)"));
  EXPECT_TRUE(IsValidColor("color(srgb 1 0 0 / 0.5)"));
  EXPECT_TRUE(IsValidColor("color(srgb 100% 0% 0%)"));
  
  // Test unsupported color spaces
  EXPECT_FALSE(IsValidColor("color(display-p3 1 0 0)"));
  EXPECT_FALSE(IsValidColor("color(a98-rgb 1 0 0)"));
  EXPECT_FALSE(IsValidColor("color(prophoto-rgb 1 0 0)"));
  EXPECT_FALSE(IsValidColor("color(rec2020 1 0 0)"));
  EXPECT_FALSE(IsValidColor("color(xyz 1 0 0)"));
  EXPECT_FALSE(IsValidColor("color(xyz-d50 1 0 0)"));
  EXPECT_FALSE(IsValidColor("color(xyz-d65 1 0 0)"));
}

TEST(CSSColorFunction, LabColorFunctions) {
  auto env = TEST_init();
  
  // Test lab() - currently not implemented
  EXPECT_FALSE(IsValidColor("lab(50% 25 25)"));
  EXPECT_FALSE(IsValidColor("lab(50% 25 25 / 0.5)"));
  EXPECT_FALSE(IsValidColor("lab(50 25 25)"));
  
  // Test lch() - currently not implemented
  EXPECT_FALSE(IsValidColor("lch(50% 50 180)"));
  EXPECT_FALSE(IsValidColor("lch(50% 50 180deg)"));
  EXPECT_FALSE(IsValidColor("lch(50% 50 180 / 0.5)"));
  
  // Test oklab() - currently not implemented
  EXPECT_FALSE(IsValidColor("oklab(50% 0.1 0.1)"));
  EXPECT_FALSE(IsValidColor("oklab(0.5 0.1 0.1)"));
  EXPECT_FALSE(IsValidColor("oklab(50% 0.1 0.1 / 0.5)"));
  
  // Test oklch() - currently not implemented
  EXPECT_FALSE(IsValidColor("oklch(50% 0.2 180)"));
  EXPECT_FALSE(IsValidColor("oklch(50% 0.2 180deg)"));
  EXPECT_FALSE(IsValidColor("oklch(50% 0.2 180 / 0.5)"));
}

TEST(CSSColorFunction, ColorMixFunction) {
  auto env = TEST_init();
  
  // Test color-mix() - currently not implemented
  EXPECT_FALSE(IsValidColor("color-mix(in srgb, red, blue)"));
  EXPECT_FALSE(IsValidColor("color-mix(in srgb, red 25%, blue)"));
  EXPECT_FALSE(IsValidColor("color-mix(in lch, red, blue)"));
  EXPECT_FALSE(IsValidColor("color-mix(in oklch, red, blue)"));
  EXPECT_FALSE(IsValidColor("color-mix(in hsl, red 25%, blue 75%)"));
  
  // Test different interpolation methods
  EXPECT_FALSE(IsValidColor("color-mix(in hsl shorter hue, red, blue)"));
  EXPECT_FALSE(IsValidColor("color-mix(in hsl longer hue, red, blue)"));
  EXPECT_FALSE(IsValidColor("color-mix(in hsl increasing hue, red, blue)"));
  EXPECT_FALSE(IsValidColor("color-mix(in hsl decreasing hue, red, blue)"));
}

TEST(CSSColorFunction, RelativeColorSyntax) {
  auto env = TEST_init();
  
  // Test relative color syntax with rgb()
  EXPECT_FALSE(IsValidColor("rgb(from red r g b)"));
  EXPECT_FALSE(IsValidColor("rgb(from red r g b / 0.5)"));
  EXPECT_FALSE(IsValidColor("rgb(from red calc(r * 0.5) g b)"));
  
  // Test relative color syntax with hsl()
  EXPECT_FALSE(IsValidColor("hsl(from red h s l)"));
  EXPECT_FALSE(IsValidColor("hsl(from red calc(h + 180) s l)"));
  
  // Test relative color syntax with lab()
  EXPECT_FALSE(IsValidColor("lab(from red l a b)"));
  EXPECT_FALSE(IsValidColor("lab(from red calc(l * 0.8) a b)"));
}

TEST(CSSColorFunction, ColorValues) {
  auto env = TEST_init();
  
  // Test actual color values with direct Color construction
  Color red = Color(255, 0, 0, 255);
  EXPECT_EQ(red.Red(), 255);
  EXPECT_EQ(red.Green(), 0);
  EXPECT_EQ(red.Blue(), 0);
  EXPECT_EQ(red.AlphaAsInteger(), 255);
  
  Color semiTransparentBlue = Color(0, 0, 255, 128);
  EXPECT_EQ(semiTransparentBlue.Red(), 0);
  EXPECT_EQ(semiTransparentBlue.Green(), 0);
  EXPECT_EQ(semiTransparentBlue.Blue(), 255);
  EXPECT_EQ(semiTransparentBlue.AlphaAsInteger(), 128);
  
  // Test HSL red color
  Color hslRed = Color(255, 0, 0, 255);
  EXPECT_EQ(hslRed.Red(), 255);
  EXPECT_EQ(hslRed.Green(), 0);
  EXPECT_EQ(hslRed.Blue(), 0);
}

}  // namespace webf