/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "hybrid_router_change_event.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "event_type_names.h"
#include "qjs_hybrid_router_change_event.h"

namespace webf {

HybridRouterChangeEvent* HybridRouterChangeEvent::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<HybridRouterChangeEvent>(context, event_type_names::khybridrouterchange, exception_state);
}

HybridRouterChangeEvent* HybridRouterChangeEvent::Create(
    ExecutingContext* context,
    const AtomicString& type,
    const std::shared_ptr<HybridRouterChangeEventInit>& initializer,
    ExceptionState& exception_state) {
  return MakeGarbageCollected<HybridRouterChangeEvent>(context, type, initializer, exception_state);
}

HybridRouterChangeEvent::HybridRouterChangeEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 ExceptionState& exception_state)
    : Event(context, type) {}

HybridRouterChangeEvent::HybridRouterChangeEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 const std::shared_ptr<HybridRouterChangeEventInit>& initializer,
                                                 ExceptionState& exception_state)
    : Event(context, type),
      state_(initializer->hasState() ? initializer->state() : ScriptValue::Empty(ctx())),
      kind_(initializer->hasKind() ? initializer->kind() : AtomicString::Empty()),
      name_(initializer->hasName() ? initializer->name() : AtomicString::Empty()) {}

HybridRouterChangeEvent::HybridRouterChangeEvent(ExecutingContext* context,
                                                 const AtomicString& type,
                                                 NativeHybridRouterChangeEvent* native_event)
    : Event(context, type, &native_event->native_event),
#if ANDROID_32_BIT
      state_(ScriptValue::CreateJsonObject(context->ctx(),
                                           reinterpret_cast<const char*>(native_event->state),
                                           strlen(reinterpret_cast<const char*>(native_event->state)))),
      kind_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_event->kind)))),
      name_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_event->name))))
#else
      state_(ScriptValue::CreateJsonObject(context->ctx(),
                                           static_cast<const char*>(native_event->state),
                                           strlen(static_cast<const char*>(native_event->state)))),
      kind_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_event->kind)))),
      name_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_event->name))))
#endif
{
}

ScriptValue HybridRouterChangeEvent::state() const {
  return state_;
}

AtomicString HybridRouterChangeEvent::kind() const {
  return kind_;
}

AtomicString HybridRouterChangeEvent::name() const {
  return name_;
}

bool HybridRouterChangeEvent::IsHybridRouterChangeEvent() const {
  return true;
}

void HybridRouterChangeEvent::Trace(GCVisitor* visitor) const {
  state_.Trace(visitor);
  Event::Trace(visitor);
}

}  // namespace webf