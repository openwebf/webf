/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_QJS_FUNCTION_H
#define BRIDGE_QJS_FUNCTION_H

#include "script_value.h"

namespace webf {

using QJSFunctionCallback = ScriptValue (*)(JSContext* ctx,
                                            const ScriptValue& this_val,
                                            uint32_t argc,
                                            const ScriptValue* argv,
                                            void* private_data);

// https://webidl.spec.whatwg.org/#dfn-callback-interface
// QJSFunction memory are auto managed by std::shared_ptr.
class QJSFunction {
 public:
  static std::shared_ptr<QJSFunction> Create(JSContext* ctx, JSValue function) {
    return std::make_shared<QJSFunction>(ctx, function);
  }
  static std::shared_ptr<QJSFunction> Create(JSContext* ctx,
                                             QJSFunctionCallback qjs_function_callback,
                                             int32_t length,
                                             void* private_data) {
    return std::make_shared<QJSFunction>(ctx, qjs_function_callback, length, private_data);
  }
  explicit QJSFunction(JSContext* ctx, JSValue function)
      : ctx_(ctx), runtime_(JS_GetRuntime(ctx)), function_(JS_DupValue(ctx, function)){};
  explicit QJSFunction(JSContext* ctx, QJSFunctionCallback qjs_function_callback, int32_t length, void* private_data);
  ~QJSFunction() { JS_FreeValueRT(runtime_, function_); }

  bool IsFunction(JSContext* ctx);

  JSValue ToQuickJS() { return JS_DupValue(ctx_, function_); };
  JSValue ToQuickJSUnsafe() { return function_; }

  // Performs "invoke".
  // https://webidl.spec.whatwg.org/#invoke-a-callback-function
  ScriptValue Invoke(JSContext* ctx, const ScriptValue& this_val, int32_t argc, ScriptValue* arguments);

  friend bool operator==(const QJSFunction& lhs, const QJSFunction& rhs) {
    return JS_VALUE_GET_PTR(lhs.function_) == JS_VALUE_GET_PTR(rhs.function_);
  };

  void Trace(GCVisitor* visitor) const;

 private:
  JSContext* ctx_{nullptr};
  JSRuntime* runtime_{nullptr};
  JSValue function_{JS_NULL};
};

}  // namespace webf

#endif  // BRIDGE_QJS_FUNCTION_H
