// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ANIMATION_CSS_CSS_TIMING_DATA_H_
#define WEBF_CORE_ANIMATION_CSS_CSS_TIMING_DATA_H_

#include <optional>

#include "core/animation/timeline_offset.h"
#include "core/animation/timing.h"
#include "core/platform/animation/timing_function.h"

namespace webf {

struct Timing;

class CSSTimingData {
  USING_FAST_MALLOC(CSSTimingData);

 public:
  using DelayVector = std::vector<Timing::Delay>;
  using DurationVector = std::vector<std::optional<double>>;
  using TimingFunctionVector = std::vector<std::shared_ptr<TimingFunction>>;

  ~CSSTimingData() = default;

  const DelayVector& DelayStartList() const { return delay_start_list_; }
  const DelayVector& DelayEndList() const { return delay_end_list_; }
  const DurationVector& DurationList() const { return duration_list_; }
  const TimingFunctionVector& TimingFunctionList() const {
    return timing_function_list_;
  }

  DelayVector& DelayStartList() { return delay_start_list_; }
  DelayVector& DelayEndList() { return delay_end_list_; }
  DurationVector& DurationList() { return duration_list_; }
  TimingFunctionVector& TimingFunctionList() { return timing_function_list_; }

  bool HasSingleInitialDelayStart() const {
    return delay_start_list_.size() == 1u &&
           delay_start_list_.front() == InitialDelayStart();
  }

  bool HasSingleInitialDelayEnd() const {
    return delay_end_list_.size() == 1u &&
           delay_end_list_.front() == InitialDelayEnd();
  }

  static Timing::Delay InitialDelayStart() { return Timing::Delay(); }
  static Timing::Delay InitialDelayEnd() { return Timing::Delay(); }
  static std::shared_ptr<TimingFunction> InitialTimingFunction() {
    return CubicBezierTimingFunction::Preset(
        CubicBezierTimingFunction::EaseType::EASE);
  }

  template <class T>
  static const T& GetRepeated(const std::vector<T>& v, size_t index) {
    return v[index % v.size()];
  }

 protected:
  explicit CSSTimingData(std::optional<double> initial_duration);
  CSSTimingData(const CSSTimingData&);

  Timing ConvertToTiming(size_t index) const;
  bool TimingMatchForStyleRecalc(const CSSTimingData&) const;

 private:
  DelayVector delay_start_list_;
  DelayVector delay_end_list_;
  DurationVector duration_list_;
  TimingFunctionVector timing_function_list_;
};

}  // namespace webf

#endif  // WEBF_CORE_ANIMATION_CSS_CSS_TIMING_DATA_H_
