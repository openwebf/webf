/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "promise_rejection_event.h"
#include "event_type_names.h"

namespace webf {

PromiseRejectionEvent* PromiseRejectionEvent::Create(ExecutingContext* context,
                                                     const AtomicString& type,
                                                     ExceptionState& exception_state) {
  return MakeGarbageCollected<PromiseRejectionEvent>(context, type, exception_state);
}

PromiseRejectionEvent* PromiseRejectionEvent::Create(ExecutingContext* context,
                                                     const AtomicString& type,
                                                     const std::shared_ptr<PromiseRejectionEventInit>& initializer,
                                                     ExceptionState& exception_state) {
  return MakeGarbageCollected<PromiseRejectionEvent>(context, type, initializer, exception_state);
}

PromiseRejectionEvent::PromiseRejectionEvent(ExecutingContext* context,
                                             const AtomicString& type,
                                             ExceptionState& exception_state)
    : Event(context, type) {}

PromiseRejectionEvent::PromiseRejectionEvent(ExecutingContext* context,
                                             const AtomicString& type,
                                             const std::shared_ptr<PromiseRejectionEventInit>& initializer,
                                             ExceptionState& exception_state)
    : Event(context, type),
      reason_(initializer->hasReason() ? initializer->reason() : ScriptValue::Empty(ctx())),
      promise_(initializer->hasPromise() ? initializer->promise() : ScriptValue::Empty(ctx())) {}

bool PromiseRejectionEvent::IsPromiseRejectionEvent() const {
  return true;
}

const PromiseRejectionEventPublicMethods* PromiseRejectionEvent::promiseRejectionEventPublicMethods() {
  static PromiseRejectionEventPublicMethods promise_rejection_event_public_methods;
  return &promise_rejection_event_public_methods;
}

}  // namespace webf
