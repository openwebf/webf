// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_GFX_GEOMETRY_SIZE_H_
#define WEBF_GFX_GEOMETRY_SIZE_H_

#include <algorithm>
#include <iosfwd>
#include <string>

#include "core/base/build_config.h"
#include "core/base/numerics/safe_math.h"

namespace gfx {

// A size has width and height values.
class Size {
 public:
  constexpr Size() : width_(0), height_(0) {}
  constexpr Size(int width, int height) : width_(std::max(0, width)), height_(std::max(0, height)) {}

  void operator+=(const Size& size);

  void operator-=(const Size& size);

  constexpr int width() const { return width_; }
  constexpr int height() const { return height_; }

  void set_width(int width) { width_ = std::max(0, width); }
  void set_height(int height) { height_ = std::max(0, height); }

  // This call will CHECK if the area of this size would overflow int.
  int GetArea() const;
  // Returns a checked numeric representation of the area.
  base::CheckedNumeric<int> GetCheckedArea() const;

  uint64_t Area64() const { return static_cast<uint64_t>(width_) * static_cast<uint64_t>(height_); }

  void SetSize(int width, int height) {
    set_width(width);
    set_height(height);
  }

  void Enlarge(int grow_width, int grow_height);

  void SetToMin(const Size& other);
  void SetToMax(const Size& other);

  bool IsEmpty() const { return !width() || !height(); }
  bool IsZero() const { return !width() && !height(); }

  void Transpose() {
    using std::swap;
    swap(width_, height_);
  }

  std::string ToString() const;

 private:
  int width_;
  int height_;
};

inline bool operator==(const Size& lhs, const Size& rhs) {
  return lhs.width() == rhs.width() && lhs.height() == rhs.height();
}

inline bool operator!=(const Size& lhs, const Size& rhs) {
  return !(lhs == rhs);
}

inline Size operator+(Size lhs, const Size& rhs) {
  lhs += rhs;
  return lhs;
}

inline Size operator-(Size lhs, const Size& rhs) {
  lhs -= rhs;
  return lhs;
}

// This is declared here for use in gtest-based unit tests but is defined in
// the //ui/gfx:test_support target. Depend on that to use this in your unit
// test. This should not be used in production code - call ToString() instead.
void PrintTo(const Size& size, ::std::ostream* os);

// Helper methods to scale a gfx::Size to a new gfx::Size.
Size ScaleToCeiledSize(const Size& size, float x_scale, float y_scale);
Size ScaleToCeiledSize(const Size& size, float scale);
Size ScaleToFlooredSize(const Size& size, float x_scale, float y_scale);
Size ScaleToFlooredSize(const Size& size, float scale);
Size ScaleToRoundedSize(const Size& size, float x_scale, float y_scale);
Size ScaleToRoundedSize(const Size& size, float scale);

inline Size TransposeSize(const Size& s) {
  return Size(s.height(), s.width());
}

}  // namespace gfx

#endif  // WEBF_GFX_GEOMETRY_SIZE_H_
