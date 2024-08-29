// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef UI_GFX_GEOMETRY_POINT_CONVERSIONS_H_
#define UI_GFX_GEOMETRY_POINT_CONVERSIONS_H_

#include "point.h"
#include "point_f.h"

namespace gfx {

// Returns a Point with each component from the input PointF floored.
Point ToFlooredPoint(const PointF& point);

// Returns a Point with each component from the input PointF ceiled.
Point ToCeiledPoint(const PointF& point);

// Returns a Point with each component from the input PointF rounded.
Point ToRoundedPoint(const PointF& point);

}  // namespace gfx

#endif  // UI_GFX_GEOMETRY_POINT_CONVERSIONS_H_