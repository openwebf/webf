/*
 * Copyright (C) 2008 Apple Inc. All rights reserved.
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

#ifndef WEBF_CORE_CSS_CSS_GRADIENT_VALUE_H_
#define WEBF_CORE_CSS_CSS_GRADIENT_VALUE_H_

#include "core/css/css_identifier_value.h"
#include "core/css/css_image_generator_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_to_length_conversion_data.h"
#include "core/css/css_value.h"
#include "core/css/properties/css_property.h"
#include "core/platform/graphics/color.h"
#include "foundation/macros.h"
#include "foundation/string_builder.h"

namespace webf {

class Color;
class Gradient;
class Document;

namespace cssvalue {

enum CSSGradientType {
  kCSSDeprecatedLinearGradient,
  kCSSDeprecatedRadialGradient,
  kCSSPrefixedLinearGradient,
  kCSSPrefixedRadialGradient,
  kCSSLinearGradient,
  kCSSRadialGradient,
  kCSSConicGradient,
  kCSSConstantGradient,  // Internal.
};

enum CSSGradientRepeat { kNonRepeating, kRepeating };

// This struct is stack allocated and allocated as part of vectors.
// When allocated on the stack its members are found by conservative
// stack scanning. When allocated as part of Vectors in heap-allocated
// objects its members are visited via the containing object's
// (CSSGradientValue) traceAfterDispatch method.
//
// http://www.w3.org/TR/css3-images/#color-stop-syntax
struct CSSGradientColorStop {
  WEBF_DISALLOW_NEW();

 public:
  bool operator==(const CSSGradientColorStop& other) const {
    return ValuesEquivalent(color_, other.color_) && ValuesEquivalent(offset_, other.offset_);
  }

  bool IsHint() const {
    DCHECK(color_ || offset_);
    return !color_;
  }

  bool IsCacheable() const;

  void Trace(GCVisitor*) const;

  std::shared_ptr<const CSSPrimitiveValue> offset_;  // percentage | length | angle
  std::shared_ptr<const CSSValue> color_;
};

}  // namespace cssvalue
}  // namespace webf

namespace webf {
namespace cssvalue {

class CSSGradientValue : public CSSImageGeneratorValue {
 public:
  void AddStop(const CSSGradientColorStop& stop) {
    stops_.push_back(stop);
    is_cacheable_ = is_cacheable_ && stop.IsCacheable();
  }

  size_t StopCount() const { return stops_.size(); }

  bool IsRepeating() const { return repeating_; }

  CSSGradientType GradientType() const { return gradient_type_; }

  void TraceAfterDispatch(GCVisitor*) const;

  struct GradientDesc;

 protected:
  CSSGradientValue(ClassType class_type, CSSGradientRepeat repeat, CSSGradientType gradient_type)
      : CSSImageGeneratorValue(class_type),
        gradient_type_(gradient_type),
        repeating_(repeat == kRepeating),
        is_cacheable_(true) {}

  void AppendCSSTextForColorStops(StringBuilder&, bool requires_separator) const;
  void AppendCSSTextForDeprecatedColorStops(StringBuilder&) const;

  bool Equals(const CSSGradientValue&) const;

  // Stops
  std::vector<CSSGradientColorStop> stops_;
  CSSGradientType gradient_type_;
  bool repeating_ : 1;
  bool is_cacheable_ : 1;
};

class CSSLinearGradientValue final : public CSSGradientValue {
 public:
  CSSLinearGradientValue(std::shared_ptr<const CSSValue> first_x,
                         std::shared_ptr<const CSSValue> first_y,
                         std::shared_ptr<const CSSValue> second_x,
                         std::shared_ptr<const CSSValue> second_y,
                         std::shared_ptr<const CSSPrimitiveValue> angle,
                         CSSGradientRepeat repeat,
                         CSSGradientType gradient_type = kCSSLinearGradient)
      : CSSGradientValue(kLinearGradientClass, repeat, gradient_type),
        first_x_(first_x),
        first_y_(first_y),
        second_x_(second_x),
        second_y_(second_y),
        angle_(angle) {}

  std::string CustomCSSText() const;

  // Create the gradient for a given size.
  std::shared_ptr<Gradient> CreateGradient(const CSSToLengthConversionData&,
                                           const gfx::SizeF&,
                                           const Document&,
                                           const ComputedStyle&) const;

  bool Equals(const CSSLinearGradientValue&) const;

  bool IsUsingCurrentColor() const;
  bool IsUsingContainerRelativeUnits() const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  // Any of these may be null.
  std::shared_ptr<const CSSValue> first_x_;
  std::shared_ptr<const CSSValue> first_y_;
  std::shared_ptr<const CSSValue> second_x_;
  std::shared_ptr<const CSSValue> second_y_;
  std::shared_ptr<const CSSPrimitiveValue> angle_;
};

class CSSRadialGradientValue final : public CSSGradientValue {
 public:
  CSSRadialGradientValue(const std::shared_ptr<const CSSValue>& first_x,
                         const std::shared_ptr<const CSSValue>& first_y,
                         const std::shared_ptr<const CSSPrimitiveValue>& first_radius,
                         const std::shared_ptr<const CSSValue>& second_x,
                         const std::shared_ptr<const CSSValue>& second_y,
                         const std::shared_ptr<const CSSPrimitiveValue>& second_radius,
                         const std::shared_ptr<const CSSIdentifierValue>& shape,
                         const std::shared_ptr<const CSSIdentifierValue>& sizing_behavior,
                         const std::shared_ptr<const CSSPrimitiveValue>& horizontal_size,
                         const std::shared_ptr<const CSSPrimitiveValue>& vertical_size,
                         CSSGradientRepeat repeat,
                         CSSGradientType gradient_type = kCSSRadialGradient)
      : CSSGradientValue(kRadialGradientClass, repeat, gradient_type),
        first_x_(first_x),
        first_y_(first_y),
        second_x_(second_x),
        second_y_(second_y),
        first_radius_(first_radius),
        second_radius_(second_radius),
        shape_(shape),
        sizing_behavior_(sizing_behavior),
        end_horizontal_size_(horizontal_size),
        end_vertical_size_(vertical_size) {}

  CSSRadialGradientValue(const std::shared_ptr<const CSSValue>& first_x,
                         const std::shared_ptr<const CSSValue>& first_y,
                         const std::shared_ptr<const CSSPrimitiveValue>& first_radius,
                         const std::shared_ptr<const CSSValue>& second_x,
                         const std::shared_ptr<const CSSValue>& second_y,
                         const std::shared_ptr<const CSSPrimitiveValue>& second_radius,
                         CSSGradientRepeat repeat,
                         CSSGradientType gradient_type = kCSSRadialGradient)
      : CSSGradientValue(kRadialGradientClass, repeat, gradient_type),
        first_x_(first_x),
        first_y_(first_y),
        second_x_(second_x),
        second_y_(second_y),
        first_radius_(first_radius),
        second_radius_(second_radius),
        shape_(nullptr),
        sizing_behavior_(nullptr),
        end_horizontal_size_(nullptr),
        end_vertical_size_(nullptr) {}

  CSSRadialGradientValue(const std::shared_ptr<const CSSValue>& center_x,
                         const std::shared_ptr<const CSSValue>& center_y,
                         const std::shared_ptr<const CSSIdentifierValue>& shape,
                         const std::shared_ptr<const CSSIdentifierValue>& sizing_behavior,
                         const std::shared_ptr<const CSSPrimitiveValue>& horizontal_size,
                         const std::shared_ptr<const CSSPrimitiveValue>& vertical_size,
                         CSSGradientRepeat repeat,
                         CSSGradientType gradient_type)
      : CSSGradientValue(kRadialGradientClass, repeat, gradient_type),
        first_x_(center_x),
        first_y_(center_y),
        second_x_(center_x),
        second_y_(center_y),
        first_radius_(nullptr),
        second_radius_(nullptr),
        shape_(shape),
        sizing_behavior_(sizing_behavior),
        end_horizontal_size_(horizontal_size),
        end_vertical_size_(vertical_size) {}

  std::string CustomCSSText() const;

  void SetShape(std::shared_ptr<const CSSIdentifierValue> val) { shape_ = val; }
  void SetSizingBehavior(std::shared_ptr<const CSSIdentifierValue> val) { sizing_behavior_ = val; }

  void SetEndHorizontalSize(std::shared_ptr<const CSSPrimitiveValue> val) { end_horizontal_size_ = val; }
  void SetEndVerticalSize(std::shared_ptr<const CSSPrimitiveValue> val) { end_vertical_size_ = val; }

  // Create the gradient for a given size.
  std::shared_ptr<Gradient> CreateGradient(const CSSToLengthConversionData&,
                                           const gfx::SizeF&,
                                           const Document&,
                                           const ComputedStyle&) const;

  bool Equals(const CSSRadialGradientValue&) const;

  bool IsUsingCurrentColor() const;
  bool IsUsingContainerRelativeUnits() const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  // Any of these may be null.
  std::shared_ptr<const CSSValue> first_x_;
  std::shared_ptr<const CSSValue> first_y_;
  std::shared_ptr<const CSSValue> second_x_;
  std::shared_ptr<const CSSValue> second_y_;

  // These may be null for non-deprecated gradients.
  std::shared_ptr<const CSSPrimitiveValue> first_radius_;
  std::shared_ptr<const CSSPrimitiveValue> second_radius_;

  // The below are only used for non-deprecated gradients. Any of them may be
  // null.
  std::shared_ptr<const CSSIdentifierValue> shape_;
  std::shared_ptr<const CSSIdentifierValue> sizing_behavior_;

  std::shared_ptr<const CSSPrimitiveValue> end_horizontal_size_;
  std::shared_ptr<const CSSPrimitiveValue> end_vertical_size_;
};

class CSSConicGradientValue final : public CSSGradientValue {
 public:
  CSSConicGradientValue(const std::shared_ptr<const CSSValue>& x,
                        const std::shared_ptr<const CSSValue>& y,
                        const std::shared_ptr<const CSSPrimitiveValue>& from_angle,
                        CSSGradientRepeat repeat)
      : CSSGradientValue(kConicGradientClass, repeat, kCSSConicGradient), x_(x), y_(y), from_angle_(from_angle) {}

  std::string CustomCSSText() const;

  // Create the gradient for a given size.
  std::shared_ptr<Gradient> CreateGradient(const CSSToLengthConversionData&,
                                           const gfx::SizeF&,
                                           const Document&,
                                           const ComputedStyle&) const;

  bool Equals(const CSSConicGradientValue&) const;

  bool IsUsingCurrentColor() const;
  bool IsUsingContainerRelativeUnits() const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  // Any of these may be null.
  std::shared_ptr<const CSSValue> x_;
  std::shared_ptr<const CSSValue> y_;
  std::shared_ptr<const CSSPrimitiveValue> from_angle_;
};

// cross-fade() supports interpolating between not only images,
// but also colors. This is a proxy class that takes in a ColorValue
// and behaves otherwise like a one-color gradient, since gradients
// have all the machinery needed to resolve colors and convert them
// into images.
class CSSConstantGradientValue final : public CSSGradientValue {
 public:
  explicit CSSConstantGradientValue(std::shared_ptr<const CSSValue> color)
      : CSSGradientValue(kConstantGradientClass, kNonRepeating, kCSSConstantGradient), color_(color) {}

  std::string CustomCSSText() const { return color_->CssText(); }

  // Create the gradient for a given size.
  std::shared_ptr<Gradient> CreateGradient(const CSSToLengthConversionData&,
                                           const gfx::SizeF&,
                                           const Document&,
                                           const ComputedStyle&) const;

  bool Equals(const CSSConstantGradientValue&) const;
  void TraceAfterDispatch(GCVisitor*) const;

 protected:
  std::shared_ptr<const CSSValue> color_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSGradientValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsGradientValue(); }
};

template <>
struct DowncastTraits<cssvalue::CSSLinearGradientValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsLinearGradientValue(); }
};

template <>
struct DowncastTraits<cssvalue::CSSRadialGradientValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsRadialGradientValue(); }
};

template <>
struct DowncastTraits<cssvalue::CSSConicGradientValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsConicGradientValue(); }
};

template <>
struct DowncastTraits<cssvalue::CSSConstantGradientValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsConstantGradientValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_GRADIENT_VALUE_H_