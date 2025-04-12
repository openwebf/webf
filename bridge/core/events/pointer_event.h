/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_EVENTS_POINTER_EVENT_H_
#define WEBF_CORE_EVENTS_POINTER_EVENT_H_

#include "mouse_event.h"
#include "plugin_api_gen/pointer_event.h"
#include "qjs_pointer_event_init.h"

namespace webf {

struct NativePointerEvent;

class PointerEvent : public MouseEvent {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = UIEvent*;

  static PointerEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  static PointerEvent* Create(ExecutingContext* context,
                              const AtomicString& type,
                              const std::shared_ptr<PointerEventInit>& initializer,
                              ExceptionState& exception_state);

  explicit PointerEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit PointerEvent(ExecutingContext* context,
                        const AtomicString& type,
                        const std::shared_ptr<PointerEventInit>& initializer,
                        ExceptionState& exception_state);

  explicit PointerEvent(ExecutingContext* context, const AtomicString& type, NativePointerEvent* native_pointer_event);

  double height() const;
  bool isPrimary() const;
  double pointerId() const;
  AtomicString pointerType() const;
  double pressure() const;
  double tangentialPressure() const;
  double tiltX() const;
  double tiltY() const;
  double twist() const;
  double width() const;

  bool IsPointerEvent() const override;

  const PointerEventPublicMethods* pointerEventPublicMethods();

 private:
  double height_;
  bool is_primary;
  double pointer_id_;
  AtomicString pointer_type_;
  double pressure_;
  double tangential_pressure_;
  double tilt_x_;
  double tilt_y_;
  double twist_;
  double width_;
};

template <>
struct DowncastTraits<PointerEvent> {
  static bool AllowFrom(const Event& event) { return event.IsPointerEvent(); }
};

}  // namespace webf

#endif  // WEBF_CORE_EVENTS_TOUCH_EVENT_H_
