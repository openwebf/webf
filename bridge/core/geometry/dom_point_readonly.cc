/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_point_readonly.h"

#include <binding_call_methods.h>
#include <native_value_converter.h>

#include "core/executing_context.h"
#include "dom_point.h"

namespace webf {

DOMPointReadonly* DOMPointReadonly::Create(webf::ExecutingContext* context, webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadonly>(context, exception_state);
}
DOMPointReadonly* DOMPointReadonly::Create(webf::ExecutingContext* context,
                                           double x,
                                           webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadonly>(context, x, exception_state);
}
DOMPointReadonly* DOMPointReadonly::Create(webf::ExecutingContext* context,
                                           double x,
                                           double y,
                                           webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadonly>(context, x, y, exception_state);
}
DOMPointReadonly* DOMPointReadonly::Create(webf::ExecutingContext* context,
                                           double x,
                                           double y,
                                           double z,
                                           webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadonly>(context, x, y, z, exception_state);
}
DOMPointReadonly* DOMPointReadonly::Create(webf::ExecutingContext* context,
                                           double x,
                                           double y,
                                           double z,
                                           double w,
                                           webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMPointReadonly>(context, x, y, z, w, exception_state);
}

DOMPointReadonly::DOMPointReadonly(webf::ExecutingContext* context, webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreateDOMPoint, nullptr, 0);
}

DOMPointReadonly::DOMPointReadonly(webf::ExecutingContext* context, double x, webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x)};

  GetExecutingContext()->dartMethodPtr()->createBindingObject(
      GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
      CreateBindingObjectType::kCreateDOMPoint, arguments, sizeof(arguments) / sizeof(NativeValue));
}

DOMPointReadonly::DOMPointReadonly(webf::ExecutingContext* context,
                                   double x,
                                   double y,
                                   webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};

  GetExecutingContext()->dartMethodPtr()->createBindingObject(
      GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
      CreateBindingObjectType::kCreateDOMPoint, arguments, sizeof(arguments) / sizeof(NativeValue));
}

DOMPointReadonly::DOMPointReadonly(webf::ExecutingContext* context,
                                   double x,
                                   double y,
                                   double w,
                                   webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w)};

  GetExecutingContext()->dartMethodPtr()->createBindingObject(
      GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
      CreateBindingObjectType::kCreateDOMPoint, arguments, sizeof(arguments) / sizeof(NativeValue));
}

DOMPointReadonly::DOMPointReadonly(webf::ExecutingContext* context,
                                   double x,
                                   double y,
                                   double w,
                                   double z,
                                   webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(z)};

  GetExecutingContext()->dartMethodPtr()->createBindingObject(
      GetExecutingContext()->isDedicated(), GetExecutingContext()->contextId(), bindingObject(),
      CreateBindingObjectType::kCreateDOMPoint, arguments, sizeof(arguments) / sizeof(NativeValue));
}

double DOMPointReadonly::getPointProperty(const AtomicString& prop) const {
  NativeValue dart_result = GetBindingProperty(prop, FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(dart_result);
}

void DOMPointReadonly::setPointProperty(const AtomicString& prop, double v, ExceptionState& exception_state) {
  if (DynamicTo<DOMPoint>(this)) {
    SetBindingProperty(prop, NativeValueConverter<NativeTypeDouble>::ToNativeValue(v), exception_state);
  }
}

double DOMPointReadonly::x() const {
  return getPointProperty(binding_call_methods::kx);
}
void DOMPointReadonly::setX(double v, ExceptionState& exception_state) {
  setPointProperty(binding_call_methods::kx, v, exception_state);
}
double DOMPointReadonly::y() {
  return getPointProperty(binding_call_methods::ky);
}
void DOMPointReadonly::setY(double v, ExceptionState& exception_state) {
  setPointProperty(binding_call_methods::ky, v, exception_state);
}
double DOMPointReadonly::z() const {
  return getPointProperty(binding_call_methods::kz);
}
void DOMPointReadonly::setZ(double v, ExceptionState& exception_state) {
  setPointProperty(binding_call_methods::kz, v, exception_state);
}
double DOMPointReadonly::w() const {
  return getPointProperty(binding_call_methods::kw);
}
void DOMPointReadonly::setW(double v, ExceptionState& exception_state) {
  setPointProperty(binding_call_methods::kw, v, exception_state);
}

NativeValue DOMPointReadonly::HandleCallFromDartSide(const AtomicString& method,
                                                      int32_t argc,
                                                     const NativeValue* argv,
                                                     Dart_Handle dart_object) {
  return Native_NewNull();
}

}  // namespace webf
