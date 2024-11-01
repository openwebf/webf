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
#include "foundation/native_value.h"
#include "qjs_engine_patch.h"

namespace webf {

class ExecutingContext;
class WrapperTypeInfo;
struct NativeValue;
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
  // Create an undefined ScriptValue;
  static ScriptValue Undefined(JSContext* ctx);
  // Wrap an Quickjs JSValue to ScriptValue.
  explicit ScriptValue(JSContext* ctx, JSValue value) : value_(JS_DupValue(ctx, value)), runtime_(JS_GetRuntime(ctx)){};
  explicit ScriptValue(JSContext* ctx, const AtomicString& value)
      : value_(JS_AtomToString(ctx, value.Impl())), runtime_(JS_GetRuntime(ctx)){};
  explicit ScriptValue(JSContext* ctx, const SharedNativeString* string)
      : value_(JS_NewUnicodeString(ctx, string->string(), string->length())), runtime_(JS_GetRuntime(ctx)) {}
  explicit ScriptValue(JSContext* ctx, double v) : value_(JS_NewFloat64(ctx, v)), runtime_(JS_GetRuntime(ctx)) {}
  explicit ScriptValue(JSContext* ctx) : runtime_(JS_GetRuntime(ctx)){};
  explicit ScriptValue(JSContext* ctx, const NativeValue& native_value, bool shared_js_value = false);
  ScriptValue() = default;

  // Copy and assignment
  ScriptValue(ScriptValue const& value);
  ScriptValue& operator=(const ScriptValue& value);

  // Move operations
  ScriptValue(ScriptValue&& value) noexcept;
  ScriptValue& operator=(ScriptValue&& value) noexcept;

  ~ScriptValue() { JS_FreeValueRT(runtime_, value_); };

  JSValue QJSValue() const;
  // Create a new ScriptValue from call JSON.stringify to current value.
  ScriptValue ToJSONStringify(JSContext* ctx, ExceptionState* exception) const;
  AtomicString ToString(JSContext* ctx) const;
  AtomicString ToLegacyDOMString(JSContext* ctx) const;
  std::unique_ptr<SharedNativeString> ToNativeString(JSContext* ctx) const;
  NativeValue ToNative(JSContext* ctx, ExceptionState& exception_state, bool shared_js_value = false) const;

  double ToDouble(JSContext* ctx) const;

  bool IsException() const;
  bool IsEmpty() const;
  bool IsObject() const;
  bool IsString() const;
  bool IsNull() const;
  bool IsUndefined() const;
  bool IsBool() const;
  bool IsNumber() const;

  void Trace(GCVisitor* visitor) const;

 private:
  JSRuntime* runtime_{nullptr};
  JSValue value_{JS_NULL};
};

template <typename T, typename SFINAEHelper = void>
class ScriptValueConverter {
  using ImplType = T;
};

}  // namespace webf

#endif  // BRIDGE_SCRIPT_VALUE_H
