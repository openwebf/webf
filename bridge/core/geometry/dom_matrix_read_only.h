/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_
#define WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "qjs_dom_matrix_init.h"
#include "qjs_union_sequencedoubledom_matrix_init.h"

namespace webf {

class DOMMatrix;
class DOMPoint;

class DOMMatrixReadOnly : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMMatrixReadOnly*;
  static DOMMatrixReadOnly* Create(ExecutingContext* context,
                                   const std::shared_ptr<QJSUnionSequenceDoubleDOMMatrixInit>& init,
                                   ExceptionState& exception_state);
  static DOMMatrixReadOnly* Create(ExecutingContext* context, ExceptionState& exception_state);
  static DOMMatrix* fromMatrix(ExecutingContext* context, DOMMatrixReadOnly* matrix, ExceptionState& exception_state);

  DOMMatrixReadOnly() = delete;
  explicit DOMMatrixReadOnly(ExecutingContext* context,
                             const std::shared_ptr<QJSUnionSequenceDoubleDOMMatrixInit>& init,
                             ExceptionState& exception_state);
  explicit DOMMatrixReadOnly(ExecutingContext* context, ExceptionState& exception_state);

  virtual bool IsDOMMatrix() const { return false; }
  double m11() const;
  void setM11(double v, ExceptionState& exception_state);
  ScriptPromise m11_async(ExceptionState& exception_state);
  ScriptPromise setM11_async(double v, ExceptionState& exception_state);

  double m12() const;
  void setM12(double v, ExceptionState& exception_state);
  ScriptPromise m12_async(ExceptionState& exception_state);
  ScriptPromise setM12_async(double v, ExceptionState& exception_state);

  double m13() const;
  void setM13(double v, ExceptionState& exception_state);
  ScriptPromise m13_async(ExceptionState& exception_state);
  ScriptPromise setM13_async(double v, ExceptionState& exception_state);

  double m14() const;
  void setM14(double v, ExceptionState& exception_state);
  ScriptPromise m14_async(ExceptionState& exception_state);
  ScriptPromise setM14_async(double v, ExceptionState& exception_state);

  double m21() const;
  void setM21(double v, ExceptionState& exception_state);
  ScriptPromise m21_async(ExceptionState& exception_state);
  ScriptPromise setM21_async(double v, ExceptionState& exception_state);

  double m22() const;
  void setM22(double v, ExceptionState& exception_state);
  ScriptPromise m22_async(ExceptionState& exception_state);
  ScriptPromise setM22_async(double v, ExceptionState& exception_state);

  double m23() const;
  void setM23(double v, ExceptionState& exception_state);
  ScriptPromise m23_async(ExceptionState& exception_state);
  ScriptPromise setM23_async(double v, ExceptionState& exception_state);

  [[nodiscard]] double m24() const;
  void setM24(double v, ExceptionState& exception_state);
  ScriptPromise m24_async(ExceptionState& exception_state);
  ScriptPromise setM24_async(double v, ExceptionState& exception_state);

  double m31() const;
  void setM31(double v, ExceptionState& exception_state);
  ScriptPromise m31_async(ExceptionState& exception_state);
  ScriptPromise setM31_async(double v, ExceptionState& exception_state);

  double m32() const;
  void setM32(double v, ExceptionState& exception_state);
  ScriptPromise m32_async(ExceptionState& exception_state);
  ScriptPromise setM32_async(double v, ExceptionState& exception_state);

  double m33() const;
  void setM33(double v, ExceptionState& exception_state);
  ScriptPromise m33_async(ExceptionState& exception_state);
  ScriptPromise setM33_async(double v, ExceptionState& exception_state);

  double m34() const;
  void setM34(double v, ExceptionState& exception_state);
  ScriptPromise m34_async(ExceptionState& exception_state);
  ScriptPromise setM34_async(double v, ExceptionState& exception_state);

  double m41() const;
  void setM41(double v, ExceptionState& exception_state);
  ScriptPromise m41_async(ExceptionState& exception_state);
  ScriptPromise setM41_async(double v, ExceptionState& exception_state);

  double m42() const;
  void setM42(double v, ExceptionState& exception_state);
  ScriptPromise m42_async(ExceptionState& exception_state);
  ScriptPromise setM42_async(double v, ExceptionState& exception_state);

  double m43() const;
  void setM43(double v, ExceptionState& exception_state);
  ScriptPromise m43_async(ExceptionState& exception_state);
  ScriptPromise setM43_async(double v, ExceptionState& exception_state);

  double m44() const;
  void setM44(double v, ExceptionState& exception_state);
  ScriptPromise m44_async(ExceptionState& exception_state);
  ScriptPromise setM44_async(double v, ExceptionState& exception_state);

  double a() const { return m11(); }
  void setA(double v, ExceptionState& exception_state) { setM11(v, exception_state); }
  ScriptPromise a_async(ExceptionState& exception_state) { return m11_async(exception_state); }
  ScriptPromise setA_async(double v, ExceptionState& exception_state) { return setM11_async(v, exception_state); }

  double b() const { return m12(); }
  void setB(double v, ExceptionState& exception_state) { setM12(v, exception_state); }
  ScriptPromise b_async(ExceptionState& exception_state) { return m12_async(exception_state); }
  ScriptPromise setB_async(double v, ExceptionState& exception_state) { return setM12_async(v, exception_state); }

