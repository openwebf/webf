/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_
#define WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "qjs_union_dom_string_sequencedouble.h"

namespace webf {

class DOMMatrixReadonly : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = DOMMatrixReadonly*;
  static DOMMatrixReadonly* Create(ExecutingContext* context,
                                   const std::shared_ptr<QJSUnionDomStringSequenceDouble>& init,
                                   ExceptionState& exception_state);

  DOMMatrixReadonly() = delete;
  explicit DOMMatrixReadonly(ExecutingContext* context,
                             const std::shared_ptr<QJSUnionDomStringSequenceDouble>& init,
                             ExceptionState& exception_state);

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;
};

}  // namespace webf

#endif  // WEBF_CORE_GEOMETRY_DOM_MATRIX_READONLY_H_
