/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_matrix.h"
#include "core/executing_context.h"

namespace webf {

DOMMatrix* DOMMatrix::Create(ExecutingContext* context,
                             const std::vector<double>& init,
                             ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMMatrix>(context, init, exception_state);
}

DOMMatrix* DOMMatrix::Create(webf::ExecutingContext* context, webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMMatrix>(context, exception_state);
}

DOMMatrix* DOMMatrix::fromMatrix(ExecutingContext* context,
                                 DOMMatrix *matrix,
                                 ExceptionState& exception_state) {
  return DOMMatrixReadonly::fromMatrix(context, matrix ,exception_state);
}

DOMMatrix::DOMMatrix(webf::ExecutingContext* context, webf::ExceptionState& exception_state):
      DOMMatrixReadonly(context, exception_state) {}

DOMMatrix::DOMMatrix(ExecutingContext* context,
                     const std::vector<double>& init,
                     ExceptionState& exception_state)
    : DOMMatrixReadonly(context, init, exception_state) {}

DOMMatrix::DOMMatrix(webf::ExecutingContext* context, webf::NativeBindingObject* native_binding_object): DOMMatrixReadonly(context, native_binding_object) {

}

}  // namespace webf