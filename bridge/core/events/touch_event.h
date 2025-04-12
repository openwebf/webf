/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_EVENTS_TOUCH_EVENT_H_
#define WEBF_CORE_EVENTS_TOUCH_EVENT_H_

#include "core/input/touch_list.h"
#include "plugin_api_gen/touch_event.h"
#include "qjs_touch_event_init.h"
#include "ui_event.h"

namespace webf {

struct NativeTouchEvent;

class TouchEvent : public UIEvent {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = TouchEvent*;

  static TouchEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  static TouchEvent* Create(ExecutingContext* context,
                            const AtomicString& type,
                            const std::shared_ptr<TouchEventInit>& initializer,
                            ExceptionState& exception_state);

  explicit TouchEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit TouchEvent(ExecutingContext* context,
                      const AtomicString& type,
                      const std::shared_ptr<TouchEventInit>& initializer,
                      ExceptionState& exception_state);

  explicit TouchEvent(ExecutingContext* context, const AtomicString& type, NativeTouchEvent* native_touch_event);

  bool altKey() const;
  bool ctrlKey() const;
  bool metaKey() const;
  bool shiftKey() const;
  TouchList* changedTouches() const;
  TouchList* targetTouches() const;
  TouchList* touches() const;

  void Trace(GCVisitor* visitor) const override;

  bool IsTouchEvent() const override;

  const TouchEventPublicMethods* touchEventPublicMethods();

 private:
  bool alt_key_;
  bool ctrl_key_;
  bool meta_key_;
  bool shift_key_;
  Member<TouchList> changed_touches_;
  Member<TouchList> target_touches_;
  Member<TouchList> touches_;
};

template <>
struct DowncastTraits<TouchEvent> {
  static bool AllowFrom(const Event& event) { return event.IsTouchEvent(); }
};

}  // namespace webf

#endif  // WEBF_CORE_EVENTS_TOUCH_EVENT_H_
