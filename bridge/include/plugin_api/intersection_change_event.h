// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_INTERSECTION_CHANGE_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_INTERSECTION_CHANGE_EVENT_H_
#include <stdint.h>
#include "script_value_ref.h"
#include "event.h"
namespace webf {
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct IntersectionChangeEvent IntersectionChangeEvent;
typedef struct ScriptValueRef ScriptValueRef;
using PublicIntersectionChangeEventGetIntersectionRatio = double (*)(IntersectionChangeEvent*);
struct IntersectionChangeEventPublicMethods : public WebFPublicMethods {
  static double IntersectionRatio(IntersectionChangeEvent* intersectionChangeEvent);
  double version{1.0};
  PublicIntersectionChangeEventGetIntersectionRatio intersection_change_event_get_intersection_ratio{IntersectionRatio};
};
}  // namespace webf
#endif // WEBF_CORE_WEBF_API_PLUGIN_API_INTERSECTION_CHANGE_EVENT_H_