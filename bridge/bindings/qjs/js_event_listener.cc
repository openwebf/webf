/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "js_event_listener.h"
#include "core/dom/events/event.h"

#include <utility>
#include "core/dom/events/event_target.h"

namespace webf {

JSEventListener::JSEventListener(std::shared_ptr<QJSFunction> listener) : event_listener_(std::move(listener)) {}
JSValue JSEventListener::GetListenerObject() {
  return event_listener_->ToQuickJS();
}
void JSEventListener::InvokeInternal(EventTarget& event_target, Event& event, ExceptionState& exception_state) {
  ScriptValue arguments[] = {event.ToValue()};

  ScriptValue result = event_listener_->Invoke(event.ctx(), event_target.ToValue(), 1, arguments);
  if (result.IsException()) {
    exception_state.ThrowException(event.ctx(), result.QJSValue());
    return;
  }
}

void JSEventListener::Trace(GCVisitor* visitor) const {
  event_listener_->Trace(visitor);
}

}  // namespace webf
