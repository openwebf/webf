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
  NativeValue* detail{nullptr};
};

class CustomEvent final : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CustomEvent*;

  static CustomEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  static CustomEvent* Create(ExecutingContext* context,
                             const AtomicString& type,
                             NativeCustomEvent* native_custom_event);
  static CustomEvent* Create(ExecutingContext* context,
                             const AtomicString& type,
                             const std::shared_ptr<CustomEventInit>& initialize,
                             ExceptionState& exception_state);

  CustomEvent() = delete;
  explicit CustomEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  explicit CustomEvent(ExecutingContext* context, const AtomicString& type, NativeCustomEvent* native_custom_event);
  explicit CustomEvent(ExecutingContext* context,
                       const AtomicString& type,
                       const std::shared_ptr<CustomEventInit>& initialize,
                       ExceptionState& exception_state);

  ScriptValue detail() const;

  void initCustomEvent(const AtomicString& type, ExceptionState& exception_state);
  void initCustomEvent(const AtomicString& type, bool can_bubble, ExceptionState& exception_state);
  void initCustomEvent(const AtomicString& type, bool can_bubble, bool cancelable, ExceptionState& exception_state);
  void initCustomEvent(const AtomicString& type,
                       bool can_bubble,
                       bool cancelable,
                       const ScriptValue& detail,
                       ExceptionState& exception_state);
  void initCustomEvent(const AtomicString& type,
                       bool can_bubble,
                       bool cancelable,
                       const ScriptValueRef* script_value_ref,
                       ExceptionState& exception_state);

  bool IsCustomEvent() const override;

  void Trace(GCVisitor* visitor) const override;

 private:
  ScriptValue detail_;
};

template <>
struct DowncastTraits<CustomEvent> {
  static bool AllowFrom(const Event& event) { return event.IsCustomEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_CUSTOM_EVENT_H
