/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_matrix_readonly.h"
#include "binding_call_methods.h"
#include "core/executing_context.h"
#include "core/geometry/dom_matrix.h"
#include "foundation/native_value_converter.h"

namespace webf {

DOMMatrixReadonly* DOMMatrixReadonly::Create(ExecutingContext* context,
                                             const std::vector<double>& init,
                                             ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMMatrixReadonly>(context, init, exception_state);
}

DOMMatrixReadonly* DOMMatrixReadonly::Create(webf::ExecutingContext* context, webf::ExceptionState& exception_state) {

}

DOMMatrixReadonly::DOMMatrixReadonly(ExecutingContext* context,
                                     const std::vector<double>& init,
                                     ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  NativeValue arguments[1];
  arguments[0] = NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::ToNativeValue(init);
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreateDOMMatrix, arguments, 1);
}

DOMMatrixReadonly::DOMMatrixReadonly(webf::ExecutingContext* context, webf::ExceptionState& exception_state)
    : BindingObject(context->ctx()) {
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreateDOMMatrix, nullptr, 0);
}

DOMMatrix* DOMMatrixReadonly::flipX(ExceptionState& exception_state) {
  NativeValue arguments[0];
  NativeValue value = InvokeBindingMethod(binding_call_methods::kflipX, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
  if (native_binding_object == nullptr)
    return nullptr;
  return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
}

// DOMMatrix* DOMMatrixReadonly::flipY(ExceptionState& exception_state) {
//   NativeValue arguments[0];
//   NativeValue value = InvokeBindingMethod(binding_call_methods::kflipY, sizeof(arguments) / sizeof(NativeValue),
//                                           arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
//   NativeBindingObject* native_binding_object =
//       NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
//   if (native_binding_object == nullptr)
//     return nullptr;
//   return MakeGarbageCollected<DOMMatrix>(GetExecutingContext(), native_binding_object);
// }

NativeValue DOMMatrixReadonly::HandleCallFromDartSide(const AtomicString& method,
                                                      int32_t argc,
                                                      const NativeValue* argv,
                                                      Dart_Handle dart_object) {
  return Native_NewNull();
}

}  // namespace webf