/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_NATIVE_NATIVE_FUNCTION_H_
#define WEBF_CORE_NATIVE_NATIVE_FUNCTION_H_

#include "foundation/casting.h"
#include "foundation/function.h"
#include "foundation/native_value.h"
#include "plugin_api/rust_readable.h"

namespace webf {

class SharedExceptionState;
typedef struct WebFNativeFunctionContext WebFNativeFunctionContext;

using WebFNativeFunctionCallback = NativeValue (*)(WebFNativeFunctionContext* callback_context,
                                            int32_t argc,
                                            NativeValue* argv,
                                            SharedExceptionState* shared_exception_state);
using WebFNativeFunctionFreePtrFn = void (*)(WebFNativeFunctionContext* callback_context);

struct WebFNativeFunctionContext : public RustReadable {
  WebFNativeFunctionCallback callback;
  WebFNativeFunctionFreePtrFn free_ptr;
  void* ptr;
};

class WebFNativeFunction : public Function {
 public:
  WebFNativeFunction(WebFNativeFunctionContext* callback_context, SharedExceptionState* shared_exception_state)
      : callback_context_(callback_context), shared_exception_state_(shared_exception_state) {}

  static const std::shared_ptr<WebFNativeFunction> Create(WebFNativeFunctionContext* callback_context,
                                                          SharedExceptionState* shared_exception_state) {
    return std::make_shared<WebFNativeFunction>(callback_context, shared_exception_state);
  }

  ~WebFNativeFunction() {
    callback_context_->free_ptr(callback_context_);
    delete callback_context_;
  }

  bool IsWebFNativeFunction() const override { return true; }

  NativeValue Invoke(ExecutingContext* context, int32_t argc, NativeValue* argv) {
    return callback_context_->callback(callback_context_, argc, argv, shared_exception_state_);
  }

 private:
  WebFNativeFunctionContext* callback_context_;
  SharedExceptionState* shared_exception_state_;
};

template <>
struct DowncastTraits<WebFNativeFunction> {
  static bool AllowFrom(const Function& function) { return function.IsWebFNativeFunction(); }
};

}  // namespace webf

#endif  // WEBF_CORE_NATIVE_NATIVE_FUNCTION_H_
