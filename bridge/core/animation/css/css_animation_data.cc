// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/animation/css/css_animation_data.h"

#include "core/animation/timing.h"
#include "css_value_keywords.h"
// TODO(guopengfei)：
//#include "third_party/blink/renderer/platform/runtime_enabled_features.h"

namespace webf {

CSSAnimationData::CSSAnimationData() : CSSTimingData(InitialDuration()) {
  name_list_.push_back(InitialName());
  timeline_list_.push_back(InitialTimeline());
  iteration_count_list_.push_back(InitialIterationCount());
  direction_list_.push_back(InitialDirection());
  fill_mode_list_.push_back(InitialFillMode());
  play_state_list_.push_back(InitialPlayState());
  range_start_list_.push_back(InitialRangeStart());
  range_end_list_.push_back(InitialRangeEnd());
  composition_list_.push_back(InitialComposition());
}

CSSAnimationData::CSSAnimationData(const CSSAnimationData& other) = default;

std::optional<double> CSSAnimationData::InitialDuration() {

  // TODO(guopengfei)：not use std::nullopt
  //if (RuntimeEnabledFeatures::ScrollTimelineEnabled()) {
  //  return std::nullopt;
  //}

  return 0;
}

const AtomicString& CSSAnimationData::InitialName() {
  // TODO(guopengfei)：
  //DEFINE_STATIC_LOCAL(const AtomicString, name, ("none"));
  //return name;
  return AtomicString::Empty();
}

const StyleTimeline& CSSAnimationData::InitialTimeline() {
  //DEFINE_STATIC_LOCAL(const StyleTimeline, timeline, (CSSValueID::kAuto));
  thread_local static const StyleTimeline timeline = new StyleTimeline(CSSValueID::kAuto)

  return timeline;
}

bool CSSAnimationData::AnimationsMatchForStyleRecalc(
    const CSSAnimationData& other) const {
  return name_list_ == other.name_list_ &&
         timeline_list_ == other.timeline_list_ &&
         play_state_list_ == other.play_state_list_ &&
         iteration_count_list_ == other.iteration_count_list_ &&
         direction_list_ == other.direction_list_ &&
         fill_mode_list_ == other.fill_mode_list_ &&
         range_start_list_ == other.range_start_list_ &&
         range_end_list_ == other.range_end_list_ &&
         TimingMatchForStyleRecalc(other);
}

Timing CSSAnimationData::ConvertToTiming(size_t index) const {
  assert(index < name_list_.size());
  Timing timing = CSSTimingData::ConvertToTiming(index);
  timing.iteration_count = GetRepeated(iteration_count_list_, index);
  timing.direction = GetRepeated(direction_list_, index);
  timing.fill_mode = GetRepeated(fill_mode_list_, index);
  timing.AssertValid();
  return timing;
}

const StyleTimeline& CSSAnimationData::GetTimeline(size_t index) const {
  assert(index < name_list_.size());
  return GetRepeated(timeline_list_, index);
}

}  // namespace webf
