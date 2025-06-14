// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_PLATFORM_GRAPHICS_COLOR_CONVERSIONS_H_
#define WEBF_CORE_PLATFORM_GRAPHICS_COLOR_CONVERSIONS_H_

#include "core/platform/graphics/SkColor.h"

namespace webf {

// All the methods below are exposed for blink::color conversions.

std::tuple<float, float, float> SRGBToSRGBLegacy(float r, float g, float b);

std::tuple<float, float, float> SRGBLegacyToSRGB(float r, float g, float b);

std::tuple<float, float, float> HSLToSRGB(float h, float s, float l);
std::tuple<float, float, float> SRGBToHSL(float r, float g, float b);

std::tuple<float, float, float> HWBToSRGB(float h, float w, float b);
std::tuple<float, float, float> SRGBToHWB(float r, float g, float b);

SkColor4f HSLToSkColor4f(float h, float s, float l, float alpha);

SkColor4f HWBToSkColor4f(float h, float w, float b, float alpha);

}  // namespace webf

#endif  // WEBF_CORE_PLATFORM_GRAPHICS_COLOR_CONVERSIONS_H_
