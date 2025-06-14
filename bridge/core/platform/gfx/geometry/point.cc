// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "point.h"
#include "core/base/build_config.h"
#include "point_conversions.h"
#include "point_f.h"

namespace gfx {

void Point::SetToMin(const Point& other) {
  x_ = std::min(x_, other.x_);
  y_ = std::min(y_, other.y_);
}

void Point::SetToMax(const Point& other) {
  x_ = std::max(x_, other.x_);
  y_ = std::max(y_, other.y_);
}

std::string Point::ToString() const {
  char buffer[10];
  snprintf(buffer, 10, "%d,%d", x(), y());
  return buffer;
}

Point ScaleToCeiledPoint(const Point& point, float x_scale, float y_scale) {
  if (x_scale == 1.f && y_scale == 1.f)
    return point;
  return ToCeiledPoint(ScalePoint(gfx::PointF(point), x_scale, y_scale));
}

Point ScaleToCeiledPoint(const Point& point, float scale) {
  if (scale == 1.f)
    return point;
  return ToCeiledPoint(ScalePoint(gfx::PointF(point), scale, scale));
}

Point ScaleToFlooredPoint(const Point& point, float x_scale, float y_scale) {
  if (x_scale == 1.f && y_scale == 1.f)
    return point;
  return ToFlooredPoint(ScalePoint(gfx::PointF(point), x_scale, y_scale));
}

Point ScaleToFlooredPoint(const Point& point, float scale) {
  if (scale == 1.f)
    return point;
  return ToFlooredPoint(ScalePoint(gfx::PointF(point), scale, scale));
}

Point ScaleToRoundedPoint(const Point& point, float x_scale, float y_scale) {
  if (x_scale == 1.f && y_scale == 1.f)
    return point;
  return ToRoundedPoint(ScalePoint(gfx::PointF(point), x_scale, y_scale));
}

Point ScaleToRoundedPoint(const Point& point, float scale) {
  if (scale == 1.f)
    return point;
  return ToRoundedPoint(ScalePoint(gfx::PointF(point), scale, scale));
}

}  // namespace gfx