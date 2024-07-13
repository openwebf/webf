/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "exception_state.h"

namespace webf {

void ExceptionState::ThrowException(v8::Isolate* ctx, ErrorType type, const std::string& message) {
  switch (type) {
    case ErrorType::TypeError:
//      exception_ = JS_ThrowTypeError(ctx, "%s", message.c_str());
      break;
    case InternalError:
//      exception_ = JS_ThrowInternalError(ctx, "%s", message.c_str());
      break;
    case RangeError:
//      exception_ = JS_ThrowRangeError(ctx, "%s", message.c_str());
      break;
    case ReferenceError:
//      exception_ = JS_ThrowReferenceError(ctx, "%s", message.c_str());
      break;
    case SyntaxError:
//      exception_ = JS_ThrowSyntaxError(ctx, "%s", message.c_str());
      break;
  }
}

void ExceptionState::ThrowException(v8::Isolate* ctx, v8::Local<v8::Value> exception) {
//  exception_ = JS_DupValue(ctx, exception);
}

bool ExceptionState::HasException() {
  return !exception_->IsNull();
}

ExceptionState& ExceptionState::ReturnThis() {
  return *this;
}

//  virtual v8::Local<v8::Value> ToV8() {
//    return ;
//  }

v8::Local<v8::Value> ExceptionState::CurrentException(v8::Isolate* ctx) {
//  return JS_GetException(ctx);
//return v8::Value;
}

}  // namespace webf
