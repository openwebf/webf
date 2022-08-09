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

JSValue ScriptPromise::ToQuickJS() {
  return JS_DupValue(ctx_, promise_.QJSValue());
}

void ScriptPromise::Trace(GCVisitor* visitor) {}

}  // namespace webf
