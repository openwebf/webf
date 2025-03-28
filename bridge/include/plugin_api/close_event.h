// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
// clang-format off
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_CLOSE_EVENT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_CLOSE_EVENT_H_
#include <stdint.h>
#include "core/native/vector_value_ref.h"
#include "rust_readable.h"
#include "event.h"
namespace webf {
class SharedExceptionState;
class ExecutingContext;
typedef struct NativeValue NativeValue;
typedef struct AtomicStringRef AtomicStringRef;
class CloseEvent;
using PublicCloseEventGetCode = int64_t (*)(CloseEvent*);
using PublicCloseEventGetReason = AtomicStringRef (*)(CloseEvent*);
using PublicCloseEventGetWasClean = int32_t (*)(CloseEvent*);
struct CloseEventPublicMethods : public WebFPublicMethods {
  static int64_t Code(CloseEvent* close_event);
  static AtomicStringRef Reason(CloseEvent* close_event);
  static int32_t WasClean(CloseEvent* close_event);
  double version{1.0};
  EventPublicMethods event;
  PublicCloseEventGetCode close_event_get_code{Code};
  PublicCloseEventGetReason close_event_get_reason{Reason};
  PublicCloseEventGetWasClean close_event_get_was_clean{WasClean};
};
}  // namespace webf
#endif  // WEBF_CORE_WEBF_API_PLUGIN_API_CLOSE_EVENT_H_
