// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "media_values.h"
#include <cassert>

namespace webf {

std::optional<double> MediaValues::InlineSize() const {
  if (webf::IsHorizontalWritingMode(GetWritingMode())) {
    return Width();
  }
  return Height();
}

std::optional<double> MediaValues::BlockSize() const {
  if (webf::IsHorizontalWritingMode(GetWritingMode())) {
    return Height();
  }
  return Width();
}

MediaValues* MediaValues::CreateDynamicIfFrameExists(ExecutingContext* context) {
//  if (frame) {
//    return MediaValuesDynamic::Create(frame);
//  }
//  return MakeGarbageCollected<MediaValuesCached>();
  assert(false);
  return nullptr;
}

double MediaValues::CalculateViewportWidth(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->View());
//  DCHECK(frame->GetDocument());
//  return frame->View()->ViewportSizeForMediaQueries().width();
  assert(false);
}

double MediaValues::CalculateViewportHeight(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->View());
//  DCHECK(frame->GetDocument());
//  return frame->View()->ViewportSizeForMediaQueries().height();
assert(false);
return 0;
}

double MediaValues::CalculateSmallViewportWidth(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->View());
//  DCHECK(frame->GetDocument());
//  return frame->View()->SmallViewportSizeForViewportUnits().width();
assert(false);
return 0;
}

double MediaValues::CalculateSmallViewportHeight(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->View());
//  DCHECK(frame->GetDocument());
//  return frame->View()->SmallViewportSizeForViewportUnits().height();
assert(false);
}

double MediaValues::CalculateLargeViewportWidth(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->View());
//  DCHECK(frame->GetDocument());
//  return frame->View()->LargeViewportSizeForViewportUnits().width();
assert(false);
}

double MediaValues::CalculateLargeViewportHeight(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->View());
//  DCHECK(frame->GetDocument());
//  return frame->View()->LargeViewportSizeForViewportUnits().height();
assert(false);
}

double MediaValues::CalculateDynamicViewportWidth(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->View());
//  DCHECK(frame->GetDocument());
//  return frame->View()->DynamicViewportSizeForViewportUnits().width();
assert(false);
}

double MediaValues::CalculateDynamicViewportHeight(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->View());
//  DCHECK(frame->GetDocument());
//  return frame->View()->DynamicViewportSizeForViewportUnits().height();
assert(false);
}

int MediaValues::CalculateDeviceWidth(ExecutingContext* frame) {
//  DCHECK(frame && frame->View() && frame->GetSettings() && frame->GetPage());
//  const display::ScreenInfo& screen_info =
//      frame->GetPage()->GetChromeClient().GetScreenInfo(*frame);
//  int device_width = screen_info.rect.width();
//  if (frame->GetSettings()->GetReportScreenSizeInPhysicalPixelsQuirk()) {
//    device_width = static_cast<int>(
//        lroundf(device_width * screen_info.device_scale_factor));
//  }
//  return device_width;
assert(false);
}

int MediaValues::CalculateDeviceHeight(ExecutingContext* frame) {
//  DCHECK(frame && frame->View() && frame->GetSettings() && frame->GetPage());
//  const display::ScreenInfo& screen_info =
//      frame->GetPage()->GetChromeClient().GetScreenInfo(*frame);
//  int device_height = screen_info.rect.height();
//  if (frame->GetSettings()->GetReportScreenSizeInPhysicalPixelsQuirk()) {
//    device_height = static_cast<int>(
//        lroundf(device_height * screen_info.device_scale_factor));
//  }
//  return device_height;
assert(false);
}

bool MediaValues::CalculateStrictMode(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetDocument());
//  return !frame->GetDocument()->InQuirksMode();
assert(false);
}

float MediaValues::CalculateDevicePixelRatio(ExecutingContext* frame) {
//  return frame->DevicePixelRatio();
assert(false);
}

bool MediaValues::CalculateDeviceSupportsHDR(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetPage());
//  return frame->GetPage()
//      ->GetChromeClient()
//      .GetScreenInfo(*frame)
//      .display_color_spaces.SupportsHDR();
assert(false);
}