  double c() const { return m21(); }
  void setC(double v, ExceptionState& exception_state) { setM21(v, exception_state); }
  ScriptPromise c_async(ExceptionState& exception_state) { return m21_async(exception_state); }
  ScriptPromise setC_async(double v, ExceptionState& exception_state) { return setM21_async(v, exception_state); }

  double d() const { return m22(); }
  void setD(double v, ExceptionState& exception_state) { setM22(v, exception_state); }
  ScriptPromise d_async(ExceptionState& exception_state) { return m22_async(exception_state); }
  ScriptPromise setD_async(double v, ExceptionState& exception_state) { return setM22_async(v, exception_state); }

  double e() const { return m41(); }
  void setE(double v, ExceptionState& exception_state) { setM41(v, exception_state); }
  ScriptPromise e_async(ExceptionState& exception_state) { return m41_async(exception_state); }
  ScriptPromise setE_async(double v, ExceptionState& exception_state) { return setM41_async(v, exception_state); }

  double f() const { return m42(); }
  void setF(double v, ExceptionState& exception_state) { setM42(v, exception_state); }
  ScriptPromise f_async(ExceptionState& exception_state) { return m42_async(exception_state); }
  ScriptPromise setF_async(double v, ExceptionState& exception_state) { return setM42_async(v, exception_state); }

  DOMMatrix* flipX(ExceptionState& exception_state) const;
  DOMMatrix* flipY(ExceptionState& exception_state) const;
  DOMMatrix* inverse(ExceptionState& exception_state) const;
  DOMMatrix* multiply(DOMMatrix* matrix, ExceptionState& exception_state) const;
  DOMMatrix* rotateAxisAngle(ExceptionState& exception_state) const;
  DOMMatrix* rotateAxisAngle(double x, ExceptionState& exception_state) const;
  DOMMatrix* rotateAxisAngle(double x, double y, ExceptionState& exception_state) const;
  DOMMatrix* rotateAxisAngle(double x, double y, double z, ExceptionState& exception_state) const;
  DOMMatrix* rotateAxisAngle(double x, double y, double z, double angle, ExceptionState& exception_state) const;
  DOMMatrix* rotate(ExceptionState& exception_state) const;
  DOMMatrix* rotate(double x, ExceptionState& exception_state) const;
  DOMMatrix* rotate(double x, double y, ExceptionState& exception_state) const;
  DOMMatrix* rotate(double x, double y, double z, ExceptionState& exception_state) const;
  DOMMatrix* rotateFromVector(ExceptionState& exception_state) const;
  DOMMatrix* rotateFromVector(double x, ExceptionState& exception_state) const;
  DOMMatrix* rotateFromVector(double x, double y, ExceptionState& exception_state) const;
  DOMMatrix* scale(ExceptionState& exception_state) const;
  DOMMatrix* scale(double sx, ExceptionState& exception_state) const;
  DOMMatrix* scale(double sx, double sy, ExceptionState& exception_state) const;
  DOMMatrix* scale(double sx, double sy, double sz, ExceptionState& exception_state) const;
  DOMMatrix* scale(double sx, double sy, double sz, double ox, ExceptionState& exception_state) const;
  DOMMatrix* scale(double sx, double sy, double sz, double ox, double oy, ExceptionState& exception_state) const;
  DOMMatrix* scale(double sx, double sy, double sz, double ox, double oy, double oz, ExceptionState& exception_state)
      const;
  DOMMatrix* scale3d(ExceptionState& exception_state) const;
  DOMMatrix* scale3d(double scale, ExceptionState& exception_state) const;
  DOMMatrix* scale3d(double scale, double ox, ExceptionState& exception_state) const;
  DOMMatrix* scale3d(double scale, double ox, double oy, ExceptionState& exception_state) const;
  DOMMatrix* scale3d(double scale, double ox, double oy, double oz, ExceptionState& exception_state) const;
  DOMMatrix* scaleNonUniform(ExceptionState& exception_state) const;
  DOMMatrix* scaleNonUniform(double sx, ExceptionState& exception_state) const;
  DOMMatrix* scaleNonUniform(double sx, double sy, ExceptionState& exception_state) const;
  DOMMatrix* skewX(ExceptionState& exception_state) const;
  DOMMatrix* skewX(double sx, ExceptionState& exception_state) const;
  DOMMatrix* skewY(ExceptionState& exception_state) const;
  DOMMatrix* skewY(double sy, ExceptionState& exception_state) const;
  // toJSON(): DartImpl<JSON>;

  AtomicString toString(ExceptionState& exception_state) const;
  DOMPoint* transformPoint(DOMPoint* point, ExceptionState& exception_state) const;
  DOMMatrix* translate(ExceptionState& exception_state) const;
  DOMMatrix* translate(double tx, ExceptionState& exception_state) const;
  DOMMatrix* translate(double tx, double ty, ExceptionState& exception_state) const;
  DOMMatrix* translate(double tx, double ty, double tz, ExceptionState& exception_state) const;

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;

 protected:
  explicit DOMMatrixReadOnly(ExecutingContext* context, NativeBindingObject* native_binding_object);

 private:
  [[nodiscard]] double getMatrixProperty(const AtomicString& prop) const;
  void setMatrixProperty(const AtomicString& prop, double v, ExceptionState& exception_state);
  ScriptPromise setMatrixPropertyAsync(const AtomicString& prop, double v, ExceptionState& exception_state);
};

}  // namespace webf

#endif  // WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_
