/*
* Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
*/

#ifndef WEBF_CORE_EVENTS_SCREEN_H_
#define WEBF_CORE_EVENTS_SCREEN_H_

#include "core/dom/events/event.h"
#include "qjs_screen_event_init.h"

namespace webf {

struct NativeScreenEvent;

class ScreenEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = ScreenEvent*;

  static ScreenEvent* Create(ExecutingContext* context, ExceptionState& exception_state);

  static ScreenEvent* Create(ExecutingContext* context,
                                         const AtomicString& type,
                                         const std::shared_ptr<ScreenEventInit>& initializer,
                                         ExceptionState& exception_state);

  explicit ScreenEvent(ExecutingContext* context,
                                   const AtomicString& type,
                                   ExceptionState& exception_state);

  explicit ScreenEvent(ExecutingContext* context,
                                   const AtomicString& type,
                                   const std::shared_ptr<ScreenEventInit>& initializer,
                                   ExceptionState& exception_state);

  explicit ScreenEvent(ExecutingContext* context,
                                   const AtomicString& type,
                       NativeScreenEvent* native_ui_event);

  ScriptValue state() const;
  AtomicString path() const;

  bool IsScreenEvent() const override;

  void Trace(GCVisitor* visitor) const override;

 private:
  ScriptValue state_;
  AtomicString path_;
};

template <>
struct DowncastTraits<ScreenEvent> {
  static bool AllowFrom(const Event& event) { return event.IsScreenEvent(); }
};

}  // namespace webf



#endif  // WEBF_CORE_EVENTS_SCREEN_H_
