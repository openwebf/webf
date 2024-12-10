/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_EXCEPTION_STATE_H_
#define WEBF_CORE_RUST_API_EXCEPTION_STATE_H_

#include <cinttypes>
#if WEBF_QUICKJS_JS_ENGINE
#include "bindings/qjs/exception_state.h"
#elif WEBF_V8_JS_ENGINE

#endif
#include "webf_value.h"

namespace webf {

class ExecutingContext;
class SharedExceptionState;

using PublicExceptionStateHasException = bool (*)(SharedExceptionState* shared_exception_state);
using PublicExceptionStateStringify = void (*)(ExecutingContext* context,
                                               SharedExceptionState* shared_exception_state,
                                               char** errmsg,
                                               uint32_t* strlen);

class ExceptionStatePublicMethods : public WebFPublicMethods {
  static bool HasException(SharedExceptionState* shared_exception_state);
  static void Stringify(ExecutingContext* context,
                        SharedExceptionState* shared_exception_state,
                        char** errmsg,
                        uint32_t* strlen);

  double version{1.0};
  PublicExceptionStateHasException has_exception_{HasException};
  PublicExceptionStateStringify stringify_{Stringify};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_EXCEPTION_STATE_H_
