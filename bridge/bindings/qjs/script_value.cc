/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "script_value.h"
#include <vector>
#include "bindings/qjs/converter_impl.h"
#include "core/binding_object.h"
#include "core/executing_context.h"
#include "cppgc/gc_visitor.h"
#include "foundation/native_value_converter.h"
#include "native_string_utils.h"
#include "qjs_bounding_client_rect.h"
#include "qjs_engine_patch.h"
#include "qjs_event_target.h"

namespace webf {

static JSValue FromNativeValue(ExecutingContext* context, const NativeValue& native_value) {
  switch (native_value.tag) {
    case NativeTag::TAG_STRING: {
      auto* string = static_cast<NativeString*>(native_value.u.ptr);
      if (string == nullptr)
        return JS_NULL;
      JSValue returnedValue = JS_NewUnicodeString(context->ctx(), string->string(), string->length());
      delete string;
      return returnedValue;
    }
    case NativeTag::TAG_INT: {
      return JS_NewInt64(context->ctx(), native_value.u.int64);
    }
    case NativeTag::TAG_BOOL: {
      return JS_NewBool(context->ctx(), native_value.u.int64 == 1);
    }
    case NativeTag::TAG_FLOAT64: {
      return JS_NewFloat64(context->ctx(), native_value.u.float64);
    }
    case NativeTag::TAG_NULL: {
      return JS_NULL;
    }
    case NativeTag::TAG_LIST: {
      size_t length = native_value.uint32;
      auto* arr = static_cast<NativeValue*>(native_value.u.ptr);
      JSValue array = JS_NewArray(context->ctx());
      JS_SetPropertyStr(context->ctx(), array, "length", Converter<IDLInt64>::ToValue(context->ctx(), length));
      for (int i = 0; i < length; i++) {
        JSValue value = FromNativeValue(context, arr[i]);
        JS_SetPropertyInt64(context->ctx(), array, i, value);
      }
      return array;
    }
    case NativeTag::TAG_JSON: {
      auto* str = static_cast<const char*>(native_value.u.ptr);
      JSValue returnedValue = JS_ParseJSON(context->ctx(), str, strlen(str), "");
      delete str;
      return returnedValue;
    }
    case NativeTag::TAG_POINTER: {
      auto* ptr = static_cast<NativeBindingObject*>(native_value.u.ptr);
      auto* binding_object = BindingObject::From(ptr);

      // Only eventTarget can be converted from nativeValue to JSValue.
      auto* event_target = DynamicTo<EventTarget>(binding_object);
      if (event_target) {
        return event_target->ToQuickJS();
      }

      return JS_NULL;
    }
  }
  return JS_NULL;
}

ScriptValue::ScriptValue(JSContext* ctx, const NativeValue& native_value)
    : ctx_(ctx), runtime_(JS_GetRuntime(ctx)), value_(FromNativeValue(ExecutingContext::From(ctx), native_value)) {}

ScriptValue ScriptValue::CreateErrorObject(JSContext* ctx, const char* errmsg) {
  JS_ThrowInternalError(ctx, "%s", errmsg);
  JSValue errorObject = JS_GetException(ctx);
  ScriptValue result = ScriptValue(ctx, errorObject);
  JS_FreeValue(ctx, errorObject);
  return result;
}

ScriptValue ScriptValue::CreateJsonObject(JSContext* ctx, const char* jsonString, size_t length) {
  JSValue jsonValue = JS_ParseJSON(ctx, jsonString, length, "");
  ScriptValue result = ScriptValue(ctx, jsonValue);
  JS_FreeValue(ctx, jsonValue);
  return result;
}

ScriptValue ScriptValue::Empty(JSContext* ctx) {
  return ScriptValue(ctx);
}

ScriptValue::ScriptValue(const ScriptValue& value) {
  if (&value != this) {
    value_ = JS_DupValue(ctx_, value.value_);
  }
  ctx_ = value.ctx_;
}
ScriptValue& ScriptValue::operator=(const ScriptValue& value) {
  if (&value != this) {
    value_ = JS_DupValue(ctx_, value.value_);
  }
  ctx_ = value.ctx_;
  return *this;
}

ScriptValue::ScriptValue(ScriptValue&& value) noexcept {
  if (&value != this) {
    value_ = JS_DupValue(ctx_, value.value_);
  }
  ctx_ = value.ctx_;
}
ScriptValue& ScriptValue::operator=(ScriptValue&& value) noexcept {
  if (&value != this) {
    value_ = JS_DupValue(ctx_, value.value_);
  }
  ctx_ = value.ctx_;
  return *this;
}

JSValue ScriptValue::QJSValue() const {
  return value_;
}

ScriptValue ScriptValue::ToJSONStringify(ExceptionState* exception) const {
  JSValue stringifyed = JS_JSONStringify(ctx_, value_, JS_NULL, JS_NULL);
  ScriptValue result = ScriptValue(ctx_, stringifyed);
  // JS_JSONStringify may return JS_EXCEPTION if object is not valid. Return JS_EXCEPTION and let quickjs to handle it.
  if (result.IsException()) {
    exception->ThrowException(ctx_, result.value_);
    result = ScriptValue::Empty(ctx_);
  }
  JS_FreeValue(ctx_, stringifyed);
  return result;
}

AtomicString ScriptValue::ToString() const {
  return {ctx_, value_};
}

std::unique_ptr<NativeString> ScriptValue::ToNativeString() const {
  return ToString().ToNativeString(ctx_);
}

NativeValue ScriptValue::ToNative(ExceptionState& exception_state) const {
  int8_t tag = JS_VALUE_GET_TAG(value_);

  switch (tag) {
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      return Native_NewNull();
    case JS_TAG_BOOL:
      return Native_NewBool(JS_ToBool(ctx_, value_));
    case JS_TAG_FLOAT64: {
      double v;
      JS_ToFloat64(ctx_, &v, value_);
      return Native_NewFloat64(v);
    }
    case JS_TAG_INT: {
      int32_t v;
      JS_ToInt32(ctx_, &v, value_);
      return Native_NewInt64(v);
    }
    case JS_TAG_STRING:
      // NativeString owned by NativeValue will be freed by users.
      return NativeValueConverter<NativeTypeString>::ToNativeValue(ctx_, ToString());
    case JS_TAG_OBJECT: {
      if (JS_IsArray(ctx_, value_)) {
        std::vector<ScriptValue> values =
            Converter<IDLSequence<IDLAny>>::FromValue(ctx_, value_, ASSERT_NO_EXCEPTION());
        auto* result = new NativeValue[values.size()];
        for (int i = 0; i < values.size(); i++) {
          result[i] = values[i].ToNative(exception_state);
        }
        return Native_NewList(values.size(), result);
      } else if (JS_IsObject(value_)) {
        if (QJSEventTarget::HasInstance(ExecutingContext::From(ctx_), value_)) {
          auto* event_target = toScriptWrappable<EventTarget>(value_);
          return Native_NewPtr(JSPointerType::Others, event_target->bindingObject());
        }
        return NativeValueConverter<NativeTypeJSON>::ToNativeValue(*this, exception_state);
      }
    }
    default:
      return Native_NewNull();
  }
}

bool ScriptValue::IsException() const {
  return JS_IsException(value_);
}

bool ScriptValue::IsEmpty() const {
  return JS_IsNull(value_) || JS_IsUndefined(value_);
}

bool ScriptValue::IsObject() const {
  return JS_IsObject(value_);
}

bool ScriptValue::IsString() const {
  return JS_IsString(value_);
}

bool ScriptValue::IsNull() const {
  return JS_IsNull(value_);
}

bool ScriptValue::IsUndefined() const {
  return JS_IsUndefined(value_);
}

bool ScriptValue::IsBool() const {
  return JS_IsBool(value_);
}

void ScriptValue::Trace(GCVisitor* visitor) const {
  visitor->Trace(value_);
}

}  // namespace webf
