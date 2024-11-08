/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_GEOMETRY_DOM_POINT_READONLY_H_
#define WEBF_CORE_GEOMETRY_DOM_POINT_READONLY_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "qjs_dom_point_init.h"
#include "qjs_union_doubledom_point_init.h"

namespace webf {

class DOMPoint;
class DOMMatrix;

class DOMPointReadOnly : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMPointReadOnly*;

  static DOMPointReadOnly* Create(ExecutingContext* context, ExceptionState& exception_state);
  static DOMPointReadOnly* Create(ExecutingContext* context,
                                  const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                  ExceptionState& exception_state);
  static DOMPointReadOnly* Create(ExecutingContext* context,
                                  const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                  double y,
                                  ExceptionState& exception_state);
  static DOMPointReadOnly* Create(ExecutingContext* context,
                                  const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                  double y,
                                  double z,
                                  ExceptionState& exception_state);
  static DOMPointReadOnly* Create(ExecutingContext* context,
                                  const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                  double y,
                                  double z,
                                  double w,
                                  ExceptionState& exception_state);

  DOMPointReadOnly() = delete;

  explicit DOMPointReadOnly(ExecutingContext* context, ExceptionState& exception_state);
  explicit DOMPointReadOnly(ExecutingContext* context,
                            const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                            ExceptionState& exception_state);
  explicit DOMPointReadOnly(ExecutingContext* context,
                            const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                            double y,
                            ExceptionState& exception_state);
  explicit DOMPointReadOnly(ExecutingContext* context,
                            const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                            double y,
                            double z,
                            ExceptionState& exception_state);
  explicit DOMPointReadOnly(ExecutingContext* context,
                            const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                            double y,
                            double z,
                            double w,
                            ExceptionState& exception_state);

  virtual bool IsDOMPoint() const { return false; }

  double x() const;
  void setX(double v, ExceptionState& exception_state);
  double y();
  void setY(double v, ExceptionState& exception_state);
  double z() const;
  void setZ(double v, ExceptionState& exception_state);
  double w() const;
  void setW(double v, ExceptionState& exception_state);

  DOMPoint* matrixTransform(DOMMatrix* matrix, ExceptionState& exception_state) const;

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;
protected:
  explicit DOMPointReadOnly(ExecutingContext* context, NativeBindingObject* native_binding_object);

 private:
  void createWithDOMPointInit(ExecutingContext* context,
                              ExceptionState& exception_state,
                              const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                              double y = 0,
                              double w = 0,
                              double z = 1);

      [[nodiscard]] double getPointProperty(const AtomicString& prop) const;
  void setPointProperty(const AtomicString& prop, double v, ExceptionState& exception_state);
};

}  // namespace webf

#endif  // WEBF_CORE_GEOMETRY_DOM_POINT_READONLY_H_
