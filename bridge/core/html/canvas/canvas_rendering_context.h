/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_H_
#define BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "plugin_api/canvas_rendering_context.h"

namespace webf {

class CanvasRenderingContext : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CanvasRenderingContext*;
  explicit CanvasRenderingContext(JSContext* ctx, NativeBindingObject* native_binding_object);

  virtual bool IsCanvas2d() const;

  const CanvasRenderingContextPublicMethods* canvasRenderingContextPublicMethods() {
    static CanvasRenderingContextPublicMethods canvas_rendering_context_public_methods;
    return &canvas_rendering_context_public_methods;
  }

 private:
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_H_
