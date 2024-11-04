/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_GEOMETRY_DOM_POINT_READONLY_H_
#define WEBF_CORE_GEOMETRY_DOM_POINT_READONLY_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"

namespace webf {

struct DOMPointData {
  double x;
  double y;
  double z;
  double w;
};

class DOMPoint;
class DOMMatrix;

class DOMPointReadonly : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMPointReadonly*;

  static DOMPointReadonly* Create(ExecutingContext* context, ExceptionState& exception_state);
  static DOMPointReadonly* Create(ExecutingContext* context, double x, ExceptionState& exception_state);
  static DOMPointReadonly* Create(ExecutingContext* context, double x, double y, ExceptionState& exception_state);
  static DOMPointReadonly* Create(ExecutingContext* context,
                                  double x,
                                  double y,
                                  double z,
                                  ExceptionState& exception_state);
  static DOMPointReadonly* Create(ExecutingContext* context,
                                  double x,
                                  double y,
                                  double z,
                                  double w,
                                  ExceptionState& exception_state);

  DOMPointReadonly() = delete;

  explicit DOMPointReadonly(ExecutingContext* context, ExceptionState& exception_state);
  explicit DOMPointReadonly(ExecutingContext* context, double x, ExceptionState& exception_state);
  explicit DOMPointReadonly(ExecutingContext* context, double x, double y, ExceptionState& exception_state);
  explicit DOMPointReadonly(ExecutingContext* context, double x, double y, double z, ExceptionState& exception_state);
  explicit DOMPointReadonly(ExecutingContext* context,
                            double x,
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
  explicit DOMPointReadonly(ExecutingContext* context, NativeBindingObject* native_binding_object);

 private:
  [[nodiscard]] double getPointProperty(const AtomicString& prop) const;
  void setPointProperty(const AtomicString& prop, double v, ExceptionState& exception_state);
  std::shared_ptr<DOMPointData> dom_point_data_ = nullptr;
};

}  // namespace webf

#endif  // WEBF_CORE_GEOMETRY_DOM_POINT_READONLY_H_
