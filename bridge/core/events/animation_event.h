/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_EVENTS_ANIMATION_EVENT_H_
#define BRIDGE_CORE_EVENTS_ANIMATION_EVENT_H_

#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "core/dom/events/event.h"
#include "qjs_animation_event_init.h"
#include "plugin_api/animation_event.h"

namespace webf {

class AnimationEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = AnimationEvent*;
  static AnimationEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  static AnimationEvent* Create(ExecutingContext* context,
                                const AtomicString& type,
                                const AtomicString& animation_name,
                                const AtomicString& pseudo_element,
                                double elapsed_time,
                                ExceptionState& exception_state);
  static AnimationEvent* Create(ExecutingContext* context,
                                const AtomicString& type,
                                const std::shared_ptr<AnimationEventInit>& initializer,
                                ExceptionState& exception_state);

  explicit AnimationEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit AnimationEvent(ExecutingContext* context,
                          const AtomicString& type,
                          const AtomicString& animation_name,
                          const AtomicString& pseudo_element,
                          double elapsed_time,
                          ExceptionState& exception_state);
  explicit AnimationEvent(ExecutingContext* context,
                          const AtomicString& type,
                          const std::shared_ptr<AnimationEventInit>& initializer,
                          ExceptionState& exception_state);

  const AtomicString& animationName() const;
  double elapsedTime() const;
  const AtomicString& pseudoElement() const;

  bool IsAnimationEvent() const override;

  const AnimationEventPublicMethods* animationEventPublicMethods();

 private:
  AtomicString animation_name_;
  AtomicString pseudo_element_;
  double elapsed_time_;
};

template <>
struct DowncastTraits<AnimationEvent> {
  static bool AllowFrom(const Event& event) { return event.IsAnimationEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_EVENTS_ANIMATION_EVENT_H_
