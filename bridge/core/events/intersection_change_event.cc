/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "intersection_change_event.h"
#include "qjs_intersection_change_event.h"

namespace webf {

IntersectionChangeEvent* IntersectionChangeEvent::Create(ExecutingContext* context,
                                                         const AtomicString& type,
                                                         ExceptionState& exception_state) {
  return MakeGarbageCollected<IntersectionChangeEvent>(context, type, exception_state);
}

IntersectionChangeEvent* IntersectionChangeEvent::Create(
    ExecutingContext* context,
    const AtomicString& type,
    const std::shared_ptr<IntersectionChangeEventInit>& initializer,
    ExceptionState& exception_state) {
  return MakeGarbageCollected<IntersectionChangeEvent>(context, type, initializer, exception_state);
}

IntersectionChangeEvent::IntersectionChangeEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 ExceptionState& exception_state)
    : Event(context, type) {}

IntersectionChangeEvent::IntersectionChangeEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 const std::shared_ptr<IntersectionChangeEventInit>& initializer,
                                                 ExceptionState& exception_state)
    : Event(context, type),
      intersection_ratio_(initializer->hasIntersectionRatio() ? initializer->intersectionRatio() : 0.0) {}

IntersectionChangeEvent::IntersectionChangeEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 NativeIntersectionChangeEvent* native_intersection_change_event)
    : Event(context, type, &native_intersection_change_event->native_event),
      intersection_ratio_(native_intersection_change_event->intersectionRatio) {}

double IntersectionChangeEvent::intersectionRatio() const {
  return intersection_ratio_;
}

bool IntersectionChangeEvent::IsIntersectionchangeEvent() const {
  return true;
}

const IntersectionChangeEventPublicMethods* IntersectionChangeEvent::intersectionChangeEventPublicMethods() {
  static IntersectionChangeEventPublicMethods intersection_change_event_public_methods;
  return &intersection_change_event_public_methods;
}

}  // namespace webf
