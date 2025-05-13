/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "script_promise_resolver.h"
#include "core/executing_context.h"

namespace webf {

std::shared_ptr<ScriptPromiseResolver> ScriptPromiseResolver::Create(ExecutingContext* context) {
  return std::make_shared<ScriptPromiseResolver>(context);
}

ScriptPromiseResolver::ScriptPromiseResolver(ExecutingContext* context)
    : context_(context), state_(ResolutionState::kPending), context_id_(context->contextId()) {
  JSValue resolving_funcs[2];
  promise_ = JS_NewPromiseCapability(context->ctx(), resolving_funcs);
  resolve_func_ = resolving_funcs[0];
  reject_func_ = resolving_funcs[1];
}

ScriptPromiseResolver::~ScriptPromiseResolver() {
  if (isContextValid(context_id_)) {
    Reset();
  }
}

void ScriptPromiseResolver::Reset() {
  JS_FreeValue(context_->ctx(), promise_);
  JS_FreeValue(context_->ctx(), resolve_func_);
  JS_FreeValue(context_->ctx(), reject_func_);
  context_ = nullptr;
}

void ScriptPromiseResolver::Trace(GCVisitor* visitor) const {
  visitor->TraceValue(promise_);
  visitor->TraceValue(resolve_func_);
  visitor->TraceValue(reject_func_);
}

ScriptPromise ScriptPromiseResolver::Promise() {
  if (context_ == nullptr)
    return {};
  return {context_->ctx(), promise_};
}

void ScriptPromiseResolver::ResolveOrRejectImmediately(JSValue value) {
  if (context_ == nullptr)
    return;
  context_->dartIsolateContext()->profiler()->StartTrackAsyncEvaluation();
  {
    if (state_ == kResolving) {
      JSValue arguments[] = {value};
      JSValue return_value = JS_Call(context_->ctx(), resolve_func_, JS_NULL, 1, arguments);
      if (JS_IsException(return_value)) {
        context_->HandleException(&return_value);
      }
      JS_FreeValue(context_->ctx(), return_value);
    } else {
      assert(state_ == kRejecting);
      JSValue arguments[] = {value};
      JSValue return_value = JS_Call(context_->ctx(), reject_func_, JS_NULL, 1, arguments);
      if (JS_IsException(return_value)) {
        context_->HandleException(&return_value);
      }
      JS_FreeValue(context_->ctx(), return_value);
    }
  }
  context_->DrainMicrotasks();
  context_->dartIsolateContext()->profiler()->FinishTrackAsyncEvaluation();
}

}  // namespace webf
