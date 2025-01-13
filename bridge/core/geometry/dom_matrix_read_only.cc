/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_matrix_read_only.h"
#include "binding_call_methods.h"
#include "bindings/qjs/converter_impl.h"
#include "core/executing_context.h"
#include "core/frame/module_manager.h"
#include "core/geometry/dom_matrix.h"
#include "core/geometry/dom_point.h"
#include "native_value_converter.h"

namespace webf {
DOMMatrixReadOnly* DOMMatrixReadOnly::Create(ExecutingContext* context,
                                             const std::shared_ptr<QJSUnionSequenceDoubleDOMMatrixInit>& init,
                                             ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMMatrixReadOnly>(context, init, exception_state);
}

DOMMatrixReadOnly* DOMMatrixReadOnly::Create(webf::ExecutingContext* context, webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMMatrixReadOnly>(context, exception_state);
}

DOMMatrix* DOMMatrixReadOnly::fromMatrix(ExecutingContext* context,
                                         DOMMatrixReadOnly* matrix,
                                         ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<DOMMatrixReadOnly>>::ToNativeValue(matrix)};
  // auto* context = matrix->GetExecutingContext();
  AtomicString module_name = AtomicString(context->ctx(), "DOMMatrix");
  AtomicString method_name = AtomicString(context->ctx(), "fromMatrix");

  NativeValue* dart_result = context->dartMethodPtr()->invokeModule(
      context->isDedicated(), nullptr, context->contextId(), context->dartIsolateContext()->profiler()->link_id(),
      module_name.ToNativeString(context->ctx()).release(), method_name.ToNativeString(context->ctx()).release(),
      arguments, nullptr);

  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(*dart_result);

  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(context, native_binding_object);
}

DOMMatrixReadOnly::DOMMatrixReadOnly(ExecutingContext* context,
                                     const std::shared_ptr<QJSUnionSequenceDoubleDOMMatrixInit>& init,
                                     ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  if (init->IsSequenceDouble()) {
    NativeValue arguments[1];
    arguments[0] = NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::ToNativeValue(init->GetAsSequenceDouble());
    GetExecutingContext()->dartMethodPtr()->createBindingObject(
        GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
        CreateBindingObjectType::kCreateDOMMatrix, arguments, 1);
  } else if (init->IsDOMMatrixInit()) {
    std::vector<double> domMatrixInitVectorDouble;
    auto domMatrixInit = init->GetAsDOMMatrixInit();
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m11());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m12());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m13());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m14());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m21());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m22());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m23());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m24());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m31());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m32());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m33());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m34());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m41());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m42());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m43());
    domMatrixInitVectorDouble.emplace_back(domMatrixInit->m44());
    NativeValue arguments[3];
    arguments[0] = NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::ToNativeValue(domMatrixInitVectorDouble);
    arguments[1] = NativeValueConverter<NativeTypeBool>::ToNativeValue(domMatrixInit->is2D());
    arguments[2] = NativeValueConverter<NativeTypeBool>::ToNativeValue(domMatrixInit->isIdentity());
    GetExecutingContext()->dartMethodPtr()->createBindingObject(
        GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
        CreateBindingObjectType::kCreateDOMMatrix, arguments, 1);
  }
}

DOMMatrixReadOnly::DOMMatrixReadOnly(webf::ExecutingContext* context, webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreateDOMMatrix, nullptr, 0);
}

DOMMatrixReadOnly::DOMMatrixReadOnly(webf::ExecutingContext* context, webf::NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object) {}

