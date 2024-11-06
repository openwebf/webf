/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "path_2d.h"
#include "binding_call_methods.h"
#include "foundation/native_value_converter.h"

namespace webf {

Path2D* Path2D::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<Path2D>(context, exception_state);
}

Path2D* Path2D::Create(ExecutingContext* context,
                       const std::shared_ptr<QJSUnionPath2DDomString>& init,
                       ExceptionState& exception_state) {
  return MakeGarbageCollected<Path2D>(context, init, exception_state);
}

Path2D::Path2D(ExecutingContext* context, ExceptionState& exception_state)
  : BindingObject(context->ctx()) {
  NativeValue arguments[0];
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreatePath2D, arguments, 0);
}

Path2D::Path2D(ExecutingContext* context,
               const std::shared_ptr<QJSUnionPath2DDomString>& init,
               ExceptionState& exception_state)
  : BindingObject(context->ctx()) {
  NativeValue arguments[1];
  if (init->IsDomString()) {
    arguments[0] = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), init->GetAsDomString());
  } else if (init->IsPath2D()) {
    arguments[0] = NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(init->GetAsPath2D());
  }

  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreatePath2D, arguments, 1);
}

void Path2D::addPath(Path2D* path, DOMMatrixReadOnly* dom_matrix, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(path),
                            NativeValueConverter<NativeTypePointer<DOMMatrixReadOnly>>::ToNativeValue(dom_matrix)};
  InvokeBindingMethod(binding_call_methods::kaddPath, 2, arguments, FlushUICommandReason::kDependentsOnElement,
                      exception_state);
}

void Path2D::addPath(webf::Path2D* path, webf::ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(path)};
  InvokeBindingMethod(binding_call_methods::kaddPath, 1, arguments, FlushUICommandReason::kDependentsOnElement,
                      exception_state);
}

void Path2D::roundRect(double x,
                       double y,
                       double w,
                       double h,
                       std::shared_ptr<const QJSUnionDoubleSequenceDouble> radii,
                       ExceptionState& exception_state) {
  std::vector<double> radii_vector;
  if (radii->IsDouble()) {
    radii_vector.emplace_back(radii->GetAsDouble());
  } else if (radii->IsSequenceDouble()) {
    std::vector<double> radii_sequence = radii->GetAsSequenceDouble();
    radii_vector.assign(radii_sequence.begin(), radii_sequence.end());
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(h),
                             NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::ToNativeValue(radii_vector)};

  InvokeBindingMethod(binding_call_methods::kroundRect, sizeof(arguments) / sizeof(NativeValue), arguments,
                      FlushUICommandReason::kDependentsOnElement, exception_state);
}

NativeValue Path2D::HandleCallFromDartSide(const AtomicString& method,
                                          int32_t argc,
                                          const NativeValue* argv,
                                          Dart_Handle dart_object) {
  return Native_NewNull();
}

}  // namespace webf
