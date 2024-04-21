/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_EXCEPTION_STATE_H
#define BRIDGE_EXCEPTION_STATE_H

#include <v8/v8.h>
#include <string>
#include "foundation/macros.h"

#define ASSERT_NO_EXCEPTION() ExceptionState().ReturnThis()

namespace webf {

enum ErrorType { TypeError, InternalError, RangeError, ReferenceError, SyntaxError };

// ExceptionState is a scope-like class and provides a way to store an exception.
class ExceptionState {
  // ExceptionState should only allocate at stack.
  WEBF_DISALLOW_NEW();

 public:
  void ThrowException(v8::Isolate* ctx, ErrorType type, const std::string& message);
  void ThrowException(v8::Isolate* ctx, v8::Local<v8::Value> exception);
  bool HasException();

  ExceptionState& ReturnThis();

//  virtual v8::Local<v8::Value> ToV8() {
//    return exception_;
//  }
  static v8::Local<v8::Value> CurrentException(v8::Isolate* ctx);

 private:
  v8::Local<v8::Value> exception_;
};

}  // namespace webf

#endif  // BRIDGE_EXCEPTION_STATE_H
