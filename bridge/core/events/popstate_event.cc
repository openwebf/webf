/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "popstate_event.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "event_type_names.h"
#include "qjs_popstate_event.h"

namespace webf {

PopstateEvent* PopstateEvent::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<PopstateEvent>(context, event_type_names::kpopstate, exception_state);
}

PopstateEvent* PopstateEvent::Create(ExecutingContext* context,
                                     const AtomicString& type,
                                     const std::shared_ptr<PopstateEventInit>& initializer,
                                     ExceptionState& exception_state) {
  return MakeGarbageCollected<PopstateEvent>(context, type, initializer, exception_state);
}

PopstateEvent::PopstateEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}

PopstateEvent::PopstateEvent(ExecutingContext* context,
                             const AtomicString& type,
                             const std::shared_ptr<PopstateEventInit>& initializer,
                             ExceptionState& exception_state)
    : Event(context, type), state_(initializer->hasState() ? initializer->state() : ScriptValue::Empty(ctx())) {}

PopstateEvent::PopstateEvent(ExecutingContext* context, const AtomicString& type, NativePopstateEvent* native_ui_event)
    : Event(context, type, &native_ui_event->native_event),
      state_(ScriptValue::CreateJsonObject(context->ctx(),
                                           static_cast<const char*>(native_ui_event->state),
                                           strlen(static_cast<const char*>(native_ui_event->state)))) {}

ScriptValue PopstateEvent::state() const {
  return state_;
}

bool PopstateEvent::IsPopstateEvent() const {
  return true;
}

void PopstateEvent::Trace(GCVisitor* visitor) const {
  Event::Trace(visitor);
}

}  // namespace webf