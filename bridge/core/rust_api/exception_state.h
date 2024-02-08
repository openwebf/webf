/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_EXCEPTION_STATE_H_
#define WEBF_CORE_RUST_API_EXCEPTION_STATE_H_

#include <cinttypes>
#include "bindings/qjs/exception_state.h"
#include "core/rust_api/rust_value.h"

namespace webf {

typedef struct ExecutingContext ExecutingContext;

struct SharedExceptionState {
  webf::ExceptionState exception_state;
};

using RustExceptionStateHasException = bool (*)(SharedExceptionState* shared_exception_state);
using RustExceptionStateStringify = void (*)(ExecutingContext* context,
                                             SharedExceptionState* shared_exception_state,
                                             char** errmsg,
                                             uint32_t* strlen);

struct ExceptionStateRustMethods : public RustMethods {
  static bool HasException(SharedExceptionState* shared_exception_state);
  static void Stringify(ExecutingContext* context,
                        SharedExceptionState* shared_exception_state,
                        char** errmsg,
                        uint32_t* strlen);

  double version{1.0};
  RustExceptionStateHasException has_exception_{HasException};
  RustExceptionStateStringify stringify_{Stringify};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_EXCEPTION_STATE_H_
