/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_EVENTS_POP_STATE_EVENT_H_
#define WEBF_CORE_EVENTS_POP_STATE_EVENT_H_

#include "plugin_api/pop_state_event.h"
#include "core/dom/events/event.h"
#include "qjs_pop_state_event_init.h"

namespace webf {

struct NativePopStateEvent;

class PopStateEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = PopStateEvent*;

  static PopStateEvent* Create(ExecutingContext* context, ExceptionState& exception_state);

  static PopStateEvent* Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<PopStateEventInit>& initializer,
                               ExceptionState& exception_state);

  explicit PopStateEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit PopStateEvent(ExecutingContext* context,
                         const AtomicString& type,
                         const std::shared_ptr<PopStateEventInit>& initializer,
                         ExceptionState& exception_state);

  explicit PopStateEvent(ExecutingContext* context, const AtomicString& type, NativePopStateEvent* native_ui_event);

  ScriptValue state() const;

  bool IsPopstateEvent() const override;

  const PopStateEventPublicMethods* popStateEventPublicMethods();

  void Trace(GCVisitor* visitor) const override;

 private:
  ScriptValue state_;
};

template <>
struct DowncastTraits<PopStateEvent> {
  static bool AllowFrom(const Event& event) { return event.IsPopstateEvent(); }
};

}  // namespace webf

#endif  // WEBF_CORE_EVENTS_POP_STATE_EVENT_H_
