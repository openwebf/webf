/*
* Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

#include "screen_event.h"
#include "event_type_names.h"
#include "qjs_screen_event.h"

namespace webf {

ScreenEvent* ScreenEvent::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<ScreenEvent>(context, event_type_names::khybridrouterchange, exception_state);
}

ScreenEvent* ScreenEvent::Create(
    ExecutingContext* context,
    const AtomicString& type,
    const std::shared_ptr<ScreenEventInit>& initializer,
    ExceptionState& exception_state) {
  return MakeGarbageCollected<ScreenEvent>(context, type, initializer, exception_state);
}

ScreenEvent::ScreenEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 ExceptionState& exception_state)
    : Event(context, type) {}

ScreenEvent::ScreenEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 const std::shared_ptr<ScreenEventInit>& initializer,
                                                 ExceptionState& exception_state)
    : Event(context, type),
      state_(initializer->hasState() ? initializer->state() : ScriptValue::Empty(ctx())),
      path_(initializer->hasPath() ? initializer->path() : AtomicString::Empty()) {}

ScreenEvent::ScreenEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 NativeScreenEvent* native_event)
    : Event(context, type, &native_event->native_event),
#if ANDROID_32_BIT
      state_(ScriptValue::CreateJsonObject(context->ctx(),
                                           reinterpret_cast<const char*>(native_event->state),
                                           strlen(reinterpret_cast<const char*>(native_event->state)))),
      path_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_event->path))))
#else
      state_(ScriptValue::CreateJsonObject(context->ctx(),
                                           static_cast<const char*>(native_event->state),
                                           strlen(static_cast<const char*>(native_event->state)))),
      path_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_event->path))))
#endif
{
}

ScriptValue ScreenEvent::state() const {
  return state_;
}

AtomicString ScreenEvent::path() const {
  return path_;
}

bool ScreenEvent::IsScreenEvent() const {
  return true;
}

void ScreenEvent::Trace(GCVisitor* visitor) const {
  state_.Trace(visitor);
  Event::Trace(visitor);
}


}