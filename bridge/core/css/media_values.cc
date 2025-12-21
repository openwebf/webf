// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "media_values.h"

#include <cassert>

#include "binding_call_methods.h"
#include "bindings/qjs/exception_state.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/screen.h"
#include "core/frame/window.h"
#include "foundation/native_value.h"
#include "foundation/native_value_converter.h"
#include "media_values_dynamic.h"

namespace webf {

namespace {

constexpr double kDefaultViewportWidth = 800.0;
constexpr double kDefaultViewportHeight = 600.0;
constexpr float kDefaultDevicePixelRatio = 1.0f;
constexpr int kDefaultColorBitsPerComponent = 24;

inline Window* GetWindow(ExecutingContext* context) {
  return context ? context->window() : nullptr;
}

inline Document* GetDocumentFromContext(ExecutingContext* context) {
  return context ? context->document() : nullptr;
}

inline Screen* GetScreen(ExecutingContext* context) {
  Window* window = GetWindow(context);
  return window ? window->screen() : nullptr;
}

double GetInnerDimension(ExecutingContext* context,
                         const AtomicString& name,
                         double fallback) {
  Window* window = GetWindow(context);
  if (!window) {
    return fallback;
  }

  NativeValue dart_result =
      window->GetBindingProperty(name, FlushUICommandReason::kDependentsOnLayout, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(dart_result);
}

}  // namespace

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
  if (!context) {
    return nullptr;
  }
  return new MediaValuesDynamic(context);
}

double MediaValues::CalculateViewportWidth(ExecutingContext* context) {
  return GetInnerDimension(context, binding_call_methods::kinnerWidth, kDefaultViewportWidth);
}

double MediaValues::CalculateViewportHeight(ExecutingContext* context) {
  return GetInnerDimension(context, binding_call_methods::kinnerHeight, kDefaultViewportHeight);
}

double MediaValues::CalculateSmallViewportWidth(ExecutingContext* context) {
  // WebF currently has a single viewport; use the same value for all viewport units.
  return CalculateViewportWidth(context);
}

double MediaValues::CalculateSmallViewportHeight(ExecutingContext* context) {
  return CalculateViewportHeight(context);
}

double MediaValues::CalculateLargeViewportWidth(ExecutingContext* context) {
  return CalculateViewportWidth(context);
}

double MediaValues::CalculateLargeViewportHeight(ExecutingContext* context) {
  return CalculateViewportHeight(context);
}

double MediaValues::CalculateDynamicViewportWidth(ExecutingContext* context) {
  return CalculateViewportWidth(context);
}

double MediaValues::CalculateDynamicViewportHeight(ExecutingContext* context) {
  return CalculateViewportHeight(context);
}

int MediaValues::CalculateDeviceWidth(ExecutingContext* context) {
  Screen* screen = GetScreen(context);
  if (!screen) {
    return static_cast<int>(kDefaultViewportWidth);
  }
  return static_cast<int>(screen->width());
}

int MediaValues::CalculateDeviceHeight(ExecutingContext* context) {
  Screen* screen = GetScreen(context);
  if (!screen) {
    return static_cast<int>(kDefaultViewportHeight);
  }
  return static_cast<int>(screen->height());
}

bool MediaValues::CalculateStrictMode(ExecutingContext* context) {
  Document* document = GetDocumentFromContext(context);
  if (!document) {
    return true;
  }
  AtomicString compat = document->compatMode();
  // In browsers, "BackCompat" means quirks mode.
  return compat != AtomicString::CreateFromUTF8("BackCompat");
}

float MediaValues::CalculateDevicePixelRatio(ExecutingContext* context) {
  Window* window = GetWindow(context);
  if (!window) {
    return kDefaultDevicePixelRatio;
  }

  NativeValue dart_result = window->GetBindingProperty(binding_call_methods::kdevicePixelRatio,
                                                       FlushUICommandReason::kDependentsOnLayout, ASSERT_NO_EXCEPTION());
  return static_cast<float>(NativeValueConverter<NativeTypeDouble>::FromNativeValue(dart_result));
}

bool MediaValues::CalculateDeviceSupportsHDR(ExecutingContext* /*context*/) {
  // WebF does not currently expose HDR capabilities; assume no HDR support.
  return false;
}

int MediaValues::CalculateColorBitsPerComponent(ExecutingContext* /*context*/) {
  // Assume a standard 24-bit color display (8 bits per component).
  return kDefaultColorBitsPerComponent;
}

int MediaValues::CalculateMonochromeBitsPerComponent(ExecutingContext* /*context*/) {
  // Assume non-monochrome display.
  return 0;
}

bool MediaValues::CalculateInvertedColors(ExecutingContext* /*context*/) {
  return false;
}

float MediaValues::CalculateEmSize(ExecutingContext* /*context*/) {
  // Default to a 16px root font size.
  return 16.0f;
}

float MediaValues::CalculateExSize(ExecutingContext* /*context*/) {
  // Commonly approximated as 0.5em.
  return 8.0f;
}

float MediaValues::CalculateChSize(ExecutingContext* /*context*/) {
  // Reasonable default; matches Blink's cached default.
  return 8.0f;
}

float MediaValues::CalculateIcSize(ExecutingContext* /*context*/) {
  return 16.0f;
}

float MediaValues::CalculateCapSize(ExecutingContext* /*context*/) {
  return 16.0f;
}

float MediaValues::CalculateLineHeight(ExecutingContext* /*context*/) {
  return 16.0f;
}

bool MediaValues::CalculateResizable(ExecutingContext* /*context*/) {
  // WebF widgets are generally resizable by the embedding environment.
  return true;
}

bool MediaValues::CalculateThreeDEnabled(ExecutingContext* /*context*/) {
  return false;
}

int MediaValues::CalculateAvailablePointerTypes(ExecutingContext* /*context*/) {
  return 0;
}

int MediaValues::CalculateAvailableHoverTypes(ExecutingContext* /*context*/) {
  return 0;
}

bool MediaValues::CalculatePrefersReducedMotion(ExecutingContext* /*context*/) {
  return false;
}

bool MediaValues::CalculatePrefersReducedData(ExecutingContext* /*context*/) {
  return false;
}

bool MediaValues::CalculatePrefersReducedTransparency(ExecutingContext* /*context*/) {
  return false;
}

int MediaValues::CalculateHorizontalViewportSegments(ExecutingContext* /*context*/) {
  return 1;
}

int MediaValues::CalculateVerticalViewportSegments(ExecutingContext* /*context*/) {
  return 1;
}

bool MediaValues::ComputeLengthImpl(double value, CSSPrimitiveValue::UnitType type, double& result) const {
  if (!CSSPrimitiveValue::IsLength(type)) {
    return false;
  }
  result = ZoomedComputedPixels(value, type);
  return true;
}

}  // namespace webf
