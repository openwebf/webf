// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_BASE_NUMERICS_ANGLE_CONVERSIONS_H_
#define WEBF_BASE_NUMERICS_ANGLE_CONVERSIONS_H_

#include <concepts>

namespace base {

template <typename T>
constexpr typename std::enable_if<std::is_floating_point<T>::value, T>::type DegToRad(T deg) {
  constexpr T pi = static_cast<T>(3.14159265358979323846);  // Manually define pi
  return deg * pi / 180;
}

template <typename T>
constexpr typename std::enable_if<std::is_floating_point<T>::value, T>::type RadToDeg(T rad) {
  constexpr T pi = static_cast<T>(3.14159265358979323846);  // Manually define pi
  return rad * 180 / pi;
}

}  // namespace base

#endif  // WEBF_BASE_NUMERICS_ANGLE_CONVERSIONS_H_