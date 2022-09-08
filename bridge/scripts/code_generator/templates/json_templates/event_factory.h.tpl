/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_CORE_EVENT_FACTORY_H_
#define BRIDGE_CORE_EVENT_FACTORY_H_

#include "bindings/qjs/atomic_string.h"
#include "core/dom/events/event.h"

namespace webf {

class EventFactory {
 public:
  // If |local_name| is unknown, nullptr is returned.
  static Event* Create(ExecutingContext* context, const AtomicString& type, RawEvent* raw_event);
  static void Dispose();
};

}  // namespace webf

#endif  // BRIDGE_CORE_EVENT_FACTORY_H_
