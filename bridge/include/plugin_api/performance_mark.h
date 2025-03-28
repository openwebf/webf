// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
// clang-format off
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_PERFORMANCE_MARK_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_PERFORMANCE_MARK_H_
#include <stdint.h>
#include "core/native/vector_value_ref.h"
#include "rust_readable.h"
#include "performance_entry.h"
namespace webf {
class SharedExceptionState;
class ExecutingContext;
typedef struct NativeValue NativeValue;
typedef struct AtomicStringRef AtomicStringRef;
class PerformanceMark;
using PublicPerformanceMarkGetDetail = NativeValue (*)(PerformanceMark*, SharedExceptionState* shared_exception_state);
struct PerformanceMarkPublicMethods : public WebFPublicMethods {
  static NativeValue Detail(PerformanceMark* performance_mark, SharedExceptionState* shared_exception_state);
  double version{1.0};
  PerformanceEntryPublicMethods performance_entry;
  PublicPerformanceMarkGetDetail performance_mark_get_detail{Detail};
};
}  // namespace webf
#endif  // WEBF_CORE_WEBF_API_PLUGIN_API_PERFORMANCE_MARK_H_