int MediaValues::CalculateColorBitsPerComponent(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetPage());
//  const display::ScreenInfo& screen_info =
//      frame->GetPage()->GetChromeClient().GetScreenInfo(*frame);
//  if (screen_info.is_monochrome) {
//    return 0;
//  }
//  return screen_info.depth_per_component;
assert(false);
}

int MediaValues::CalculateMonochromeBitsPerComponent(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetPage());
//  const display::ScreenInfo& screen_info =
//      frame->GetPage()->GetChromeClient().GetScreenInfo(*frame);
//  if (!screen_info.is_monochrome) {
//    return 0;
//  }
//  return screen_info.depth_per_component;
assert(false);
}

bool MediaValues::CalculateInvertedColors(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetSettings());
//  return frame->GetSettings()->GetInvertedColors();
assert(false);
}

float MediaValues::CalculateEmSize(ExecutingContext* frame) {
//  CHECK(frame);
//  CHECK(frame->ContentLayoutObject());
//  const ComputedStyle& style = frame->ContentLayoutObject()->StyleRef();
//  return CSSToLengthConversionData::FontSizes(style.GetFontSizeStyle(), &style)
//      .Em(/* zoom */ 1.0f);
assert(false);
}

float MediaValues::CalculateExSize(ExecutingContext* frame) {
//  CHECK(frame);
//  CHECK(frame->ContentLayoutObject());
//  const ComputedStyle& style = frame->ContentLayoutObject()->StyleRef();
//  return CSSToLengthConversionData::FontSizes(style.GetFontSizeStyle(), &style)
//      .Ex(/* zoom */ 1.0f);
assert(false);
}

float MediaValues::CalculateChSize(ExecutingContext* frame) {
//  CHECK(frame);
//  CHECK(frame->ContentLayoutObject());
//  const ComputedStyle& style = frame->ContentLayoutObject()->StyleRef();
//  return CSSToLengthConversionData::FontSizes(style.GetFontSizeStyle(), &style)
//      .Ch(/* zoom */ 1.0f);
assert(false);
}

float MediaValues::CalculateIcSize(ExecutingContext* frame) {
//  CHECK(frame);
//  CHECK(frame->ContentLayoutObject());
//  const ComputedStyle& style = frame->ContentLayoutObject()->StyleRef();
//  return CSSToLengthConversionData::FontSizes(style.GetFontSizeStyle(), &style)
//      .Ic(/* zoom */ 1.0f);
assert(false);
}

float MediaValues::CalculateCapSize(ExecutingContext* frame) {
//  CHECK(frame);
//  CHECK(frame->ContentLayoutObject());
//  const ComputedStyle& style = frame->ContentLayoutObject()->StyleRef();
//  return CSSToLengthConversionData::FontSizes(style.GetFontSizeStyle(), &style)
//      .Cap(/* zoom */ 1.0f);
assert(false);
}

float MediaValues::CalculateLineHeight(ExecutingContext* frame) {
//  CHECK(frame);
//  CHECK(frame->ContentLayoutObject());
//  const ComputedStyle& style = frame->ContentLayoutObject()->StyleRef();
//  return AdjustForAbsoluteZoom::AdjustFloat(style.ComputedLineHeight(), style);
assert(false);
}

bool MediaValues::CalculateResizable(ExecutingContext* frame) {
//  DCHECK(frame);
//
//  bool resizable = frame->GetPage()->GetSettings().GetResizable();
//  // Initial state set in /third_party/blink/renderer/core/frame/settings.json5
//  // should match with this.
//  if (!resizable) {
//    // Only non-default value should be returned "early" from the settings
//    // without checking from widget. Settings are only used for testing.
//    return resizable;
//  }
//
//  FrameWidget* widget = frame->GetWidgetForLocalRoot();
//  if (!widget) {
//    return true;
//  }
//
//  return widget->Resizable();
assert(false);
}

bool MediaValues::CalculateThreeDEnabled(ExecutingContext* frame) {
//  return frame->GetPage()->GetSettings().GetAcceleratedCompositingEnabled();
    assert(false);
}

int MediaValues::CalculateAvailablePointerTypes(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetSettings());
//  return frame->GetSettings()->GetAvailablePointerTypes();
assert(false);
}

