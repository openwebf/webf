/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_WINDOW_H_
#define WEBF_CORE_RUST_API_WINDOW_H_

#include "event_target.h"

namespace webf {

class EventTarget;
class SharedExceptionState;
class ExecutingContext;
class Event;

struct WindowPublicMethods : WebFPublicMethods {
  double version{1.0};
  EventTargetPublicMethods event_target;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_WINDOW_H_
