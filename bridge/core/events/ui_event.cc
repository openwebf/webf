/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "ui_event.h"
#include "core/frame/window.h"

namespace webf {


UIEvent* UIEvent::Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
  return MakeGarbageCollected<UIEvent>(context, type, exception_state);
}


UIEvent* UIEvent::Create(ExecutingContext* context,
                         const AtomicString& type,
                         double detail,
                         Window* view,
                         double which,
                         ExceptionState& exception_state) {
  return MakeGarbageCollected<UIEvent>(context, type, detail, view, which, exception_state);
}

UIEvent* UIEvent::Create(ExecutingContext* context,
                         const AtomicString& type,
                         const std::shared_ptr<UIEventInit>& initializer,
                         ExceptionState& exception_state) {
  return MakeGarbageCollected<UIEvent>(context, type, initializer->detail(), initializer->view(), initializer->which(),
                                       exception_state);
}

UIEvent::UIEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state): Event(context, type) {}

UIEvent::UIEvent(ExecutingContext* context,
                 const AtomicString& type,
                 double detail,
                 Window* view,
                 double which,
                 ExceptionState& exception_state)
    : Event(context, type), detail_(detail), view_(view), which_(which) {}

UIEvent::UIEvent(ExecutingContext* context,
                 const AtomicString& type,
                 const std::shared_ptr<UIEventInit>& initializer,
                 ExceptionState& exception_state)
    : Event(context, type), detail_(initializer->detail()), view_(initializer->view()), which_(initializer->which()) {}

double UIEvent::detail() const {
  return detail_;
}

Window* UIEvent::view() const {
  return view_;
}

double UIEvent::which() const {
  return which_;
}

bool UIEvent::IsUIEvent() const {
  return true;
}
}  // namespace webf
