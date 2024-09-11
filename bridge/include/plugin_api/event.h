/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_WEBF_API_EVENT_H_
#define WEBF_CORE_WEBF_API_EVENT_H_

#include "webf_value.h"
#include "event_target.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

using WebFEventGetBubbles = bool (*)(Event*);
using WebFEventGetCancelable = bool (*)(Event*);
using WebFEventGetCurrentTarget = WebFValue<EventTarget, EventTargetWebFMethods> (*)(Event*);
using WebFEventGetDefaultPrevented = bool (*)(Event*);
using WebFEventGetSrcElement = WebFValue<EventTarget, EventTargetWebFMethods> (*)(Event*);
using WebFEventGetTarget = WebFValue<EventTarget, EventTargetWebFMethods> (*)(Event*);
using WebFEventGetIsTrusted = bool (*)(Event*);
using WebFEventGetTimeStamp = double (*)(Event*);
using WebFEventGetType = const char* (*)(Event*);
using WebFEventPreventDefault = void (*)(Event*, SharedExceptionState*);
using WebFEventStopImmediatePropagation = void (*)(Event*, SharedExceptionState*);
using WebFEventStopPropagation = void (*)(Event*, SharedExceptionState*);
using WebFEventRelease = void (*)(Event*);

struct EventWebFMethods : public WebFPublicMethods {

  static bool Bubbles(Event* event);
  static bool Cancelable(Event* event);
  static WebFValue<EventTarget, EventTargetWebFMethods> CurrentTarget(Event* event);
  static bool DefaultPrevented(Event* event);
  static WebFValue<EventTarget, EventTargetWebFMethods> SrcElement(Event* event);
  static WebFValue<EventTarget, EventTargetWebFMethods> Target(Event* event);
  static bool IsTrusted(Event* event);
  static double TimeStamp(Event* event);
  static const char* Type(Event* event);
  static void PreventDefault(Event* event, SharedExceptionState* shared_exception_state);
  static void StopImmediatePropagation(Event* event, SharedExceptionState* shared_exception_state);
  static void StopPropagation(Event* event, SharedExceptionState* shared_exception_state);
  static void Release(Event* event);
  double version{1.0};

  WebFEventGetBubbles event_get_bubbles{Bubbles};
  WebFEventGetCancelable event_get_cancelable{Cancelable};
  WebFEventGetCurrentTarget event_get_current_target{CurrentTarget};
  WebFEventGetDefaultPrevented event_get_default_prevented{DefaultPrevented};
  WebFEventGetSrcElement event_get_src_element{SrcElement};
  WebFEventGetTarget event_get_target{Target};
  WebFEventGetIsTrusted event_get_is_trusted{IsTrusted};
  WebFEventGetTimeStamp event_get_time_stamp{TimeStamp};
  WebFEventGetType event_get_type{Type};
  WebFEventPreventDefault event_prevent_default{PreventDefault};
  WebFEventStopImmediatePropagation event_stop_immediate_propagation{StopImmediatePropagation};
  WebFEventStopPropagation event_stop_propagation{StopPropagation};
  WebFEventRelease event_release{Release};
};

}  // namespace webf

#endif  // WEBF_CORE_WEBF_API_EVENT_H_
