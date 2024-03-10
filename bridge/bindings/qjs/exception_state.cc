/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "exception_state.h"

namespace webf {

void ExceptionState::ThrowException(JSContext* ctx, ErrorType type, const std::string& message) {
  switch (type) {
    case ErrorType::TypeError:
      exception_ = JS_ThrowTypeError(ctx, "%s", message.c_str());
      break;
    case InternalError:
      exception_ = JS_ThrowInternalError(ctx, "%s", message.c_str());
      break;
    case RangeError:
      exception_ = JS_ThrowRangeError(ctx, "%s", message.c_str());
      break;
    case ReferenceError:
      exception_ = JS_ThrowReferenceError(ctx, "%s", message.c_str());
      break;
    case SyntaxError:
      exception_ = JS_ThrowSyntaxError(ctx, "%s", message.c_str());
      break;
  }
}


bool ExceptionState::HasException() {
  return !JS_IsNull(exception_);
}

ExceptionState& ExceptionState::ReturnThis() {
  return *this;
}

JSValue ExceptionState::ToQuickJS() {
  return exception_;
}

JSValue ExceptionState::CurrentException(JSContext* ctx) {
  return JS_GetException(ctx);
}

}  // namespace webf
