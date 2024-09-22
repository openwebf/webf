/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_FOCUS_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_FOCUS_EVENT_H_
#include <stdint.h>
#include "ui_event.h"
namespace webf {
typedef struct EventTarget EventTarget;
typedef struct EventTargetPublicMethods EventTargetPublicMethods;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct FocusEvent FocusEvent;
using PublicFocusEventGetRelatedTarget = WebFValue<EventTarget, EventTargetPublicMethods> (*)(FocusEvent*);
struct FocusEventPublicMethods : public WebFPublicMethods {
  static WebFValue<EventTarget, EventTargetPublicMethods> RelatedTarget(FocusEvent* focusEvent);
  double version{1.0};
  PublicFocusEventGetRelatedTarget focus_event_get_related_target{RelatedTarget};
};
}  // namespace webf
#endif // WEBF_CORE_WEBF_API_PLUGIN_API_FOCUS_EVENT_H_