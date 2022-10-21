/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "canvas_rendering_context.h"
#include "core/executing_context.h"

namespace webf {

CanvasRenderingContext::CanvasRenderingContext(ExecutingContext* context) : ScriptWrappable(context->ctx()) {}

bool CanvasRenderingContext::IsCanvas2d() const {
  return false;
}

}  // namespace webf