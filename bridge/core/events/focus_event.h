/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_EVENTS_FOCUS_EVENT_H_
#define BRIDGE_CORE_EVENTS_FOCUS_EVENT_H_

#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "core/dom/events/event.h"
#include "plugin_api_gen/focus_event.h"
#include "qjs_focus_event_init.h"
#include "ui_event.h"

namespace webf {

struct NativeFocusEvent;

class FocusEvent : public UIEvent {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = FocusEvent*;

  static FocusEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  static FocusEvent* Create(ExecutingContext* context,
                            const AtomicString& type,
                            double detail,
                            Window* view,
                            double which,
                            EventTarget* relatedTarget,
                            ExceptionState& exception_state);
  static FocusEvent* Create(ExecutingContext* context,
                            const AtomicString& type,
                            const std::shared_ptr<FocusEventInit>& initializer,
                            ExceptionState& exception_state);

  explicit FocusEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit FocusEvent(ExecutingContext* context,
                      const AtomicString& type,
                      double detail,
                      Window* view,
                      double which,
                      EventTarget* relatedTarget,
                      ExceptionState& exception_state);

  explicit FocusEvent(ExecutingContext* context,
                      const AtomicString& type,
                      const std::shared_ptr<FocusEventInit>& initializer,
                      ExceptionState& exception_state);

  explicit FocusEvent(ExecutingContext* context, const AtomicString& type, NativeFocusEvent* native_focus_event);

  EventTarget* relatedTarget() const;

  bool IsFocusEvent() const override;

  const FocusEventPublicMethods* focusEventPublicMethods();

 private:
  Member<EventTarget> related_target_;
};

template <>
struct DowncastTraits<FocusEvent> {
  static bool AllowFrom(const Event& event) { return event.IsFocusEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_EVENTS_FOCUS_EVENT_H_
