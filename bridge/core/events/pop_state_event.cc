/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "pop_state_event.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "event_type_names.h"
#include "qjs_pop_state_event.h"

namespace webf {

PopStateEvent* PopStateEvent::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<PopStateEvent>(context, event_type_names::kpopstate, exception_state);
}

PopStateEvent* PopStateEvent::Create(ExecutingContext* context,
                                     const AtomicString& type,
                                     const std::shared_ptr<PopStateEventInit>& initializer,
                                     ExceptionState& exception_state) {
  return MakeGarbageCollected<PopStateEvent>(context, type, initializer, exception_state);
}

PopStateEvent::PopStateEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}

PopStateEvent::PopStateEvent(ExecutingContext* context,
                             const AtomicString& type,
                             const std::shared_ptr<PopStateEventInit>& initializer,
                             ExceptionState& exception_state)
    : Event(context, type), state_(initializer->hasState() ? initializer->state() : ScriptValue::Empty(ctx())) {}

PopStateEvent::PopStateEvent(ExecutingContext* context, const AtomicString& type, NativePopStateEvent* native_ui_event)
    : Event(context, type, &native_ui_event->native_event),
#if ANDROID_32_BIT
      state_(ScriptValue::CreateJsonObject(context->ctx(),
                                           reinterpret_cast<const char*>(native_ui_event->state),
                                           strlen(reinterpret_cast<const char*>(native_ui_event->state))))
#else
      state_(ScriptValue::CreateJsonObject(context->ctx(),
                                           static_cast<const char*>(native_ui_event->state),
                                           strlen(static_cast<const char*>(native_ui_event->state))))
#endif
{
}

ScriptValue PopStateEvent::state() const {
  return state_;
}

bool PopStateEvent::IsPopstateEvent() const {
  return true;
}

const PopStateEventPublicMethods* PopStateEvent::popStateEventPublicMethods() {
  static PopStateEventPublicMethods pop_state_event_public_methods;
  return &pop_state_event_public_methods;
}

void PopStateEvent::Trace(GCVisitor* visitor) const {
  state_.Trace(visitor);
  Event::Trace(visitor);
}

}  // namespace webf
