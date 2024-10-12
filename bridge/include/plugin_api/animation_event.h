/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_ANIMATION_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_ANIMATION_EVENT_H_
#include <stdint.h>
#include "event.h"
namespace webf {
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct AnimationEvent AnimationEvent;
using PublicAnimationEventGetAnimationName = const char* (*)(AnimationEvent*);
using PublicAnimationEventDupAnimationName = const char* (*)(AnimationEvent*);
using PublicAnimationEventGetElapsedTime = double (*)(AnimationEvent*);
using PublicAnimationEventGetPseudoElement = const char* (*)(AnimationEvent*);
using PublicAnimationEventDupPseudoElement = const char* (*)(AnimationEvent*);
struct AnimationEventPublicMethods : public WebFPublicMethods {
  static const char* AnimationName(AnimationEvent* animationEvent);
  static const char* DupAnimationName(AnimationEvent* animationEvent);
  static double ElapsedTime(AnimationEvent* animationEvent);
  static const char* PseudoElement(AnimationEvent* animationEvent);
  static const char* DupPseudoElement(AnimationEvent* animationEvent);
  double version{1.0};
  PublicAnimationEventGetAnimationName animation_event_get_animation_name{AnimationName};
  PublicAnimationEventDupAnimationName animation_event_dup_animation_name{DupAnimationName};
  PublicAnimationEventGetElapsedTime animation_event_get_elapsed_time{ElapsedTime};
  PublicAnimationEventGetPseudoElement animation_event_get_pseudo_element{PseudoElement};
  PublicAnimationEventDupPseudoElement animation_event_dup_pseudo_element{DupPseudoElement};
};
}  // namespace webf
#endif // WEBF_CORE_WEBF_API_PLUGIN_API_ANIMATION_EVENT_H_