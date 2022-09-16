/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_EVENTS_POPSTATE_EVENT_H_
#define WEBF_CORE_EVENTS_POPSTATE_EVENT_H_

#include "core/dom/events/event.h"
#include "qjs_popstate_event_init.h"

namespace webf {

struct NativePopstateEvent;

class PopstateEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = PopstateEvent*;

  static PopstateEvent* Create(ExecutingContext* context, ExceptionState& exception_state);

  static PopstateEvent* Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<PopstateEventInit>& initializer,
                               ExceptionState& exception_state);

  explicit PopstateEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit PopstateEvent(ExecutingContext* context,
                         const AtomicString& type,
                         const std::shared_ptr<PopstateEventInit>& initializer,
                         ExceptionState& exception_state);

  explicit PopstateEvent(ExecutingContext* context, const AtomicString& type, NativePopstateEvent* native_ui_event);

  ScriptValue state() const;

  bool IsPopstateEvent() const override;

  void Trace(GCVisitor* visitor) const override;

 private:
  ScriptValue state_;
};

template <>
struct DowncastTraits<PopstateEvent> {
  static bool AllowFrom(const Event& event) { return event.IsPopstateEvent(); }
};

}  // namespace webf

#endif  // WEBF_CORE_EVENTS_POPSTATE_EVENT_H_
