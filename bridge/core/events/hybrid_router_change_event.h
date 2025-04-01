/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_EVENTS_HYBRID_ROUTER_CHANGE_EVENT_H_
#define WEBF_CORE_EVENTS_HYBRID_ROUTER_CHANGE_EVENT_H_

#include "core/dom/events/event.h"
#include "qjs_hybrid_router_change_event_init.h"

namespace webf {

struct NativeHybridRouterChangeEvent;

class HybridRouterChangeEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HybridRouterChangeEvent*;

  static HybridRouterChangeEvent* Create(ExecutingContext* context, ExceptionState& exception_state);

  static HybridRouterChangeEvent* Create(ExecutingContext* context,
                                         const AtomicString& type,
                                         const std::shared_ptr<HybridRouterChangeEventInit>& initializer,
                                         ExceptionState& exception_state);

  explicit HybridRouterChangeEvent(ExecutingContext* context,
                                   const AtomicString& type,
                                   ExceptionState& exception_state);

  explicit HybridRouterChangeEvent(ExecutingContext* context,
                                   const AtomicString& type,
                                   const std::shared_ptr<HybridRouterChangeEventInit>& initializer,
                                   ExceptionState& exception_state);

  explicit HybridRouterChangeEvent(ExecutingContext* context,
                                   const AtomicString& type,
                                   NativeHybridRouterChangeEvent* native_ui_event);

  ScriptValue state() const;
  AtomicString kind() const;
  AtomicString path() const;

  bool IsHybridRouterChangeEvent() const override;

  void Trace(GCVisitor* visitor) const override;

 private:
  ScriptValue state_;
  AtomicString kind_;
  AtomicString path_;
};

template <>
struct DowncastTraits<HybridRouterChangeEvent> {
  static bool AllowFrom(const Event& event) { return event.IsHybridRouterChangeEvent(); }
};

}  // namespace webf

#endif  // WEBF_CORE_EVENTS_HYBRID_ROUTER_CHANGE_EVENT_H_
