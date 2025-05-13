/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_H_
#define BRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_H_

#include <quickjs/quickjs.h>
#include "foundation/macros.h"
#include "qjs_function.h"
#include "script_value.h"

namespace webf {

// ScriptPromise is the class for representing Promise values in C++ world.
// ScriptPromise holds a Promise.
// So holding a ScriptPromise as a member variable in DOM object causes
// memory leaks since it has a reference from C++ to QuickJS.
class ScriptPromise final {
  WEBF_DISALLOW_NEW();

 public:
  ScriptPromise() = default;
  ScriptPromise(JSContext* ctx, JSValue promise);
  ScriptPromise(JSContext* ctx, std::shared_ptr<QJSFunction>* resolve_func, std::shared_ptr<QJSFunction>* reject_func);

  JSValue ToQuickJS();
  ScriptValue ToValue() const;

  void Trace(GCVisitor* visitor);

 private:
  JSContext* ctx_{nullptr};
  ScriptValue promise_;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_H_
