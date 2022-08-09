/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKENBRIDGE_GC_VISITOR_H
#define KRAKENBRIDGE_GC_VISITOR_H

#include <bindings/qjs/script_wrappable.h>
#include <quickjs/quickjs.h>

#include "foundation/macros.h"
#include "member.h"

namespace kraken {

class ScriptWrappable;

// Use GCVisitor to keep track gc managed members in C++ class.
class GCVisitor final {
  KRAKEN_DISALLOW_NEW();
  KRAKEN_DISALLOW_IMPLICIT_CONSTRUCTORS(GCVisitor);

 public:
  explicit GCVisitor(JSRuntime* rt, JS_MarkFunc* markFunc) : runtime_(rt), markFunc_(markFunc){};

  template <typename T>
  void Trace(const Member<T>& target) {
    if (target.Get() != nullptr) {
      JS_MarkValue(runtime_, target.Get()->jsObject_, markFunc_);
    }
  };

  void Trace(JSValue value);

 private:
  JSRuntime* runtime_{nullptr};
  JS_MarkFunc* markFunc_{nullptr};
  friend class ScriptWrappable;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_GC_VISITOR_H
