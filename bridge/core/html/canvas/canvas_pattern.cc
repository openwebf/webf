/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "canvas_pattern.h"
#include "binding_call_methods.h"
#include "foundation/native_value_converter.h"

namespace webf {

CanvasPattern::CanvasPattern(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object) {}

void CanvasPattern::setTransform(DOMMatrix* dom_matrix, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<DOMMatrix>>::ToNativeValue(dom_matrix)};
  InvokeBindingMethod(binding_call_methods::ksetTransform, 1, arguments, exception_state);
}

NativeValue CanvasPattern::HandleCallFromDartSide(const AtomicString& method,
                                                  int32_t argc,
                                                  const NativeValue* argv,
                                                  Dart_Handle dart_object) {
  return Native_NewNull();
}

}  // namespace webf