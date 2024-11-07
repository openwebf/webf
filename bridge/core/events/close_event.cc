/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "close_event.h"
#include "qjs_close_event.h"

namespace webf {

CloseEvent* CloseEvent::Create(ExecutingContext* context,
                               const AtomicString& type,
                               int32_t code,
                               const AtomicString& reason,
                               bool was_clean,
                               ExceptionState& exception_state) {
  return MakeGarbageCollected<CloseEvent>(context, type, code, reason, was_clean, exception_state);
}

CloseEvent* CloseEvent::Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
  return MakeGarbageCollected<CloseEvent>(context, type, exception_state);
}

CloseEvent* CloseEvent::Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<CloseEventInit>& initializer,
                               ExceptionState& exception_state) {
  return MakeGarbageCollected<CloseEvent>(context, type, initializer, exception_state);
}

CloseEvent::CloseEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}

CloseEvent::CloseEvent(ExecutingContext* context,
                       const AtomicString& type,
                       int32_t code,
                       const AtomicString& reason,
                       bool was_clean,
                       ExceptionState& exception_state)
    : Event(context, type), code_(code), reason_(reason), was_clean_(was_clean) {}

CloseEvent::CloseEvent(ExecutingContext* context,
                       const AtomicString& type,
                       const std::shared_ptr<CloseEventInit>& initializer,
                       ExceptionState& exception_state)
    : Event(context, type),
      code_(initializer->hasCode() ? initializer->code() : 0),
      reason_(initializer->hasReason() ? initializer->reason() : AtomicString::Empty()),
      was_clean_(initializer->hasWasClean() && initializer->wasClean()) {}

CloseEvent::CloseEvent(ExecutingContext* context, const AtomicString& type, NativeCloseEvent* native_close_event)
    : Event(context, type, &native_close_event->native_event),
      code_(native_close_event->code),
#if ANDROID_32_BIT
      reason_(AtomicString(
          context->ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_close_event->reason)))),
#else
      reason_(AtomicString(
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_close_event->reason)))),
#endif
      was_clean_(native_close_event->wasClean) {
}

bool CloseEvent::IsCloseEvent() const {
  return true;
}

int64_t CloseEvent::code() const {
  return code_;
}

const AtomicString& CloseEvent::reason() const {
  return reason_;
}

bool CloseEvent::wasClean() const {
  return was_clean_;
}

}  // namespace webf