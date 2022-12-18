/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_CANVAS_CANVAS_GRADIENT_H_
#define WEBF_CORE_HTML_CANVAS_CANVAS_GRADIENT_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"

namespace webf {

class CanvasGradient : public ScriptWrappable, public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CanvasGradient*;

  CanvasGradient() = delete;
  explicit CanvasGradient(ExecutingContext* context, NativeBindingObject* native_binding_object);

  NativeValue HandleCallFromDartSide(const NativeValue* method, int32_t argc, const NativeValue* argv) override;

  bool IsCanvasGradient() const override;

 private:
};

template <>
struct DowncastTraits<CanvasGradient> {
  static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsCanvasGradient(); }
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_CANVAS_CANVAS_GRADIENT_H_
