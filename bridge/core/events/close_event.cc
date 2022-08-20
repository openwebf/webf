/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "close_event.h"

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
      code_(initializer->code()),
      reason_(initializer->reason()),
      was_clean_(initializer->wasClean()) {}

int32_t CloseEvent::code() const {
  return code_;
}

const AtomicString& CloseEvent::reason() const {
  return reason_;
}

bool CloseEvent::wasClean() const {
  return was_clean_;
}

}  // namespace webf