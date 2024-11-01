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

#ifndef WEBF_CORE_CSS_CSS_BASIC_SHAPE_VALUES_H_
#define WEBF_CORE_CSS_CSS_BASIC_SHAPE_VALUES_H_

#include "core/css/css_value.h"
#include "core/css/css_value_pair.h"
#include "core/css/css_primitive_value.h"

namespace webf {
namespace cssvalue {

class CSSBasicShapeCircleValue final : public CSSValue {
public:
 CSSBasicShapeCircleValue() : CSSValue(kBasicShapeCircleClass) {}

 std::string CustomCSSText() const;
 bool Equals(const CSSBasicShapeCircleValue&) const;

 const CSSValue* CenterX() const { return center_x_.get(); }
 const CSSValue* CenterY() const { return center_y_.get(); }
 const CSSValue* Radius() const { return radius_.get(); }

 // TODO(sashab): Remove these and pass them as arguments in the constructor.
 void SetCenterX(std::shared_ptr<const CSSValue> center_x) { center_x_ = center_x; }
 void SetCenterY(std::shared_ptr<const CSSValue> center_y) { center_y_ = center_y; }
 void SetRadius(std::shared_ptr<const CSSValue> radius) { radius_ = radius; }

 void TraceAfterDispatch(GCVisitor*) const;

private:
 std::shared_ptr<const CSSValue> center_x_;
 std::shared_ptr<const CSSValue> center_y_;
 std::shared_ptr<const CSSValue> radius_;
};

class CSSBasicShapeEllipseValue final : public CSSValue {
public:
 CSSBasicShapeEllipseValue() : CSSValue(kBasicShapeEllipseClass) {}

 std::string CustomCSSText() const;
 bool Equals(const CSSBasicShapeEllipseValue&) const;

 const CSSValue* CenterX() const { return center_x_.get(); }
 const CSSValue* CenterY() const { return center_y_.get(); }
 const CSSValue* RadiusX() const { return radius_x_.get(); }
 const CSSValue* RadiusY() const { return radius_y_.get(); }

 // TODO(sashab): Remove these and pass them as arguments in the constructor.
 void SetCenterX(std::shared_ptr<const CSSValue> center_x) { center_x_ = center_x; }
 void SetCenterY(std::shared_ptr<const CSSValue> center_y) { center_y_ = center_y; }
 void SetRadiusX(std::shared_ptr<const CSSValue> radius_x) { radius_x_ = radius_x; }
 void SetRadiusY(std::shared_ptr<const CSSValue> radius_y) { radius_y_ = radius_y; }

 void TraceAfterDispatch(GCVisitor*) const;

private:
 std::shared_ptr<const CSSValue> center_x_;
 std::shared_ptr<const CSSValue> center_y_;
 std::shared_ptr<const CSSValue> radius_x_;
 std::shared_ptr<const CSSValue> radius_y_;
};

class CSSBasicShapeInsetValue final : public CSSValue {
public:
 CSSBasicShapeInsetValue() : CSSValue(kBasicShapeInsetClass) {}

 CSSValue* Top() const { return top_.get(); }
 CSSValue* Right() const { return right_.get(); }
 CSSValue* Bottom() const { return bottom_.get(); }
 CSSValue* Left() const { return left_.get(); }

 CSSValuePair* TopLeftRadius() const { return top_left_radius_.get(); }
 CSSValuePair* TopRightRadius() const { return top_right_radius_.get(); }
 CSSValuePair* BottomRightRadius() const { return bottom_right_radius_.get(); }
 CSSValuePair* BottomLeftRadius() const { return bottom_left_radius_.get(); }

 // TODO(sashab): Remove these and pass them as arguments in the constructor.
 void SetTop(std::shared_ptr<CSSValue> top) { top_ = top; }
 void SetRight(std::shared_ptr<CSSValue> right) { right_ = right; }
 void SetBottom(std::shared_ptr<CSSValue> bottom) { bottom_ = bottom; }
 void SetLeft(std::shared_ptr<CSSValue> left) { left_ = left; }

