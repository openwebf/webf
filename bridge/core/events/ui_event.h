/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_EVENTS_UI_EVENT_H_
#define BRIDGE_CORE_EVENTS_UI_EVENT_H_

#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "core/dom/events/event.h"
#include "core/frame/window.h"
#include "plugin_api/ui_event.h"
#include "qjs_ui_event_init.h"

namespace webf {

struct NativeUIEvent;

class UIEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = UIEvent*;

  static UIEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  static UIEvent* Create(ExecutingContext* context,
                         const AtomicString& type,
                         double detail,
                         Window* view,
                         double which,
                         ExceptionState& exception_state);
  static UIEvent* Create(ExecutingContext* context,
                         const AtomicString& type,
                         const std::shared_ptr<UIEventInit>& initializer,
                         ExceptionState& exception_state);

  explicit UIEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit UIEvent(ExecutingContext* context,
                   const AtomicString& type,
                   double detail,
                   Window* view,
                   double which,
                   ExceptionState& exception_state);

  explicit UIEvent(ExecutingContext* context,
                   const AtomicString& type,
                   const std::shared_ptr<UIEventInit>& initializer,
                   ExceptionState& exception_state);

  explicit UIEvent(ExecutingContext* context, const AtomicString& type, NativeUIEvent* native_ui_event);

  double detail() const;
  Window* view() const;
  double which() const;

  bool IsUiEvent() const override;

  const UIEventPublicMethods* uiEventPublicMethods();

  void Trace(GCVisitor* visitor) const override;

 private:
  double detail_;
  Member<Window> view_;
  double which_;
};

template <>
struct DowncastTraits<UIEvent> {
  static bool AllowFrom(const Event& event) { return event.IsUiEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_EVENTS_UI_EVENT_H_
