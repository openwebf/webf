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
  static DOMMatrix* Create(ExecutingContext* context,
                           const std::shared_ptr<QJSUnionDomStringSequenceDouble>& init,
                           ExceptionState& exception_state);

  DOMMatrix() = delete;
  explicit DOMMatrix(ExecutingContext* context,
                     const std::shared_ptr<QJSUnionDomStringSequenceDouble>& init,
                     ExceptionState& exception_state);

 private:
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_CANVAS_DOM_MATRIX_H_
