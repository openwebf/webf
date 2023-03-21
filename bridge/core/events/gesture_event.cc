/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gesture_event.h"
#include "qjs_gesture_event.h"

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
      state_(initializer->hasState() ? initializer->state() : AtomicString::Empty()),
      direction_(initializer->hasDirection() ? initializer->direction() : AtomicString::Empty()),
      deltaX_(initializer->hasDeltaX() ? initializer->deltaX() : 0.0),
      deltaY_(initializer->hasDeltaY() ? initializer->deltaY() : 0.0),
      scale_(initializer->hasScale() ? initializer->scale() : 0.0),
      rotation_(initializer->hasRotation() ? initializer->rotation() : 0.0) {}

GestureEvent::GestureEvent(ExecutingContext* context,
                           const AtomicString& type,
                           NativeGestureEvent* native_gesture_event)
    : Event(context, type, &native_gesture_event->native_event),
#if ANDROID_32_BIT
      state_(AtomicString(
          ctx(),
          std::make_unique<AutoFreeNativeString>(reinterpret_cast<SharedNativeString*>(native_gesture_event->state)))),
      direction_(AtomicString(ctx(),
                              std::make_unique<AutoFreeNativeString>(
                                  reinterpret_cast<SharedNativeString*>(native_gesture_event->direction)))),
#else
      state_(AtomicString(ctx(), std::make_unique<AutoFreeNativeString>(native_gesture_event->state))),
      direction_(AtomicString(ctx(), std::make_unique<AutoFreeNativeString>(native_gesture_event->direction))),
#endif
      deltaX_(native_gesture_event->deltaX),
      deltaY_(native_gesture_event->deltaY),
      velocityX_(native_gesture_event->velocityX),
      velocityY_(native_gesture_event->velocityY),
      scale_(native_gesture_event->scale),
      rotation_(native_gesture_event->rotation) {
}

bool GestureEvent::IsGestureEvent() const {
  return true;
}

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
