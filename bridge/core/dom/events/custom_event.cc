/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "custom_event.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "native_value_converter.h"

namespace webf {

CustomEvent* CustomEvent::Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
  return MakeGarbageCollected<CustomEvent>(context, type, exception_state);
}

CustomEvent* CustomEvent::Create(ExecutingContext* context,
                                 const AtomicString& type,
                                 NativeCustomEvent* native_custom_event) {
  return MakeGarbageCollected<CustomEvent>(context, type, native_custom_event);
}

CustomEvent* CustomEvent::Create(ExecutingContext* context,
                                 const AtomicString& type,
                                 const std::shared_ptr<CustomEventInit>& initialize,
                                 ExceptionState& exception_state) {
  return MakeGarbageCollected<CustomEvent>(context, type, initialize, exception_state);
}

CustomEvent::CustomEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}

CustomEvent::CustomEvent(ExecutingContext* context, const AtomicString& type, NativeCustomEvent* native_custom_event)
    : Event(context, type, &native_custom_event->native_event),
      detail_(ScriptValue(ctx(), *native_custom_event->detail)) {}

CustomEvent::CustomEvent(ExecutingContext* context,
                         const AtomicString& type,
                         const std::shared_ptr<CustomEventInit>& initialize,
                         ExceptionState& exception_state)
    : Event(context, type), detail_(initialize->detail()) {}

ScriptValue CustomEvent::detail() const {
  return detail_;
}

void CustomEvent::initCustomEvent(const AtomicString& type, ExceptionState& exception_state) {
  initCustomEvent(type, false, false, ScriptValue::Empty(ctx()), exception_state);
}
void CustomEvent::initCustomEvent(const AtomicString& type, bool can_bubble, ExceptionState& exception_state) {
  initCustomEvent(type, can_bubble, false, ScriptValue::Empty(ctx()), exception_state);
}
void CustomEvent::initCustomEvent(const AtomicString& type,
                                  bool can_bubble,
                                  bool cancelable,
                                  ExceptionState& exception_state) {
  initCustomEvent(type, can_bubble, cancelable, ScriptValue::Empty(ctx()), exception_state);
}
void CustomEvent::initCustomEvent(const AtomicString& type,
                                  bool can_bubble,
                                  bool cancelable,
                                  const ScriptValue& detail,
                                  ExceptionState& exception_state) {
  initEvent(type, can_bubble, cancelable, exception_state);
  if (!IsBeingDispatched() && !detail.IsEmpty()) {
    detail_ = detail;
  }
}

bool CustomEvent::IsCustomEvent() const {
  return true;
}

void CustomEvent::Trace(GCVisitor* visitor) const {
  Event::Trace(visitor);
  detail_.Trace(visitor);
}

}  // namespace webf
