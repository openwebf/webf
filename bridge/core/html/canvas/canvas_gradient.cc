/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "canvas_gradient.h"

namespace webf {

CanvasGradient::CanvasGradient(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : ScriptWrappable(context->ctx()), BindingObject(context, native_binding_object) {}

NativeValue CanvasGradient::HandleCallFromDartSide(const NativeValue* method, int32_t argc, const NativeValue* argv) {
  return Native_NewNull();
}

bool CanvasGradient::IsCanvasGradient() const {
  return true;
}

}  // namespace webf