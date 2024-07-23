/*
    Copyright (C) 1999 Lars Knoll (knoll@kde.org)
    Copyright (C) 2006, 2008 Apple Inc. All rights reserved.
    Copyright (C) 2011 Rik Cabanier (cabanier@adobe.com)
    Copyright (C) 2011 Adobe Systems Incorporated. All rights reserved.

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_LENGTH_H
#define WEBF_LENGTH_H

#include <cassert>
#include <cmath>
#include <cstring>
#include <functional>
#include <optional>
#include "bindings/qjs/atomic_string.h"
#include "core/platform/math_extras.h"

namespace webf {

struct PixelsAndPercent {
  WEBF_DISALLOW_NEW();

 public:
  explicit PixelsAndPercent(float pixels)
      : pixels(pixels), percent(0.0f), has_explicit_pixels(true), has_explicit_percent(false) {}
  PixelsAndPercent(float pixels, float percent, bool has_explicit_pixels, bool has_explicit_percent)
      : pixels(pixels),
        percent(percent),
        has_explicit_pixels(has_explicit_pixels),
        has_explicit_percent(has_explicit_percent) {}

  PixelsAndPercent& operator+=(const PixelsAndPercent& rhs) {
    pixels += rhs.pixels;
    percent += rhs.percent;
    has_explicit_pixels |= rhs.has_explicit_pixels;
    has_explicit_percent |= rhs.has_explicit_percent;
    return *this;
  }
  friend PixelsAndPercent operator+(PixelsAndPercent lhs, const PixelsAndPercent& rhs) {
    lhs += rhs;
    return lhs;
  }
  PixelsAndPercent& operator-=(const PixelsAndPercent& rhs) {
    pixels -= rhs.pixels;
    percent -= rhs.percent;
    has_explicit_pixels |= rhs.has_explicit_pixels;
    has_explicit_percent |= rhs.has_explicit_percent;
    return *this;
  }
  PixelsAndPercent& operator*=(float number) {
    pixels *= number;
    percent *= number;
    return *this;
  }

  float pixels;
  float percent;
  bool has_explicit_pixels;
  bool has_explicit_percent;
};

class Length;

extern const Length& g_auto_length;
extern const Length& g_fill_available_length;
extern const Length& g_fit_content_length;
extern const Length& g_max_content_length;
extern const Length& g_min_content_length;
extern const Length& g_min_intrinsic_length;

class Length {
  WEBF_DISALLOW_NEW();

 public:
  // Initializes global instances.
  static void Initialize();

  enum class ValueRange { kAll, kNonNegative };

  // FIXME: This enum makes it hard to tell in general what values may be
  // appropriate for any given Length.
  enum Type : unsigned char {
    kAuto,
    kPercent,
    kFixed,
    kMinContent,
    kMaxContent,
    kMinIntrinsic,
    kFillAvailable,
    kFitContent,
    kCalculated,
    kFlex,
    kExtendToZoom,
    kDeviceWidth,
    kDeviceHeight,
    kNone,    // only valid for max-width, max-height, or contain-intrinsic-size
    kContent  // only valid for flex-basis
  };

  Length() : value_(0), type_(kAuto) {}

  explicit Length(Length::Type t) : value_(0), type_(t) { assert(t != kCalculated); }

  Length(int v, Length::Type t) : value_(v), type_(t) { assert(t != kCalculated); }

  //  Length(LayoutUnit v, Length::Type t) : value_(v.ToFloat()), type_(t) {
  //    assert(std::isfinite(v.ToFloat()));
  //    assert(t != kCalculated);
  //  }

  Length(float v, Length::Type t) : value_(v), type_(t) {
    assert(std::isfinite(v));
    assert(t != kCalculated);
  }

  Length(double v, Length::Type t) : type_(t) {
    assert(std::isfinite(v));
    value_ = ClampTo<float>(v);
  }

  Length(const Length& length) {
    memcpy(this, &length, sizeof(Length));
    //    if (IsCalculated())
    //      IncrementCalculatedRef();
  }

  Length& operator=(const Length& length) {
    //    if (length.IsCalculated())
    //      length.IncrementCalculatedRef();
    //    if (IsCalculated())
    //      DecrementCalculatedRef();
    memcpy(this, &length, sizeof(Length));
    return *this;
  }

  ~Length() {
    //    if (IsCalculated())
    //      DecrementCalculatedRef();
  }

  bool operator==(const Length& o) const {
    if (type_ != o.type_ || quirk_ != o.quirk_) {
      return false;
    }
    if (type_ == kCalculated) {
      return IsCalculatedEqual(o);
    } else {
      // For everything that doesn't use value_, it is defined to be zero,
      // so we can compare here unconditionally.
      return value_ == o.value_;
    }
  }
  bool operator!=(const Length& o) const { return !(*this == o); }

  static const Length& Auto() { return g_auto_length; }
  static const Length& FillAvailable() { return g_fill_available_length; }
  static const Length& FitContent() { return g_fit_content_length; }
  static const Length& MaxContent() { return g_max_content_length; }
  static const Length& MinContent() { return g_min_content_length; }
  static const Length& MinIntrinsic() { return g_min_intrinsic_length; }

  static Length Content() { return Length(kContent); }
  static Length Fixed() { return Length(kFixed); }
  static Length None() { return Length(kNone); }

  static Length ExtendToZoom() { return Length(kExtendToZoom); }
  static Length DeviceWidth() { return Length(kDeviceWidth); }
  static Length DeviceHeight() { return Length(kDeviceHeight); }

  template <typename NUMBER_TYPE>
  static Length Fixed(NUMBER_TYPE number) {
    return Length(number, kFixed);
  }
  template <typename NUMBER_TYPE>
  static Length Percent(NUMBER_TYPE number) {
    return Length(number, kPercent);
  }
  static Length Flex(float value) { return Length(value, kFlex); }

  // FIXME: Make this private (if possible) or at least rename it
  // (http://crbug.com/432707).
  [[nodiscard]] inline float Value() const {
    assert(!IsCalculated());
    return GetFloatValue();
  }

  [[nodiscard]] int IntValue() const {
    if (IsCalculated()) {
      assert_m(false, "NOTREACHED_IN_MIGRATION");
      return 0;
    }
    assert(!IsNone());
    return static_cast<int>(value_);
  }

  [[nodiscard]] float Pixels() const {
    assert(GetType() == kFixed);
    return GetFloatValue();
  }

  [[nodiscard]] float Percent() const {
    assert(GetType() == kPercent);
    return GetFloatValue();
  }

  PixelsAndPercent GetPixelsAndPercent() const;

  // const CalculationValue& GetCalculationValue() const;

  // If |this| is calculated, returns the underlying |CalculationValue|. If not,
  // returns a |CalculationValue| constructed from |GetPixelsAndPercent()|. Hits
  // a DCHECK if |this| is not a specified value (e.g., 'auto').
  // std::shared_ptr<const CalculationValue> AsCalculationValue() const;

  [[nodiscard]] Length::Type GetType() const { return static_cast<Length::Type>(type_); }
  [[nodiscard]] bool Quirk() const { return quirk_; }

  void SetQuirk(bool quirk) { quirk_ = quirk; }

  [[nodiscard]] bool IsNone() const { return GetType() == kNone; }

  // FIXME calc: https://bugs.webkit.org/show_bug.cgi?id=80357. A calculated
  // Length always contains a percentage, and without a maxValue passed to these
  // functions it's impossible to determine the sign or zero-ness. We assume all
  // calc values are positive and non-zero for now.
  [[nodiscard]] bool IsZero() const {
    assert(!IsNone());
    if (IsCalculated())
      return false;

    return !value_;
  }

  // If this is a length in a property that accepts calc-size(), use
  // |HasAuto()|.  If this |Length| is a block-axis size
  // |HasAutoOrContentOrIntrinsic()| is usually a better choice.
  [[nodiscard]] bool IsAuto() const { return GetType() == kAuto; }
  [[nodiscard]] bool IsFixed() const { return GetType() == kFixed; }

  // For the block axis, intrinsic sizes such as `min-content` behave the same
  // as `auto`. https://www.w3.org/TR/css-sizing-3/#valdef-width-min-content
  // This includes content-based sizes in calc-size().
  [[nodiscard]] bool HasAuto() const;
  [[nodiscard]] bool HasContentOrIntrinsic() const;
  [[nodiscard]] bool HasAutoOrContentOrIntrinsic() const;
  // HasPercent and HasPercentOrStretch refer to whether the toplevel value
  // should be treated as a percentage type for web-exposed behavior
  // decisions.  However, a value can still depend on a percentage when
  // HasPercent() is false:  for example, calc-size(any, 20%).
  [[nodiscard]] bool HasPercent() const;
  [[nodiscard]] bool HasPercentOrStretch() const;
  [[nodiscard]] bool HasStretch() const;

  bool HasMinContent() const;
  bool HasMaxContent() const;
  bool HasMinIntrinsic() const { return IsMinIntrinsic(); }
  bool HasFitContent() const;

  bool IsSpecified() const { return GetType() == kFixed || GetType() == kPercent || GetType() == kCalculated; }

  bool IsCalculated() const { return GetType() == kCalculated; }
  bool IsCalculatedEqual(const Length&) const;

  // These type checking methods should be used with extreme caution;
  // many uses probably want the Has* methods above to work correctly
  // with calc-size().
  bool IsMinContent() const { return GetType() == kMinContent; }
  bool IsMaxContent() const { return GetType() == kMaxContent; }
  bool IsMinIntrinsic() const { return GetType() == kMinIntrinsic; }
  bool IsFillAvailable() const { return GetType() == kFillAvailable; }
  bool IsFitContent() const { return GetType() == kFitContent; }
  bool IsPercent() const { return GetType() == kPercent; }
  // MayHavePercentDependence should be used to decide whether to optimize
  // away computing the value on which percentages depend or optimize away
  // recomputation that results from changes to that value.  It is intended to
  // be used *only* in cases where the implementation could be changed to one
  // that returns true only if there are percentage values somewhere in the
  // expression (that is, one that still returns true for calc-size(any, 30%)
  // for which HasPercent() is false, but is false for calc-size(any, 30px)).
  //
  // We could (if we want) make this exact and remove "May" from the name.
  // But this would require looking into the calculation value like HasPercent
  // does.  However, it needs to be different from HasPercent because of cases
  // where calc-size() erases percentage-ness from the type, like
  // calc-size(any, 20%).
  //
  // For properties that cannot have calc-size in them, we currently use
  // HasPercent() rather than MayHavePercentDependence() since it's a
  // shorter/simpler function name, and the two functions are equivalent in
  // that case.
  bool MayHavePercentDependence() const { return GetType() == kPercent || GetType() == kCalculated; }
  bool IsFlex() const { return GetType() == kFlex; }
  bool IsExtendToZoom() const { return GetType() == kExtendToZoom; }
  bool IsDeviceWidth() const { return GetType() == kDeviceWidth; }
  bool IsDeviceHeight() const { return GetType() == kDeviceHeight; }

//  Length Blend(const Length& from, double progress, ValueRange range) const {
//    assert(IsSpecified());
//    assert(from.IsSpecified());
//
//    if (progress == 0.0)
//      return from;
//
//    if (progress == 1.0)
//      return *this;
//
//    if (from.GetType() == kCalculated || GetType() == kCalculated)
//      return BlendMixedTypes(from, progress, range);
//
//    if (!from.IsZero() && !IsZero() && from.GetType() != GetType())
//      return BlendMixedTypes(from, progress, range);
//
//    if (from.IsZero() && IsZero())
//      return *this;
//
//    return BlendSameTypes(from, progress, range);
//  }

  float GetFloatValue() const {
    assert(!IsNone());
    assert(!IsCalculated());
    return value_;
  }

  //  using IntrinsicLengthEvaluator = std::function<LayoutUnit(const Length&)>;

  struct EvaluationInput {
    WEBF_STACK_ALLOCATED();

   public:
    std::optional<float> size_keyword_basis = std::nullopt;
    //    std::optional<IntrinsicLengthEvaluator> intrinsic_evaluator = std::nullopt;
  };

//  float NonNanCalculatedValue(float max_value, const EvaluationInput&) const;

//  Length SubtractFromOneHundredPercent() const;

  Length Add(const Length& other) const;

  Length Zoom(double factor) const;

  std::string ToString() const;

 private:
//  Length BlendMixedTypes(const Length& from, double progress, ValueRange) const;
//
//  Length BlendSameTypes(const Length& from, double progress, ValueRange) const;

  int CalculationHandle() const {
    assert(IsCalculated());
    return calculation_handle_;
  }

  union {
    // If kType == kCalculated.
    int calculation_handle_;

    // Otherwise. Must be zero if not in use (e.g., for kAuto or kNone).
    float value_;
  };
  bool quirk_ = false;
  unsigned char type_;
};

std::ostream& operator<<(std::ostream&, const Length&);

}  // namespace webf

#endif  // WEBF_LENGTH_H
