/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_EVENT_TARGET_H_
#define WEBF_CORE_RUST_API_EVENT_TARGET_H_

#include "core/rust_api/rust_value.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct RustAddEventListenerOptions {
  bool passive;
  bool once;
  bool capture;
};

using RustImplEventCallback = void (*)(Event* event, SharedExceptionState* shared_exception_state);

struct RustEventListener {
  RustImplEventCallback callback;
};

using RustEventTargetAddEventListener = void (*)(EventTarget* event_target,
                                                 const char*,
                                                 RustEventListener* callback,
                                                 RustAddEventListenerOptions& options,
                                                 SharedExceptionState* shared_exception_state);

using RustEventTargetRelease = void (*)(EventTarget*);

struct EventTargetRustMethods : public RustMethods {
  static void AddEventListener(EventTarget* event_target,
                               const char* event_name_str,
                               RustEventListener* event_listener,
                               RustAddEventListenerOptions& options,
                               SharedExceptionState* shared_exception_state);
  static void Release(EventTarget* event_target);

  double version{1.0};
  RustEventTargetAddEventListener rust_event_target_add_event_listener{AddEventListener};
  RustEventTargetRelease event_target_release{Release};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_EVENT_TARGET_H_
