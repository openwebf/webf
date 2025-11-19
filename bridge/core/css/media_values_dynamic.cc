// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/media_values_dynamic.h"

#include "binding_call_methods.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/frame/window.h"
#include "foundation/native_value.h"
#include "foundation/native_value_converter.h"
#include "foundation/string/wtf_string.h"

namespace webf {

MediaValuesDynamic::MediaValuesDynamic(ExecutingContext* context)
    : MediaValues(), context_(context) {}

// MediaValues overrides.

int MediaValuesDynamic::DeviceWidth() const {
  return CalculateDeviceWidth(context_);
}

int MediaValuesDynamic::DeviceHeight() const {
  return CalculateDeviceHeight(context_);
}

float MediaValuesDynamic::DevicePixelRatio() const {
  return CalculateDevicePixelRatio(context_);
}

bool MediaValuesDynamic::DeviceSupportsHDR() const {
  return CalculateDeviceSupportsHDR(context_);
}

int MediaValuesDynamic::ColorBitsPerComponent() const {
  return CalculateColorBitsPerComponent(context_);
}

int MediaValuesDynamic::MonochromeBitsPerComponent() const {
  return CalculateMonochromeBitsPerComponent(context_);
}

bool MediaValuesDynamic::InvertedColors() const {
  return CalculateInvertedColors(context_);
}

bool MediaValuesDynamic::ThreeDEnabled() const {
  return CalculateThreeDEnabled(context_);
}

const String MediaValuesDynamic::MediaType() const {
  // WebF currently only targets screen media.
  return String::FromUTF8("screen");
}

CSSValueID MediaValuesDynamic::PreferredColorScheme() const {
  Window* window = context_ ? context_->window() : nullptr;
  if (!window) {
    return CSSValueID::kLight;
  }

  NativeValue dart_result =
      window->GetBindingProperty(binding_call_methods::kcolorScheme,
                                 FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  AtomicString scheme =
      NativeValueConverter<NativeTypeString>::FromNativeValue(window->ctx(), std::move(dart_result));

  if (scheme == AtomicString::CreateFromUTF8("dark")) {
    return CSSValueID::kDark;
  }
  if (scheme == AtomicString::CreateFromUTF8("light")) {
    return CSSValueID::kLight;
  }
  return CSSValueID::kLight;
}

bool MediaValuesDynamic::Resizable() const {
  return CalculateResizable(context_);
}

bool MediaValuesDynamic::StrictMode() const {
  return CalculateStrictMode(context_);
}

Document* MediaValuesDynamic::GetDocument() const {
  return context_ ? context_->document() : nullptr;
}

bool MediaValuesDynamic::HasValues() const {
  return context_ != nullptr;
}

// CSSLengthResolver overrides.

float MediaValuesDynamic::EmFontSize(float zoom) const {
  return CalculateEmSize(context_) * zoom;
}

float MediaValuesDynamic::RemFontSize(float zoom) const {
  // For media queries rem and em are equivalent (based on initial font).
  return CalculateEmSize(context_) * zoom;
}

float MediaValuesDynamic::ExFontSize(float zoom) const {
  return CalculateExSize(context_) * zoom;
}

float MediaValuesDynamic::RexFontSize(float zoom) const {
  return CalculateExSize(context_) * zoom;
}

float MediaValuesDynamic::ChFontSize(float zoom) const {
  return CalculateChSize(context_) * zoom;
}

float MediaValuesDynamic::RchFontSize(float zoom) const {
  return CalculateChSize(context_) * zoom;
}

float MediaValuesDynamic::IcFontSize(float zoom) const {
  return CalculateIcSize(context_) * zoom;
}

float MediaValuesDynamic::RicFontSize(float zoom) const {
  return CalculateIcSize(context_) * zoom;
}

float MediaValuesDynamic::LineHeight(float zoom) const {
  return CalculateLineHeight(context_) * zoom;
}

float MediaValuesDynamic::RootLineHeight(float zoom) const {
  return CalculateLineHeight(context_) * zoom;
}

float MediaValuesDynamic::CapFontSize(float zoom) const {
  return CalculateCapSize(context_) * zoom;
}

float MediaValuesDynamic::RcapFontSize(float zoom) const {
  return CalculateCapSize(context_) * zoom;
}

double MediaValuesDynamic::ViewportWidth() const {
  return CalculateViewportWidth(context_);
}

double MediaValuesDynamic::ViewportHeight() const {
  return CalculateViewportHeight(context_);
}

double MediaValuesDynamic::SmallViewportWidth() const {
  return CalculateSmallViewportWidth(context_);
}

double MediaValuesDynamic::SmallViewportHeight() const {
  return CalculateSmallViewportHeight(context_);
}

double MediaValuesDynamic::LargeViewportWidth() const {
  return CalculateLargeViewportWidth(context_);
}

double MediaValuesDynamic::LargeViewportHeight() const {
  return CalculateLargeViewportHeight(context_);
}

double MediaValuesDynamic::DynamicViewportWidth() const {
  return CalculateDynamicViewportWidth(context_);
}

double MediaValuesDynamic::DynamicViewportHeight() const {
  return CalculateDynamicViewportHeight(context_);
}

double MediaValuesDynamic::ContainerWidth() const {
  // WebF does not yet support container queries; fall back to small viewport.
  return SmallViewportWidth();
}

double MediaValuesDynamic::ContainerHeight() const {
  return SmallViewportHeight();
}

double MediaValuesDynamic::ContainerWidth(const ScopedCSSName&) const {
  return SmallViewportWidth();
}

double MediaValuesDynamic::ContainerHeight(const ScopedCSSName&) const {
  return SmallViewportHeight();
}

WritingMode MediaValuesDynamic::GetWritingMode() const {
  // WebF currently assumes horizontal-tb for media query units.
  return WritingMode::kHorizontalTb;
}

void MediaValuesDynamic::ReferenceTreeScope() const {}

}  // namespace webf
