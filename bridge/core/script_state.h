/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SCRIPT_STATE_H_
#define BRIDGE_CORE_SCRIPT_STATE_H_

#include <quickjs/quickjs.h>
#include "bindings/qjs/script_wrappable.h"

namespace webf {

// ScriptState is an abstraction class that holds all information about script
// execution (e.g., JSContext etc). If you need any info about the script execution, you're expected to
// pass around ScriptState in the code base. ScriptState is in a 1:1
// relationship with JSContext.
class ScriptState {
 public:
  ScriptState();
  ~ScriptState();

  inline bool Invalid() const { return !ctx_invalid_; }
  inline JSContext* ctx() {
    assert(!ctx_invalid_ && "GetExecutingContext has been released");
    return ctx_;
  }
  static JSRuntime* runtime();

 private:
  bool ctx_invalid_{false};
  JSContext* ctx_{nullptr};
};

}  // namespace webf

#endif  // BRIDGE_CORE_SCRIPT_STATE_H_
