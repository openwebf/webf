/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_RESOLVER_H_
#define BRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_RESOLVER_H_

#include "converter_impl.h"
#include "to_quickjs.h"

namespace webf {

class GCVisitor;

class ScriptPromiseResolver {
 public:
  static std::shared_ptr<ScriptPromiseResolver> Create(ExecutingContext* context);
  ScriptPromiseResolver() = delete;
  ScriptPromiseResolver(ExecutingContext* context);
  ~ScriptPromiseResolver();

  void Reset();

  FORCE_INLINE bool isAlive() const {
    return context_ != nullptr && context_->IsContextValid() && context_->IsCtxValid();
  }
  FORCE_INLINE ExecutingContext* context() const { return context_; }

  // Return a promise object and wait to be resolve or reject.
  // Note that an empty ScriptPromise will be returned after resolve or
  // reject is called.
  ScriptPromise Promise();

  // Anything that can be passed to toQuickJS can be passed to this function.
  template <typename T>
  void Resolve(T value) {
    ResolveOrReject(value, kResolving);
  }

  void Resolve(JSValue value) { ResolveOrReject(value, kResolving); }

  // Anything that can be passed to toQuickJS can be passed to this function.
  template <typename T>
  void Reject(T value) {
    ResolveOrReject(value, kRejecting);
  }

  void Reject(JSValue value) { ResolveOrReject(value, kRejecting); }

  void Trace(GCVisitor* visitor) const;

 private:
  enum ResolutionState {
    kPending,
    kResolving,
    kRejecting,
    kDetached,
  };

  ExecutingContext* GetExecutionContext() const { return context_; }

  template <typename T>
  void ResolveOrReject(T value, ResolutionState new_state) {
    JSValue qjs_value = toQuickJS(context_->ctx(), value);
    ResolveOrReject(qjs_value, new_state);
    JS_FreeValue(context_->ctx(), qjs_value);
  }

  void ResolveOrReject(JSValue value, ResolutionState new_state) {
    if (state_ != kPending || !context_->IsContextValid() || !context_)
      return;
    assert(new_state == kResolving || new_state == kRejecting);
    state_ = new_state;
    ResolveOrRejectImmediately(value);
  }

  void ResolveOrRejectImmediately(JSValue value);

  ResolutionState state_;
  ExecutingContext* context_{nullptr};
  JSValue promise_{JS_NULL};
  JSValue resolve_func_{JS_NULL};
  JSValue reject_func_{JS_NULL};
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_RESOLVER_H_
