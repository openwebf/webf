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

Path2D::Path2D(ExecutingContext* context, ExceptionState& exception_state)
  : BindingObject(context->ctx()) {
  NativeValue arguments[0];
  GetExecutingContext()->dartMethodPtr()->createBindingObject(GetExecutingContext()->isDedicated(),
                                                              GetExecutingContext()->contextId(), bindingObject(),
                                                              CreateBindingObjectType::kCreatePath2D, arguments, 0);
}

void Path2D::addPath(Path2D* path, DOMMatrix* dom_matrix, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(path),
                            NativeValueConverter<NativeTypePointer<DOMMatrix>>::ToNativeValue(dom_matrix)};
  InvokeBindingMethod(binding_call_methods::kaddPath, 2, arguments, exception_state, true);
}

NativeValue Path2D::HandleCallFromDartSide(const AtomicString& method,
                                          int32_t argc,
                                          const NativeValue* argv,
                                          Dart_Handle dart_object) {
  return Native_NewNull();
}

}  // namespace webf
