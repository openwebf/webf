/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_HASHCHANGE_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_HASHCHANGE_EVENT_H_
#include <stdint.h>
#include "event.h"
namespace webf {
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct HashchangeEvent HashchangeEvent;
using PublicHashchangeEventGetNewURL = const char* (*)(HashchangeEvent*);
using PublicHashchangeEventDupNewURL = const char* (*)(HashchangeEvent*);
using PublicHashchangeEventGetOldURL = const char* (*)(HashchangeEvent*);
using PublicHashchangeEventDupOldURL = const char* (*)(HashchangeEvent*);
struct HashchangeEventPublicMethods : public WebFPublicMethods {
  static const char* NewURL(HashchangeEvent* hashchangeEvent);
  static const char* DupNewURL(HashchangeEvent* hashchangeEvent);
  static const char* OldURL(HashchangeEvent* hashchangeEvent);
  static const char* DupOldURL(HashchangeEvent* hashchangeEvent);
  double version{1.0};
  PublicHashchangeEventGetNewURL hashchange_event_get_new_url{NewURL};
  PublicHashchangeEventDupNewURL hashchange_event_dup_new_url{DupNewURL};
  PublicHashchangeEventGetOldURL hashchange_event_get_old_url{OldURL};
  PublicHashchangeEventDupOldURL hashchange_event_dup_old_url{DupOldURL};
};
}  // namespace webf
#endif // WEBF_CORE_WEBF_API_PLUGIN_API_HASHCHANGE_EVENT_H_