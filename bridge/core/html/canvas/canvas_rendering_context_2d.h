/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_
#define BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_

#include "canvas_rendering_context.h"
#include "core/html/html_image_element.h"

namespace webf {

class CanvasRenderingContext2D : public CanvasRenderingContext, public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CanvasRenderingContext2D*;
  CanvasRenderingContext2D() = delete;
  explicit CanvasRenderingContext2D(ExecutingContext* context, NativeBindingObject* native_binding_object);

  NativeValue HandleCallFromDartSide(NativeString* method, int32_t argc, const NativeValue* argv) const override;

  bool IsCanvas2d() const override;
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_
