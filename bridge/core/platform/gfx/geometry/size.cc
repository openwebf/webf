// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "size.h"

#include "core/base/build_config.h"
#include "core/base/numerics/clamped_math.h"
#include "core/base/numerics/safe_math.h"
#include "size_conversions.h"

namespace gfx {

void Size::operator+=(const Size& size) {
  Enlarge(size.width(), size.height());
}

void Size::operator-=(const Size& size) {
  Enlarge(-size.width(), -size.height());
}

int Size::GetArea() const {
  return GetCheckedArea().ValueOrDie();
}

base::CheckedNumeric<int> Size::GetCheckedArea() const {
  base::CheckedNumeric<int> checked_area = width();
  checked_area *= height();
  return checked_area;
}

void Size::Enlarge(int grow_width, int grow_height) {
  SetSize(base::ClampAdd(width(), grow_width), base::ClampAdd(height(), grow_height));
}

void Size::SetToMin(const Size& other) {
  width_ = std::min(width_, other.width_);
  height_ = std::min(height_, other.height_);
}

void Size::SetToMax(const Size& other) {
  width_ = std::max(width_, other.width_);
  height_ = std::max(height_, other.height_);
}

std::string Size::ToString() const {
  char buffer[20];
  snprintf(buffer, 20, "%dx%d", width(), height());
  return buffer;
}

Size ScaleToCeiledSize(const Size& size, float x_scale, float y_scale) {
  if (x_scale == 1.f && y_scale == 1.f)
    return size;
  return ToCeiledSize(ScaleSize(gfx::SizeF(size), x_scale, y_scale));
}

Size ScaleToCeiledSize(const Size& size, float scale) {
  if (scale == 1.f)
    return size;
  return ToCeiledSize(ScaleSize(gfx::SizeF(size), scale, scale));
}

Size ScaleToFlooredSize(const Size& size, float x_scale, float y_scale) {
  if (x_scale == 1.f && y_scale == 1.f)
    return size;
  return ToFlooredSize(ScaleSize(gfx::SizeF(size), x_scale, y_scale));
}

Size ScaleToFlooredSize(const Size& size, float scale) {
  if (scale == 1.f)
    return size;
  return ToFlooredSize(ScaleSize(gfx::SizeF(size), scale, scale));
}

Size ScaleToRoundedSize(const Size& size, float x_scale, float y_scale) {
  if (x_scale == 1.f && y_scale == 1.f)
    return size;
  return ToRoundedSize(ScaleSize(gfx::SizeF(size), x_scale, y_scale));
}

Size ScaleToRoundedSize(const Size& size, float scale) {
  if (scale == 1.f)
    return size;
  return ToRoundedSize(ScaleSize(gfx::SizeF(size), scale, scale));
}

}  // namespace gfx