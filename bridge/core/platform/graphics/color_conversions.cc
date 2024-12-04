// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "color_conversions.h"
#include <tuple>
#include "core/base/numerics/angle_conversion.h"

namespace webf {

// Namespace containing some of the helper methods for color conversions.
namespace {

// NOTE: SkFixedToFloat is exact. SkFloatToFixed seems to lack a rounding step. For all fixed-point
// values, this version is as accurate as possible for (fixed -> float -> fixed). Rounding reduces
// accuracy if the intermediate floats are in the range that only holds integers (adding 0.5f to an
// odd integer then snaps to nearest even). Using double for the rounding math gives maximum
// accuracy for (float -> fixed -> float), but that's usually overkill.
#define SkFixedToFloat(x) ((x)*1.52587890625e-5f)

typedef struct {
  float vals[2];
} skcms_Vector2;

float dot(const skcms_Vector2& a, const skcms_Vector2& b) {
  return a.vals[0] * b.vals[0] + a.vals[1] * b.vals[1];
}

}  // namespace

std::tuple<float, float, float> SRGBToSRGBLegacy(float r, float g, float b) {
  return std::make_tuple(r * 255.0, g * 255.0, b * 255.0);
}

std::tuple<float, float, float> SRGBLegacyToSRGB(float r, float g, float b) {
  return std::make_tuple(r / 255.0, g / 255.0, b / 255.0);
}

std::tuple<float, float, float> HSLToSRGB(float h, float s, float l) {
  // See https://www.w3.org/TR/css-color-4/#hsl-to-rgb
  if (!s) {
    return std::make_tuple(l, l, l);
  }

  auto f = [&h, &l, &s](float n) {
    float k = fmod(n + h / 30.0f, 12.0);
    float a = s * std::min(l, 1.0f - l);
    return l - a * std::max(-1.0f, std::min({k - 3.0f, 9.0f - k, 1.0f}));
  };

  return std::make_tuple(f(0), f(8), f(4));
}

std::tuple<float, float, float> SRGBToHSL(float r, float g, float b) {
  // See https://www.w3.org/TR/css-color-4/#rgb-to-hsl
  float max = std::max({r, g, b});
  float min = std::min({r, g, b});
  float hue = 0.0f, saturation = 0.0f, ligth = (max + min) / 2.0f;
  float d = max - min;

  if (d != 0.0f) {
    saturation = (ligth == 0.0f || ligth == 1.0f) ? 0.0f : (max - ligth) / std::min(ligth, 1 - ligth);
    if (max == r) {
      hue = (g - b) / d + (g < b ? 6.0f : 0.0f);
    } else if (max == g) {
      hue = (b - r) / d + 2.0f;
    } else {  // if(max == b)
      hue = (r - g) / d + 4.0f;
    }
    hue *= 60.0f;
  }

  return std::make_tuple(hue, saturation, ligth);
}

std::tuple<float, float, float> HWBToSRGB(float h, float w, float b) {
  if (w + b >= 1.0f) {
    float gray = (w / (w + b));
    return std::make_tuple(gray, gray, gray);
  }

  // Leverage HSL to RGB conversion to find HWB to RGB, see
  // https://drafts.csswg.org/css-color-4/#hwb-to-rgb
  auto [red, green, blue] = HSLToSRGB(h, 1.0f, 0.5f);

  red += w - (w + b) * red;
  green += w - (w + b) * green;
  blue += w - (w + b) * blue;

  return std::make_tuple(red, green, blue);
}

std::tuple<float, float, float> SRGBToHWB(float r, float g, float b) {
  // Leverage RGB to HSL conversion to find RGB to HWB, see
  // https://www.w3.org/TR/css-color-4/#rgb-to-hwb
  auto [hue, saturation, light] = SRGBToHSL(r, g, b);
  float white = std::min({r, g, b});
  float black = 1.0f - std::max({r, g, b});

  return std::make_tuple(hue, white, black);
}

SkColor4f HSLToSkColor4f(float h, float s, float l, float alpha) {
  auto [r, g, b] = HSLToSRGB(h, s, l);
  return SkColor4f{r, g, b, alpha};
}

SkColor4f HWBToSkColor4f(float h, float w, float b, float alpha) {
  auto [red, green, blue] = HWBToSRGB(h, w, b);
  return SkColor4f{red, green, blue, alpha};
}

}  // namespace webf