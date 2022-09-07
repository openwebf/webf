/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "transition_event.h"
#include "qjs_transition_event.h"

namespace webf {

TransitionEvent *TransitionEvent::Create(ExecutingContext *context,
                                         const AtomicString &type,
                                         ExceptionState &exception_state) {
  return MakeGarbageCollected<TransitionEvent>(context, type, exception_state);
}

TransitionEvent *TransitionEvent::Create(ExecutingContext *context,
                                         const AtomicString &type,
                                         const std::shared_ptr<TransitionEventInit> &initializer,
                                         ExceptionState &exception_state) {
  return MakeGarbageCollected<TransitionEvent>(context, type, initializer, exception_state);
}

TransitionEvent::TransitionEvent(ExecutingContext *context, const AtomicString &type, ExceptionState &exception_state)
    : Event(context, type) {}
TransitionEvent::TransitionEvent(ExecutingContext *context,
                                 const AtomicString &type,
                                 const std::shared_ptr<TransitionEventInit> &initializer,
                                 ExceptionState &exception_state) :
    Event(context, type, initializer),
    elapsed_time_(initializer->elapsedTime()),
    property_name_(initializer->propertyName()),
    pseudo_element_(initializer->pseudoElement()) {
}

TransitionEvent::TransitionEvent(ExecutingContext *context,
                                 const AtomicString &type,
                                 NativeTransitionEvent *native_transition_event) :

    Event(context, type, &native_transition_event->native_event),
    elapsed_time_(native_transition_event->elapsedTime),
    property_name_(AtomicString(ctx(), native_transition_event->propertyName)),
    pseudo_element_(AtomicString(ctx(), native_transition_event->pseudoElement)) {
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

}