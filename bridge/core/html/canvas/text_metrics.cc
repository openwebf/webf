/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "text_metrics.h"
#include "core/executing_context.h"

namespace webf {

TextMetrics* TextMetrics::Create(ExecutingContext* context, NativeBindingObject* native_binding_object) {
  return MakeGarbageCollected<TextMetrics>(context, native_binding_object);
}

TextMetrics::TextMetrics(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object),
      extra_(static_cast<TextMetricsData*>(native_binding_object->extra)) {}

NativeValue TextMetrics::HandleCallFromDartSide(const AtomicString& method,
                                                int32_t argc,
                                                const NativeValue* argv,
                                                Dart_Handle dart_object) {
  return Native_NewNull();
}

}  // namespace webf
