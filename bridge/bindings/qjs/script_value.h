/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_SCRIPT_VALUE_H
#define BRIDGE_SCRIPT_VALUE_H

#include <quickjs/quickjs.h>
#include <memory>

#include "atomic_string.h"
#include "exception_state.h"
#include "foundation/macros.h"
#include "foundation/native_string.h"
#include "qjs_engine_patch.h"

namespace webf {

class ExecutingContext;
class WrapperTypeInfo;
class NativeValue;
class GCVisitor;

// ScriptValue is a stack allocate only QuickJS JSValue wrapper ScriptValuewhich hold all information to hide out
// QuickJS running details.
class ScriptValue final {
  // ScriptValue should only allocate at stack.
  WEBF_DISALLOW_NEW();

 public:
  // Create an errorObject from string error message.
  static ScriptValue CreateErrorObject(JSContext* ctx, const char* errmsg);
  // Create an object from JSON string.
  static ScriptValue CreateJsonObject(JSContext* ctx, const char* jsonString, size_t length);

  // Create an empty ScriptValue;
  static ScriptValue Empty(JSContext* ctx);
  // Wrap an Quickjs JSValue to ScriptValue.
  explicit ScriptValue(JSContext* ctx, JSValue value)
      : ctx_(ctx), value_(JS_DupValue(ctx, value)), runtime_(JS_GetRuntime(ctx)){};
  explicit ScriptValue(JSContext* ctx, const NativeString* string)
      : ctx_(ctx), value_(JS_NewUnicodeString(ctx, string->string(), string->length())), runtime_(JS_GetRuntime(ctx)) {}
  explicit ScriptValue(JSContext* ctx, double v)
      : ctx_(ctx), value_(JS_NewFloat64(ctx, v)), runtime_(JS_GetRuntime(ctx)) {}
  explicit ScriptValue(JSContext* ctx) : ctx_(ctx), runtime_(JS_GetRuntime(ctx)){};
  explicit ScriptValue(JSContext* ctx, const NativeValue& native_value);
  ScriptValue() = default;

  // Copy and assignment
  ScriptValue(ScriptValue const& value);
  ScriptValue& operator=(const ScriptValue& value);

  // Move operations
  ScriptValue(ScriptValue&& value) noexcept;
  ScriptValue& operator=(ScriptValue&& value) noexcept;

  ~ScriptValue() { JS_FreeValue(ctx_, value_); };

  JSValue QJSValue() const;
  // Create a new ScriptValue from call JSON.stringify to current value.
  ScriptValue ToJSONStringify(ExceptionState* exception) const;
  AtomicString ToString() const;
  std::unique_ptr<NativeString> ToNativeString() const;
  NativeValue ToNative(ExceptionState& exception_state) const;

  bool IsException() const;
  bool IsEmpty() const;
  bool IsObject() const;
  bool IsString() const;
  bool IsNull() const;
  bool IsUndefined() const;
  bool IsBool() const;

  void Trace(GCVisitor* visitor) const;

 private:
  JSContext* ctx_{nullptr};
  JSRuntime* runtime_{nullptr};
  JSValue value_{JS_NULL};
};

template <typename T, typename SFINAEHelper = void>
class ScriptValueConverter {
  using ImplType = T;
};

}  // namespace webf

#endif  // BRIDGE_SCRIPT_VALUE_H
