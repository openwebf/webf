// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_ANIMATION_ANIMATION_TIME_DELTA_H_
#define WEBF_CORE_ANIMATION_ANIMATION_TIME_DELTA_H_

#include <cassert>
#include <limits>
#include <ostream>
#include "foundation/macros.h"

namespace webf {

// AnimationTimeDelta exists to ease the transition of Blink animations from
// double-based time values to base::TimeDelta-based time values (see
// http://crbug.com/737867.
//
// It represents a delta between two times, analogous to base::TimeDelta. It is
// provided in two modes, based on a compiler flag. The first is the traditional
// (and default) double mode, where time deltas are represented using seconds in
// double-precision. The second mode uses base::TimeDelta to represent time
// instead.

//#if !BUILDFLAG(BLINK_ANIMATION_USE_TIME_DELTA)

// The double-based version of AnimationTimeDelta. Internally, time is stored as
// double-precision seconds.
//
// This class is modelled on the API from base::TimeDelta, with a lot of
// unnecessary methods stripped out.
class AnimationTimeDelta {
  USING_FAST_MALLOC(AnimationTimeDelta);

 public:
  constexpr AnimationTimeDelta() : delta_(0) {}

  // Do not use this directly -- use the macros below.
  constexpr explicit AnimationTimeDelta(double delta) : delta_(delta) {}

#define ANIMATION_TIME_DELTA_FROM_SECONDS(x) AnimationTimeDelta(x)
#define ANIMATION_TIME_DELTA_FROM_MILLISECONDS(x) AnimationTimeDelta(x / 1000.0)

  static constexpr AnimationTimeDelta Max() { return AnimationTimeDelta(std::numeric_limits<double>::infinity()); }

  double InSecondsF() const { return delta_; }
  double InMillisecondsF() const { return delta_ * 1000; }
  double InMicrosecondsF() const { return delta_ * 1000000; }

  bool is_max() const { return delta_ == std::numeric_limits<double>::infinity(); }

  bool is_inf() const { return std::isinf(delta_); }

  bool is_zero() const { return delta_ == 0; }

  AnimationTimeDelta operator+(AnimationTimeDelta other) const { return AnimationTimeDelta(delta_ + other.delta_); }
  AnimationTimeDelta& operator+=(AnimationTimeDelta other) { return *this = (*this + other); }
  AnimationTimeDelta operator-(AnimationTimeDelta other) const { return AnimationTimeDelta(delta_ - other.delta_); }
  AnimationTimeDelta operator-() { return AnimationTimeDelta(-delta_); }
  template <typename T>
  AnimationTimeDelta operator*(T a) const {
    return AnimationTimeDelta(delta_ * a);
  }
  template <typename T>
  AnimationTimeDelta& operator*=(T a) {
    return *this = (*this * a);
  }
  template <typename T>
  AnimationTimeDelta operator/(T a) const {
    return AnimationTimeDelta(delta_ / a);
  }
  template <typename T>
  AnimationTimeDelta& operator/=(T a) {
    return *this = (*this / a);
  }
  double operator/(AnimationTimeDelta a) const {
    assert(!a.is_zero());
    assert(!is_inf() || !a.is_inf());
    return delta_ / a.delta_;
  }

 protected:
  // The time delta represented by this |AnimationTimeDelta|, in seconds. May be
  // negative, in which case the end of the delta is before the start.
  double delta_;
};

template <typename T>
AnimationTimeDelta operator*(T a, AnimationTimeDelta td) {
  return td * a;
}

// Comparison operators on AnimationTimeDelta.
bool operator==(const AnimationTimeDelta& lhs, const AnimationTimeDelta& rhs);
bool operator!=(const AnimationTimeDelta& lhs, const AnimationTimeDelta& rhs);
bool operator>(const AnimationTimeDelta& lhs, const AnimationTimeDelta& rhs);
bool operator<(const AnimationTimeDelta& lhs, const AnimationTimeDelta& rhs);
bool operator>=(const AnimationTimeDelta& lhs, const AnimationTimeDelta& rhs);
bool operator<=(const AnimationTimeDelta& lhs, const AnimationTimeDelta& rhs);

// Defined to allow DCHECK_EQ/etc to work with the class.
std::ostream& operator<<(std::ostream& os, const AnimationTimeDelta& time);
/* // TODO(guopengfei)：默认使用双精度，by guopengfei
#else  // !BUILDFLAG(BLINK_ANIMATION_USE_TIME_DELTA)

// When compiling in TimeDelta-based mode, AnimationTimeDelta is equivalent to
// base::TimeDelta.
using AnimationTimeDelta = base::TimeDelta;

#define ANIMATION_TIME_DELTA_FROM_SECONDS(x) base::Seconds(x)
#define ANIMATION_TIME_DELTA_FROM_MILLISECONDS(x) base::Milliseconds(x)

#endif
 */

}  // namespace webf

#endif  // WEBF_CORE_ANIMATION_ANIMATION_TIME_DELTA_H_
