// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_LENGTH_RESOLVER_H_
#define WEBF_CORE_CSS_CSS_LENGTH_RESOLVER_H_

#include "core/css/css_primitive_value.h"
#include "core/style/scoped_css_name.h"
#include "core/platform/geometry/length.h"
#include "core/platform/text/writing_mode.h"

namespace webf {

class AnchorEvaluator;
class ScopedCSSName;
class InsetAreaOffsets;

class CSSLengthResolver {
 public:
  explicit CSSLengthResolver(float zoom) : zoom_(zoom) {}

  // Font-relative sizes handle the target zoom themselves. This is because
  // font-relative sizes may be pre-zoomed (with a factor potentially different
  // from the target zoom).
  virtual float EmFontSize(float zoom) const = 0;
  virtual float RemFontSize(float zoom) const = 0;
  virtual float ExFontSize(float zoom) const = 0;
  virtual float RexFontSize(float zoom) const = 0;
  virtual float ChFontSize(float zoom) const = 0;
  virtual float RchFontSize(float zoom) const = 0;
  virtual float IcFontSize(float zoom) const = 0;
  virtual float RicFontSize(float zoom) const = 0;
  virtual float LineHeight(float zoom) const = 0;
  virtual float RootLineHeight(float zoom) const = 0;
  virtual float CapFontSize(float zoom) const = 0;
  virtual float RcapFontSize(float zoom) const = 0;

  // Other sizes are not pre-zoomed.
  virtual double ViewportWidth() const = 0;
  virtual double ViewportHeight() const = 0;
  virtual double SmallViewportWidth() const = 0;
  virtual double SmallViewportHeight() const = 0;
  virtual double LargeViewportWidth() const = 0;
  virtual double LargeViewportHeight() const = 0;
  virtual double DynamicViewportWidth() const = 0;
  virtual double DynamicViewportHeight() const = 0;
  virtual double ContainerWidth() const = 0;
  virtual double ContainerHeight() const = 0;
  virtual double ContainerWidth(const ScopedCSSName&) const = 0;
  virtual double ContainerHeight(const ScopedCSSName&) const = 0;

  virtual WritingMode GetWritingMode() const = 0;

  // Invoked to notify the resolver that there is a function with
  // a tree-scoped reference, e.g. anchor(--a top).
  //
  // https://drafts.csswg.org/css-scoping-1/#css-tree-scoped-reference
  virtual void ReferenceTreeScope() const = 0;

  float Zoom() const { return zoom_; }
  void SetZoom(float zoom) {
    assert(std::isfinite(zoom));
    assert(zoom > 0);
    zoom_ = zoom;
  }

  double ZoomedComputedPixels(double value, CSSPrimitiveValue::UnitType) const;

 private:
  bool IsHorizontalWritingMode() const {
    return webf::IsHorizontalWritingMode(GetWritingMode());
  }
  double ViewportWidthPercent() const;
  double ViewportHeightPercent() const;
  double ViewportInlineSizePercent() const;
  double ViewportBlockSizePercent() const;
  double ViewportMinPercent() const;
  double ViewportMaxPercent() const;
  double SmallViewportWidthPercent() const;
  double SmallViewportHeightPercent() const;
  double SmallViewportInlineSizePercent() const;
  double SmallViewportBlockSizePercent() const;
  double SmallViewportMinPercent() const;
  double SmallViewportMaxPercent() const;
  double LargeViewportWidthPercent() const;
  double LargeViewportHeightPercent() const;
  double LargeViewportInlineSizePercent() const;
  double LargeViewportBlockSizePercent() const;
  double LargeViewportMinPercent() const;
  double LargeViewportMaxPercent() const;
  double DynamicViewportWidthPercent() const;
  double DynamicViewportHeightPercent() const;
  double DynamicViewportInlineSizePercent() const;
  double DynamicViewportBlockSizePercent() const;
  double DynamicViewportMinPercent() const;
  double DynamicViewportMaxPercent() const;
  double ContainerWidthPercent() const;
  double ContainerHeightPercent() const;
  double ContainerInlineSizePercent() const;
  double ContainerBlockSizePercent() const;
  double ContainerMinPercent() const;
  double ContainerMaxPercent() const;

  float zoom_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_LENGTH_RESOLVER_H_
