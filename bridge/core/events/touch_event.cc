/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "touch_event.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "qjs_touch_event.h"

namespace webf {

TouchEvent* TouchEvent::Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
  return MakeGarbageCollected<TouchEvent>(context, type, exception_state);
}

TouchEvent* TouchEvent::Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<TouchEventInit>& initializer,
                               ExceptionState& exception_state) {
  return MakeGarbageCollected<TouchEvent>(context, type, initializer, exception_state);
}

TouchEvent::TouchEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : UIEvent(context, type, exception_state),
    changed_touches_(TouchList::Create(context)),
    touches_(TouchList::Create(context)),
    target_touches_(TouchList::Create(context)) {}

TouchEvent::TouchEvent(ExecutingContext* context,
                       const AtomicString& type,
                       const std::shared_ptr<TouchEventInit>& initializer,
                       ExceptionState& exception_state)
    : UIEvent(context, type, initializer, exception_state),
      alt_key_(initializer->hasAltKey() && initializer->altKey()),
      changed_touches_(initializer->hasChangedTouches() ? initializer->changedTouches() : TouchList::Create(context)),
      ctrl_key_(initializer->hasCtrlKey() && initializer->ctrlKey()),
      meta_key_(initializer->hasMetaKey() && initializer->metaKey()),
      shift_key_(initializer->hasShiftKey() && initializer->shiftKey()),
      target_touches_(initializer->hasTargetTouches() ? initializer->targetTouches() : TouchList::Create(context)),
      touches_(initializer->hasTouches() ? initializer->touches() : TouchList::Create(context)) {}

TouchEvent::TouchEvent(ExecutingContext* context, const AtomicString& type, NativeTouchEvent* native_touch_event)
    : UIEvent(context, type, &native_touch_event->native_event),
      alt_key_(native_touch_event->altKey),
      ctrl_key_(native_touch_event->ctrlKey),
      meta_key_(native_touch_event->metaKey),
      shift_key_(native_touch_event->shiftKey),
#if ANDROID_32_BIT
      changed_touches_(
          MakeGarbageCollected<TouchList>(context,
                                          reinterpret_cast<NativeTouchList*>(native_touch_event->changedTouches))),
      target_touches_(
          MakeGarbageCollected<TouchList>(context,
                                          reinterpret_cast<NativeTouchList*>(native_touch_event->targetTouches))),
      touches_(
          MakeGarbageCollected<TouchList>(context, reinterpret_cast<NativeTouchList*>(native_touch_event->touches)))
#else
      changed_touches_(
          MakeGarbageCollected<TouchList>(context, static_cast<NativeTouchList*>(native_touch_event->changedTouches))),
      target_touches_(
          MakeGarbageCollected<TouchList>(context, static_cast<NativeTouchList*>(native_touch_event->targetTouches))),
      touches_(MakeGarbageCollected<TouchList>(context, static_cast<NativeTouchList*>(native_touch_event->touches)))
#endif
{
}

bool TouchEvent::altKey() const {
  return alt_key_;
}
bool TouchEvent::ctrlKey() const {
  return ctrl_key_;
}

bool TouchEvent::metaKey() const {
  return false;
}

bool TouchEvent::shiftKey() const {
  return shift_key_;
}

TouchList* TouchEvent::changedTouches() const {
  return changed_touches_;
}

TouchList* TouchEvent::targetTouches() const {
  return target_touches_;
}

void TouchEvent::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(touches_);
  visitor->TraceMember(changed_touches_);
  visitor->TraceMember(target_touches_);
  UIEvent::Trace(visitor);
}

TouchList* TouchEvent::touches() const {
  return touches_;
}

bool TouchEvent::IsTouchEvent() const {
  return true;
}

}  // namespace webf
