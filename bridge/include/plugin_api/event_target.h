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
typedef struct EventPublicMethods EventWebFMethods;
typedef struct WebFEventListenerContext WebFEventListenerContext;

struct WebFAddEventListenerOptions {
  bool passive;
  bool once;
  bool capture;
};

using WebFImplEventCallback = void (*)(WebFEventListenerContext* callback_context,
                                       Event* event,
                                       const EventPublicMethods* event_methods,
                                       SharedExceptionState* shared_exception_state);
using FreePtrFn = void(*)(WebFEventListenerContext* callback_context);


enum class EventTargetType {
  kEventTarget = 0,
  kNode = 1,
  kContainerNode = 2,
  kWindow = 3,
  kDocument = 4,
  kElement = 5,
  HTMLElement = 6,
  kHTMLImageElement = 7,
  kHTMLCanvasElement = 8,
  kHTMLDivElement = 9,
  kHTMLScriptElement = 10,
  kDocumentFragment = 11,
  kText = 12,
  kComment = 13,
};

struct WebFEventListenerContext {
  WebFImplEventCallback callback;
  FreePtrFn free_ptr;
  void* ptr;
};

using PublicEventTargetAddEventListener = void (*)(EventTarget* event_target,
                                                 const char*,
                                                 WebFEventListenerContext* callback_context,
                                                 WebFAddEventListenerOptions* options,
                                                 SharedExceptionState* shared_exception_state);
using PublicEventTargetRemoveEventListener = void (*)(EventTarget* event_target,
                                                    const char*,
                                                    WebFEventListenerContext* callback_context,
                                                    SharedExceptionState* shared_exception_state);
using PublicEventTargetDispatchEvent = bool (*)(EventTarget* event_target,
                                              Event* event,
                                              SharedExceptionState* shared_exception_state);

using PublicEventTargetRelease = void (*)(EventTarget*);

using PublicEventTargetDynamicTo = WebFValue<EventTarget , WebFPublicMethods> (*)(EventTarget*, EventTargetType event_target_type);

struct EventTargetPublicMethods : public WebFPublicMethods {
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
  static WebFValue<EventTarget , WebFPublicMethods> DynamicTo(EventTarget* event_target, EventTargetType event_target_type);

  double version{1.0};
  PublicEventTargetAddEventListener event_target_add_event_listener{AddEventListener};
  PublicEventTargetRemoveEventListener event_target_remove_event_listener{RemoveEventListener};
  PublicEventTargetDispatchEvent event_target_dispatch_event{DispatchEvent};
  PublicEventTargetRelease event_target_release{Release};
  PublicEventTargetDynamicTo event_target_dynamic_to{DynamicTo};
};

}  // namespace webf

#endif  // WEBF_CORE_WEBF_API_EVENT_TARGET_H_
