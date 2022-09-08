/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "qjs_function.h"
#include <algorithm>
#include "cppgc/gc_visitor.h"

namespace webf {

bool QJSFunction::IsFunction(JSContext* ctx) {
  return JS_IsFunction(ctx, function_);
}

ScriptValue QJSFunction::Invoke(JSContext* ctx, const ScriptValue& this_val, int32_t argc, ScriptValue* arguments) {
  // 'm_function' might be destroyed when calling itself (if it frees the handler), so must take extra care.
  JS_DupValue(ctx, function_);

  JSValue argv[std::max(1, argc)];

  for (int i = 0; i < argc; i++) {
    argv[0 + i] = arguments[i].QJSValue();
  }

  JSValue returnValue = JS_Call(ctx, function_, this_val.QJSValue(), argc, argv);

  // Free the previous duplicated function.
  JS_FreeValue(ctx, function_);

  ScriptValue result = ScriptValue(ctx, returnValue);
  JS_FreeValue(ctx, returnValue);
  return result;
}

void QJSFunction::Trace(GCVisitor* visitor) const {
  visitor->Trace(function_);
}

}  // namespace webf
