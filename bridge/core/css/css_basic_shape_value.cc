/*
 * Copyright (C) 2011 Adobe Systems Incorporated. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer.
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "core/css/css_basic_shape_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "foundation/string_builder.h"

namespace webf {
namespace cssvalue {

static std::string BuildCircleString(const std::string& radius,
                                     const std::string& center_x,
                                     const std::string& center_y,
                                     bool has_explicit_center) {
  char at[] = "at";
  char separator[] = " ";
  StringBuilder result;
  result.Append("circle(");
  if (!radius.empty()) {
    result.Append(radius);
  }

  if (has_explicit_center) {
    if (!radius.empty()) {
      result.Append(separator);
    }
    result.Append(at);
    result.Append(separator);
    result.Append(center_x);
    result.Append(separator);
    result.Append(center_y);
  }
  result.Append(')');
  return result.ReleaseString();
}

static std::string SerializePositionOffset(const CSSValuePair& offset, const CSSValuePair& other) {
  if ((To<CSSIdentifierValue>(offset.First().get())->GetValueID() == CSSValueID::kLeft &&
       To<CSSIdentifierValue>(other.First().get())->GetValueID() == CSSValueID::kTop) ||
      (To<CSSIdentifierValue>(offset.First().get())->GetValueID() == CSSValueID::kTop &&
       To<CSSIdentifierValue>(other.First().get())->GetValueID() == CSSValueID::kLeft)) {
    return offset.Second()->CssText();
  }
  return offset.CssText();
}

static std::shared_ptr<const CSSValuePair> BuildSerializablePositionOffset(
    const std::shared_ptr<const CSSValue>& offset,
    CSSValueID default_side) {
  CSSValueID side = default_side;
  std::shared_ptr<const CSSPrimitiveValue> amount = nullptr;

  if (!offset) {
    side = CSSValueID::kCenter;
  } else if (auto* offset_identifier_value = DynamicTo<CSSIdentifierValue>(offset.get())) {
    side = offset_identifier_value->GetValueID();
  } else if (auto* offset_value_pair = DynamicTo<CSSValuePair>(offset.get())) {
    side = To<CSSIdentifierValue>(*offset_value_pair->First()).GetValueID();
    amount = std::static_pointer_cast<const CSSPrimitiveValue>(offset_value_pair->Second());
    if ((side == CSSValueID::kRight || side == CSSValueID::kBottom) && amount->IsPercentage()) {
      side = default_side;
      amount = CSSNumericLiteralValue::Create(100 - amount->GetFloatValue(), CSSPrimitiveValue::UnitType::kPercentage);
    }
  } else {
    amount = std::static_pointer_cast<const CSSPrimitiveValue>(offset);
  }

  if (side == CSSValueID::kCenter) {
    side = default_side;
    amount = CSSNumericLiteralValue::Create(50, CSSPrimitiveValue::UnitType::kPercentage);
  } else if (!amount || (amount->IsLength() && amount->IsZero() == CSSPrimitiveValue::BoolStatus::kTrue)) {
    if (side == CSSValueID::kRight || side == CSSValueID::kBottom) {
      amount = CSSNumericLiteralValue::Create(100, CSSPrimitiveValue::UnitType::kPercentage);
    } else {
      amount = CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kPercentage);
    }
    side = default_side;
  }

  return std::make_shared<CSSValuePair>(CSSIdentifierValue::Create(side), amount, CSSValuePair::kKeepIdenticalValues);
}

std::string CSSBasicShapeCircleValue::CustomCSSText() const {
  std::shared_ptr<const CSSValuePair> normalized_cx = BuildSerializablePositionOffset(center_x_, CSSValueID::kLeft);
  std::shared_ptr<const CSSValuePair> normalized_cy = BuildSerializablePositionOffset(center_y_, CSSValueID::kTop);

  std::string radius;
  auto* radius_identifier_value = DynamicTo<CSSIdentifierValue>(radius_.get());
  if (radius_ && !(radius_identifier_value && radius_identifier_value->GetValueID() == CSSValueID::kClosestSide)) {
    radius = radius_->CssText();
  }

  return BuildCircleString(radius, SerializePositionOffset(*normalized_cx, *normalized_cy),
                           SerializePositionOffset(*normalized_cy, *normalized_cx), center_x_ != nullptr);
}

bool CSSBasicShapeCircleValue::Equals(const CSSBasicShapeCircleValue& other) const {
  return ValuesEquivalent(center_x_, other.center_x_) && ValuesEquivalent(center_y_, other.center_y_) &&
         ValuesEquivalent(radius_, other.radius_);
}

void CSSBasicShapeCircleValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

static std::string BuildEllipseString(const std::string& radius_x,
                                      const std::string& radius_y,
                                      const std::string& center_x,
                                      const std::string& center_y,
                                      bool has_explicit_center) {
  char at[] = "at";
  char separator[] = " ";
  StringBuilder result;
  result.Append("ellipse(");
  bool needs_separator = false;
  if (!radius_x.empty()) {
    result.Append(radius_x);
    needs_separator = true;
  }
  if (!radius_y.empty()) {
    if (needs_separator) {
      result.Append(separator);
    }
    result.Append(radius_y);
    needs_separator = true;
  }

  if (has_explicit_center) {
    if (needs_separator) {
      result.Append(separator);
    }
    result.Append(at);
    result.Append(separator);
    result.Append(center_x);
    result.Append(separator);
    result.Append(center_y);
  }
  result.Append(')');
  return result.ReleaseString();
}

std::string CSSBasicShapeEllipseValue::CustomCSSText() const {
  std::shared_ptr<const CSSValuePair> normalized_cx = BuildSerializablePositionOffset(center_x_, CSSValueID::kLeft);
  std::shared_ptr<const CSSValuePair> normalized_cy = BuildSerializablePositionOffset(center_y_, CSSValueID::kTop);

  std::string radius_x;
  std::string radius_y;
  if (radius_x_) {
    DCHECK(radius_y_);

    auto* radius_x_identifier_value = DynamicTo<CSSIdentifierValue>(radius_x_.get());
    bool radius_x_closest_side =
        (radius_x_identifier_value && radius_x_identifier_value->GetValueID() == CSSValueID::kClosestSide);

    auto* radius_y_identifier_value = DynamicTo<CSSIdentifierValue>(radius_y_.get());
    bool radius_y_closest_side =
        (radius_y_identifier_value && radius_y_identifier_value->GetValueID() == CSSValueID::kClosestSide);

    if (!radius_x_closest_side || !radius_y_closest_side) {
      radius_x = radius_x_->CssText();
      radius_y = radius_y_->CssText();
    }
  }

  return BuildEllipseString(radius_x, radius_y, SerializePositionOffset(*normalized_cx, *normalized_cy),
                            SerializePositionOffset(*normalized_cy, *normalized_cx), center_x_.get());
}

bool CSSBasicShapeEllipseValue::Equals(const CSSBasicShapeEllipseValue& other) const {
  return ValuesEquivalent(center_x_, other.center_x_) && ValuesEquivalent(center_y_, other.center_y_) &&
         ValuesEquivalent(radius_x_, other.radius_x_) && ValuesEquivalent(radius_y_, other.radius_y_);
}

void CSSBasicShapeEllipseValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

static bool BuildInsetRadii(std::vector<std::string>& radii,
                            const std::string& top_left_radius,
                            const std::string& top_right_radius,
                            const std::string& bottom_right_radius,
                            const std::string& bottom_left_radius) {
  bool show_bottom_left = top_right_radius != bottom_left_radius;
  bool show_bottom_right = show_bottom_left || (bottom_right_radius != top_left_radius);
  bool show_top_right = show_bottom_right || (top_right_radius != top_left_radius);

  radii.push_back(top_left_radius);
  if (show_top_right) {
    radii.push_back(top_right_radius);
  }
  if (show_bottom_right) {
    radii.push_back(bottom_right_radius);
  }
  if (show_bottom_left) {
    radii.push_back(bottom_left_radius);
  }

  return radii.size() == 1 && radii[0] == "0px";
}

static void AppendRoundedCorners(const char* separator,
                                 const std::string& top_left_radius_width,
                                 const std::string& top_left_radius_height,
                                 const std::string& top_right_radius_width,
                                 const std::string& top_right_radius_height,
                                 const std::string& bottom_right_radius_width,
                                 const std::string& bottom_right_radius_height,
                                 const std::string& bottom_left_radius_width,
                                 const std::string& bottom_left_radius_height,
                                 StringBuilder& result) {
  char corners_separator[] = "round";
  if (!top_left_radius_width.empty() && !top_left_radius_height.empty()) {
    std::vector<std::string> horizontal_radii;
    bool are_default_corner_radii = BuildInsetRadii(horizontal_radii, top_left_radius_width, top_right_radius_width,
                                                    bottom_right_radius_width, bottom_left_radius_width);

    std::vector<std::string> vertical_radii;
    are_default_corner_radii &= BuildInsetRadii(vertical_radii, top_left_radius_height, top_right_radius_height,
                                                bottom_right_radius_height, bottom_left_radius_height);

    if (!are_default_corner_radii) {
      result.Append(separator);
      result.Append(corners_separator);

      for (size_t i = 0; i < horizontal_radii.size(); ++i) {
        result.Append(separator);
        result.Append(horizontal_radii[i]);
      }
      if (horizontal_radii != vertical_radii) {
        result.Append(separator);
        result.Append('/');

        for (size_t i = 0; i < vertical_radii.size(); ++i) {
          result.Append(separator);
          result.Append(vertical_radii[i]);
        }
      }
    }
  }
}

static std::string BuildRectStringCommon(const char* opening,
                                         bool show_left_arg,
                                         const std::string& top,
                                         const std::string& right,
                                         const std::string& bottom,
                                         const std::string& left,
                                         const std::string& top_left_radius_width,
                                         const std::string& top_left_radius_height,
                                         const std::string& top_right_radius_width,
                                         const std::string& top_right_radius_height,
                                         const std::string& bottom_right_radius_width,
                                         const std::string& bottom_right_radius_height,
                                         const std::string& bottom_left_radius_width,
                                         const std::string& bottom_left_radius_height) {
  char separator[] = " ";
  StringBuilder result;
  result.Append(opening);
  result.Append(top);
  show_left_arg |= !left.empty() && left != right;
  bool show_bottom_arg = !bottom.empty() && (bottom != top || show_left_arg);
  bool show_right_arg = !right.empty() && (right != top || show_bottom_arg);
  if (show_right_arg) {
    result.Append(separator);
    result.Append(right);
  }
  if (show_bottom_arg) {
    result.Append(separator);
    result.Append(bottom);
  }
  if (show_left_arg) {
    result.Append(separator);
    result.Append(left);
  }

  AppendRoundedCorners(separator, top_left_radius_width, top_left_radius_height, top_right_radius_width,
                       top_right_radius_height, bottom_right_radius_width, bottom_right_radius_height,
                       bottom_left_radius_width, bottom_left_radius_height, result);

  result.Append(')');

  return result.ReleaseString();
}

static std::string BuildXYWHString(const std::string& x,
                                   const std::string& y,
                                   const std::string& width,
                                   const std::string& height,
                                   const std::string& top_left_radius_width,
                                   const std::string& top_left_radius_height,
                                   const std::string& top_right_radius_width,
                                   const std::string& top_right_radius_height,
                                   const std::string& bottom_right_radius_width,
                                   const std::string& bottom_right_radius_height,
                                   const std::string& bottom_left_radius_width,
                                   const std::string& bottom_left_radius_height) {
  const char opening[] = "xywh(";
  char separator[] = " ";
  StringBuilder result;

  result.Append(opening);
  result.Append(x);

  result.Append(separator);
  result.Append(y);

  result.Append(separator);
  result.Append(width);

  result.Append(separator);
  result.Append(height);

  AppendRoundedCorners(separator, top_left_radius_width, top_left_radius_height, top_right_radius_width,
                       top_right_radius_height, bottom_right_radius_width, bottom_right_radius_height,
                       bottom_left_radius_width, bottom_left_radius_height, result);

  result.Append(')');

  return result.ReleaseString();
}

static inline void UpdateCornerRadiusWidthAndHeight(const CSSValuePair* corner_radius,
                                                    std::string& width,
                                                    std::string& height) {
  if (!corner_radius) {
    return;
  }

  width = corner_radius->First()->CssText();
  height = corner_radius->Second()->CssText();
}

std::string CSSBasicShapeInsetValue::CustomCSSText() const {
  std::string top_left_radius_width;
  std::string top_left_radius_height;
  std::string top_right_radius_width;
  std::string top_right_radius_height;
  std::string bottom_right_radius_width;
  std::string bottom_right_radius_height;
  std::string bottom_left_radius_width;
  std::string bottom_left_radius_height;

  UpdateCornerRadiusWidthAndHeight(TopLeftRadius(), top_left_radius_width, top_left_radius_height);
  UpdateCornerRadiusWidthAndHeight(TopRightRadius(), top_right_radius_width, top_right_radius_height);
  UpdateCornerRadiusWidthAndHeight(BottomRightRadius(), bottom_right_radius_width, bottom_right_radius_height);
  UpdateCornerRadiusWidthAndHeight(BottomLeftRadius(), bottom_left_radius_width, bottom_left_radius_height);

  return BuildRectStringCommon("inset(", false, top_ ? top_->CssText() : "", right_ ? right_->CssText() : "",
                               bottom_ ? bottom_->CssText() : "", left_ ? left_->CssText() : "", top_left_radius_width,
                               top_left_radius_height, top_right_radius_width, top_right_radius_height,
                               bottom_right_radius_width, bottom_right_radius_height, bottom_left_radius_width,
                               bottom_left_radius_height);
}

bool CSSBasicShapeInsetValue::Equals(const CSSBasicShapeInsetValue& other) const {
  return ValuesEquivalent(top_, other.top_) && ValuesEquivalent(right_, other.right_) &&
         ValuesEquivalent(bottom_, other.bottom_) && ValuesEquivalent(left_, other.left_) &&
         ValuesEquivalent(top_left_radius_, other.top_left_radius_) &&
         ValuesEquivalent(top_right_radius_, other.top_right_radius_) &&
         ValuesEquivalent(bottom_right_radius_, other.bottom_right_radius_) &&
         ValuesEquivalent(bottom_left_radius_, other.bottom_left_radius_);
}

void CSSBasicShapeInsetValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

std::string CSSBasicShapeRectValue::CustomCSSText() const {
  std::string top_left_radius_width;
  std::string top_left_radius_height;
  std::string top_right_radius_width;
  std::string top_right_radius_height;
  std::string bottom_right_radius_width;
  std::string bottom_right_radius_height;
  std::string bottom_left_radius_width;
  std::string bottom_left_radius_height;

  UpdateCornerRadiusWidthAndHeight(TopLeftRadius(), top_left_radius_width, top_left_radius_height);
  UpdateCornerRadiusWidthAndHeight(TopRightRadius(), top_right_radius_width, top_right_radius_height);
  UpdateCornerRadiusWidthAndHeight(BottomRightRadius(), bottom_right_radius_width, bottom_right_radius_height);
  UpdateCornerRadiusWidthAndHeight(BottomLeftRadius(), bottom_left_radius_width, bottom_left_radius_height);

  return BuildRectStringCommon("rect(", true, top_->CssText(), right_->CssText(), bottom_->CssText(), left_->CssText(),
                               top_left_radius_width, top_left_radius_height, top_right_radius_width,
                               top_right_radius_height, bottom_right_radius_width, bottom_right_radius_height,
                               bottom_left_radius_width, bottom_left_radius_height);
}

bool CSSBasicShapeRectValue::Equals(const CSSBasicShapeRectValue& other) const {
  return ValuesEquivalent(top_, other.top_) && ValuesEquivalent(right_, other.right_) &&
         ValuesEquivalent(bottom_, other.bottom_) && ValuesEquivalent(left_, other.left_) &&
         ValuesEquivalent(top_left_radius_, other.top_left_radius_) &&
         ValuesEquivalent(top_right_radius_, other.top_right_radius_) &&
         ValuesEquivalent(bottom_right_radius_, other.bottom_right_radius_) &&
         ValuesEquivalent(bottom_left_radius_, other.bottom_left_radius_);
}

void CSSBasicShapeRectValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

void CSSBasicShapeRectValue::Validate() const {
  auto validate_length = [](std::shared_ptr<const CSSValue> length) {
    if (length->IsIdentifierValue()) {
      DCHECK(To<CSSIdentifierValue>(length.get())->GetValueID() == CSSValueID::kAuto);
      return;
    }
    DCHECK(length->IsPrimitiveValue());
  };

  validate_length(top_);
  validate_length(left_);
  validate_length(bottom_);
  validate_length(right_);
}

std::string CSSBasicShapeXYWHValue::CustomCSSText() const {
  std::string top_left_radius_width;
  std::string top_left_radius_height;
  std::string top_right_radius_width;
  std::string top_right_radius_height;
  std::string bottom_right_radius_width;
  std::string bottom_right_radius_height;
  std::string bottom_left_radius_width;
  std::string bottom_left_radius_height;

  UpdateCornerRadiusWidthAndHeight(TopLeftRadius(), top_left_radius_width, top_left_radius_height);
  UpdateCornerRadiusWidthAndHeight(TopRightRadius(), top_right_radius_width, top_right_radius_height);
  UpdateCornerRadiusWidthAndHeight(BottomRightRadius(), bottom_right_radius_width, bottom_right_radius_height);
  UpdateCornerRadiusWidthAndHeight(BottomLeftRadius(), bottom_left_radius_width, bottom_left_radius_height);

  return BuildXYWHString(x_->CssText(), y_->CssText(), width_->CssText(), height_->CssText(), top_left_radius_width,
                         top_left_radius_height, top_right_radius_width, top_right_radius_height,
                         bottom_right_radius_width, bottom_right_radius_height, bottom_left_radius_width,
                         bottom_left_radius_height);
}

bool CSSBasicShapeXYWHValue::Equals(const CSSBasicShapeXYWHValue& other) const {
  return ValuesEquivalent(x_, other.x_) && ValuesEquivalent(y_, other.y_) && ValuesEquivalent(width_, other.width_) &&
         ValuesEquivalent(height_, other.height_) && ValuesEquivalent(top_left_radius_, other.top_left_radius_) &&
         ValuesEquivalent(top_right_radius_, other.top_right_radius_) &&
         ValuesEquivalent(bottom_right_radius_, other.bottom_right_radius_) &&
         ValuesEquivalent(bottom_left_radius_, other.bottom_left_radius_);
}

void CSSBasicShapeXYWHValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

void CSSBasicShapeXYWHValue::Validate() const {
  DCHECK(x_);
  DCHECK(y_);
  DCHECK(width_);
  DCHECK(height_);

  // The spec requires non-negative width and height but we can only validate
  // numeric literals here.
  if (width_->IsNumericLiteralValue()) {
    DCHECK_GE(width_->GetFloatValue(), 0);
  }
  if (height_->IsNumericLiteralValue()) {
    DCHECK_GE(height_->GetFloatValue(), 0);
  }
}

}  // namespace cssvalue
}  // namespace webf