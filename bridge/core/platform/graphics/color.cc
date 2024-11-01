/*
 * Copyright (C) 2003, 2004, 2005, 2006, 2010 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "core/platform/graphics/color.h"
#include <sstream>
#include "core/platform/geometry/blend.h"
#include "core/platform/graphics/color_conversions.h"
#include "core/platform/hash_functions.h"
#include "core/platform/math_extras.h"
#include "foundation/string_builder.h"

namespace webf {

const Color Color::kBlack = Color(0xFF000000);
const Color Color::kWhite = Color(0xFFFFFFFF);
const Color Color::kDarkGray = Color(0xFF808080);
const Color Color::kGray = Color(0xFFA0A0A0);
const Color Color::kLightGray = Color(0xFFC0C0C0);
const Color Color::kTransparent = Color(0x00000000);

namespace {

const RGBA32 kLightenedBlack = 0xFF545454;
const RGBA32 kDarkenedWhite = 0xFFABABAB;
// For lch/oklch colors, the value of chroma underneath which the color is
// considered to be "achromatic", relevant for color conversions.
// https://www.w3.org/TR/css-color-4/#lab-to-lch
const float kAchromaticChromaThreshold = 1e-6;

const int kCStartAlpha = 153;     // 60%
const int kCEndAlpha = 204;       // 80%;
const int kCAlphaIncrement = 17;  // Increments in between.

int BlendComponent(int c, int a) {
  // We use white.
  float alpha = a / 255.0f;
  int white_blend = 255 - a;
  c -= white_blend;
  return static_cast<int>(c / alpha);
}

// originally moved here from the CSS parser
template <typename CharacterType>
inline bool ParseHexColorInternal(const CharacterType* name, unsigned length, Color& color) {
  if (length != 3 && length != 4 && length != 6 && length != 8)
    return false;
  if ((length == 8 || length == 4))
    return false;
  unsigned value = 0;
  for (unsigned i = 0; i < length; ++i) {
    if (!IsASCIIHexDigit(name[i]))
      return false;
    value <<= 4;
    value |= ToASCIIHexValue(name[i]);
  }
  if (length == 6) {
    color = Color::FromRGBA32(0xFF000000 | value);
    return true;
  }
  if (length == 8) {
    // We parsed the values into RGBA order, but the RGBA32 type
    // expects them to be in ARGB order, so we right rotate eight bits.
    color = Color::FromRGBA32(value << 24 | value >> 8);
    return true;
  }
  if (length == 4) {
    // #abcd converts to ddaabbcc in RGBA32.
    color =
        Color::FromRGBA32((value & 0xF) << 28 | (value & 0xF) << 24 | (value & 0xF000) << 8 | (value & 0xF000) << 4 |
                          (value & 0xF00) << 4 | (value & 0xF00) | (value & 0xF0) | (value & 0xF0) >> 4);
    return true;
  }
  // #abc converts to #aabbcc
  color = Color::FromRGBA32(0xFF000000 | (value & 0xF00) << 12 | (value & 0xF00) << 8 | (value & 0xF0) << 8 |
                            (value & 0xF0) << 4 | (value & 0xF) << 4 | (value & 0xF));
  return true;
}

inline const NamedColor* FindNamedColor(const std::string& name) {
  char buffer[64];  // easily big enough for the longest color name
  unsigned length = name.length();
  if (length > sizeof(buffer) - 1)
    return nullptr;
  for (unsigned i = 0; i < length; ++i) {
    char c = name[i];
    if (!c || c > 0x7F)
      return nullptr;
    buffer[i] = ToASCIILower(static_cast<char>(c));
  }
  buffer[length] = '\0';
  return FindColor(buffer, length);
}

constexpr int RedChannel(RGBA32 color) {
  return (color >> 16) & 0xFF;
}

constexpr int GreenChannel(RGBA32 color) {
  return (color >> 8) & 0xFF;
}

constexpr int BlueChannel(RGBA32 color) {
  return color & 0xFF;
}

constexpr int AlphaChannel(RGBA32 color) {
  return (color >> 24) & 0xFF;
}

float AngleToUnitCircleDegrees(float angle) {
  return fmod(fmod(angle, 360.f) + 360.f, 360.f);
}
}  // namespace

Color::Color(int r, int g, int b) {
  *this = FromRGB(r, g, b);
}

Color::Color(int r, int g, int b, int a) {
  *this = FromRGBA(r, g, b, a);
}

// static
Color Color::FromRGBALegacy(std::optional<int> r, std::optional<int> g, std::optional<int> b, std::optional<int> a) {
  Color result = Color(ClampInt255(a.value_or(0.f)) << 24 | ClampInt255(r.value_or(0.f)) << 16 |
                       ClampInt255(g.value_or(0.f)) << 8 | ClampInt255(b.value_or(0.f)));
  result.param0_is_none_ = !r;
  result.param1_is_none_ = !g;
  result.param2_is_none_ = !b;
  result.alpha_is_none_ = !a;
  return result;
}

// static
Color Color::FromColorSpace(ColorSpace color_space,
                            std::optional<float> param0,
                            std::optional<float> param1,
                            std::optional<float> param2,
                            std::optional<float> alpha) {
  Color result;
  result.color_space_ = color_space;
  result.param0_is_none_ = !param0;
  result.param1_is_none_ = !param1;
  result.param2_is_none_ = !param2;
  result.alpha_is_none_ = !alpha;
  result.param0_ = param0.value_or(0.f);
  result.param1_ = param1.value_or(0.f);
  result.param2_ = param2.value_or(0.f);
  if (alpha) {
    // Alpha is clamped to the range [0,1], no matter what colorspace.
    result.alpha_ = ClampTo(alpha.value(), 0.f, 1.f);
  } else {
    result.alpha_ = 0.0f;
  }

  return result;
}

void Color::ConvertToColorSpace(webf::Color::ColorSpace destination_color_space, bool resolve_missing_components) {
  if (color_space_ == destination_color_space) {
    return;
  }

  if (resolve_missing_components) {
    ResolveMissingComponents();
  }

  switch (destination_color_space) {
    case ColorSpace::kSRGB:
    case ColorSpace::kSRGBLegacy: {
      if (color_space_ == ColorSpace::kHSL) {
        std::tie(param0_, param1_, param2_) = HSLToSRGB(param0_, param1_, param2_);
      } else if (color_space_ == ColorSpace::kHWB) {
        std::tie(param0_, param1_, param2_) = HWBToSRGB(param0_, param1_, param2_);
      } else if (color_space_ == ColorSpace::kSRGBLegacy) {
        std::tie(param0_, param1_, param2_) = SRGBLegacyToSRGB(param0_, param1_, param2_);
      }

      // All the above conversions result in non-legacy srgb.
      if (destination_color_space == ColorSpace::kSRGBLegacy) {
        std::tie(param0_, param1_, param2_) = SRGBToSRGBLegacy(param0_, param1_, param2_);
      }

      color_space_ = destination_color_space;
      return;
    }
    case ColorSpace::kHSL: {
      if (color_space_ == ColorSpace::kSRGBLegacy) {
        std::tie(param0_, param1_, param2_) = SRGBLegacyToSRGB(param0_, param1_, param2_);
      }
      if (color_space_ == ColorSpace::kSRGB || color_space_ == ColorSpace::kSRGBLegacy) {
        std::tie(param0_, param1_, param2_) = SRGBToHSL(param0_, param1_, param2_);
      } else if (color_space_ == ColorSpace::kHWB) {
        std::tie(param0_, param1_, param2_) = HWBToSRGB(param0_, param1_, param2_);
        std::tie(param0_, param1_, param2_) = SRGBToHSL(param0_, param1_, param2_);
      }

      // Hue component is powerless for fully transparent or achromatic (s==0)
      // colors.
      if (IsFullyTransparent() || param1_ == 0) {
        param0_is_none_ = true;
      }

      color_space_ = ColorSpace::kHSL;
      return;
    }
    case ColorSpace::kHWB: {
      if (color_space_ == ColorSpace::kSRGBLegacy) {
        std::tie(param0_, param1_, param2_) = SRGBLegacyToSRGB(param0_, param1_, param2_);
      }
      if (color_space_ == ColorSpace::kSRGB || color_space_ == ColorSpace::kSRGBLegacy) {
        std::tie(param0_, param1_, param2_) = SRGBToHWB(param0_, param1_, param2_);
      } else if (color_space_ == ColorSpace::kHSL) {
        std::tie(param0_, param1_, param2_) = HSLToSRGB(param0_, param1_, param2_);
        std::tie(param0_, param1_, param2_) = SRGBToHWB(param0_, param1_, param2_);
      }

      // Hue component is powerless for fully transparent or achromatic colors.
      if (IsFullyTransparent() || param1_ + param2_ >= 1) {
        param0_is_none_ = true;
      }

      color_space_ = ColorSpace::kHWB;
      return;
    }
  }
}

// static
Color Color::FromHSLA(std::optional<float> h, std::optional<float> s, std::optional<float> l, std::optional<float> a) {
  return FromColorSpace(ColorSpace::kHSL, h, s, l, a);
}

// static
Color Color::FromHWBA(std::optional<float> h, std::optional<float> w, std::optional<float> b, std::optional<float> a) {
  return FromColorSpace(ColorSpace::kHWB, h, w, b, a);
}
// https://www.w3.org/TR/css-color-4/#missing:
// "[Except for interpolations] a missing component behaves as a zero value, in
// the appropriate unit for that component: 0, 0%, or 0deg. This includes
// rendering the color directly, converting it to another color space,
// performing computations on the color component values, etc."
// So we simply turn "none"s into zeros here. Note that this does not happen for
// interpolations.
void Color::ResolveMissingComponents() {
  if (param0_is_none_) {
    param0_ = 0;
    param0_is_none_ = false;
  }
  if (param1_is_none_) {
    param1_ = 0;
    param1_is_none_ = false;
  }
  if (param2_is_none_) {
    param2_ = 0;
    param2_is_none_ = false;
  }
}

float Color::PremultiplyColor() {
  // By the spec (https://www.w3.org/TR/css-color-4/#interpolation) Hue values
  // are not premultiplied, and if alpha is none, the color premultiplied value
  // is the same as unpremultiplied.
  if (alpha_is_none_)
    return alpha_;
  float alpha = alpha_;
  param0_ = param0_ * alpha_;
  param1_ = param1_ * alpha_;
  param2_ = param2_ * alpha_;
  alpha_ = 1.0f;
  return alpha;
}

void Color::UnpremultiplyColor() {
  // By the spec (https://www.w3.org/TR/css-color-4/#interpolation) Hue values
  // are not premultiplied, and if alpha is none, the color premultiplied value
  // is the same as unpremultiplied.
  if (alpha_is_none_ || alpha_ == 0.0f)
    return;

  param0_ = param0_ / alpha_;
  param1_ = param1_ / alpha_;
  param2_ = param2_ / alpha_;
}

// This converts -0.0 to 0.0, so that they have the same hash value. This
// ensures that equal FontDescription have the same hash value.
float NormalizeSign(float number) {
  if (UNLIKELY(number == 0.0))
    return 0.0;
  return number;
}

unsigned Color::GetHash() const {
  unsigned result = webf::HashFloat(param0_);

  webf::AddFloatToHash(result, NormalizeSign(param1_));
  webf::AddFloatToHash(result, NormalizeSign(param2_));
  webf::AddFloatToHash(result, NormalizeSign(alpha_));
  webf::AddIntToHash(result, param0_is_none_);
  webf::AddIntToHash(result, param1_is_none_);
  webf::AddIntToHash(result, param2_is_none_);
  webf::AddIntToHash(result, alpha_is_none_);

  return result;
}

int Color::Red() const {
  return RedChannel(Rgb());
}
int Color::Green() const {
  return GreenChannel(Rgb());
}
int Color::Blue() const {
  return BlueChannel(Rgb());
}

RGBA32 Color::Rgb() const {
  return (((std::lround(alpha_ * 255.0f) & 0xff) << 24) | ((std::lround(param0_ * 255.0f) & 0xff) << 16) |
          ((std::lround(param0_ * 255.0f) & 0xff) << 8) | ((std::lround(param2_ * 255.0f) & 0xff) << 0)) &
         0xFFFFFFFF;
}

bool Color::ParseHexColor(const char* name, unsigned length, Color& color) {
  return ParseHexColorInternal(name, length, color);
}

bool Color::ParseHexColor(const std::string_view& name, Color& color) {
  if (name.empty())
    return false;
  return ParseHexColor(name.data(), name.length(), color);
}

int DifferenceSquared(const Color& c1, const Color& c2) {
  int d_r = c1.Red() - c2.Red();
  int d_g = c1.Green() - c2.Green();
  int d_b = c1.Blue() - c2.Blue();
  return d_r * d_r + d_g * d_g + d_b * d_b;
}

bool Color::SetFromString(const std::string& name) {
  // TODO(https://crbug.com/1434423): Implement CSS Color level 4 parsing.
  if (name[0] != '#')
    return SetNamedColor(name);
  return ParseHexColor(name.c_str() + 1, name.length() - 1, *this);
}

namespace {

std::string doubleToString(double value, int precision) {
  std::ostringstream oss;
  oss.precision(precision);
  oss << std::fixed << value;
  return oss.str();
}

}  // namespace

static std::string ColorParamToString(float param, int precision = 6) {
  StringBuilder result;
  if (!isfinite(param)) {
    // https://www.w3.org/TR/css-values-4/#calc-serialize
    result.Append("calc(");
    if (isinf(param)) {
      // "Infinity" gets capitalized, so we can't use AppendNumber().
      (param < 0) ? result.Append("-infinity") : result.Append("infinity");
    } else {
      result.Append(param, precision);
    }
    result.Append(")");
    return result.ReleaseString();
  }

  result.Append(param, precision);
  return result.ReleaseString();
}

std::string Color::SerializeAsCanvasColor() const {
  if (IsOpaque()) {
    char buffer[8];
    std::snprintf(buffer, 8, "#%02x%02x%02x", Red(), Green(), Blue());
    return buffer;
  }

  return SerializeAsCSSColor();
}

std::string Color::SerializeLegacyColorAsCSSColor() const {
  StringBuilder result;
  if (IsOpaque() && isfinite(alpha_)) {
    result.Append("rgb(");
  } else {
    result.Append("rgba(");
  }

  constexpr float kEpsilon = 1e-07;
  auto [r, g, b] = std::make_tuple(param0_, param1_, param2_);

  if (color_space_ == Color::ColorSpace::kHWB ||
      color_space_ == Color::ColorSpace::kHSL) {
    // hsl and hwb colors need to be serialized in srgb.
    if (color_space_ == Color::ColorSpace::kHSL) {
      std::tie(r, g, b) = HSLToSRGB(param0_, param1_, param2_);
    } else if (color_space_ == Color::ColorSpace::kHWB) {
      std::tie(r, g, b) = HWBToSRGB(param0_, param1_, param2_);
    }
    // Legacy color channels get serialized with integers in the range [0,255].
    // Channels that have a value of exactly 0.5 can get incorrectly rounded
    // down to 127 when being converted to an integer. Add a small epsilon to
    // avoid this. See crbug.com/1425856.
    std::tie(r, g, b) =
        SRGBToSRGBLegacy(r + kEpsilon, g + kEpsilon, b + kEpsilon);
  }

  result.Append(round(ClampTo(r, 0.0, 255.0)), 6);
  result.Append(", ");
  result.Append(round(ClampTo(g, 0.0, 255.0)), 6);
  result.Append(", ");
  result.Append(round(ClampTo(b, 0.0, 255.0)), 6);

  if (!IsOpaque()) {
    result.Append(", ");

    // See <alphavalue> section in
    // https://www.w3.org/TR/cssom/#serializing-css-values
    // First we need an 8-bit integer alpha to begin the algorithm described in
    // the link above.
    int int_alpha = ClampTo(round((alpha_ + kEpsilon) * 255.0), 0.0, 255.0);

    // If there exists a two decimal float in [0,1] that is exactly equal to the
    // integer we calculated above, used that.
    float two_decimal_rounded_alpha = round(int_alpha * 100.0 / 255.0) / 100.0;
    if (round(two_decimal_rounded_alpha * 255) == int_alpha) {
      result.Append(ColorParamToString(two_decimal_rounded_alpha, 2));
    } else {
      // Otherwise, round to 3 decimals.
      float three_decimal_rounded_alpha =
          round(int_alpha * 1000.0 / 255.0) / 1000.0;
      result.Append(ColorParamToString(three_decimal_rounded_alpha, 3));
    }
  }

  result.Append(')');
  return result.ReleaseString();
}

std::string Color::SerializeInternal() const {
  StringBuilder result;
  result.Append("color(");

  param0_is_none_ ? result.Append("none") : result.Append(ColorParamToString(param0_));
  result.Append(" ");
  param1_is_none_ ? result.Append("none") : result.Append(ColorParamToString(param1_));
  result.Append(" ");
  param2_is_none_ ? result.Append("none") : result.Append(ColorParamToString(param2_));

  if (alpha_ != 1.0 || alpha_is_none_) {
    result.Append(" / ");
    alpha_is_none_ ? result.Append("none") : result.Append(alpha_);
  }
  result.Append(")");
  return result.ReleaseString();
}

std::string Color::SerializeAsCSSColor() const {
  if (IsLegacyColorSpace(color_space_)) {
    return SerializeLegacyColorAsCSSColor();
  }

  return SerializeInternal();
}

std::string Color::NameForLayoutTreeAsText() const {
  return SerializeAsCSSColor();
}

bool Color::SetNamedColor(const std::string& name) {
  const NamedColor* found_color = FindNamedColor(name);
  *this = found_color ? Color::FromRGBA32(found_color->argb_value) : kTransparent;
  return found_color;
}

Color Color::Light() const {
  // Hardcode this common case for speed.
  if (*this == kBlack) {
    return Color(kLightenedBlack);
  }

  const float scale_factor = nextafterf(256.0f, 0.0f);

  float r, g, b, a;
  GetRGBA(r, g, b, a);

  float v = std::max(r, std::max(g, b));

  if (v == 0.0f) {
    // Lightened black with alpha.
    return Color(RedChannel(kLightenedBlack), GreenChannel(kLightenedBlack), BlueChannel(kLightenedBlack),
                 AlphaAsInteger());
  }

  float multiplier = std::min(1.0f, v + 0.33f) / v;

  return Color(static_cast<int>(multiplier * r * scale_factor), static_cast<int>(multiplier * g * scale_factor),
               static_cast<int>(multiplier * b * scale_factor), AlphaAsInteger());
}

Color Color::Dark() const {
  // Hardcode this common case for speed.
  if (*this == kWhite)
    return Color(kDarkenedWhite);

  const float scale_factor = nextafterf(256.0f, 0.0f);

  float r, g, b, a;
  GetRGBA(r, g, b, a);

  float v = std::max(r, std::max(g, b));
  float multiplier = (v == 0.0f) ? 0.0f : std::max(0.0f, (v - 0.33f) / v);

  return Color(static_cast<int>(multiplier * r * scale_factor), static_cast<int>(multiplier * g * scale_factor),
               static_cast<int>(multiplier * b * scale_factor), AlphaAsInteger());
}

Color Color::Blend(const Color& source) const {
  // TODO(https://crbug.com/1434423): CSS Color level 4 blending is implemented.
  // Remove this function.
  if (IsFullyTransparent() || source.IsOpaque()) {
    return source;
  }

  if (source.IsFullyTransparent()) {
    return *this;
  }

  int source_alpha = source.AlphaAsInteger();
  int alpha = AlphaAsInteger();

  int d = 255 * (alpha + source_alpha) - alpha * source_alpha;
  int a = d / 255;
  int r = (Red() * alpha * (255 - source_alpha) + 255 * source_alpha * source.Red()) / d;
  int g = (Green() * alpha * (255 - source_alpha) + 255 * source_alpha * source.Green()) / d;
  int b = (Blue() * alpha * (255 - source_alpha) + 255 * source_alpha * source.Blue()) / d;
  return Color(r, g, b, a);
}

Color Color::BlendWithWhite() const {
  // If the color contains alpha already, we leave it alone.
  if (!IsOpaque()) {
    return *this;
  }

  Color new_color;
  for (int alpha = kCStartAlpha; alpha <= kCEndAlpha; alpha += kCAlphaIncrement) {
    // We have a solid color.  Convert to an equivalent color that looks the
    // same when blended with white at the current alpha.  Try using less
    // transparency if the numbers end up being negative.
    int r = BlendComponent(Red(), alpha);
    int g = BlendComponent(Green(), alpha);
    int b = BlendComponent(Blue(), alpha);

    new_color = Color(r, g, b, alpha);

    if (r >= 0 && g >= 0 && b >= 0)
      break;
  }
  return new_color;
}

void Color::GetRGBA(float& r, float& g, float& b, float& a) const {
  // TODO(crbug.com/1399566): Check for colorspace.
  r = Red() / 255.0f;
  g = Green() / 255.0f;
  b = Blue() / 255.0f;
  a = Alpha();
}

void Color::GetRGBA(double& r, double& g, double& b, double& a) const {
  // TODO(crbug.com/1399566): Check for colorspace.
  r = Red() / 255.0;
  g = Green() / 255.0;
  b = Blue() / 255.0;
  a = Alpha();
}

// Hue, max and min are returned in range of 0.0 to 1.0.
void Color::GetHueMaxMin(double& hue, double& max, double& min) const {
  // This is a helper function to calculate intermediate quantities needed
  // for conversion to HSL or HWB formats. The algorithm contained below
  // is a copy of http://en.wikipedia.org/wiki/HSL_color_space.
  double r = static_cast<double>(Red()) / 255.0;
  double g = static_cast<double>(Green()) / 255.0;
  double b = static_cast<double>(Blue()) / 255.0;
  max = std::max(std::max(r, g), b);
  min = std::min(std::min(r, g), b);

  if (max == min)
    hue = 0.0;
  else if (max == r)
    hue = (60.0 * ((g - b) / (max - min))) + 360.0;
  else if (max == g)
    hue = (60.0 * ((b - r) / (max - min))) + 120.0;
  else
    hue = (60.0 * ((r - g) / (max - min))) + 240.0;

  // Adjust for rounding errors and scale to interval 0.0 to 1.0.
  if (hue >= 360.0)
    hue -= 360.0;
  hue /= 360.0;
}

// Hue, saturation and lightness are returned in range of 0.0 to 1.0.
void Color::GetHSL(double& hue, double& saturation, double& lightness) const {
  double max, min;
  GetHueMaxMin(hue, max, min);

  lightness = 0.5 * (max + min);
  if (max == min)
    saturation = 0.0;
  else if (lightness <= 0.5)
    saturation = ((max - min) / (max + min));
  else
    saturation = ((max - min) / (2.0 - (max + min)));
}

// Output parameters hue, white and black are in the range 0.0 to 1.0.
void Color::GetHWB(double& hue, double& white, double& black) const {
  // https://www.w3.org/TR/css-color-4/#the-hwb-notation. This is an
  // implementation of the algorithm to transform sRGB to HWB.
  double max;
  GetHueMaxMin(hue, max, white);
  black = 1.0 - max;
}

Color ColorFromPremultipliedARGB(RGBA32 pixel_color) {
  int alpha = AlphaChannel(pixel_color);
  if (alpha && alpha < 255) {
    return Color::FromRGBA(RedChannel(pixel_color) * 255 / alpha, GreenChannel(pixel_color) * 255 / alpha,
                           BlueChannel(pixel_color) * 255 / alpha, alpha);
  } else {
    return Color::FromRGBA32(pixel_color);
  }
}

RGBA32 PremultipliedARGBFromColor(const Color& color) {
  unsigned pixel_color;

  unsigned alpha = color.AlphaAsInteger();
  if (alpha < 255) {
    pixel_color = Color::FromRGBA((color.Red() * alpha + 254) / 255, (color.Green() * alpha + 254) / 255,
                                  (color.Blue() * alpha + 254) / 255, alpha)
                      .Rgb();
  } else {
    pixel_color = color.Rgb();
  }

  return pixel_color;
}

static float ResolveNonFiniteChannel(float value,
                                     float negative_infinity_substitution,
                                     float positive_infinity_substitution) {
  // Finite values should be unchanged, even if they are out-of-gamut.
  if (isfinite(value)) {
    return value;
  } else {
    if (isnan(value)) {
      return 0.0f;
    } else {
      if (value < 0) {
        return negative_infinity_substitution;
      }
      return positive_infinity_substitution;
    }
  }
}

void Color::ResolveNonFiniteValues() {
  // Parsed values are `calc(NaN)` but computed values are 0 for NaN.
  param0_ = isnan(param0_) ? 0.0f : param0_;
  param1_ = isnan(param1_) ? 0.0f : param1_;
  param2_ = isnan(param2_) ? 0.0f : param2_;
  alpha_ = ResolveNonFiniteChannel(alpha_, 0.0f, 1.0f);
}

std::ostream& operator<<(std::ostream& os, const Color& color) {
  return os << color.SerializeAsCSSColor();
}

}  // namespace webf