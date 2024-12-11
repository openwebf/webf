/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "qjs_function.h"
#include <algorithm>
#include <vector>
#include "core/binding_object.h"
#include "core/dom/events/event_target.h"
#include "cppgc/gc_visitor.h"

namespace webf {

struct QJSFunctionCallbackContext {
  QJSFunctionCallback qjs_function_callback;
  void* private_data;
};

static JSValue HandleQJSFunctionCallback(JSContext* ctx,
                                         JSValueConst this_val,
                                         int argc,
                                         JSValueConst* argv,
                                         int magic,
                                         JSValue* func_data) {
  JSValue opaque_object = func_data[0];
  auto* callback_context = static_cast<QJSFunctionCallbackContext*>(JS_GetOpaque(opaque_object, JS_CLASS_OBJECT));
  std::vector<ScriptValue> arguments;
  arguments.reserve(argc);
  for (int i = 0; i < argc; i++) {
    arguments.emplace_back(ScriptValue(ctx, argv[i]));
  }
  ScriptValue result = callback_context->qjs_function_callback(ctx, ScriptValue(ctx, this_val), argc, arguments.data(),
                                                               callback_context->private_data);
  return JS_DupValue(ctx, result.QJSValue());
}

QJSFunction::QJSFunction(JSContext* ctx, QJSFunctionCallback qjs_function_callback, int32_t length, void* private_data)
    : ctx_(ctx), runtime_(JS_GetRuntime(ctx)) {
  JSValue opaque_object = JS_NewObject(ctx);
  auto* context = new QJSFunctionCallbackContext{qjs_function_callback, private_data};
  JS_SetOpaque(opaque_object, context);
  function_ = JS_NewCFunctionData(ctx, HandleQJSFunctionCallback, length, 0, 1, &opaque_object);
  JS_FreeValue(ctx, opaque_object);
}

bool QJSFunction::IsFunction(JSContext* ctx) {
  return JS_IsFunction(ctx, function_);
}

ScriptValue QJSFunction::Invoke(JSContext* ctx, const ScriptValue& this_val, int argc, ScriptValue* arguments) {
  // 'm_function' might be destroyed when calling itself (if it frees the handler), so must take extra care.
  JS_DupValue(ctx, function_);

  auto* argv = new JSValue[std::max(1, argc)];

  for (int i = 0; i < argc; i++) {
    argv[0 + i] = arguments[i].QJSValue();
  }

  ExecutingContext* context = ExecutingContext::From(ctx);
  context->dartIsolateContext()->profiler()->StartTrackSteps("JS_Call");

  JSValue returnValue = JS_Call(ctx, function_, JS_IsNull(this_val_) ? this_val.QJSValue() : this_val_, argc, argv);

  context->dartIsolateContext()->profiler()->FinishTrackSteps();

  context->DrainMicrotasks();

  // Free the previous duplicated function.
  JS_FreeValue(ctx, function_);

  ScriptValue result = ScriptValue(ctx, returnValue);
  JS_FreeValue(ctx, returnValue);
  return result;
}

void QJSFunction::Trace(GCVisitor* visitor) const {
  visitor->TraceValue(function_);
  visitor->TraceValue(this_val_);
}

}  // namespace webf