int MediaValues::CalculateAvailableHoverTypes(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetSettings());
//  return frame->GetSettings()->GetAvailableHoverTypes();
assert(false);
}

bool MediaValues::CalculatePrefersReducedMotion(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetSettings());
//  const MediaFeatureOverrides* overrides =
//      frame->GetPage()->GetMediaFeatureOverrides();
//  std::optional<bool> override_value =
//      overrides ? overrides->GetPrefersReducedMotion() : std::nullopt;
//  if (override_value.has_value()) {
//    return override_value.value();
//  }
//
//  const PreferenceOverrides* preference_overrides =
//      frame->GetPage()->GetPreferenceOverrides();
//  std::optional<bool> preference_override_value =
//      preference_overrides ? preference_overrides->GetPrefersReducedMotion()
//                           : std::nullopt;
//  return preference_override_value.value_or(
//      frame->GetSettings()->GetPrefersReducedMotion());
assert(false);
return 0;
}

bool MediaValues::CalculatePrefersReducedData(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetSettings());
//  const MediaFeatureOverrides* overrides =
//      frame->GetPage()->GetMediaFeatureOverrides();
//  std::optional<bool> override_value =
//      overrides ? overrides->GetPrefersReducedData() : std::nullopt;
//  if (override_value.has_value()) {
//    return override_value.value();
//  }
//
//  const PreferenceOverrides* preference_overrides =
//      frame->GetPage()->GetPreferenceOverrides();
//  std::optional<bool> preference_override_value =
//      preference_overrides ? preference_overrides->GetPrefersReducedData()
//                           : std::nullopt;
//  return preference_override_value.value_or(
//      GetNetworkStateNotifier().SaveDataEnabled());
assert(false);
}

bool MediaValues::CalculatePrefersReducedTransparency(ExecutingContext* frame) {
//  DCHECK(frame);
//  DCHECK(frame->GetSettings());
//  const MediaFeatureOverrides* overrides =
//      frame->GetPage()->GetMediaFeatureOverrides();
//  std::optional<bool> override_value =
//      overrides ? overrides->GetPrefersReducedTransparency() : std::nullopt;
//  if (override_value.has_value()) {
//    return override_value.value();
//  }
//
//  const PreferenceOverrides* preference_overrides =
//      frame->GetPage()->GetPreferenceOverrides();
//  std::optional<bool> preference_override_value =
//      preference_overrides
//          ? preference_overrides->GetPrefersReducedTransparency()
//          : std::nullopt;
//  return preference_override_value.value_or(
//      frame->GetSettings()->GetPrefersReducedTransparency());
    assert(false);
}

int MediaValues::CalculateHorizontalViewportSegments(ExecutingContext* frame) {
//  if (!frame->GetWidgetForLocalRoot()) {
//    return 1;
//  }
//
//  WebVector<gfx::Rect> viewport_segments =
//      frame->GetWidgetForLocalRoot()->ViewportSegments();
//  WTF::HashSet<int> unique_x;
//  for (const auto& segment : viewport_segments) {
//    // HashSet can't have 0 as a key, so add 1 to all the values we see.
//    unique_x.insert(segment.x() + 1);
//  }
//
//  return static_cast<int>(unique_x.size());
assert(false);
}

int MediaValues::CalculateVerticalViewportSegments(ExecutingContext* frame) {
//  if (!frame->GetWidgetForLocalRoot()) {
//    return 1;
//  }
//
//  WebVector<gfx::Rect> viewport_segments =
//      frame->GetWidgetForLocalRoot()->ViewportSegments();
//  WTF::HashSet<int> unique_y;
//  for (const auto& segment : viewport_segments) {
//    // HashSet can't have 0 as a key, so add 1 to all the values we see.
//    unique_y.insert(segment.y() + 1);
//  }
//
//  return static_cast<int>(unique_y.size());
    assert(false);
}

bool MediaValues::ComputeLengthImpl(double value,
                                    CSSPrimitiveValue::UnitType type,
                                    double& result) const {
  if (!CSSPrimitiveValue::IsLength(type)) {
    return false;
  }
  result = ZoomedComputedPixels(value, type);
  return true;
}


}