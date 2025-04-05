/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_CANVAS_CANVAS_GRADIENT_H_
#define WEBF_CORE_HTML_CANVAS_CANVAS_GRADIENT_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "plugin_api/canvas_gradient.h"

namespace webf {

class CanvasGradient : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CanvasGradient*;

  CanvasGradient() = delete;
  explicit CanvasGradient(ExecutingContext* context, NativeBindingObject* native_binding_object);

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;

  bool IsCanvasGradient() const override;

  const CanvasGradientPublicMethods* canvasGradientPublicMethods();

 private:
};

template <>
struct DowncastTraits<CanvasGradient> {
  static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsCanvasGradient(); }
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_CANVAS_CANVAS_GRADIENT_H_
