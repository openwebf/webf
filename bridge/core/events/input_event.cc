/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "input_event.h"
#include "qjs_input_event.h"

namespace webf {

InputEvent* InputEvent::Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
  return MakeGarbageCollected<InputEvent>(context, type, exception_state);
}

InputEvent* InputEvent::Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<InputEventInit>& initializer,
                               ExceptionState& exception_state) {
  return MakeGarbageCollected<InputEvent>(context, type, initializer, exception_state);
}

InputEvent::InputEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : UIEvent(context, type, exception_state) {}

InputEvent::InputEvent(ExecutingContext* context,
                       const AtomicString& type,
                       const std::shared_ptr<InputEventInit>& initializer,
                       ExceptionState& exception_state)
    : UIEvent(context, type, initializer, exception_state),
      input_type_(initializer->inputType()),
      data_(initializer->data()) {}

InputEvent::InputEvent(ExecutingContext* context, const AtomicString& type, NativeInputEvent* native_input_event)
    : UIEvent(context, type, &native_input_event->native_event),
      input_type_(AtomicString(ctx(), native_input_event->inputType)),
      data_(AtomicString(ctx(), native_input_event->data)) {}

const AtomicString& InputEvent::inputType() const {
  return input_type_;
}

const AtomicString& InputEvent::data() const {
  return data_;
}

bool InputEvent::IsInputEvent() const {
  return true;
}

}  // namespace webf