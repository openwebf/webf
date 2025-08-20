/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_EVENTS_PROMISE_REJECTION_EVENT_H_
#define BRIDGE_CORE_EVENTS_PROMISE_REJECTION_EVENT_H_

#include "core/dom/events/event.h"
#include "plugin_api_gen/promise_rejection_event.h"
#include "qjs_promise_rejection_event_init.h"

namespace webf {

class PromiseRejectionEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = ErrorEvent*;
  static PromiseRejectionEvent* Create(ExecutingContext* context,
                                       const AtomicString& type,
                                       ExceptionState& exception_state);
  static PromiseRejectionEvent* Create(ExecutingContext* context,
                                       const AtomicString& type,
                                       const std::shared_ptr<PromiseRejectionEventInit>& initializer,
                                       ExceptionState& exception_state);

  explicit PromiseRejectionEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit PromiseRejectionEvent(ExecutingContext* context,
                                 const AtomicString& type,
                                 const std::shared_ptr<PromiseRejectionEventInit>& initializer,
                                 ExceptionState& exception_state);

  ScriptValue promise() { return promise_; }
  ScriptValue reason() { return reason_; }

  bool IsPromiseRejectionEvent() const override;

  const PromiseRejectionEventPublicMethods* promiseRejectionEventPublicMethods();

 private:
  ScriptValue promise_;
  ScriptValue reason_;
};

template <>
struct DowncastTraits<PromiseRejectionEvent> {
  static bool AllowFrom(const Event& event) { return event.IsPromiseRejectionEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_EVENTS_PROMISE_REJECTION_EVENT_H_
