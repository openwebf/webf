/*
 * Copyright (C) 2013 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ANIMATION_TIMING_H_
#define WEBF_CORE_ANIMATION_TIMING_H_

#include <optional>
#include "foundation/webf_malloc.h"
#include "core/base/memory/values_equivalent.h"
#include "cc/animation/keyframe_model.h"
#include "third_party/blink/renderer/bindings/core/v8/v8_timeline_range.h"
#include "third_party/blink/renderer/bindings/core/v8/v8_typedefs.h"
#include "third_party/blink/renderer/bindings/core/v8/v8_union_cssnumericvalue_double.h"
#include "third_party/blink/renderer/bindings/core/v8/v8_union_string_timelinerangeoffset.h"
#include "core/animation/animation_time_delta.h"
#include "core/css/css_value.h"
#include "core/platform/animation/timing_function.h"
#include "core/geometry/length.h"
#include "core/platform/math_extras.h"

namespace webf {

class EffectTiming;
class ComputedEffectTiming;
enum class TimelinePhase;

struct Timing {
  USING_FAST_MALLOC(Timing);

 public:
  // Note that logic in CSSAnimations depends on the order of these values.
  enum Phase {
    kPhaseBefore,
    kPhaseActive,
    kPhaseAfter,
    kPhaseNone,
  };
  // Represents the animation direction from the Web Animations spec, see
  // https://drafts.csswg.org/web-animations-1/#animation-direction.
  enum class AnimationDirection {
    kForwards,
    kBackwards,
  };

  // Timing properties set via AnimationEffect.updateTiming override their
  // corresponding CSS properties.
  enum AnimationTimingOverride {
    kOverrideNode = 0,
    kOverrideDirection = 1,
    kOverrideDuration = 1 << 1,
    kOverrideEndDelay = 1 << 2,
    kOverideFillMode = 1 << 3,
    kOverrideIterationCount = 1 << 4,
    kOverrideIterationStart = 1 << 5,
    kOverrideStartDelay = 1 << 6,
    kOverrideTimingFunction = 1 << 7,
    kOverrideRangeStart = 1 << 8,
    kOverrideRangeEnd = 1 << 9,
    kOverrideAll = (1 << 10) - 1
  };

  using V8Delay = V8UnionCSSNumericValueOrDouble;

  // Delay can be directly expressed as time delays or calculated based on a
  // position on a view timeline. As part of the normalization process, a
  // timeline offsets are converted to time-based delays.
  struct Delay {
    // TODO(crbug.com/7575): Support percent delays in addition to time-based
    // delays.
    AnimationTimeDelta time_delay;
    std::optional<double> relative_delay;

    Delay() = default;

    explicit Delay(AnimationTimeDelta time) : time_delay(time) {}

    bool IsInfinite() const { return time_delay.is_inf(); }

    bool operator==(const Delay& other) const {
      return time_delay == other.time_delay &&
             relative_delay == other.relative_delay;
    }

    bool operator!=(const Delay& other) const { return !(*this == other); }

    bool IsNonzeroTimeBasedDelay() const {
      return !relative_delay && !time_delay.is_zero();
    }

    // Scaling only affects time based delays.
    void Scale(double scale_factor) { time_delay *= scale_factor; }

    AnimationTimeDelta AsTimeValue() const { return time_delay; }

    V8Delay* ToV8Delay() const;
  };

  using FillMode = cc::KeyframeModel::FillMode;
  using PlaybackDirection = cc::KeyframeModel::Direction;

  static double NullValue() { return std::numeric_limits<double>::quiet_NaN(); }

  static std::string FillModeString(FillMode);
  static FillMode StringToFillMode(const std::string&);
  static std::string PlaybackDirectionString(PlaybackDirection);

  Timing() = default;

  void AssertValid() const {
    assert(!start_delay.IsInfinite());
    assert(!end_delay.IsInfinite());
    assert(std::isfinite(iteration_start));
    assert(iteration_start >= 0);
    assert(iteration_count >= 0);
    assert(!iteration_duration ||
           iteration_duration.value() >= AnimationTimeDelta());
    assert(timing_function);
  }

  Timing::FillMode ResolvedFillMode(bool is_animation) const;
  EffectTiming* ConvertToEffectTiming() const;

  bool operator==(const Timing& other) const {
    return start_delay == other.start_delay && end_delay == other.end_delay &&
           fill_mode == other.fill_mode &&
           iteration_start == other.iteration_start &&
           iteration_count == other.iteration_count &&
           iteration_duration == other.iteration_duration &&
           direction == other.direction &&
           webf::ValuesEquivalent(timing_function.get(),
                                  other.timing_function.get());
  }

  bool operator!=(const Timing& other) const { return !(*this == other); }

  // Explicit changes to animation timing through the web animations API,
  // override timing changes due to CSS style.
  void SetTimingOverride(AnimationTimingOverride override) {
    timing_overrides |= override;
  }
  bool HasTimingOverride(AnimationTimingOverride override) {
    return timing_overrides & override;
  }
  bool HasTimingOverrides() { return timing_overrides != kOverrideNode; }

  V8CSSNumberish* ToComputedValue(std::optional<AnimationTimeDelta>,
                                  std::optional<AnimationTimeDelta>) const;

  Delay start_delay;
  Delay end_delay;
  FillMode fill_mode = FillMode::AUTO;
  double iteration_start = 0;
  double iteration_count = 1;
  // If empty, indicates the 'auto' value.
  std::optional<AnimationTimeDelta> iteration_duration = std::nullopt;

  PlaybackDirection direction = PlaybackDirection::NORMAL;
  std::shared_ptr<TimingFunction> timing_function =
      LinearTimingFunction::Shared();
  // Mask of timing attributes that are set by calls to
  // AnimationEffect.updateTiming. Once set, these attributes ignore changes
  // based on the CSS style.
  uint16_t timing_overrides = kOverrideNode;

  struct CalculatedTiming {
    WEBF_DISALLOW_NEW();
    Phase phase = Phase::kPhaseNone;
    std::optional<double> current_iteration = 0;
    std::optional<double> progress = 0;
    bool is_current = false;
    bool is_in_effect = false;
    bool is_in_play = false;
    std::optional<AnimationTimeDelta> local_time;
    AnimationTimeDelta time_to_forwards_effect_change =
        AnimationTimeDelta::Max();
    AnimationTimeDelta time_to_reverse_effect_change =
        AnimationTimeDelta::Max();
    AnimationTimeDelta time_to_next_iteration = AnimationTimeDelta::Max();
  };

  // Normalized values contain specified timing values after normalizing to
  // timeline.
  struct NormalizedTiming {
    WEBF_DISALLOW_NEW();
    // Value used in normalization math. Stored so that we can convert back if
    // needed. At present, only scroll-linked animations have a timeline
    // duration. If this changes, we need to update the is_current calculation.
    std::optional<AnimationTimeDelta> timeline_duration;
    // Though timing delays may be expressed as either times or (phase,offset)
    // pairs, post normalization, delays is expressed in time.
    AnimationTimeDelta start_delay;
    AnimationTimeDelta end_delay;
    AnimationTimeDelta iteration_duration;
    // Calculated as (iteration_duration * iteration_count)
    AnimationTimeDelta active_duration;
    // Calculated as (start_delay + active_duration + end_delay)
    AnimationTimeDelta end_time;
    // Indicates if the before-active phase boundary aligns with the minimum
    // scroll position.
    bool is_start_boundary_aligned = false;
    // Indicates if the active-after phase boundary aligns with the maximum
    // scroll position.
    bool is_end_boundary_aligned = false;
  };

  // TODO(crbug.com/1394434): Cleanup method signature by passing in
  // AnimationEffectOwner.
  CalculatedTiming CalculateTimings(
      std::optional<AnimationTimeDelta> local_time,
      bool is_idle,
      const NormalizedTiming& normalized_timing,
      AnimationDirection animation_direction,
      bool is_keyframe_effect,
      std::optional<double> playback_rate) const;
  ComputedEffectTiming* getComputedTiming(const CalculatedTiming& calculated,
                                          const NormalizedTiming& normalized,
                                          bool is_keyframe_effect) const;
};

}  // namespace webf

#endif  // WEBF_CORE_ANIMATION_TIMING_H_