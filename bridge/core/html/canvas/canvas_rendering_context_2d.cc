/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "canvas_rendering_context_2d.h"

namespace webf {

bool CanvasRenderingContext2D::IsCanvas2d() const {
  return true;
}

CanvasRenderingContext2D::CanvasRenderingContext2D(ExecutingContext* context,
                                                   NativeBindingObject* native_binding_object)
    : BindingObject(context, native_binding_object), CanvasRenderingContext(context) {}

NativeValue CanvasRenderingContext2D::HandleCallFromDartSide(NativeString* method,
                                                             int32_t argc,
                                                             const NativeValue* argv) {
  return Native_NewNull();
}

}  // namespace webf