/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_GEOMETRY_DOM_POINT_H_
#define WEBF_CORE_GEOMETRY_DOM_POINT_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "dom_point_readonly.h"

namespace webf {

class DOMPoint : public DOMPointReadonly {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMPoint*;
  static DOMPoint* Create(ExecutingContext* context, ExceptionState& exception_state);
  static DOMPoint* Create(ExecutingContext* context, double x, ExceptionState& exception_state);
  static DOMPoint* Create(ExecutingContext* context, double x, double y, ExceptionState& exception_state);
  static DOMPoint* Create(ExecutingContext* context, double x, double y, double z, ExceptionState& exception_state);
  static DOMPoint* Create(ExecutingContext* context,
                          double x,
                          double y,
                          double z,
                          double w,
                          ExceptionState& exception_state);
  DOMPoint() = delete;
  explicit DOMPoint(ExecutingContext* context, ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context, double x, ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context, double x, double y, ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context, double x, double y, double z, ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context, double x, double y, double z, double w, ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context, NativeBindingObject* native_binding_object);

  [[nodiscard]] bool IsDOMPoint() const override { return true; }
};
template <>
struct DowncastTraits<DOMPoint> {
  static bool AllowFrom(const DOMPointReadonly& matrix) { return matrix.IsDOMPoint(); }
};
}  // namespace webf

#endif WEBF_CORE_GEOMETRY_DOM_POINT_H_