double DOMMatrixReadOnly::getMatrixProperty(const AtomicString& prop) const {
  NativeValue dart_result = GetBindingProperty(prop, FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(dart_result);
}

void DOMMatrixReadOnly::setMatrixProperty(const AtomicString& prop, double v, ExceptionState& exception_state) {
  if (DynamicTo<DOMMatrix>(this)) {
    SetBindingProperty(prop, NativeValueConverter<NativeTypeDouble>::ToNativeValue(v), exception_state);
  }
}

void DOMMatrixReadOnly::setMatrixPropertyAsync(const AtomicString& prop, double v, ExceptionState& exception_state) {
  if (DynamicTo<DOMMatrix>(this)) {
    SetBindingPropertyAsync(prop, NativeValueConverter<NativeTypeDouble>::ToNativeValue(v), exception_state);
  }
}

double DOMMatrixReadOnly::m11() const {
  return getMatrixProperty(defined_properties::km11);
}
void DOMMatrixReadOnly::setM11(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km11, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m11_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km11, exception_state);
}
void DOMMatrixReadOnly::setM11_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km11, v, exception_state);
}
double DOMMatrixReadOnly::m12() const {
  return getMatrixProperty(defined_properties::km12);
}
void DOMMatrixReadOnly::setM12(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km12, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m12_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km12, exception_state);
}
void DOMMatrixReadOnly::setM12_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km12, v, exception_state);
}

double DOMMatrixReadOnly::m13() const {
  return getMatrixProperty(defined_properties::km13);
}
void DOMMatrixReadOnly::setM13(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km13, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m13_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km13, exception_state);
}
void DOMMatrixReadOnly::setM13_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km13, v, exception_state);
}

double DOMMatrixReadOnly::m14() const {
  return getMatrixProperty(defined_properties::km14);
}
void DOMMatrixReadOnly::setM14(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km14, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m14_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km14, exception_state);
}
void DOMMatrixReadOnly::setM14_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km14, v, exception_state);
}

double DOMMatrixReadOnly::m21() const {
  return getMatrixProperty(defined_properties::km21);
}
void DOMMatrixReadOnly::setM21(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km21, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m21_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km21, exception_state);
}
void DOMMatrixReadOnly::setM21_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km21, v, exception_state);
}

double DOMMatrixReadOnly::m22() const {
  return getMatrixProperty(defined_properties::km22);
}
void DOMMatrixReadOnly::setM22(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km22, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m22_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km22, exception_state);
}
void DOMMatrixReadOnly::setM22_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km22, v, exception_state);
}

double DOMMatrixReadOnly::m23() const {
  return getMatrixProperty(defined_properties::km23);
}
void DOMMatrixReadOnly::setM23(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km23, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m23_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km23, exception_state);
}
void DOMMatrixReadOnly::setM23_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km23, v, exception_state);
}

double DOMMatrixReadOnly::m24() const {
  return getMatrixProperty(defined_properties::km24);
}
void DOMMatrixReadOnly::setM24(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km24, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m24_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km24, exception_state);
}
void DOMMatrixReadOnly::setM24_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km24, v, exception_state);
}

double DOMMatrixReadOnly::m31() const {
  return getMatrixProperty(defined_properties::km31);
}
void DOMMatrixReadOnly::setM31(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km31, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m31_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km31, exception_state);
}
void DOMMatrixReadOnly::setM31_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km31, v, exception_state);
}

double DOMMatrixReadOnly::m32() const {
  return getMatrixProperty(defined_properties::km32);
}
void DOMMatrixReadOnly::setM32(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km32, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m32_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km32, exception_state);
}
void DOMMatrixReadOnly::setM32_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km32, v, exception_state);
}

double DOMMatrixReadOnly::m33() const {
  return getMatrixProperty(defined_properties::km33);
}
void DOMMatrixReadOnly::setM33(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km33, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m33_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km33, exception_state);
}
void DOMMatrixReadOnly::setM33_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km33, v, exception_state);
}

double DOMMatrixReadOnly::m34() const {
  return getMatrixProperty(defined_properties::km34);
}
void DOMMatrixReadOnly::setM34(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km34, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m34_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km34, exception_state);
}
void DOMMatrixReadOnly::setM34_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km34, v, exception_state);
}

double DOMMatrixReadOnly::m41() const {
  return getMatrixProperty(defined_properties::km41);
}
void DOMMatrixReadOnly::setM41(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km41, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m41_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km41, exception_state);
}
void DOMMatrixReadOnly::setM41_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km41, v, exception_state);
}

