/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "custom_event.h"
#include "native_value_converter.h"

namespace webf {

CustomEvent *CustomEvent::Create(ExecutingContext *context, const AtomicString &type, ExceptionState &exception_state) {
  return MakeGarbageCollected<CustomEvent>(context, type, exception_state);
}

CustomEvent *CustomEvent::Create(ExecutingContext *context,
                                 const AtomicString &type,
                                 NativeCustomEvent *native_custom_event) {
  return MakeGarbageCollected<CustomEvent>(context, type, native_custom_event);
}

CustomEvent *CustomEvent::Create(ExecutingContext *context,
                                 const AtomicString &type,
                                 const std::shared_ptr<CustomEventInit> &initialize,
                                 ExceptionState &exception_state) {
  return MakeGarbageCollected<CustomEvent>(context, type, initialize, exception_state);
}

CustomEvent::CustomEvent(ExecutingContext *context, const AtomicString &type, ExceptionState &exception_state): Event(context, type) {
}

CustomEvent::CustomEvent(ExecutingContext *context, const AtomicString &type, NativeCustomEvent *native_custom_event) :
    Event(context, type, &native_custom_event->native_event),
    detail_(ScriptValue::CreateJsonObject(ctx(), native_custom_event->detail, strlen(native_custom_event->detail))) {
}

CustomEvent::CustomEvent(ExecutingContext *context,
                         const AtomicString &type,
                         const std::shared_ptr<CustomEventInit> &initialize,
                         ExceptionState &exception_state):
                         Event(context, type),
                         detail_(initialize->detail()) {

}

ScriptValue CustomEvent::detail() const {
  return detail_;
}

bool CustomEvent::IsCustomEvent() const {
  return true;
}

}  // namespace webf
