/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_MOUSE_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_MOUSE_EVENT_H_
#include <stdint.h>
#include "ui_event.h"
namespace webf {
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct MouseEvent MouseEvent;
using PublicMouseEventGetClientX = double (*)(MouseEvent*);
using PublicMouseEventGetClientY = double (*)(MouseEvent*);
using PublicMouseEventGetOffsetX = double (*)(MouseEvent*);
using PublicMouseEventGetOffsetY = double (*)(MouseEvent*);
struct MouseEventPublicMethods : public WebFPublicMethods {
  static double ClientX(MouseEvent* mouseEvent);
  static double ClientY(MouseEvent* mouseEvent);
  static double OffsetX(MouseEvent* mouseEvent);
  static double OffsetY(MouseEvent* mouseEvent);
  double version{1.0};
  PublicMouseEventGetClientX mouse_event_get_client_x{ClientX};
  PublicMouseEventGetClientY mouse_event_get_client_y{ClientY};
  PublicMouseEventGetOffsetX mouse_event_get_offset_x{OffsetX};
  PublicMouseEventGetOffsetY mouse_event_get_offset_y{OffsetY};
};
}  // namespace webf
#endif // WEBF_CORE_WEBF_API_PLUGIN_API_MOUSE_EVENT_H_