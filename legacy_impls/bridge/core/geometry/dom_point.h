/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_GEOMETRY_DOM_POINT_H_
#define WEBF_CORE_GEOMETRY_DOM_POINT_H_

#include "dom_point_read_only.h"

namespace webf {

class DOMPoint : public DOMPointReadOnly {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMPoint*;
  static DOMPoint* Create(ExecutingContext* context, ExceptionState& exception_state);
  static DOMPoint* Create(ExecutingContext* context,
                          const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                          ExceptionState& exception_state);
  static DOMPoint* Create(ExecutingContext* context,
                          const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                          double y,
                          ExceptionState& exception_state);
  static DOMPoint* Create(ExecutingContext* context,
                          const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                          double y,
                          double z,
                          ExceptionState& exception_state);
  static DOMPoint* Create(ExecutingContext* context,
                          const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                          double y,
                          double z,
                          double w,
                          ExceptionState& exception_state);
  DOMPoint() = delete;
  explicit DOMPoint(ExecutingContext* context, ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context,
                    const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                    ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context,
                    const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                    double y,
                    ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context,
                    const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                    double y,
                    double z,
                    ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context,
                    const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                    double y,
                    double z,
                    double w,
                    ExceptionState& exception_state);
  explicit DOMPoint(ExecutingContext* context, NativeBindingObject* native_binding_object);

  [[nodiscard]] bool IsDOMPoint() const override { return true; }
};
template <>
struct DowncastTraits<DOMPoint> {
  static bool AllowFrom(const DOMPointReadOnly& matrix) { return matrix.IsDOMPoint(); }
};
}  // namespace webf

#endif  // WEBF_CORE_GEOMETRY_DOM_POINT_H_
