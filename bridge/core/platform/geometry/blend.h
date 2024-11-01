// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_PLATFORM_GEOMETRY_BLEND_H_
#define WEBF_CORE_PLATFORM_GEOMETRY_BLEND_H_

#include <type_traits>
#include <cmath>

namespace webf {

inline int Blend(int from, int to, double progress) {
  return static_cast<int>(lround(from + (to - from) * progress));
}

// For unsigned types.
template <typename T>
inline T Blend(T from, T to, double progress) {
  static_assert(std::is_integral<T>::value,
                "blend can only be used with integer types");
  return ClampTo<T>(round(to > from ? from + (to - from) * progress
                                    : from - (from - to) * progress));
}

inline double Blend(double from, double to, double progress) {
  return from + (to - from) * progress;
}

inline float Blend(float from, float to, double progress) {
  return static_cast<float>(from + (to - from) * progress);
}

}

#endif