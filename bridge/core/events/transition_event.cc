/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "transition_event.h"
#include "qjs_transition_event.h"

namespace webf {

TransitionEvent* TransitionEvent::Create(ExecutingContext* context,
                                         const AtomicString& type,
                                         ExceptionState& exception_state) {
  return MakeGarbageCollected<TransitionEvent>(context, type, exception_state);
}

TransitionEvent* TransitionEvent::Create(ExecutingContext* context,
                                         const AtomicString& type,
                                         const std::shared_ptr<TransitionEventInit>& initializer,
                                         ExceptionState& exception_state) {
  return MakeGarbageCollected<TransitionEvent>(context, type, initializer, exception_state);
}

TransitionEvent::TransitionEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}
TransitionEvent::TransitionEvent(ExecutingContext* context,
                                 const AtomicString& type,
                                 const std::shared_ptr<TransitionEventInit>& initializer,
                                 ExceptionState& exception_state)
    : Event(context, type, initializer),
      elapsed_time_(initializer->hasElapsedTime() ? initializer->elapsedTime() : 0.0),
      property_name_(initializer->hasPropertyName() ? initializer->propertyName() : AtomicString::Empty()),
      pseudo_element_(initializer->hasPseudoElement() ? initializer->pseudoElement() : AtomicString::Empty()) {}

TransitionEvent::TransitionEvent(ExecutingContext* context,
                                 const AtomicString& type,
                                 NativeTransitionEvent* native_transition_event)
    :

      Event(context, type, &native_transition_event->native_event),
      elapsed_time_(native_transition_event->elapsedTime),
#if ANDROID_32_BIT
      property_name_(AtomicString(ctx(),
                                  std::unique_ptr<AutoFreeNativeString>(
                                      reinterpret_cast<AutoFreeNativeString*>(native_transition_event->propertyName)))),
      pseudo_element_(AtomicString(ctx(),
                                   std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(
                                       native_transition_event->pseudoElement))))
#else
      property_name_(AtomicString(ctx(),
                                  std::unique_ptr<AutoFreeNativeString>(
                                      reinterpret_cast<AutoFreeNativeString*>(native_transition_event->propertyName)))),
      pseudo_element_(AtomicString(ctx(),
                                   std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(
                                       native_transition_event->pseudoElement))))
#endif
{
}

double TransitionEvent::elapsedTime() const {
  return elapsed_time_;
}

AtomicString TransitionEvent::propertyName() const {
  return property_name_;
}

AtomicString TransitionEvent::pseudoElement() const {
  return pseudo_element_;
}

bool TransitionEvent::IsTransitionEvent() const {
  return true;
}

}  // namespace webf