 void UpdateShapeSize4Values(std::shared_ptr<CSSValue> top,
                             std::shared_ptr<CSSValue> right,
                             std::shared_ptr<CSSValue> bottom,
                             std::shared_ptr<CSSValue> left) {
   SetTop(top);
   SetRight(right);
   SetBottom(bottom);
   SetLeft(left);
 }

 void UpdateShapeSize1Value(std::shared_ptr<CSSValue> value1) {
   UpdateShapeSize4Values(value1, value1, value1, value1);
 }

 void UpdateShapeSize2Values(std::shared_ptr<CSSValue> value1, std::shared_ptr<CSSValue> value2) {
   UpdateShapeSize4Values(value1, value2, value1, value2);
 }

 void UpdateShapeSize3Values(std::shared_ptr<CSSValue> value1,
                             std::shared_ptr<CSSValue> value2,
                             std::shared_ptr<CSSValue> value3) {
   UpdateShapeSize4Values(value1, value2, value3, value2);
 }

 void SetTopLeftRadius(std::shared_ptr<CSSValuePair> radius) { top_left_radius_ = radius; }
 void SetTopRightRadius(std::shared_ptr<CSSValuePair> radius) { top_right_radius_ = radius; }
 void SetBottomRightRadius(std::shared_ptr<CSSValuePair> radius) {
   bottom_right_radius_ = radius;
 }
 void SetBottomLeftRadius(std::shared_ptr<CSSValuePair> radius) {
   bottom_left_radius_ = radius;
 }

 std::string CustomCSSText() const;
 bool Equals(const CSSBasicShapeInsetValue&) const;

 void TraceAfterDispatch(GCVisitor*) const;

private:
 std::shared_ptr<CSSValue> top_;
 std::shared_ptr<CSSValue> right_;
 std::shared_ptr<CSSValue> bottom_;
 std::shared_ptr<CSSValue> left_;

 std::shared_ptr<CSSValuePair> top_left_radius_;
 std::shared_ptr<CSSValuePair> top_right_radius_;
 std::shared_ptr<CSSValuePair> bottom_right_radius_;
 std::shared_ptr<CSSValuePair> bottom_left_radius_;
};

class CSSBasicShapeRectValue final : public CSSValue {
public:
 CSSBasicShapeRectValue(std::shared_ptr<CSSValue> top,
                        std::shared_ptr<CSSValue> right,
                        std::shared_ptr<CSSValue> bottom,
                        std::shared_ptr<CSSValue> left)
     : CSSValue(kBasicShapeRectClass),
       top_(top),
       right_(right),
       bottom_(bottom),
       left_(left) {
   Validate();
 }

 CSSValue* Top() const { return top_.get(); }
 CSSValue* Right() const { return right_.get(); }
 CSSValue* Bottom() const { return bottom_.get(); }
 CSSValue* Left() const { return left_.get(); }

 CSSValuePair* TopLeftRadius() const { return top_left_radius_.get(); }
 CSSValuePair* TopRightRadius() const { return top_right_radius_.get(); }
 CSSValuePair* BottomRightRadius() const { return bottom_right_radius_.get(); }
 CSSValuePair* BottomLeftRadius() const { return bottom_left_radius_.get(); }

 void SetTopLeftRadius(std::shared_ptr<CSSValuePair> radius) { top_left_radius_ = radius; }
 void SetTopRightRadius(std::shared_ptr<CSSValuePair> radius) { top_right_radius_ = radius; }
 void SetBottomRightRadius(std::shared_ptr<CSSValuePair> radius) {
   bottom_right_radius_ = radius;
 }
 void SetBottomLeftRadius(std::shared_ptr<CSSValuePair> radius) {
   bottom_left_radius_ = radius;
 }

 std::string CustomCSSText() const;
 bool Equals(const CSSBasicShapeRectValue&) const;

 void TraceAfterDispatch(GCVisitor*) const;

private:
 void Validate() const;

