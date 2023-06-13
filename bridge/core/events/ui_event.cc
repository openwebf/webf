/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "ui_event.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/frame/window.h"
#include "qjs_ui_event.h"

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

UIEvent::UIEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}

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
    : Event(context, type),
      detail_(initializer->hasDetail() ? initializer->detail() : 0.0),
      view_(initializer->hasView() ? initializer->view() : nullptr),
      which_(initializer->hasWhich() ? initializer->which() : 0.0) {}

UIEvent::UIEvent(ExecutingContext* context, const AtomicString& type, NativeUIEvent* native_ui_event)
    : Event(context, type, &native_ui_event->native_event),
      detail_(native_ui_event->detail),
#if ANDROID_32_BIT
      view_(DynamicTo<Window>(BindingObject::From(reinterpret_cast<NativeBindingObject*>(native_ui_event->view)))),
#else
      view_(DynamicTo<Window>(BindingObject::From(static_cast<NativeBindingObject*>(native_ui_event->view)))),
#endif
      which_(native_ui_event->which) {
}

double UIEvent::detail() const {
  return detail_;
}

Window* UIEvent::view() const {
  return view_;
}

double UIEvent::which() const {
  return which_;
}

bool UIEvent::IsUiEvent() const {
  return true;
}

void UIEvent::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(view_);
  Event::Trace(visitor);
}

}  // namespace webf
