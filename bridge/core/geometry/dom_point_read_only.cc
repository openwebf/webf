/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_point_read_only.h"
#include "binding_call_methods.h"
#include "native_value_converter.h"
#include "bindings/qjs/converter_impl.h"
#include "core/executing_context.h"
#include "core/geometry/dom_point.h"
#include "core/geometry/dom_matrix.h"

namespace webf {

DOMPointReadOnly* DOMPointReadOnly::Create(webf::ExecutingContext* context, webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadOnly>(context, exception_state);
}
DOMPointReadOnly* DOMPointReadOnly::Create(webf::ExecutingContext* context,
                                           const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                           webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadOnly>(context, init, exception_state);
}
DOMPointReadOnly* DOMPointReadOnly::Create(webf::ExecutingContext* context,
                                           const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                           double y,
                                           webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadOnly>(context, init, y, exception_state);
}
DOMPointReadOnly* DOMPointReadOnly::Create(webf::ExecutingContext* context,
                                           const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                           double y,
                                           double z,
                                           webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadOnly>(context, init, y, z, exception_state);
}
DOMPointReadOnly* DOMPointReadOnly::Create(webf::ExecutingContext* context,
                                           const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                           double y,
                                           double z,
                                           double w,
                                           webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadOnly>(context, init, y, z, w, exception_state);
}

DOMPointReadOnly::DOMPointReadOnly(webf::ExecutingContext* context, webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreateDOMPoint, nullptr, 0);
}

DOMPointReadOnly::DOMPointReadOnly(webf::ExecutingContext* context, const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init, webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  this->createWithDOMPointInit(context, exception_state, init);
}
DOMPointReadOnly::DOMPointReadOnly(webf::ExecutingContext* context,
                                   const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                   double y,
                                   webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  this->createWithDOMPointInit(context, exception_state, init, y);
}
DOMPointReadOnly::DOMPointReadOnly(webf::ExecutingContext* context,
                                   const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                   double y,
                                   double w,
                                   webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  this->createWithDOMPointInit(context, exception_state, init, y, w);
}

DOMPointReadOnly::DOMPointReadOnly(webf::ExecutingContext* context,
                                   const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                   double y,
                                   double w,
                                   double z,
                                   webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  this->createWithDOMPointInit(context, exception_state, init, y, w, z);
}

DOMPointReadOnly::DOMPointReadOnly(webf::ExecutingContext* context, webf::NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object) {}

void DOMPointReadOnly::createWithDOMPointInit(ExecutingContext* context,
                                              ExceptionState& exception_state,
                                              const std::shared_ptr<QJSUnionDoubleDOMPointInit>& init,
                                              double y,
                                              double w,
                                              double z) {
  if (init->IsDOMPointInit()) {
    auto domPointInit = init->GetAsDOMPointInit();
    NativeValue arguments[] = {
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(domPointInit->x()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(domPointInit->y()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(domPointInit->z()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(domPointInit->w()),
    };
    GetExecutingContext()->dartMethodPtr()->createBindingObject(
        GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
        CreateBindingObjectType::kCreateDOMPoint, arguments, sizeof(arguments) / sizeof(NativeValue));
  } else if (init->IsDouble()) {
    // DOMPointReadOnly(x,y,z,w)
    NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(init->GetAsDouble()),
                               NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                               NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                               NativeValueConverter<NativeTypeDouble>::ToNativeValue(z)};
    GetExecutingContext()->dartMethodPtr()->createBindingObject(
        GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
        CreateBindingObjectType::kCreateDOMPoint, arguments, sizeof(arguments) / sizeof(NativeValue));
  }
}

double DOMPointReadOnly::getPointProperty(const AtomicString& prop) const {
  NativeValue dart_result = GetBindingProperty(prop, FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(dart_result);
}

void DOMPointReadOnly::setPointProperty(const AtomicString& prop, double v, ExceptionState& exception_state) {
  if (DynamicTo<DOMPoint>(this)) {
    SetBindingProperty(prop, NativeValueConverter<NativeTypeDouble>::ToNativeValue(v), exception_state);
  }
}

double DOMPointReadOnly::x() const {
  return getPointProperty(binding_call_methods::kx);
}
void DOMPointReadOnly::setX(double v, ExceptionState& exception_state) {
  setPointProperty(binding_call_methods::kx, v, exception_state);
}
double DOMPointReadOnly::y() {
  return getPointProperty(binding_call_methods::ky);
}
void DOMPointReadOnly::setY(double v, ExceptionState& exception_state) {
  setPointProperty(binding_call_methods::ky, v, exception_state);
}
double DOMPointReadOnly::z() const {
  return getPointProperty(binding_call_methods::kz);
}
void DOMPointReadOnly::setZ(double v, ExceptionState& exception_state) {
  setPointProperty(binding_call_methods::kz, v, exception_state);
}
double DOMPointReadOnly::w() const {
  return getPointProperty(binding_call_methods::kw);
}
void DOMPointReadOnly::setW(double v, ExceptionState& exception_state) {
  setPointProperty(binding_call_methods::kw, v, exception_state);
}

DOMPoint* DOMPointReadOnly::matrixTransform(DOMMatrix* matrix, ExceptionState& exception_state) const {
  NativeValue arguments[] = {
    NativeValueConverter<NativeTypePointer<DOMMatrix>>::ToNativeValue(matrix)
  };
  NativeValue value = InvokeBindingMethod(binding_call_methods::kmatrixTransform, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);

  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMPoint>(GetExecutingContext(), native_binding_object);
}

NativeValue DOMPointReadOnly::HandleCallFromDartSide(const AtomicString& method,
                                                      int32_t argc,
                                                     const NativeValue* argv,
                                                     Dart_Handle dart_object) {
  return Native_NewNull();
}

}  // namespace webf
