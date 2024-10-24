/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_CANVAS_DOM_MATRIX_H_
#define WEBF_CORE_HTML_CANVAS_DOM_MATRIX_H_

#include "dom_matrix_readonly.h"

namespace webf {

class DOMMatrix : public DOMMatrixReadonly {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMMatrix*;
  static DOMMatrix* Create(ExecutingContext* context,
                           const std::vector<double>& init,
                           ExceptionState& exception_state);
  static DOMMatrix* Create(ExecutingContext* context,
                           ExceptionState& exception_state);

  DOMMatrix() = delete;
  explicit DOMMatrix(ExecutingContext* context,
                     ExceptionState& exception_state);
  explicit DOMMatrix(ExecutingContext* context,
                     const std::vector<double>& init,
                     ExceptionState& exception_state);
  explicit DOMMatrix(ExecutingContext* context,
                     NativeBindingObject* native_binding_object);

 private:
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_CANVAS_DOM_MATRIX_H_
