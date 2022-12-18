/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_CANVAS_CANVAS_PATTERN_H_
#define WEBF_CORE_HTML_CANVAS_CANVAS_PATTERN_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "core/geometry/dom_matrix.h"

namespace webf {

class CanvasPattern : public ScriptWrappable, public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CanvasPattern*;

  CanvasPattern() = delete;
  explicit CanvasPattern(ExecutingContext* context, NativeBindingObject* native_binding_object);

  void setTransform(DOMMatrix* dom_matrix, ExceptionState& exception_state);

  NativeValue HandleCallFromDartSide(const NativeValue* method, int32_t argc, const NativeValue* argv) override;
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_CANVAS_CANVAS_PATTERN_H_
