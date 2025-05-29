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

static JSValue CreateJSFunctionWithFinalizerCallback(JSRuntime* runtime,
                                                     JSContext* ctx,
                                                     JSClassCall callback_fn,
                                                     JSClassGCMark mark_fn,
                                                     JSClassFinalizer finalized_fn,
                                                     void* private_data) {
  JSClassDef def{};
  def.class_name = "fn";
  def.call = callback_fn;
  def.gc_mark = mark_fn;
  def.finalizer = finalized_fn;

  JSClassID class_id = 0;
  JS_NewClassID(&class_id);

  JS_NewClass(runtime, class_id, &def);

  JSValue function = JS_NewObjectClass(ctx, class_id);
  JS_SetOpaque(function, private_data);

  return function;
}

static JSValue HandleQJSFunctionCallback(JSContext* ctx,
                                         JSValueConst func_obj,
                                         JSValueConst this_val,
                                         int argc,
                                         JSValueConst* argv,
                                         int flags) {
  auto* callback_context = static_cast<QJSFunctionCallbackContext*>(JS_GetOpaque(func_obj, JS_GetClassID(func_obj)));
  std::vector<ScriptValue> arguments;
  arguments.reserve(argc);
  for (int i = 0; i < argc; i++) {
    arguments.emplace_back(ScriptValue(ctx, argv[i]));
  }
  ScriptValue result = callback_context->qjs_function_callback(ctx, ScriptValue(ctx, this_val), argc, arguments.data(),
                                                               callback_context->private_data);
  return JS_DupValue(ctx, result.QJSValue());
}

QJSFunction::QJSFunction(JSContext* ctx,
                         QJSFunctionCallback qjs_function_callback,
                         int32_t length,
                         void* private_data,
                         JSClassGCMark gc_mark,
                         JSClassFinalizer gc_finalizer)
    : ctx_(ctx), runtime_(JS_GetRuntime(ctx)) {
  auto* context = new QJSFunctionCallbackContext{qjs_function_callback, private_data};
  function_ =
      CreateJSFunctionWithFinalizerCallback(runtime_, ctx, HandleQJSFunctionCallback, gc_mark, gc_finalizer, context);
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

  JSValue returnValue = JS_Call(ctx, function_, JS_IsNull(this_val_) ? this_val.QJSValue() : this_val_, argc, argv);

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
