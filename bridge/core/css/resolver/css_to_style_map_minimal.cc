/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/resolver/css_to_style_map.h"

#include "css_value_keywords.h"
#include "core/animation/css/css_animation_data.h"
#include "core/animation/css/css_transition_data.h"
#include "core/animation/timing.h"
#include "core/css/css_custom_ident_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/platform/animation/timing_function.h"

namespace webf {

// Animation mapping methods needed for transition properties

Timing::Delay CSSToStyleMap::MapAnimationDelayStart(StyleResolverState& state,
                                                    const CSSValue& value) {
  if (auto* primitive_value = DynamicTo<CSSPrimitiveValue>(&value)) {
    return Timing::Delay(AnimationTimeDelta(primitive_value->ComputeSeconds()));
  }
  return Timing::Delay();
}

std::optional<double> CSSToStyleMap::MapAnimationDuration(
    StyleResolverState& state,
    const CSSValue& value) {
  if (auto* primitive_value = DynamicTo<CSSPrimitiveValue>(&value)) {
    return primitive_value->ComputeSeconds();
  }
  return 0.0;
}

CSSTransitionData::TransitionBehavior CSSToStyleMap::MapAnimationBehavior(
    StyleResolverState& state,
    const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kNormal:
        return CSSTransitionData::TransitionBehavior::kNormal;
      case CSSValueID::kAllowDiscrete:
        return CSSTransitionData::TransitionBehavior::kAllowDiscrete;
      default:
        break;
    }
  }
  return CSSTransitionData::TransitionBehavior::kNormal;
}

CSSTransitionData::TransitionProperty CSSToStyleMap::MapAnimationProperty(
    StyleResolverState& state,
    const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    if (identifier_value->GetValueID() == CSSValueID::kAll) {
      return CSSTransitionData::InitialProperty();
    }
    if (identifier_value->GetValueID() == CSSValueID::kNone) {
      return CSSTransitionData::TransitionProperty(CSSTransitionData::kTransitionNone);
    }
  }
  // TODO: Parse specific property names
  return CSSTransitionData::InitialProperty();
}

std::shared_ptr<TimingFunction> CSSToStyleMap::MapAnimationTimingFunction(
    StyleResolverState& state,
    const CSSValue& value) {
  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(&value)) {
    switch (identifier_value->GetValueID()) {
      case CSSValueID::kEase:
        return CubicBezierTimingFunction::Preset(
            CubicBezierTimingFunction::EaseType::EASE);
      case CSSValueID::kLinear:
        return LinearTimingFunction::Shared();
      case CSSValueID::kEaseIn:
        return CubicBezierTimingFunction::Preset(
            CubicBezierTimingFunction::EaseType::EASE_IN);
      case CSSValueID::kEaseOut:
        return CubicBezierTimingFunction::Preset(
            CubicBezierTimingFunction::EaseType::EASE_OUT);
      case CSSValueID::kEaseInOut:
        return CubicBezierTimingFunction::Preset(
            CubicBezierTimingFunction::EaseType::EASE_IN_OUT);
      case CSSValueID::kStepStart:
        return StepsTimingFunction::Preset(
            StepsTimingFunction::StepPosition::START);
      case CSSValueID::kStepEnd:
        return StepsTimingFunction::Preset(
            StepsTimingFunction::StepPosition::END);
      default:
        break;
    }
  }
  // TODO: Handle cubic-bezier() and steps() functions
  return CubicBezierTimingFunction::Preset(
      CubicBezierTimingFunction::EaseType::EASE);
}

}  // namespace webf