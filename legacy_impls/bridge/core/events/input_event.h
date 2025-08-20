/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_INPUT_EVENT_H
#define BRIDGE_INPUT_EVENT_H

#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "plugin_api_gen/input_event.h"
#include "qjs_input_event_init.h"
#include "ui_event.h"

namespace webf {

struct NativeInputEvent;

class InputEvent : public UIEvent {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = InputEvent*;

  static InputEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  static InputEvent* Create(ExecutingContext* context,
                            const AtomicString& type,
                            const std::shared_ptr<InputEventInit>& initializer,
                            ExceptionState& exception_state);

  explicit InputEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit InputEvent(ExecutingContext* context,
                      const AtomicString& type,
                      const std::shared_ptr<InputEventInit>& initializer,
                      ExceptionState& exception_state);

  explicit InputEvent(ExecutingContext* context, const AtomicString& type, NativeInputEvent* native_input_event);

  const AtomicString& inputType() const;
  const AtomicString& data() const;

  bool IsInputEvent() const override;

  const InputEventPublicMethods* inputEventPublicMethods();

 private:
  AtomicString input_type_;
  AtomicString data_;
};

template <>
struct DowncastTraits<InputEvent> {
  static bool AllowFrom(const Event& event) { return event.IsInputEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_INPUT_EVENT_H
