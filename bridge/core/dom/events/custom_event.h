/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CUSTOM_EVENT_H
#define BRIDGE_CUSTOM_EVENT_H

#include "event.h"
#include "qjs_custom_event_init.h"

namespace webf {

struct NativeCustomEvent {
  NativeEvent native_event;
  const char* detail{nullptr};
};

class CustomEvent final : public Event {
  DEFINE_WRAPPERTYPEINFO();
 public:
  using ImplType = CustomEvent*;

  static CustomEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  static CustomEvent* Create(ExecutingContext* context, const AtomicString& type, NativeCustomEvent* native_custom_event);
  static CustomEvent* Create(ExecutingContext* context, const AtomicString& type, const std::shared_ptr<CustomEventInit>& initialize, ExceptionState& exception_state);

  CustomEvent() = delete;
  explicit CustomEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  explicit CustomEvent(ExecutingContext* context, const AtomicString& type, NativeCustomEvent* native_custom_event);
  explicit CustomEvent(ExecutingContext* context, const AtomicString& type, const std::shared_ptr<CustomEventInit>& initialize, ExceptionState& exception_state);

  ScriptValue detail() const;

  bool IsCustomEvent() const override;

 private:
  ScriptValue detail_;
};

template <>
struct DowncastTraits<CustomEvent> {
  static bool AllowFrom(const Event& event) { return event.IsCustomEvent(); }
};


}  // namespace webf

#endif  // BRIDGE_CUSTOM_EVENT_H
