/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "animation_event.h"
#include "event_type_names.h"

namespace webf {

AnimationEvent* AnimationEvent::Create(ExecutingContext* context,
                                       const AtomicString& type,
                                       ExceptionState& exception_state) {
  return MakeGarbageCollected<AnimationEvent>(context, type, exception_state);
}

AnimationEvent* AnimationEvent::Create(ExecutingContext* context,
                                       const AtomicString& type,
                                       const AtomicString& animation_name,
                                       const AtomicString& pseudo_element,
                                       double elapsed_time,
                                       ExceptionState& exception_state) {
  return MakeGarbageCollected<AnimationEvent>(context, type, animation_name, pseudo_element, elapsed_time,
                                              exception_state);
}
AnimationEvent* AnimationEvent::Create(ExecutingContext* context,
                                       const AtomicString& type,
                                       const std::shared_ptr<AnimationEventInit>& initializer,
                                       ExceptionState& exception_state) {
  return MakeGarbageCollected<AnimationEvent>(context, type, initializer, exception_state);
}

AnimationEvent::AnimationEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}

AnimationEvent::AnimationEvent(ExecutingContext* context,
                               const AtomicString& type,
                               const AtomicString& animation_name,
                               const AtomicString& pseudo_element,
                               double elapsed_time,
                               ExceptionState& exception_state)
    : Event(context, type),
      animation_name_(animation_name),
      pseudo_element_(pseudo_element),
      elapsed_time_(elapsed_time) {}

AnimationEvent::AnimationEvent(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<AnimationEventInit>& initializer,
                               ExceptionState& exception_state)
    : Event(context, type),
      animation_name_(initializer->hasAnimationName() ? initializer->animationName() : AtomicString::Empty()),
      pseudo_element_(initializer->hasPseudoElement() ? initializer->pseudoElement() : AtomicString::Empty()),
      elapsed_time_(initializer->hasElapsedTime() ? initializer->elapsedTime() : 0) {}

const AtomicString& AnimationEvent::animationName() const {
  return animation_name_;
}

bool AnimationEvent::IsAnimationEvent() const {
  return true;
}

double AnimationEvent::elapsedTime() const {
  return elapsed_time_;
}

const AtomicString& AnimationEvent::pseudoElement() const {
  return pseudo_element_;
}

const AnimationEventPublicMethods* AnimationEvent::animationEventPublicMethods() {
  static AnimationEventPublicMethods animation_event_public_methods;
  return &animation_event_public_methods;
}

}  // namespace webf
