/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_INTERSECTION_CHANGE_EVENT_H
#define BRIDGE_INTERSECTION_CHANGE_EVENT_H

#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "core/dom/events/event.h"
#include "qjs_intersection_change_event_init.h"

namespace webf {

class IntersectionChangeEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();
 public:
  using ImplType = IntersectionChangeEvent*;

  static IntersectionChangeEvent* Create(ExecutingContext* context,
                                         const AtomicString& type,
                                         ExceptionState& exception_state);

  static IntersectionChangeEvent* Create(ExecutingContext* context,
                            const AtomicString& type,
                            const std::shared_ptr<IntersectionChangeEventInit>& initializer,
                            ExceptionState& exception_state);

  explicit IntersectionChangeEvent(ExecutingContext* context,
                      const AtomicString& type,
                      const std::shared_ptr<IntersectionChangeEventInit>& initializer,
                      ExceptionState& exception_state);

  explicit IntersectionChangeEvent(ExecutingContext* context,
                                   const AtomicString& type,
                                   ExceptionState& exception_state);

  double intersectionRatio() const;

 private:
  double intersection_ratio_;
};

}

#endif  // BRIDGE_INTERSECTION_CHANGE_EVENT_H
