// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_MEDIA_VALUES_H_
#define WEBF_CORE_CSS_MEDIA_VALUES_H_

#include "core/css/css_length_resolver.h"

namespace webf {

class CSSPrimitiveValue;
class Document;
class Element;
class LocalFrame;
enum class CSSValueID;


class MediaValues : public CSSLengthResolver {
 public:
  MediaValues() : CSSLengthResolver(1.0f /* zoom */) {}
  virtual ~MediaValues() = default;
  virtual void Trace(GCVisitor* visitor) const {}

  static MediaValues* CreateDynamicIfFrameExists(ExecutingContext*);

  template <typename T>
  bool ComputeLength(double value,
                     CSSPrimitiveValue::UnitType type,
                     T& result) const {
    double temp_result;
    if (!ComputeLengthImpl(value, type, temp_result)) {
      return false;
    }
    result = ClampTo<T>(temp_result);
    return true;
  }

  std::optional<double> InlineSize() const;
  std::optional<double> BlockSize() const;
  virtual std::optional<double> Width() const { return ViewportWidth(); }
  virtual std::optional<double> Height() const { return ViewportHeight(); }
  virtual int DeviceWidth() const = 0;
  virtual int DeviceHeight() const = 0;
  virtual float DevicePixelRatio() const = 0;
  virtual bool DeviceSupportsHDR() const = 0;
  virtual int ColorBitsPerComponent() const = 0;
  virtual int MonochromeBitsPerComponent() const = 0;
  virtual bool InvertedColors() const = 0;
  virtual bool ThreeDEnabled() const = 0;
  virtual const std::string MediaType() const = 0;
  virtual bool Resizable() const = 0;
  virtual bool StrictMode() const = 0;
  virtual Document* GetDocument() const = 0;
  virtual bool HasValues() const = 0;

  // Returns the container element used to retrieve base style and parent style
  // when computing the computed value of a style() container query.
  virtual Element* ContainerElement() const { return nullptr; }

 protected:
  static double CalculateViewportWidth(ExecutingContext*);
  static double CalculateViewportHeight(ExecutingContext*);
  static double CalculateSmallViewportWidth(ExecutingContext*);
  static double CalculateSmallViewportHeight(ExecutingContext*);
  static double CalculateLargeViewportWidth(ExecutingContext*);
  static double CalculateLargeViewportHeight(ExecutingContext*);
  static double CalculateDynamicViewportWidth(ExecutingContext*);
  static double CalculateDynamicViewportHeight(ExecutingContext*);
  static float CalculateEmSize(ExecutingContext*);
  static float CalculateExSize(ExecutingContext*);
  static float CalculateChSize(ExecutingContext*);
  static float CalculateIcSize(ExecutingContext*);
  static float CalculateCapSize(ExecutingContext*);
  static float CalculateLineHeight(ExecutingContext*);
  static int CalculateDeviceWidth(ExecutingContext*);
  static int CalculateDeviceHeight(ExecutingContext*);
  static bool CalculateStrictMode(ExecutingContext*);
  static float CalculateDevicePixelRatio(ExecutingContext*);
  static bool CalculateDeviceSupportsHDR(ExecutingContext*);
  static int CalculateColorBitsPerComponent(ExecutingContext*);
  static int CalculateMonochromeBitsPerComponent(ExecutingContext*);
  static bool CalculateInvertedColors(ExecutingContext*);
  static bool CalculateResizable(ExecutingContext*);
  static bool CalculateThreeDEnabled(ExecutingContext*);
  static int CalculateAvailablePointerTypes(ExecutingContext*);
  static int CalculateAvailableHoverTypes(ExecutingContext*);
  static bool CalculatePrefersReducedMotion(ExecutingContext*);
  static bool CalculatePrefersReducedData(ExecutingContext*);
  static bool CalculatePrefersReducedTransparency(ExecutingContext*);
  static int CalculateHorizontalViewportSegments(ExecutingContext*);
  static int CalculateVerticalViewportSegments(ExecutingContext*);

  bool ComputeLengthImpl(double value,
                         CSSPrimitiveValue::UnitType,
                         double& result) const;
};

}

#endif  // WEBF_CORE_CSS_MEDIA_VALUES_H_
