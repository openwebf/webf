/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_ERROR_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_ERROR_EVENT_H_
#include "plugin_api_event.h"
namespace webf {
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct ErrorEvent ErrorEvent;
using PublicErrorEventGetMessage = const char* (*)(ErrorEvent*);
using PublicErrorEventDupMessage = const char* (*)(ErrorEvent*);
using PublicErrorEventGetFilename = const char* (*)(ErrorEvent*);
using PublicErrorEventDupFilename = const char* (*)(ErrorEvent*);
using PublicErrorEventGetLineno = double (*)(ErrorEvent*);
using PublicErrorEventGetColno = double (*)(ErrorEvent*);
using PublicErrorEventGetError = int64_t (*)(ErrorEvent*);
struct ErrorEventPublicMethods : public WebFPublicMethods {
  static const char* Message(ErrorEvent* errorEvent);
  static const char* DupMessage(ErrorEvent* errorEvent);
  static const char* Filename(ErrorEvent* errorEvent);
  static const char* DupFilename(ErrorEvent* errorEvent);
  static double Lineno(ErrorEvent* errorEvent);
  static double Colno(ErrorEvent* errorEvent);
  static int64_t Error(ErrorEvent* errorEvent);
  double version{1.0};
  PublicErrorEventGetMessage error_event_get_message{Message};
  PublicErrorEventDupMessage error_event_dup_message{DupMessage};
  PublicErrorEventGetFilename error_event_get_filename{Filename};
  PublicErrorEventDupFilename error_event_dup_filename{DupFilename};
  PublicErrorEventGetLineno error_event_get_lineno{Lineno};
  PublicErrorEventGetColno error_event_get_colno{Colno};
  PublicErrorEventGetError error_event_get_error{Error};
};
}  // namespace webf
#endif // WEBF_CORE_WEBF_API_PLUGIN_API_ERROR_EVENT_H_