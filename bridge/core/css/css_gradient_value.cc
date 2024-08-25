/*
 * Copyright (C) 2008 Apple Inc.  All rights reserved.
 * Copyright (C) 2015 Google Inc. All rights reserved.
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

#include "core/css/css_gradient_value.h"

#include <algorithm>
#include <tuple>
#include <utility>

#include "core/css/css_identifier_value.h"
#include "core/css/css_math_function_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_value_pair.h"
#include "core/platform/geometry/SKScalar.h"
#include "core/platform/graphics/gradient.h"
#include "css_value_keywords.h"
#include "core/platform/gfx/geometry/point_f.h"
#include "core/platform/gfx/geometry/rect_f.h"

namespace webf::cssvalue {

namespace {

bool ColorIsDerivedFromElement(const CSSIdentifierValue& value) {
  CSSValueID value_id = value.GetValueID();
  switch (value_id) {
    case CSSValueID::kInternalQuirkInherit:
    case CSSValueID::kWebkitLink:
    case CSSValueID::kWebkitActivelink:
    case CSSValueID::kCurrentcolor:
      return true;
    default:
      return false;
  }
}

bool AppendPosition(StringBuilder& result,
                    std::shared_ptr<const CSSValue> x,
                    std::shared_ptr<const CSSValue> y,
                    bool wrote_something) {
  if (!x && !y) {
    return false;
  }

  if (IsA<CSSIdentifierValue>(x.get()) && To<CSSIdentifierValue>(x.get())->GetValueID() == CSSValueID::kCenter &&
      IsA<CSSIdentifierValue>(y.get()) && To<CSSIdentifierValue>(y.get())->GetValueID() == CSSValueID::kCenter) {
    return false;
  }

  if (wrote_something) {
    result.Append(' ');
  }
  result.Append("at ");

  if (x) {
    result.Append(x->CssText());
    if (y) {
      result.Append(' ');
    }
  }

  if (y) {
    result.Append(y->CssText());
  }

  return true;
}

}  // namespace

bool CSSGradientColorStop::IsCacheable() const {
  if (!IsHint()) {
    auto* identifier_value = DynamicTo<CSSIdentifierValue>(color_.get());
    if (identifier_value && ColorIsDerivedFromElement(*identifier_value)) {
      return false;
    }
  }

  // TODO(crbug.com/979895): This is the result of a refactoring, which might
  // have revealed an existing bug with calculated lengths. Investigate.
  return !offset_ || offset_->IsMathFunctionValue() || !To<CSSNumericLiteralValue>(*offset_).IsFontRelativeLength();
}

void CSSGradientColorStop::Trace(GCVisitor* visitor) const {
  // visitor->Trace(offset_);
  // visitor->Trace(color_);
}

// Should only ever be called for deprecated gradients.
static inline bool CompareStops(const CSSGradientColorStop& a,
                                const CSSGradientColorStop& b,
                                const CSSToLengthConversionData& conversion_data) {
  double a_val = a.offset_->ComputeNumber(conversion_data);
  double b_val = b.offset_->ComputeNumber(conversion_data);

  return a_val < b_val;
}

struct GradientStop {
  Color color;
  float offset;
  bool specified;

  GradientStop() : offset(0), specified(false) {}
};

struct CSSGradientValue::GradientDesc {
  WEBF_STACK_ALLOCATED();

 public:
  GradientDesc(const gfx::PointF& p0, const gfx::PointF& p1, GradientSpreadMethod spread_method)
      : p0(p0), p1(p1), spread_method(spread_method) {}
  GradientDesc(const gfx::PointF& p0, const gfx::PointF& p1, float r0, float r1, GradientSpreadMethod spread_method)
      : p0(p0), p1(p1), r0(r0), r1(r1), spread_method(spread_method) {}

  std::vector<Gradient::ColorStop> stops;
  gfx::PointF p0, p1;
  float r0 = 0, r1 = 0;
  float start_angle = 0, end_angle = 360;
  GradientSpreadMethod spread_method;
};

// Skia has problems when passed infinite, etc floats, filter them to 0.
inline SkScalar WebCoreFloatToSkScalar(float f) {
  return SkFloatToScalar(std::isfinite(f) ? f : 0);
}

inline bool WebCoreFloatNearlyEqual(float a, float b) {
  return SkScalarNearlyEqual(WebCoreFloatToSkScalar(a), WebCoreFloatToSkScalar(b));
}

namespace {

// Used in AdjustedGradientDomainForOffsetRange when the type of v1 - v0 is
// gfx::Vector2dF.
gfx::Vector2dF operator*(const gfx::Vector2dF& v, float scale) {
  return gfx::ScaleVector2d(v, scale);
}

template <typename T>
std::tuple<T, T> AdjustedGradientDomainForOffsetRange(const T& v0, const T& v1, float first_offset, float last_offset) {
  DCHECK_LE(first_offset, last_offset);

  const auto d = v1 - v0;

  // The offsets are relative to the [v0 , v1] segment.
  return std::make_tuple(v0 + d * first_offset, v0 + d * last_offset);
}

// Update the radial gradient radii to align with the given offset range.
void AdjustGradientRadiiForOffsetRange(CSSGradientValue::GradientDesc& desc, float first_offset, float last_offset) {
  DCHECK_LE(first_offset, last_offset);

  // Radial offsets are relative to the [0 , endRadius] segment.
  float adjusted_r0 = ClampTo<float>(desc.r1 * first_offset);
  float adjusted_r1 = ClampTo<float>(desc.r1 * last_offset);
  DCHECK_LE(adjusted_r0, adjusted_r1);
  // Unlike linear gradients (where we can adjust the points arbitrarily),
  // we cannot let our radii turn negative here.
  if (adjusted_r0 < 0) {
    // For the non-repeat case, this can never happen: clampNegativeOffsets()
    // ensures we don't have to deal with negative offsets at this point.

    //    DCHECK_EQ(desc.spread_method, kSpreadMethodRepeat);

    // When in repeat mode, we deal with it by repositioning both radii in the
    // positive domain - shifting them by a multiple of the radius span (which
    // is the period of our repeating gradient -> hence no visible side
    // effects).
    const float radius_span = adjusted_r1 - adjusted_r0;
    const float shift_to_positive = radius_span * ceilf(-adjusted_r0 / radius_span);
    adjusted_r0 += shift_to_positive;
    adjusted_r1 += shift_to_positive;
  }
  DCHECK_GE(adjusted_r0, 0);
  DCHECK_GE(adjusted_r1, adjusted_r0);

  desc.r0 = adjusted_r0;
  desc.r1 = adjusted_r1;
}

}  // namespace

static float PositionFromValue(std::shared_ptr<const CSSValue> value,
                               const CSSToLengthConversionData& conversion_data,
                               const gfx::SizeF& size,
                               bool is_horizontal) {
  float origin = 0;
  int sign = 1;
  float edge_distance = is_horizontal ? size.width() : size.height();

  // In this case the center of the gradient is given relative to an edge in the
  // form of: [ top | bottom | right | left ] [ <percentage> | <length> ].
  if (const auto* pair = DynamicTo<CSSValuePair>(*value)) {
    CSSValueID origin_id = To<CSSIdentifierValue>(pair->First().get())->GetValueID();
    value = pair->Second();

    if (origin_id == CSSValueID::kRight || origin_id == CSSValueID::kBottom) {
      // For right/bottom, the offset is relative to the far edge.
      origin = edge_distance;
      sign = -1;
    }
  }

  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(value.get())) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kTop:
        DCHECK(!is_horizontal);
        return 0;
      case CSSValueID::kLeft:
        DCHECK(is_horizontal);
        return 0;
      case CSSValueID::kBottom:
        DCHECK(!is_horizontal);
        return size.height();
      case CSSValueID::kRight:
        DCHECK(is_horizontal);
        return size.width();
      case CSSValueID::kCenter:
        return origin + sign * .5f * edge_distance;
      default:
        NOTREACHED_IN_MIGRATION();
        break;
    }
  }

  const CSSPrimitiveValue* primitive_value = To<CSSPrimitiveValue>(value.get());

  if (primitive_value->IsNumber()) {
    return origin + sign * primitive_value->ComputeNumber(conversion_data) * conversion_data.Zoom();
  }

  if (primitive_value->IsPercentage()) {
    return origin + sign * primitive_value->ComputePercentage(conversion_data) / 100.f * edge_distance;
  }

  if (primitive_value->IsCalculatedPercentageWithLength()) {
    return origin +
           sign * To<CSSMathFunctionValue>(primitive_value)->ToCalcValue(conversion_data)->Evaluate(edge_distance);
  }

  return origin + sign * primitive_value->ComputeLength<float>(conversion_data);
}

// Resolve points/radii to front end values.
static gfx::PointF ComputeEndPoint(std::shared_ptr<const CSSValue> horizontal,
                                   std::shared_ptr<const CSSValue> vertical,
                                   const CSSToLengthConversionData& conversion_data,
                                   const gfx::SizeF& size) {
  gfx::PointF result;

  if (horizontal) {
    result.set_x(PositionFromValue(horizontal, conversion_data, size, true));
  }

  if (vertical) {
    result.set_y(PositionFromValue(vertical, conversion_data, size, false));
  }

  return result;
}

void CSSGradientValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSImageGeneratorValue::TraceAfterDispatch(visitor);
}

std::string CSSLinearGradientValue::CustomCSSText() const {
  StringBuilder result;
  if (gradient_type_ == kCSSDeprecatedLinearGradient) {
    result.Append("-webkit-gradient(linear, ");
    result.Append(first_x_->CssText());
    result.Append(' ');
    result.Append(first_y_->CssText());
    result.Append(", ");
    result.Append(second_x_->CssText());
    result.Append(' ');
    result.Append(second_y_->CssText());
    AppendCSSTextForDeprecatedColorStops(result);
  } else if (gradient_type_ == kCSSPrefixedLinearGradient) {
    if (repeating_) {
      result.Append("-webkit-repeating-linear-gradient(");
    } else {
      result.Append("-webkit-linear-gradient(");
    }

    if (angle_) {
      result.Append(angle_->CssText());
    } else {
      if (first_x_ && first_y_) {
        result.Append(first_x_->CssText());
        result.Append(' ');
        result.Append(first_y_->CssText());
      } else if (first_x_ || first_y_) {
        if (first_x_) {
          result.Append(first_x_->CssText());
        }

        if (first_y_) {
          result.Append(first_y_->CssText());
        }
      }
    }

    constexpr bool kAppendSeparator = true;
    AppendCSSTextForColorStops(result, kAppendSeparator);
  } else {
    if (repeating_) {
      result.Append("repeating-linear-gradient(");
    } else {
      result.Append("linear-gradient(");
    }

    bool wrote_something = false;

    if (angle_ && (angle_->IsMathFunctionValue() ||
                   (angle_->IsNumericLiteralValue() && To<CSSNumericLiteralValue>(*angle_).ComputeDegrees() != 180))) {
      result.Append(angle_->CssText());
      wrote_something = true;
    } else if ((first_x_ || first_y_) &&
               !(!first_x_ && first_y_ && first_y_->IsIdentifierValue() &&
                 To<CSSIdentifierValue>(first_y_.get())->GetValueID() == CSSValueID::kBottom)) {
      result.Append("to ");
      if (first_x_ && first_y_) {
        result.Append(first_x_->CssText());
        result.Append(' ');
        result.Append(first_y_->CssText());
      } else if (first_x_) {
        result.Append(first_x_->CssText());
      } else {
        result.Append(first_y_->CssText());
      }
      wrote_something = true;
    }

    AppendCSSTextForColorStops(result, wrote_something);
  }

  result.Append(')');
  return result.ReleaseString();
}

// Compute the endpoints so that a gradient of the given angle covers a box of
// the given size.
static void EndPointsFromAngle(float angle_deg,
                               const gfx::SizeF& size,
                               gfx::PointF& first_point,
                               gfx::PointF& second_point,
                               CSSGradientType type) {
  // Prefixed gradients use "polar coordinate" angles, rather than "bearing"
  // angles.
  if (type == kCSSPrefixedLinearGradient) {
    angle_deg = 90 - angle_deg;
  }

  angle_deg = fmodf(angle_deg, 360);
  if (angle_deg < 0) {
    angle_deg += 360;
  }

  if (!angle_deg) {
    first_point.SetPoint(0, size.height());
    second_point.SetPoint(0, 0);
    return;
  }

  if (angle_deg == 90) {
    first_point.SetPoint(0, 0);
    second_point.SetPoint(size.width(), 0);
    return;
  }

  if (angle_deg == 180) {
    first_point.SetPoint(0, 0);
    second_point.SetPoint(0, size.height());
    return;
  }

  if (angle_deg == 270) {
    first_point.SetPoint(size.width(), 0);
    second_point.SetPoint(0, 0);
    return;
  }

  // angleDeg is a "bearing angle" (0deg = N, 90deg = E),
  // but tan expects 0deg = E, 90deg = N.
  float slope = tan(Deg2rad(90 - angle_deg));

  // We find the endpoint by computing the intersection of the line formed by
  // the slope, and a line perpendicular to it that intersects the corner.
  float perpendicular_slope = -1 / slope;

  // Compute start corner relative to center, in Cartesian space (+y = up).
  float half_height = size.height() / 2;
  float half_width = size.width() / 2;
  gfx::PointF end_corner;
  if (angle_deg < 90) {
    end_corner.SetPoint(half_width, half_height);
  } else if (angle_deg < 180) {
    end_corner.SetPoint(half_width, -half_height);
  } else if (angle_deg < 270) {
    end_corner.SetPoint(-half_width, -half_height);
  } else {
    end_corner.SetPoint(-half_width, half_height);
  }

  // Compute c (of y = mx + c) using the corner point.
  float c = end_corner.y() - perpendicular_slope * end_corner.x();
  float end_x = c / (slope - perpendicular_slope);
  float end_y = perpendicular_slope * end_x + c;

  // We computed the end point, so set the second point, taking into account the
  // moved origin and the fact that we're in drawing space (+y = down).
  second_point.SetPoint(half_width + end_x, half_height - end_y);
  // Reflect around the center for the start point.
  first_point.SetPoint(half_width - end_x, half_height + end_y);
}

std::shared_ptr<Gradient> CSSLinearGradientValue::CreateGradient(const CSSToLengthConversionData& conversion_data,
                                                                 const gfx::SizeF& size,
                                                                 const Document& document,
                                                                 const ComputedStyle& style) const {
  DCHECK(!size.IsEmpty());

  gfx::PointF first_point;
  gfx::PointF second_point;
  if (angle_) {
    float angle = angle_->ComputeDegrees(conversion_data);
    EndPointsFromAngle(angle, size, first_point, second_point, gradient_type_);
  } else {
    switch (gradient_type_) {
      case kCSSDeprecatedLinearGradient:
        first_point = ComputeEndPoint(first_x_, first_y_, conversion_data, size);
        if (second_x_ || second_y_) {
          second_point = ComputeEndPoint(second_x_, second_y_, conversion_data, size);
        } else {
          if (first_x_) {
            second_point.set_x(size.width() - first_point.x());
          }
          if (first_y_) {
            second_point.set_y(size.height() - first_point.y());
          }
        }
        break;
      case kCSSPrefixedLinearGradient:
        first_point = ComputeEndPoint(first_x_, first_y_, conversion_data, size);
        if (first_x_) {
          second_point.set_x(size.width() - first_point.x());
        }
        if (first_y_) {
          second_point.set_y(size.height() - first_point.y());
        }
        break;
      case kCSSLinearGradient:
        if (first_x_ && first_y_) {
          // "Magic" corners, so the 50% line touches two corners.
          float rise = size.width();
          float run = size.height();
          auto* first_x_identifier_value = DynamicTo<CSSIdentifierValue>(first_x_.get());
          if (first_x_identifier_value && first_x_identifier_value->GetValueID() == CSSValueID::kLeft) {
            run *= -1;
          }
          auto* first_y_identifier_value = DynamicTo<CSSIdentifierValue>(first_y_.get());
          if (first_y_identifier_value && first_y_identifier_value->GetValueID() == CSSValueID::kBottom) {
            rise *= -1;
          }
          // Compute angle, and flip it back to "bearing angle" degrees.
          float angle = 90 - Rad2deg(atan2(rise, run));
          EndPointsFromAngle(angle, size, first_point, second_point, gradient_type_);
        } else if (first_x_ || first_y_) {
          second_point = ComputeEndPoint(first_x_, first_y_, conversion_data, size);
          if (first_x_) {
            first_point.set_x(size.width() - second_point.x());
          }
          if (first_y_) {
            first_point.set_y(size.height() - second_point.y());
          }
        } else {
          second_point.set_y(size.height());
        }
        break;
      default:
        NOTREACHED_IN_MIGRATION();
    }
  }

  GradientDesc desc(first_point, second_point, repeating_ ? kSpreadMethodRepeat : kSpreadMethodPad);
  //  AddStops(desc, conversion_data, document, style);

  std::shared_ptr<Gradient> gradient =
      Gradient::CreateLinear(desc.p0, desc.p1, desc.spread_method, Gradient::ColorInterpolation::kPremultiplied);

  //  gradient->SetColorInterpolationSpace(color_interpolation_space_, hue_interpolation_method_);
  gradient->AddColorStops(desc.stops);

  return gradient;
}

bool CSSLinearGradientValue::Equals(const CSSLinearGradientValue& other) const {
  if (gradient_type_ != other.gradient_type_) {
    return false;
  }

  if (gradient_type_ == kCSSDeprecatedLinearGradient) {
    return ValuesEquivalent(first_x_, other.first_x_) && ValuesEquivalent(first_y_, other.first_y_) &&
           ValuesEquivalent(second_x_, other.second_x_) && ValuesEquivalent(second_y_, other.second_y_) &&
           stops_ == other.stops_;
  }

  if (!CSSGradientValue::Equals(other)) {
    return false;
  }

  if (angle_) {
    return ValuesEquivalent(angle_, other.angle_) && stops_ == other.stops_;
  }

  if (other.angle_) {
    return false;
  }

  bool equal_xand_y = false;
  if (first_x_ && first_y_) {
    equal_xand_y = ValuesEquivalent(first_x_, other.first_x_) && ValuesEquivalent(first_y_, other.first_y_);
  } else if (first_x_) {
    equal_xand_y = ValuesEquivalent(first_x_, other.first_x_) && !other.first_y_;
  } else if (first_y_) {
    equal_xand_y = ValuesEquivalent(first_y_, other.first_y_) && !other.first_x_;
  } else {
    equal_xand_y = !other.first_x_ && !other.first_y_;
  }

  return equal_xand_y;
}

static bool IsUsingCurrentColor(const std::vector<CSSGradientColorStop>& stops) {
  for (const CSSGradientColorStop& stop : stops) {
    auto* identifier_value = DynamicTo<CSSIdentifierValue>(stop.color_.get());
    if (identifier_value && identifier_value->GetValueID() == CSSValueID::kCurrentcolor) {
      return true;
    }
  }
  return false;
}

static bool IsUsingContainerRelativeUnits(const CSSValue* value) {
  const auto* primitive_value = DynamicTo<CSSPrimitiveValue>(value);
  return primitive_value && primitive_value->HasContainerRelativeUnits();
}

static bool IsUsingContainerRelativeUnits(const std::vector<CSSGradientColorStop>& stops) {
  for (const CSSGradientColorStop& stop : stops) {
    if (IsUsingContainerRelativeUnits(stop.offset_.get())) {
      return true;
    }
  }
  return false;
}

bool CSSLinearGradientValue::IsUsingCurrentColor() const {
  return webf::cssvalue::IsUsingCurrentColor(stops_);
}

bool CSSLinearGradientValue::IsUsingContainerRelativeUnits() const {
  return webf::cssvalue::IsUsingContainerRelativeUnits(stops_);
}

void CSSLinearGradientValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSGradientValue::TraceAfterDispatch(visitor);
}

void CSSGradientValue::AppendCSSTextForColorStops(StringBuilder& result, bool requires_separator) const {
  for (const auto& stop : stops_) {
    if (requires_separator) {
      result.Append(", ");
    } else {
      requires_separator = true;
    }

    if (stop.color_) {
      result.Append(stop.color_->CssText());
    }
    if (stop.color_ && stop.offset_) {
      result.Append(' ');
    }
    if (stop.offset_) {
      result.Append(stop.offset_->CssText());
    }
  }
}

void CSSGradientValue::AppendCSSTextForDeprecatedColorStops(StringBuilder& result) const {
  for (unsigned i = 0; i < stops_.size(); i++) {
    const CSSGradientColorStop& stop = stops_[i];
    result.Append(", ");
    if (stop.offset_->IsZero() == CSSPrimitiveValue::BoolStatus::kTrue) {
      result.Append("from(");
      result.Append(stop.color_->CssText());
      result.Append(')');
    } else if (stop.offset_->IsOne() == CSSPrimitiveValue::BoolStatus::kTrue) {
      result.Append("to(");
      result.Append(stop.color_->CssText());
      result.Append(')');
    } else {
      result.Append("color-stop(");
      result.Append(stop.offset_->CssText());
      result.Append(", ");
      result.Append(stop.color_->CssText());
      result.Append(')');
    }
  }
}

bool CSSGradientValue::Equals(const CSSGradientValue& other) const {
  return repeating_ == other.repeating_ && stops_ == other.stops_;
}

std::string CSSRadialGradientValue::CustomCSSText() const {
  StringBuilder result;

  if (gradient_type_ == kCSSDeprecatedRadialGradient) {
    result.Append("-webkit-gradient(radial, ");
    result.Append(first_x_->CssText());
    result.Append(' ');
    result.Append(first_y_->CssText());
    result.Append(", ");
    result.Append(first_radius_->CssText());
    result.Append(", ");
    result.Append(second_x_->CssText());
    result.Append(' ');
    result.Append(second_y_->CssText());
    result.Append(", ");
    result.Append(second_radius_->CssText());
    AppendCSSTextForDeprecatedColorStops(result);
  } else if (gradient_type_ == kCSSPrefixedRadialGradient) {
    if (repeating_) {
      result.Append("-webkit-repeating-radial-gradient(");
    } else {
      result.Append("-webkit-radial-gradient(");
    }

    if (first_x_ && first_y_) {
      result.Append(first_x_->CssText());
      result.Append(' ');
      result.Append(first_y_->CssText());
    } else if (first_x_) {
      result.Append(first_x_->CssText());
    } else if (first_y_) {
      result.Append(first_y_->CssText());
    } else {
      result.Append("center");
    }

    if (shape_ || sizing_behavior_) {
      result.Append(", ");
      if (shape_) {
        result.Append(shape_->CssText());
        result.Append(' ');
      } else {
        result.Append("ellipse ");
      }

      if (sizing_behavior_) {
        result.Append(sizing_behavior_->CssText());
      } else {
        result.Append("cover");
      }

    } else if (end_horizontal_size_ && end_vertical_size_) {
      result.Append(", ");
      result.Append(end_horizontal_size_->CssText());
      result.Append(' ');
      result.Append(end_vertical_size_->CssText());
    }
    constexpr bool kAppendSeparator = true;

    AppendCSSTextForColorStops(result, kAppendSeparator);
  } else {
    if (repeating_) {
      result.Append("repeating-radial-gradient(");
    } else {
      result.Append("radial-gradient(");
    }

    bool wrote_something = false;

    // The only ambiguous case that needs an explicit shape to be provided
    // is when a sizing keyword is used (or all sizing is omitted).
    if (shape_ && shape_->GetValueID() != CSSValueID::kEllipse &&
        (sizing_behavior_ || (!sizing_behavior_ && !end_horizontal_size_))) {
      result.Append("circle");
      wrote_something = true;
    }

    if (sizing_behavior_ && sizing_behavior_->GetValueID() != CSSValueID::kFarthestCorner) {
      if (wrote_something) {
        result.Append(' ');
      }
      result.Append(sizing_behavior_->CssText());
      wrote_something = true;
    } else if (end_horizontal_size_) {
      if (wrote_something) {
        result.Append(' ');
      }
      result.Append(end_horizontal_size_->CssText());
      if (end_vertical_size_) {
        result.Append(' ');
        result.Append(end_vertical_size_->CssText());
      }
      wrote_something = true;
    }

    wrote_something |= AppendPosition(result, first_x_, first_y_, wrote_something);

    AppendCSSTextForColorStops(result, wrote_something);
  }

  result.Append(')');
  return result.ReleaseString();
}

namespace {

// Resolve points/radii to front end values.
float ResolveRadius(const std::shared_ptr<const CSSPrimitiveValue> radius,
                    const CSSToLengthConversionData& conversion_data,
                    float* width_or_height = nullptr) {
  float result = 0;
  if (radius->IsNumber()) {
    result = radius->ComputeNumber(conversion_data) * conversion_data.Zoom();
  } else if (width_or_height && radius->IsPercentage()) {
    result = *width_or_height * radius->ComputePercentage(conversion_data) / 100;
  } else {
    result = radius->ComputeLength<float>(conversion_data);
  }

  return ClampTo<float>(std::max(result, 0.0f));
}

enum EndShapeType { kCircleEndShape, kEllipseEndShape };

// Compute the radius to the closest/farthest side (depending on the compare
// functor).
gfx::SizeF RadiusToSide(const gfx::PointF& point,
                        const gfx::SizeF& size,
                        EndShapeType shape,
                        bool (*compare)(float, float)) {
  float dx1 = ClampTo<float>(fabs(point.x()));
  float dy1 = ClampTo<float>(fabs(point.y()));
  float dx2 = ClampTo<float>(fabs(point.x() - size.width()));
  float dy2 = ClampTo<float>(fabs(point.y() - size.height()));

  float dx = compare(dx1, dx2) ? dx1 : dx2;
  float dy = compare(dy1, dy2) ? dy1 : dy2;

  if (shape == kCircleEndShape) {
    return compare(dx, dy) ? gfx::SizeF(dx, dx) : gfx::SizeF(dy, dy);
  }

  DCHECK_EQ(shape, kEllipseEndShape);
  return gfx::SizeF(dx, dy);
}

// Compute the radius of an ellipse which passes through a point at
// |offset_from_center|, and has width/height given by aspectRatio.
inline gfx::SizeF EllipseRadius(const gfx::Vector2dF& offset_from_center, float aspect_ratio) {
  // If the aspectRatio is 0 or infinite, the ellipse is completely flat.
  // (If it is NaN, the ellipse is 0x0, and should be handled as zero width.)
  // TODO(sashab): Implement Degenerate Radial Gradients, see crbug.com/635727.
  if (!std::isfinite(aspect_ratio) || aspect_ratio == 0) {
    return gfx::SizeF(0, 0);
  }

  // x^2/a^2 + y^2/b^2 = 1
  // a/b = aspectRatio, b = a/aspectRatio
  // a = sqrt(x^2 + y^2/(1/aspect_ratio^2))
  float a = sqrtf(offset_from_center.x() * offset_from_center.x() +
                  offset_from_center.y() * offset_from_center.y() * aspect_ratio * aspect_ratio);
  return gfx::SizeF(ClampTo<float>(a), ClampTo<float>(a / aspect_ratio));
}

// Compute the radius to the closest/farthest corner (depending on the compare
// functor).
gfx::SizeF RadiusToCorner(const gfx::PointF& point,
                          const gfx::SizeF& size,
                          EndShapeType shape,
                          bool (*compare)(float, float)) {
  const gfx::RectF rect(size);
  const gfx::PointF corners[] = {rect.origin(), rect.top_right(), rect.bottom_right(), rect.bottom_left()};

  unsigned corner_index = 0;
  float distance = (point - corners[corner_index]).Length();
  for (unsigned i = 1; i < std::size(corners); ++i) {
    float new_distance = (point - corners[i]).Length();
    if (compare(new_distance, distance)) {
      corner_index = i;
      distance = new_distance;
    }
  }

  if (shape == kCircleEndShape) {
    distance = ClampTo<float>(distance);
    return gfx::SizeF(distance, distance);
  }

  DCHECK_EQ(shape, kEllipseEndShape);
  // If the end shape is an ellipse, the gradient-shape has the same ratio of
  // width to height that it would if closest-side or farthest-side were
  // specified, as appropriate.
  const gfx::SizeF side_radius = RadiusToSide(point, size, kEllipseEndShape, compare);

  return EllipseRadius(corners[corner_index] - point, side_radius.AspectRatio());
}

}  // anonymous namespace

std::shared_ptr<Gradient> CSSRadialGradientValue::CreateGradient(const CSSToLengthConversionData& conversion_data,
                                                               const gfx::SizeF& size,
                                                               const Document& document,
                                                               const ComputedStyle& style) const {
  DCHECK(!size.IsEmpty());

  gfx::PointF first_point = ComputeEndPoint(first_x_, first_y_, conversion_data, size);
  if (!first_x_) {
    first_point.set_x(size.width() / 2);
  }
  if (!first_y_) {
    first_point.set_y(size.height() / 2);
  }

  gfx::PointF second_point = ComputeEndPoint(second_x_, second_y_, conversion_data, size);
  if (!second_x_) {
    second_point.set_x(size.width() / 2);
  }
  if (!second_y_) {
    second_point.set_y(size.height() / 2);
  }

  float first_radius = 0;
  if (first_radius_) {
    first_radius = ResolveRadius(first_radius_, conversion_data);
  }

  gfx::SizeF second_radius(0, 0);
  if (second_radius_) {
    second_radius.set_width(ResolveRadius(second_radius_, conversion_data));
    second_radius.set_height(second_radius.width());
  } else if (end_horizontal_size_) {
    float width = size.width();
    float height = size.height();
    second_radius.set_width(ResolveRadius(end_horizontal_size_, conversion_data, &width));
    second_radius.set_height(end_vertical_size_ ? ResolveRadius(end_vertical_size_, conversion_data, &height)
                                                : second_radius.width());
  } else {
    EndShapeType shape = (shape_ && shape_->GetValueID() == CSSValueID::kCircle) ||
                                 (!shape_ && !sizing_behavior_ && end_horizontal_size_ && !end_vertical_size_)
                             ? kCircleEndShape
                             : kEllipseEndShape;

    switch (sizing_behavior_ ? sizing_behavior_->GetValueID() : CSSValueID::kInvalid) {
      case CSSValueID::kContain:
      case CSSValueID::kClosestSide:
        second_radius = RadiusToSide(second_point, size, shape, [](float a, float b) { return a < b; });
        break;
      case CSSValueID::kFarthestSide:
        second_radius = RadiusToSide(second_point, size, shape, [](float a, float b) { return a > b; });
        break;
      case CSSValueID::kClosestCorner:
        second_radius = RadiusToCorner(second_point, size, shape, [](float a, float b) { return a < b; });
        break;
      default:
        second_radius = RadiusToCorner(second_point, size, shape, [](float a, float b) { return a > b; });
        break;
    }
  }

  DCHECK(std::isfinite(first_radius));
  DCHECK(std::isfinite(second_radius.width()));
  DCHECK(std::isfinite(second_radius.height()));

  bool is_degenerate = !second_radius.width() || !second_radius.height();
  GradientDesc desc(first_point, second_point, first_radius, is_degenerate ? 0 : second_radius.width(),
                    repeating_ ? kSpreadMethodRepeat : kSpreadMethodPad);
//  AddStops(desc, conversion_data, document, style);

  std::shared_ptr<Gradient> gradient =
      Gradient::CreateRadial(desc.p0, desc.r0, desc.p1, desc.r1, is_degenerate ? 1 : second_radius.AspectRatio(),
                             desc.spread_method, Gradient::ColorInterpolation::kPremultiplied);

//  gradient->SetColorInterpolationSpace(color_interpolation_space_, hue_interpolation_method_);
  gradient->AddColorStops(desc.stops);

  return gradient;
}

namespace {

bool EqualIdentifiersWithDefault(const CSSIdentifierValue* id_a,
                                 const CSSIdentifierValue* id_b,
                                 CSSValueID default_id) {
  CSSValueID value_a = id_a ? id_a->GetValueID() : default_id;
  CSSValueID value_b = id_b ? id_b->GetValueID() : default_id;
  return value_a == value_b;
}

}  // namespace

bool CSSRadialGradientValue::Equals(const CSSRadialGradientValue& other) const {
  if (gradient_type_ == kCSSDeprecatedRadialGradient) {
    return other.gradient_type_ == gradient_type_ && ValuesEquivalent(first_x_, other.first_x_) &&
           ValuesEquivalent(first_y_, other.first_y_) && ValuesEquivalent(second_x_, other.second_x_) &&
           ValuesEquivalent(second_y_, other.second_y_) &&
           ValuesEquivalent(first_radius_, other.first_radius_) &&
           ValuesEquivalent(second_radius_, other.second_radius_) && stops_ == other.stops_;
  }

  if (!CSSGradientValue::Equals(other)) {
    return false;
  }

  if (!ValuesEquivalent(first_x_, other.first_x_) || !ValuesEquivalent(first_y_, other.first_y_)) {
    return false;
  }

  // There's either a size keyword or an explicit size specification.
  if (end_horizontal_size_) {
    // Explicit size specification. One <length> or two <length-percentage>.
    if (!ValuesEquivalent(end_horizontal_size_, other.end_horizontal_size_)) {
      return false;
    }
    if (!ValuesEquivalent(end_vertical_size_, other.end_vertical_size_)) {
      return false;
    }
  } else {
    if (other.end_horizontal_size_) {
      return false;
    }
    // There's a size keyword.
    if (!EqualIdentifiersWithDefault(sizing_behavior_.get(), other.sizing_behavior_.get(), CSSValueID::kFarthestCorner)) {
      return false;
    }
    // Here the shape is 'ellipse' unless explicitly set to 'circle'.
    if (!EqualIdentifiersWithDefault(shape_.get(), other.shape_.get(), CSSValueID::kEllipse)) {
      return false;
    }
  }
  return true;
}

bool CSSRadialGradientValue::IsUsingCurrentColor() const {
  return webf::cssvalue::IsUsingCurrentColor(stops_);
}

bool CSSRadialGradientValue::IsUsingContainerRelativeUnits() const {
  return webf::cssvalue::IsUsingContainerRelativeUnits(stops_);
}

void CSSRadialGradientValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSGradientValue::TraceAfterDispatch(visitor);
}

std::string CSSConicGradientValue::CustomCSSText() const {
  StringBuilder result;

  if (repeating_) {
    result.Append("repeating-");
  }
  result.Append("conic-gradient(");

  bool wrote_something = false;

  if (from_angle_) {
    result.Append("from ");
    result.Append(from_angle_->CssText());
    wrote_something = true;
  }

  wrote_something |= AppendPosition(result, x_, y_, wrote_something);

  AppendCSSTextForColorStops(result, wrote_something);

  result.Append(')');
  return result.ReleaseString();
}

std::shared_ptr<Gradient> CSSConicGradientValue::CreateGradient(const CSSToLengthConversionData& conversion_data,
                                                              const gfx::SizeF& size,
                                                              const Document& document,
                                                              const ComputedStyle& style) const {
  DCHECK(!size.IsEmpty());

  const float angle = from_angle_ ? from_angle_->ComputeDegrees(conversion_data) : 0;

  const gfx::PointF position(x_ ? PositionFromValue(x_, conversion_data, size, true) : size.width() / 2,
                             y_ ? PositionFromValue(y_, conversion_data, size, false) : size.height() / 2);

  GradientDesc desc(position, position, repeating_ ? kSpreadMethodRepeat : kSpreadMethodPad);
//  AddStops(desc, conversion_data, document, style);

  std::shared_ptr<Gradient> gradient =
      Gradient::CreateConic(position, angle, desc.start_angle, desc.end_angle, desc.spread_method,
                            Gradient::ColorInterpolation::kPremultiplied);

//  gradient->SetColorInterpolationSpace(color_interpolation_space_, hue_interpolation_method_);
  gradient->AddColorStops(desc.stops);

  return gradient;
}

bool CSSConicGradientValue::Equals(const CSSConicGradientValue& other) const {
  return CSSGradientValue::Equals(other) && ValuesEquivalent(x_, other.x_) &&
         ValuesEquivalent(y_, other.y_) && ValuesEquivalent(from_angle_, other.from_angle_);
}

bool CSSConicGradientValue::IsUsingCurrentColor() const {
  return webf::cssvalue::IsUsingCurrentColor(stops_);
}

bool CSSConicGradientValue::IsUsingContainerRelativeUnits() const {
  return webf::cssvalue::IsUsingContainerRelativeUnits(stops_) ||
         webf::cssvalue::IsUsingContainerRelativeUnits(x_.get()) ||
         webf::cssvalue::IsUsingContainerRelativeUnits(y_.get());
}

void CSSConicGradientValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSGradientValue::TraceAfterDispatch(visitor);
}

bool CSSConstantGradientValue::Equals(const CSSConstantGradientValue& other) const {
  return ValuesEquivalent(color_, other.color_);
}

void CSSConstantGradientValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSGradientValue::TraceAfterDispatch(visitor);
}

std::shared_ptr<Gradient> CSSConstantGradientValue::CreateGradient(const CSSToLengthConversionData& conversion_data,
                                                                 const gfx::SizeF& size,
                                                                 const Document& document,
                                                                 const ComputedStyle& style) const {
  DCHECK(!size.IsEmpty());

  GradientDesc desc({0.0f, 0.0f}, {1.0f, 1.0f}, kSpreadMethodPad);
//  const Color color = ResolveStopColor(*color_, document, style);
//  desc.stops.emplace_back(0.0f, color);
//  desc.stops.emplace_back(1.0f, color);

  std::shared_ptr<Gradient> gradient =
      Gradient::CreateLinear(desc.p0, desc.p1, desc.spread_method, Gradient::ColorInterpolation::kPremultiplied);

//  gradient->SetColorInterpolationSpace(color_interpolation_space_, hue_interpolation_method_);
//  gradient->AddColorStops(desc.stops);

  return gradient;
}

}  // namespace webf::cssvalue