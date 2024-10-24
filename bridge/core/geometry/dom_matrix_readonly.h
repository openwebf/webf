/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_
#define WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"

namespace webf {

class DOMMatrix;

class DOMMatrixReadonly : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMMatrixReadonly*;
  static DOMMatrixReadonly* Create(ExecutingContext* context,
                                   const std::vector<double>& init,
                                   ExceptionState& exception_state);
  static DOMMatrixReadonly* Create(ExecutingContext* context,
                                   ExceptionState& exception_state);
  DOMMatrixReadonly() = delete;
  explicit DOMMatrixReadonly(ExecutingContext* context,
                             const std::vector<double>& init,
                             ExceptionState& exception_state);
  explicit DOMMatrixReadonly(ExecutingContext* context,
                                 ExceptionState& exception_state);

  DOMMatrix* flipX(ExceptionState& exception_state);
  // DOMMatrix* flipY(ExceptionState& exception_state);

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;
};

}  // namespace webf

#endif  // WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_
