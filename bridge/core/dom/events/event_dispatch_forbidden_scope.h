/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_CORE_DOM_EVENTS_EVENT_DISPATCH_FORBIDDEN_SCOPE_H_
#define WEBF_CORE_DOM_EVENTS_EVENT_DISPATCH_FORBIDDEN_SCOPE_H_

#include <cassert>
#include "foundation/macros.h"

namespace webf {

class EventDispatchForbiddenScope {
  WEBF_STACK_ALLOCATED();

 public:
  EventDispatchForbiddenScope() {
    ++count_;
  }
  EventDispatchForbiddenScope(const EventDispatchForbiddenScope&) = delete;
  EventDispatchForbiddenScope& operator=(const EventDispatchForbiddenScope&) =
      delete;

  ~EventDispatchForbiddenScope() {
    assert(count_);
    --count_;
  }

  static bool IsEventDispatchForbidden() {
    return count_;
  }

 private:
  static unsigned count_;
};


}

#endif  // WEBF_CORE_DOM_EVENTS_EVENT_DISPATCH_FORBIDDEN_SCOPE_H_
