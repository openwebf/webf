/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DEVTOOLS_DEVTOOLS_BRIDGE_H_
#define WEBF_CORE_DEVTOOLS_DEVTOOLS_BRIDGE_H_

#include "foundation/native_value.h"
#include "include/webf_bridge.h"

// These functions are exported for Dart FFI
WEBF_EXPORT_C
webf::NativeValue* GetObjectPropertiesFromDart(void* dart_isolate_context_ptr,
                                               double context_id,
                                               const char* object_id,
                                               int32_t include_prototype);

WEBF_EXPORT_C
webf::NativeValue* EvaluatePropertyPathFromDart(void* dart_isolate_context_ptr,
                                                double context_id,
                                                const char* object_id,
                                                const char* property_path);

WEBF_EXPORT_C
webf::NativeValue* GetPropertyValueFromDart(void* dart_isolate_context_ptr,
                                           double context_id,
                                           const char* object_id,
                                           const char* property_name);

WEBF_EXPORT_C
void ReleaseObjectFromDart(void* dart_isolate_context_ptr, double context_id, const char* object_id);

namespace webf {

class ExecutingContext;

namespace devtools_internal {

// Register/unregister ExecutingContext for DevTools access
void RegisterExecutingContext(ExecutingContext* context);
void UnregisterExecutingContext(ExecutingContext* context);

}  // namespace devtools_internal

}  // namespace webf

#endif  // WEBF_CORE_DEVTOOLS_DEVTOOLS_BRIDGE_H_