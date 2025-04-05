/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "canvas_gradient.h"
#include "core/executing_context.h"

namespace webf {

CanvasGradient::CanvasGradient(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object) {}

NativeValue CanvasGradient::HandleCallFromDartSide(const AtomicString& method,
                                                   int32_t argc,
                                                   const NativeValue* argv,
                                                   Dart_Handle dart_object) {
  return Native_NewNull();
}
const CanvasGradientPublicMethods* CanvasGradient::canvasGradientPublicMethods() {
  static CanvasGradientPublicMethods canvas_gradient_public_methods;
  return &canvas_gradient_public_methods;
}
bool CanvasGradient::IsCanvasGradient() const {
  return true;
}

}  // namespace webf