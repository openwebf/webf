/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "mouse_event.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "qjs_mouse_event.h"

namespace webf {

MouseEvent* MouseEvent::Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
  return MakeGarbageCollected<MouseEvent>(context, type, exception_state);
}

MouseEvent* MouseEvent::Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<MouseEventInit>& initializer,
                               ExceptionState& exception_state) {
  return MakeGarbageCollected<MouseEvent>(context, type, initializer, exception_state);
}

MouseEvent::MouseEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : UIEvent(context, type, exception_state) {}

MouseEvent::MouseEvent(ExecutingContext* context,
                       const AtomicString& type,
                       const std::shared_ptr<MouseEventInit>& initializer,
                       ExceptionState& exception_state)
    : UIEvent(context, type, initializer, exception_state)
//    alt_key_(initializer->altKey()),
//    button_(initializer->button()),
//    buttons_(initializer->buttons()),
//    client_x_(initializer->clientX()),
//    client_y_(initializer->clientY()),
//    ctrl_key_(initializer->ctrlKey()),
//    meta_key_(initializer->metaKey()),
//    screen_x_(initializer->screenX()),
//    screen_y_(initializer->screenY()),
//    shift_key_(initializer->shiftKey()),
//    related_target_(initializer->relatedTarget()) {}
{}

MouseEvent::MouseEvent(ExecutingContext* context, const AtomicString& type, NativeMouseEvent* native_mouse_event)
    : UIEvent(context, type, &native_mouse_event->native_event),
      //    alt_key_(native_mouse_event->altKey),
      //    button_(native_mouse_event->button),
      //    buttons_(native_mouse_event->buttons),
      client_x_(native_mouse_event->clientX),
      client_y_(native_mouse_event->clientY),
      //    ctrl_key_(native_mouse_event->ctrlKey),
      //    meta_key_(native_mouse_event->metaKey),
      //    movement_x_(native_mouse_event->movementX),
      //    movement_y_(native_mouse_event->movementY),
      offset_x_(native_mouse_event->offsetX),
      offset_y_(native_mouse_event->offsetY)
//    page_x_(native_mouse_event->pageX),
//    page_y_(native_mouse_event->pageY),
//    screen_x_(native_mouse_event->screenX),
//    screen_y_(native_mouse_event->screenY),
//    shift_key_(native_mouse_event->shiftKey),
//    x_(native_mouse_event->x),
//    y_(native_mouse_event->y)
{}

bool MouseEvent::altKey() const {
  return alt_key_;
};
double MouseEvent::button() const {
  return button_;
};
double MouseEvent::buttons() const {
  return buttons_;
};
double MouseEvent::clientX() const {
  return client_x_;
};
double MouseEvent::clientY() const {
  return client_y_;
};
bool MouseEvent::ctrlKey() const {
  return ctrl_key_;
};
bool MouseEvent::metaKey() const {
  return meta_key_;
};
double MouseEvent::movementX() const {
  return movement_x_;
};
double MouseEvent::movementY() const {
  return movement_y_;
};
double MouseEvent::offsetX() const {
  return offset_x_;
};
double MouseEvent::offsetY() const {
  return offset_y_;
};
double MouseEvent::pageX() const {
  return page_x_;
};
double MouseEvent::pageY() const {
  return page_y_;
};
double MouseEvent::screenX() const {
  return screen_x_;
};
double MouseEvent::screenY() const {
  return screen_y_;
};
bool MouseEvent::shiftKey() const {
  return shift_key_;
};
double MouseEvent::x() const {
  return x_;
};
double MouseEvent::y() const {
  return y_;
};

EventTarget* MouseEvent::relatedTarget() const {
  return related_target_;
}

bool MouseEvent::IsMouseEvent() const {
  return true;
}

void MouseEvent::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(related_target_);
  UIEvent::Trace(visitor);
}

}  // namespace webf