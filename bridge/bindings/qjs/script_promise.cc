/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "script_promise.h"
#include "qjs_engine_patch.h"

namespace webf {

ScriptPromise::ScriptPromise(JSContext* ctx, JSValue promise) : ctx_(ctx) {
  if (JS_IsUndefined(promise) || JS_IsNull(promise))
    return;

  if (!JS_IsPromise(promise)) {
    return;
  }

  promise_ = ScriptValue(ctx, promise);
}

ScriptPromise::ScriptPromise(JSContext* ctx,
                             std::shared_ptr<QJSFunction>* resolve_func,
                             std::shared_ptr<QJSFunction>* reject_func) {
  JSValue resolving_funcs[2];
  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);

  *resolve_func = QJSFunction::Create(ctx, resolving_funcs[0]);
  *reject_func = QJSFunction::Create(ctx, resolving_funcs[1]);

  promise_ = ScriptValue(ctx, promise);
}

JSValue ScriptPromise::ToQuickJS() {
  if (ctx_ == nullptr)
    return JS_NULL;
  return JS_DupValue(ctx_, promise_.QJSValue());
}

ScriptValue ScriptPromise::ToValue() const {
  return promise_;
}

void ScriptPromise::Trace(GCVisitor* visitor) {}

}  // namespace webf