double DOMMatrixReadOnly::m42() const {
  return getMatrixProperty(defined_properties::km42);
}
void DOMMatrixReadOnly::setM42(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km42, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m42_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km42, exception_state);
}
void DOMMatrixReadOnly::setM42_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km42, v, exception_state);
}

double DOMMatrixReadOnly::m43() const {
  return getMatrixProperty(defined_properties::km43);
}
void DOMMatrixReadOnly::setM43(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km43, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m43_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km43, exception_state);
}
void DOMMatrixReadOnly::setM43_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km43, v, exception_state);
}

double DOMMatrixReadOnly::m44() const {
  return getMatrixProperty(defined_properties::km44);
}
void DOMMatrixReadOnly::setM44(double v, ExceptionState& exception_state) {
  setMatrixProperty(defined_properties::km44, v, exception_state);
}
ScriptPromise DOMMatrixReadOnly::m44_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(defined_properties::km44, exception_state);
}
void DOMMatrixReadOnly::setM44_async(double v, ExceptionState& exception_state) {
  setMatrixPropertyAsync(defined_properties::km44, v, exception_state);
}

DOMMatrix* DOMMatrixReadOnly::flipX(ExceptionState& exception_state) const {
  NativeValue value = InvokeBindingMethod(binding_call_methods::kflipX, 0, nullptr,
                                          FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}
DOMMatrix* DOMMatrixReadOnly::flipY(ExceptionState& exception_state) const {
  NativeValue value = InvokeBindingMethod(binding_call_methods::kflipY, 0, nullptr,
                                          FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}
DOMMatrix* DOMMatrixReadOnly::inverse(ExceptionState& exception_state) const {
  NativeValue value = InvokeBindingMethod(binding_call_methods::kinverse, 0, nullptr,
                                          FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::multiply(DOMMatrix* matrix, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<DOMMatrix>>::ToNativeValue(matrix)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::kmultiply, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);

  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::rotateAxisAngle(ExceptionState& exception_state) const {
  return this->rotateAxisAngle(0, 0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::rotateAxisAngle(double x, ExceptionState& exception_state) const {
  return this->rotateAxisAngle(x, 0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::rotateAxisAngle(double x, double y, ExceptionState& exception_state) const {
  return this->rotateAxisAngle(x, y, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::rotateAxisAngle(double x, double y, double z, ExceptionState& exception_state) const {
  return this->rotateAxisAngle(x, y, z, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::rotateAxisAngle(double x,
                                              double y,
                                              double z,
                                              double angle,
                                              ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(z),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(angle)};
  NativeValue value =
      InvokeBindingMethod(binding_call_methods::krotateAxisAngle, sizeof(arguments) / sizeof(NativeValue), arguments,
                          FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::rotate(ExceptionState& exception_state) const {
  return this->rotate(0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::rotate(double x, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::krotate, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}
DOMMatrix* DOMMatrixReadOnly::rotate(double x, double y, ExceptionState& exception_state) const {
  return this->rotate(x, y, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::rotate(double x, double y, double z, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(z)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::krotate, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::rotateFromVector(ExceptionState& exception_state) const {
  return this->rotateFromVector(0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::rotateFromVector(double x, ExceptionState& exception_state) const {
  return this->rotateFromVector(x, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::rotateFromVector(double x, double y, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  NativeValue value =
      InvokeBindingMethod(binding_call_methods::krotateFromVector, sizeof(arguments) / sizeof(NativeValue), arguments,
                          FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::scale(ExceptionState& exception_state) const {
  return this->scale(1, 1, 1, 0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale(double sx, ExceptionState& exception_state) const {
  return this->scale(sx, 1, 1, 0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale(double sx, double sy, ExceptionState& exception_state) const {
  return this->scale(sx, sy, 1, 0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale(double sx, double sy, double sz, ExceptionState& exception_state) const {
  return this->scale(sx, sy, sz, 0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale(double sx, double sy, double sz, double ox, ExceptionState& exception_state) const {
  return this->scale(sx, sy, sz, ox, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale(double sx,
                                    double sy,
                                    double sz,
                                    double ox,
                                    double oy,
                                    ExceptionState& exception_state) const {
  return this->scale(sx, sy, sz, ox, oy, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale(double sx,
                                    double sy,
                                    double sz,
                                    double ox,
                                    double oy,
                                    double oz,
                                    ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(sx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(sy),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(sz),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(ox),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(oy),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(oz)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::kscale, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::scale3d(ExceptionState& exception_state) const {
  return this->scale3d(1, 0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale3d(double scale, ExceptionState& exception_state) const {
  return this->scale3d(scale, 0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale3d(double scale, double ox, ExceptionState& exception_state) const {
  return this->scale3d(scale, ox, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale3d(double scale, double ox, double oy, ExceptionState& exception_state) const {
  return this->scale3d(scale, ox, oy, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scale3d(double scale,
                                      double ox,
                                      double oy,
                                      double oz,
                                      ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(scale),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(ox),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(oy),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(oz)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::kscale3d, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::scaleNonUniform(ExceptionState& exception_state) const {
  return this->scaleNonUniform(1, 1, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scaleNonUniform(double sx, ExceptionState& exception_state) const {
  return this->scaleNonUniform(sx, 1, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::scaleNonUniform(double sx, double sy, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(sx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(sy)};
  NativeValue value =
      InvokeBindingMethod(binding_call_methods::kscaleNonUniform, sizeof(arguments) / sizeof(NativeValue), arguments,
                          FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::skewX(ExceptionState& exception_state) const {
  return this->skewX(0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::skewX(double sx, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(sx)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::kskewX, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::skewY(ExceptionState& exception_state) const {
  return this->skewY(0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::skewY(double sy, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(sy)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::kskewY, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}
// std::vector<float>& DOMMatrixReadOnly::toFloat32Array(ExceptionState& exception_state) const {
//   std::vector<float> float32Vector;
//   // NativeValue arguments[0];
//   // NativeValue value = InvokeBindingMethod(binding_call_methods::ktoFloat32Array, sizeof(arguments) /
//   sizeof(NativeValue),
//   //   arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
//   // auto&& arr = NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::FromNativeValue(ctx(), value);
//   // if (native_binding_object == nullptr)
//   //   return float32Vector;
//   // // return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
//   return float32Vector;
// }
// std::vector<double>& DOMMatrixReadOnly::toFloat64Array(ExceptionState& exception_state) const {
//   std::vector<double> float64Vector;
//   return float64Vector;
// }
// toJSON(): DartImpl<JSON>;
AtomicString DOMMatrixReadOnly::toString(ExceptionState& exception_state) const {
  NativeValue dart_result = InvokeBindingMethod(binding_call_methods::ktoString, 0, nullptr,
                                                FlushUICommandReason::kDependentsOnElement, exception_state);
  return NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(dart_result));
}

DOMPoint* DOMMatrixReadOnly::transformPoint(DOMPoint* point, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<DOMPoint>>::ToNativeValue(point)};
  NativeValue value =
      InvokeBindingMethod(binding_call_methods::ktransformPoint, sizeof(arguments) / sizeof(NativeValue), arguments,
                          FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);

  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMPoint>(GetExecutingContext(), native_binding_object);
}

DOMMatrix* DOMMatrixReadOnly::translate(ExceptionState& exception_state) const {
  return this->translate(0, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::translate(double tx, ExceptionState& exception_state) const {
  return this->translate(tx, 0, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::translate(double tx, double ty, ExceptionState& exception_state) const {
  return this->translate(tx, ty, 0, exception_state);
}
DOMMatrix* DOMMatrixReadOnly::translate(double tx, double ty, double tz, ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(tx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(ty),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(tz)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::ktranslate, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

NativeValue DOMMatrixReadOnly::HandleCallFromDartSide(const AtomicString& method,
                                                      int32_t argc,
                                                      const NativeValue* argv,
                                                      Dart_Handle dart_object) {
  return Native_NewNull();
}

}  // namespace webf