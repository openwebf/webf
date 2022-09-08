/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "pointer_event.h"
#include "qjs_pointer_event.h"

namespace webf {

PointerEvent* PointerEvent::Create(ExecutingContext* context,
                                   const AtomicString& type,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<PointerEvent>(context, type, exception_state);
}

PointerEvent* PointerEvent::Create(ExecutingContext* context,
                                   const AtomicString& type,
                                   const std::shared_ptr<PointerEventInit>& initializer,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<PointerEvent>(context, type, initializer, exception_state);
}

PointerEvent::PointerEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : MouseEvent(context, type, exception_state) {}

PointerEvent::PointerEvent(ExecutingContext* context,
                           const AtomicString& type,
                           const std::shared_ptr<PointerEventInit>& initializer,
                           ExceptionState& exception_state)
    : MouseEvent(context, type, initializer, exception_state),
      height_(initializer->height()),
      is_primary(initializer->isPrimary()),
      pointer_id_(initializer->pointerId()),
      pointer_type_(initializer->pointerType()),
      pressure_(initializer->pressure()),
      tangential_pressure_(initializer->tangentialPressure()),
      tilt_x_(initializer->tiltX()),
      tilt_y_(initializer->tiltY()),
      twist_(initializer->twist()),
      width_(initializer->width()) {}

PointerEvent::PointerEvent(ExecutingContext* context,
                           const AtomicString& type,
                           NativePointerEvent* native_pointer_event)
    : MouseEvent(context, type, &native_pointer_event->native_event),
      height_(native_pointer_event->height),
      is_primary(native_pointer_event->isPrimary),
      pointer_id_(native_pointer_event->pointerId),
      pointer_type_(AtomicString(ctx(), native_pointer_event->pointerType)),
      pressure_(native_pointer_event->pressure),
      tangential_pressure_(native_pointer_event->tangentialPressure),
      tilt_x_(native_pointer_event->tiltX),
      tilt_y_(native_pointer_event->tiltY),
      twist_(native_pointer_event->twist),
      width_(native_pointer_event->width) {}

double PointerEvent::height() const {
  return height_;
};
bool PointerEvent::isPrimary() const {
  return is_primary;
};
double PointerEvent::pointerId() const {
  return pointer_id_;
};
AtomicString PointerEvent::pointerType() const {
  return pointer_type_;
};
double PointerEvent::pressure() const {
  return pressure_;
};
double PointerEvent::tangentialPressure() const {
  return tangential_pressure_;
};
double PointerEvent::tiltX() const {
  return tilt_x_;
};
double PointerEvent::tiltY() const {
  return tilt_y_;
};
double PointerEvent::twist() const {
  return twist_;
};
double PointerEvent::width() const {
  return width_;
};

bool PointerEvent::IsPointerEvent() const {
  return true;
}

}  // namespace webf