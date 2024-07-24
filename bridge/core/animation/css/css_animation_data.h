// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ANIMATION_CSS_CSS_ANIMATION_DATA_H_
#define WEBF_CORE_ANIMATION_CSS_CSS_ANIMATION_DATA_H_

#include <memory>

#include "foundation/ptr_util.h"
#include "core/animation/css/css_timing_data.h"
#include "core/animation/effect_model.h"
#include "core/animation/timing.h"
#include "core/style/computed_style_constants.h"
#include "core/style/style_name_or_keyword.h"
#include "core/style/style_timeline.h"

namespace webf {

class CSSAnimationData final : public CSSTimingData {
 public:
  CSSAnimationData();
  explicit CSSAnimationData(const CSSAnimationData&);

  std::unique_ptr<CSSAnimationData> Clone() const {
    return base::WrapUnique(new CSSAnimationData(*this));
  }

  bool AnimationsMatchForStyleRecalc(const CSSAnimationData& other) const;
  bool operator==(const CSSAnimationData& other) const {
    return AnimationsMatchForStyleRecalc(other);
  }

  Timing ConvertToTiming(size_t index) const;
  const StyleTimeline& GetTimeline(size_t index) const;

  const std::vector<AtomicString>& NameList() const { return name_list_; }
  const std::vector<StyleTimeline>& TimelineList() const { return timeline_list_; }

  const std::vector<double>& IterationCountList() const {
    return iteration_count_list_;
  }
  const std::vector<Timing::PlaybackDirection>& DirectionList() const {
    return direction_list_;
  }
  const std::vector<Timing::FillMode>& FillModeList() const {
    return fill_mode_list_;
  }
  const std::vector<EAnimPlayState>& PlayStateList() const {
    return play_state_list_;
  }
  const std::vector<std::optional<TimelineOffset>>& RangeStartList() const {
    return range_start_list_;
  }
  const std::vector<std::optional<TimelineOffset>>& RangeEndList() const {
    return range_end_list_;
  }

  const std::vector<EffectModel::CompositeOperation>& CompositionList() const {
    return composition_list_;
  }

  EffectModel::CompositeOperation GetComposition(size_t animation_index) const {
    if (!composition_list_.size()) {
      return EffectModel::kCompositeReplace;
    }
    uint32_t index = animation_index % composition_list_.size();
    return composition_list_[index];
  }

  std::vector<AtomicString>& NameList() { return name_list_; }
  std::vector<StyleTimeline>& TimelineList() { return timeline_list_; }
  std::vector<double>& IterationCountList() { return iteration_count_list_; }
  std::vector<Timing::PlaybackDirection>& DirectionList() { return direction_list_; }
  std::vector<Timing::FillMode>& FillModeList() { return fill_mode_list_; }
  std::vector<EAnimPlayState>& PlayStateList() { return play_state_list_; }

  std::vector<std::optional<TimelineOffset>>& RangeStartList() {
    return range_start_list_;
  }
  std::vector<std::optional<TimelineOffset>>& RangeEndList() {
    return range_end_list_;
  }
  std::vector<EffectModel::CompositeOperation>& CompositionList() {
    return composition_list_;
  }

  bool HasSingleInitialTimeline() const {
    return timeline_list_.size() == 1u &&
           timeline_list_.front() == InitialTimeline();
  }
  bool HasSingleInitialRangeStart() const {
    return range_start_list_.size() == 1u &&
           range_start_list_.front() == InitialRangeStart();
  }
  bool HasSingleInitialRangeEnd() const {
    return range_end_list_.size() == 1u &&
           range_end_list_.front() == InitialRangeEnd();
  }

  static std::optional<double> InitialDuration();
  static const AtomicString& InitialName();
  static const StyleTimeline& InitialTimeline();
  static Timing::PlaybackDirection InitialDirection() {
    return Timing::PlaybackDirection::NORMAL;
  }
  static Timing::FillMode InitialFillMode() { return Timing::FillMode::NONE; }
  static double InitialIterationCount() { return 1.0; }
  static EAnimPlayState InitialPlayState() { return EAnimPlayState::kPlaying; }
  static std::optional<TimelineOffset> InitialRangeStart() {
    return std::nullopt;
  }
  static std::optional<TimelineOffset> InitialRangeEnd() {
    return std::nullopt;
  }
  static EffectModel::CompositeOperation InitialComposition() {
    return EffectModel::CompositeOperation::kCompositeReplace;
  }

 private:
  std::vector<AtomicString> name_list_;
  std::vector<StyleTimeline> timeline_list_;
  std::vector<std::optional<TimelineOffset>> range_start_list_;
  std::vector<std::optional<TimelineOffset>> range_end_list_;
  std::vector<double> iteration_count_list_;
  std::vector<Timing::PlaybackDirection> direction_list_;
  std::vector<Timing::FillMode> fill_mode_list_;
  std::vector<EAnimPlayState> play_state_list_;
  std::vector<EffectModel::CompositeOperation> composition_list_;
};

}  // namespace webf

#endif  // WEBF_CORE_ANIMATION_CSS_CSS_ANIMATION_DATA_H_
