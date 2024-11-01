// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/animation/css/css_transition_data.h"

#include "core/animation/timing.h"
#include <cassert>

namespace webf {

CSSTransitionData::CSSTransitionData() : CSSTimingData(InitialDuration()) {
  property_list_.push_back(InitialProperty());
  behavior_list_.push_back(InitialBehavior());
}

CSSTransitionData::CSSTransitionData(const CSSTransitionData& other) = default;

bool CSSTransitionData::TransitionsMatchForStyleRecalc(
    const CSSTransitionData& other) const {
  return property_list_ == other.property_list_ &&
         TimingMatchForStyleRecalc(other);
}

Timing CSSTransitionData::ConvertToTiming(size_t index) const {
  assert(index < property_list_.size());
  // Note that the backwards fill part is required for delay to work.
  Timing timing = CSSTimingData::ConvertToTiming(index);
  timing.fill_mode = Timing::FillMode::BACKWARDS;
  return timing;
}

}  // namespace blink
