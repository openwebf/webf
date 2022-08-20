/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gesture_event.h"

namespace webf {

GestureEvent* GestureEvent::Create(ExecutingContext* context,
                                   const AtomicString& type,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<GestureEvent>(context, type, exception_state);
}

GestureEvent* GestureEvent::Create(ExecutingContext* context,
                                   const AtomicString& type,
                                   const std::shared_ptr<GestureEventInit>& initializer,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<GestureEvent>(context, type, initializer, exception_state);
}

GestureEvent::GestureEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}

GestureEvent::GestureEvent(ExecutingContext* context,
                           const AtomicString& type,
                           const std::shared_ptr<GestureEventInit>& initializer,
                           ExceptionState& exception_state)
    : Event(context, type),
      state_(initializer->state()),
      direction_(initializer->direction()),
      deltaX_(initializer->deltaX()),
      deltaY_(initializer->deltaY()),
      scale_(initializer->scale()),
      rotation_(initializer->rotation()) {}

const AtomicString& GestureEvent::state() const {
  return state_;
}

const AtomicString& GestureEvent::direction() const {
  return direction_;
}

double GestureEvent::deltaX() const {
  return deltaX_;
}

double GestureEvent::deltaY() const {
  return deltaY_;
}

double GestureEvent::velocityX() const {
  return velocityX_;
}

double GestureEvent::velocityY() const {
  return velocityY_;
}

double GestureEvent::scale() const {
  return scale_;
}

double GestureEvent::rotation() const {
  return rotation_;
}

}  // namespace webf