 std::shared_ptr<CSSValue> top_;
 std::shared_ptr<CSSValue> right_;
 std::shared_ptr<CSSValue> bottom_;
 std::shared_ptr<CSSValue> left_;

 std::shared_ptr<CSSValuePair> top_left_radius_;
 std::shared_ptr<CSSValuePair> top_right_radius_;
 std::shared_ptr<CSSValuePair> bottom_right_radius_;
 std::shared_ptr<CSSValuePair> bottom_left_radius_;
};

class CSSBasicShapeXYWHValue final : public CSSValue {
public:
 CSSBasicShapeXYWHValue(std::shared_ptr<CSSPrimitiveValue> x,
                        std::shared_ptr<CSSPrimitiveValue> y,
                        std::shared_ptr<CSSPrimitiveValue> width,
                        std::shared_ptr<CSSPrimitiveValue> height)
     : CSSValue(kBasicShapeXYWHClass),
       x_(x),
       y_(y),
       width_(width),
       height_(height) {
   Validate();
 }

 CSSPrimitiveValue* X() const { return x_.get(); }
 CSSPrimitiveValue* Y() const { return y_.get(); }
 CSSPrimitiveValue* Width() const { return width_.get(); }
 CSSPrimitiveValue* Height() const { return height_.get(); }

 CSSValuePair* TopLeftRadius() const { return top_left_radius_.get(); }
 CSSValuePair* TopRightRadius() const { return top_right_radius_.get(); }
 CSSValuePair* BottomRightRadius() const { return bottom_right_radius_.get(); }
 CSSValuePair* BottomLeftRadius() const { return bottom_left_radius_.get(); }

 void SetTopLeftRadius(std::shared_ptr<CSSValuePair> radius) { top_left_radius_ = radius; }
 void SetTopRightRadius(std::shared_ptr<CSSValuePair> radius) { top_right_radius_ = radius; }
 void SetBottomRightRadius(std::shared_ptr<CSSValuePair> radius) {
   bottom_right_radius_ = radius;
 }
 void SetBottomLeftRadius(std::shared_ptr<CSSValuePair> radius) {
   bottom_left_radius_ = radius;
 }

 std::string CustomCSSText() const;
 bool Equals(const CSSBasicShapeXYWHValue&) const;

 void TraceAfterDispatch(GCVisitor*) const;

private:
 void Validate() const;

 std::shared_ptr<CSSPrimitiveValue> x_;
 std::shared_ptr<CSSPrimitiveValue> y_;
 std::shared_ptr<CSSPrimitiveValue> width_;
 std::shared_ptr<CSSPrimitiveValue> height_;

 std::shared_ptr<CSSValuePair> top_left_radius_;
 std::shared_ptr<CSSValuePair> top_right_radius_;
 std::shared_ptr<CSSValuePair> bottom_right_radius_;
 std::shared_ptr<CSSValuePair> bottom_left_radius_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSBasicShapeCircleValue> {
 static bool AllowFrom(const CSSValue& value) {
   return value.IsBasicShapeCircleValue();
 }
};

template <>
struct DowncastTraits<cssvalue::CSSBasicShapeEllipseValue> {
 static bool AllowFrom(const CSSValue& value) {
   return value.IsBasicShapeEllipseValue();
 }
};

template <>
struct DowncastTraits<cssvalue::CSSBasicShapeInsetValue> {
 static bool AllowFrom(const CSSValue& value) {
   return value.IsBasicShapeInsetValue();
 }
};

template <>
struct DowncastTraits<cssvalue::CSSBasicShapeRectValue> {
 static bool AllowFrom(const CSSValue& value) {
   return value.IsBasicShapeRectValue();
 }
};

template <>
struct DowncastTraits<cssvalue::CSSBasicShapeXYWHValue> {
 static bool AllowFrom(const CSSValue& value) {
   return value.IsBasicShapeXYWHValue();
 }
};

}  // namespace blink

#endif  // WEBF_CORE_CSS_CSS_BASIC_SHAPE_VALUES_H_