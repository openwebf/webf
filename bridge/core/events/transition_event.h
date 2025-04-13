/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_EVENTS_TRANSITION_EVENT_H_
#define WEBF_CORE_EVENTS_TRANSITION_EVENT_H_

#include "core/dom/events/event.h"
#include "plugin_api_gen/transition_event.h"
#include "qjs_transition_event_init.h"

namespace webf {

struct NativeTransitionEvent;

class TransitionEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = TransitionEvent*;

  static TransitionEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  static TransitionEvent* Create(ExecutingContext* context,
                                 const AtomicString& type,
                                 const std::shared_ptr<TransitionEventInit>& initializer,
                                 ExceptionState& exception_state);

  explicit TransitionEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit TransitionEvent(ExecutingContext* context,
                           const AtomicString& type,
                           const std::shared_ptr<TransitionEventInit>& initializer,
                           ExceptionState& exception_state);

  explicit TransitionEvent(ExecutingContext* context,
                           const AtomicString& type,
                           NativeTransitionEvent* native_transition_event);

  double elapsedTime() const;
  AtomicString propertyName() const;
  AtomicString pseudoElement() const;

  bool IsTransitionEvent() const override;

  const TransitionEventPublicMethods* transitionEventPublicMethods();

 private:
  double elapsed_time_;
  AtomicString property_name_;
  AtomicString pseudo_element_;
};

template <>
struct DowncastTraits<TransitionEvent> {
  static bool AllowFrom(const Event& event) { return event.IsTransitionEvent(); }
};

}  // namespace webf

#endif  // WEBF_CORE_EVENTS_TRANSITION_EVENT_H_
