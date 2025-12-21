// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_MEDIA_VALUES_DYNAMIC_H_
#define WEBF_CORE_CSS_MEDIA_VALUES_DYNAMIC_H_

#include "core/css/media_values.h"

namespace webf {

class ExecutingContext;

// MediaValues implementation backed by a live ExecutingContext (Window/Document).
// It queries the host environment for viewport and device data through MediaValues'
// Calculate* helpers.
class MediaValuesDynamic : public MediaValues {
 public:
  explicit MediaValuesDynamic(ExecutingContext* context);

  // MediaValues overrides.
  int DeviceWidth() const override;
  int DeviceHeight() const override;
  float DevicePixelRatio() const override;
  bool DeviceSupportsHDR() const override;
  int ColorBitsPerComponent() const override;
  int MonochromeBitsPerComponent() const override;
  bool InvertedColors() const override;
  bool ThreeDEnabled() const override;
  const String MediaType() const override;
   CSSValueID PreferredColorScheme() const override;
  bool Resizable() const override;
  bool StrictMode() const override;
  Document* GetDocument() const override;
  bool HasValues() const override;

  // CSSLengthResolver overrides.
  float EmFontSize(float zoom) const override;
  float RemFontSize(float zoom) const override;
  float ExFontSize(float zoom) const override;
  float RexFontSize(float zoom) const override;
  float ChFontSize(float zoom) const override;
  float RchFontSize(float zoom) const override;
  float IcFontSize(float zoom) const override;
  float RicFontSize(float zoom) const override;
  float LineHeight(float zoom) const override;
  float RootLineHeight(float zoom) const override;
  float CapFontSize(float zoom) const override;
  float RcapFontSize(float zoom) const override;

  double ViewportWidth() const override;
  double ViewportHeight() const override;
  double SmallViewportWidth() const override;
  double SmallViewportHeight() const override;
  double LargeViewportWidth() const override;
  double LargeViewportHeight() const override;
  double DynamicViewportWidth() const override;
  double DynamicViewportHeight() const override;
  double ContainerWidth() const override;
  double ContainerHeight() const override;
  double ContainerWidth(const ScopedCSSName&) const override;
  double ContainerHeight(const ScopedCSSName&) const override;

  WritingMode GetWritingMode() const override;
  void ReferenceTreeScope() const override;

 private:
  ExecutingContext* context_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_MEDIA_VALUES_DYNAMIC_H_
