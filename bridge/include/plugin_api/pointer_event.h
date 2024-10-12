/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_POINTER_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_POINTER_EVENT_H_
#include <stdint.h>
#include "mouse_event.h"
namespace webf {
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct PointerEvent PointerEvent;
using PublicPointerEventGetHeight = double (*)(PointerEvent*);
using PublicPointerEventGetIsPrimary = bool (*)(PointerEvent*);
using PublicPointerEventGetPointerId = double (*)(PointerEvent*);
using PublicPointerEventGetPointerType = const char* (*)(PointerEvent*);
using PublicPointerEventDupPointerType = const char* (*)(PointerEvent*);
using PublicPointerEventGetPressure = double (*)(PointerEvent*);
using PublicPointerEventGetTangentialPressure = double (*)(PointerEvent*);
using PublicPointerEventGetTiltX = double (*)(PointerEvent*);
using PublicPointerEventGetTiltY = double (*)(PointerEvent*);
using PublicPointerEventGetTwist = double (*)(PointerEvent*);
using PublicPointerEventGetWidth = double (*)(PointerEvent*);
struct PointerEventPublicMethods : public WebFPublicMethods {
  static double Height(PointerEvent* pointerEvent);
  static bool IsPrimary(PointerEvent* pointerEvent);
  static double PointerId(PointerEvent* pointerEvent);
  static const char* PointerType(PointerEvent* pointerEvent);
  static const char* DupPointerType(PointerEvent* pointerEvent);
  static double Pressure(PointerEvent* pointerEvent);
  static double TangentialPressure(PointerEvent* pointerEvent);
  static double TiltX(PointerEvent* pointerEvent);
  static double TiltY(PointerEvent* pointerEvent);
  static double Twist(PointerEvent* pointerEvent);
  static double Width(PointerEvent* pointerEvent);
  double version{1.0};
  PublicPointerEventGetHeight pointer_event_get_height{Height};
  PublicPointerEventGetIsPrimary pointer_event_get_is_primary{IsPrimary};
  PublicPointerEventGetPointerId pointer_event_get_pointer_id{PointerId};
  PublicPointerEventGetPointerType pointer_event_get_pointer_type{PointerType};
  PublicPointerEventDupPointerType pointer_event_dup_pointer_type{DupPointerType};
  PublicPointerEventGetPressure pointer_event_get_pressure{Pressure};
  PublicPointerEventGetTangentialPressure pointer_event_get_tangential_pressure{TangentialPressure};
  PublicPointerEventGetTiltX pointer_event_get_tilt_x{TiltX};
  PublicPointerEventGetTiltY pointer_event_get_tilt_y{TiltY};
  PublicPointerEventGetTwist pointer_event_get_twist{Twist};
  PublicPointerEventGetWidth pointer_event_get_width{Width};
};
}  // namespace webf
#endif // WEBF_CORE_WEBF_API_PLUGIN_API_POINTER_EVENT_H_