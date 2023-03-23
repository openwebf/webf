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
      height_(initializer->hasHeight() ? initializer->height() : 0.0),
      is_primary(initializer->hasIsPrimary() && initializer->isPrimary()),
      pointer_id_(initializer->hasPointerId() ? initializer->pointerId() : 0.0),
      pointer_type_(initializer->hasPointerType() ? initializer->pointerType() : AtomicString::Empty()),
      pressure_(initializer->hasPressure() ? initializer->pressure() : 0.0),
      tangential_pressure_(initializer->hasTangentialPressure() ? initializer->tangentialPressure() : 0.0),
      tilt_x_(initializer->hasTiltX() ? initializer->tiltX() : 0.0),
      tilt_y_(initializer->hasTiltY() ? initializer->tiltY() : 0.0),
      twist_(initializer->hasTwist() ? initializer->twist() : 0.0),
      width_(initializer->hasWidth() ? initializer->width() : 0.0) {}

PointerEvent::PointerEvent(ExecutingContext* context,
                           const AtomicString& type,
                           NativePointerEvent* native_pointer_event)
    : MouseEvent(context, type, &native_pointer_event->native_event),
      height_(native_pointer_event->height),
      is_primary(native_pointer_event->isPrimary),
      pointer_id_(native_pointer_event->pointerId),
#if ANDROID_32_BIT
      pointer_type_(AtomicString(ctx(),
                                 std::unique_ptr<AutoFreeNativeString>(
                                     reinterpret_cast<AutoFreeNativeString*>(native_pointer_event->pointerType)))),
#else
      pointer_type_(AtomicString(ctx(), std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_pointer_event->pointerType)))),
#endif
      pressure_(native_pointer_event->pressure),
      tangential_pressure_(native_pointer_event->tangentialPressure),
      tilt_x_(native_pointer_event->tiltX),
      tilt_y_(native_pointer_event->tiltY),
      twist_(native_pointer_event->twist),
      width_(native_pointer_event->width) {
}

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