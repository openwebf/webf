/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_WEBF_API_EVENT_TARGET_H_
#define WEBF_CORE_WEBF_API_EVENT_TARGET_H_

#include "webf_value.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;
typedef struct EventWebFMethods EventWebFMethods;
typedef struct WebFEventListenerContext WebFEventListenerContext;

struct WebFAddEventListenerOptions {
  bool passive;
  bool once;
  bool capture;
};

using WebFImplEventCallback = void (*)(WebFEventListenerContext* callback_context,
                                       Event* event,
                                       EventWebFMethods* event_methods,
                                       SharedExceptionState* shared_exception_state);
using FreePtrFn = void(*)(WebFEventListenerContext* callback_context);

struct WebFEventListenerContext {
  WebFImplEventCallback callback;
  FreePtrFn free_ptr;
  void* ptr;
};

using WebFEventTargetAddEventListener = void (*)(EventTarget* event_target,
                                                 const char*,
                                                 WebFEventListenerContext* callback_context,
                                                 WebFAddEventListenerOptions* options,
                                                 SharedExceptionState* shared_exception_state);
using WebFEventTargetRemoveEventListener = void (*)(EventTarget* event_target,
                                                    const char*,
                                                    WebFEventListenerContext* callback_context,
                                                    SharedExceptionState* shared_exception_state);
using WebFEventTargetDispatchEvent = bool (*)(EventTarget* event_target,
                                              Event* event,
                                              SharedExceptionState* shared_exception_state);

using WebFEventTargetRelease = void (*)(EventTarget*);

struct EventTargetWebFMethods : public WebFPublicMethods {
  static void AddEventListener(EventTarget* event_target,
                               const char* event_name_str,
                               WebFEventListenerContext* callback_context,
                               WebFAddEventListenerOptions* options,
                               SharedExceptionState* shared_exception_state);
  static void RemoveEventListener(EventTarget* event_target,
                                  const char* event_name_str,
                                  WebFEventListenerContext* callback_context,
                                  SharedExceptionState* shared_exception_state);
  static bool DispatchEvent(EventTarget* event_target, Event* event, SharedExceptionState* shared_exception_state);
  static void Release(EventTarget* event_target);

  double version{1.0};
  WebFEventTargetAddEventListener event_target_add_event_listener{AddEventListener};
  WebFEventTargetRemoveEventListener event_target_remove_event_listener{RemoveEventListener};
  WebFEventTargetDispatchEvent event_target_dispatch_event{DispatchEvent};
  WebFEventTargetRelease event_target_release{Release};
};

}  // namespace webf

#endif  // WEBF_CORE_WEBF_API_EVENT_TARGET_H_
