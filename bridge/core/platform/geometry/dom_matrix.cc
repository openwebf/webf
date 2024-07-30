/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_matrix.h"

namespace webf {

DOMMatrix* DOMMatrix::Create(ExecutingContext* context,
                             const std::shared_ptr<QJSUnionDomStringSequenceDouble>& init,
                             ExceptionState& exception_state) {
  return MakeGarbageCollected<DOMMatrix>(context, init, exception_state);
}

DOMMatrix::DOMMatrix(ExecutingContext* context,
                     const std::shared_ptr<QJSUnionDomStringSequenceDouble>& init,
                     ExceptionState& exception_state)
    : DOMMatrixReadonly(context, init, exception_state) {}

}  // namespace webf