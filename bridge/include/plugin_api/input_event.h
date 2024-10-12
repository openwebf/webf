/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_INPUT_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_INPUT_EVENT_H_
#include <stdint.h>
#include "ui_event.h"
namespace webf {
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct InputEvent InputEvent;
using PublicInputEventGetInputType = const char* (*)(InputEvent*);
using PublicInputEventDupInputType = const char* (*)(InputEvent*);
using PublicInputEventGetData = const char* (*)(InputEvent*);
using PublicInputEventDupData = const char* (*)(InputEvent*);
struct InputEventPublicMethods : public WebFPublicMethods {
  static const char* InputType(InputEvent* inputEvent);
  static const char* DupInputType(InputEvent* inputEvent);
  static const char* Data(InputEvent* inputEvent);
  static const char* DupData(InputEvent* inputEvent);
  double version{1.0};
  PublicInputEventGetInputType input_event_get_input_type{InputType};
  PublicInputEventDupInputType input_event_dup_input_type{DupInputType};
  PublicInputEventGetData input_event_get_data{Data};
  PublicInputEventDupData input_event_dup_data{DupData};
};
}  // namespace webf
#endif // WEBF_CORE_WEBF_API_PLUGIN_API_INPUT_EVENT_H_