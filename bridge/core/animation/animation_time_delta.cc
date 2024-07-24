// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/animation/animation_time_delta.h"

namespace webf {
// TODO(guopengfei)：默认使用双精度
//#if !BUILDFLAG(BLINK_ANIMATION_USE_TIME_DELTA)

// Comparison operators on AnimationTimeDelta.
bool operator==(const AnimationTimeDelta& lhs,
                            const AnimationTimeDelta& rhs) {
  return lhs.InSecondsF() == rhs.InSecondsF();
}
bool operator!=(const AnimationTimeDelta& lhs,
                            const AnimationTimeDelta& rhs) {
  return lhs.InSecondsF() != rhs.InSecondsF();
}
bool operator>(const AnimationTimeDelta& lhs,
                           const AnimationTimeDelta& rhs) {
  return lhs.InSecondsF() > rhs.InSecondsF();
}
bool operator<(const AnimationTimeDelta& lhs,
                           const AnimationTimeDelta& rhs) {
  return !(lhs >= rhs);
}
bool operator>=(const AnimationTimeDelta& lhs,
                            const AnimationTimeDelta& rhs) {
  return lhs.InSecondsF() >= rhs.InSecondsF();
}
bool operator<=(const AnimationTimeDelta& lhs,
                            const AnimationTimeDelta& rhs) {
  return lhs.InSecondsF() <= rhs.InSecondsF();
}

std::ostream& operator<<(std::ostream& os, const AnimationTimeDelta& time) {
  return os << time.InSecondsF() << " s";
}
//#endif

}  // namespace webf
