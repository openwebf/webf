/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/exception_state.h"
#include "bindings/qjs/exception_state.h"
#include "core/api/exception_state.h"
#include "core/executing_context.h"

namespace webf {

SharedExceptionState::SharedExceptionState() = default;

bool ExceptionStatePublicMethods::HasException(SharedExceptionState* shared_exception_state) {
  return shared_exception_state->exception_state.HasException();
}

void ExceptionStatePublicMethods::Stringify(webf::ExecutingContext* context,
                                            webf::SharedExceptionState* shared_exception_state,
                                            char** errmsg,
                                            uint32_t* strlen) {
  context->HandleException(shared_exception_state->exception_state, errmsg, strlen);
}

}  // namespace webf