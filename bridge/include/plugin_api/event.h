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

using PublicEventGetBubbles = bool (*)(Event*);
using PublicEventGetCancelable = bool (*)(Event*);
using PublicEventGetCurrentTarget = WebFValue<EventTarget, EventTargetPublicMethods> (*)(Event*);
using PublicEventGetDefaultPrevented = bool (*)(Event*);
using PublicEventGetSrcElement = WebFValue<EventTarget, EventTargetPublicMethods> (*)(Event*);
using PublicEventGetTarget = WebFValue<EventTarget, EventTargetPublicMethods> (*)(Event*);
using PublicEventGetIsTrusted = bool (*)(Event*);
using PublicEventGetTimeStamp = double (*)(Event*);
using PublicEventGetType = const char* (*)(Event*);
using PublicEventPreventDefault = void (*)(Event*, SharedExceptionState*);
using PublicEventStopImmediatePropagation = void (*)(Event*, SharedExceptionState*);
using PublicEventStopPropagation = void (*)(Event*, SharedExceptionState*);
using PublicEventRelease = void (*)(Event*);

struct EventPublicMethods : public WebFPublicMethods {

  static bool Bubbles(Event* event);
  static bool Cancelable(Event* event);
  static WebFValue<EventTarget, EventTargetPublicMethods> CurrentTarget(Event* event);
  static bool DefaultPrevented(Event* event);
  static WebFValue<EventTarget, EventTargetPublicMethods> SrcElement(Event* event);
  static WebFValue<EventTarget, EventTargetPublicMethods> Target(Event* event);
  static bool IsTrusted(Event* event);
  static double TimeStamp(Event* event);
  static const char* Type(Event* event);
  static void PreventDefault(Event* event, SharedExceptionState* shared_exception_state);
  static void StopImmediatePropagation(Event* event, SharedExceptionState* shared_exception_state);
  static void StopPropagation(Event* event, SharedExceptionState* shared_exception_state);
  static void Release(Event* event);
  double version{1.0};

  PublicEventGetBubbles event_get_bubbles{Bubbles};
  PublicEventGetCancelable event_get_cancelable{Cancelable};
  PublicEventGetCurrentTarget event_get_current_target{CurrentTarget};
  PublicEventGetDefaultPrevented event_get_default_prevented{DefaultPrevented};
  PublicEventGetSrcElement event_get_src_element{SrcElement};
  PublicEventGetTarget event_get_target{Target};
  PublicEventGetIsTrusted event_get_is_trusted{IsTrusted};
  PublicEventGetTimeStamp event_get_time_stamp{TimeStamp};
  PublicEventGetType event_get_type{Type};
  PublicEventPreventDefault event_prevent_default{PreventDefault};
  PublicEventStopImmediatePropagation event_stop_immediate_propagation{StopImmediatePropagation};
  PublicEventStopPropagation event_stop_propagation{StopPropagation};
  PublicEventRelease event_release{Release};
};

}  // namespace webf

#endif  // WEBF_CORE_WEBF_API_EVENT_H_
