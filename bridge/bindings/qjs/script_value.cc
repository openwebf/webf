/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "script_value.h"
#include <quickjs/quickjs.h>
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

#if WIN32
#include <Windows.h>
#endif

namespace webf {

static JSValue FromNativeValue(ExecutingContext* context,
                               const NativeValue& native_value,
                               bool shared_js_value = false) {
  switch (native_value.tag) {
    case NativeTag::TAG_STRING: {
      if (shared_js_value) {
        auto* string = static_cast<SharedNativeString*>(native_value.u.ptr);
        if (string == nullptr)
          return JS_NULL;
        JSValue returnedValue = JS_NewUnicodeString(context->ctx(), string->string(), string->length());
        return returnedValue;
      } else {
        std::unique_ptr<AutoFreeNativeString> string{static_cast<AutoFreeNativeString*>(native_value.u.ptr)};
        if (string == nullptr)
          return JS_NULL;
        JSValue returnedValue = JS_NewUnicodeString(context->ctx(), string->string(), string->length());
        return returnedValue;
      }
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
    case NativeTag::TAG_UINT8_BYTES: {
      auto free_func = [](JSRuntime* rt, void* opaque, void* ptr) {
#if WIN32
        return CoTaskMemFree(ptr);
#else
        return free(ptr);
#endif
      };

      return JS_NewArrayBuffer(context->ctx(), (uint8_t*)native_value.u.ptr, native_value.uint32, free_func, nullptr,
                               0);
    }
    case NativeTag::TAG_LIST: {
      size_t length = native_value.uint32;
      auto* arr = static_cast<NativeValue*>(native_value.u.ptr);
      JSValue array = JS_NewArray(context->ctx());
      JS_SetPropertyStr(context->ctx(), array, "length", Converter<IDLInt64>::ToValue(context->ctx(), length));
      for (int i = 0; i < length; i++) {
        JSValue value = FromNativeValue(context, arr[i], shared_js_value);
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
      auto pointer_type = static_cast<JSPointerType>(native_value.uint32);

      switch (pointer_type) {
        case JSPointerType::NativeBindingObject: {
          auto* binding_object = BindingObject::From(ptr);
          // Only eventTarget can be converted from nativeValue to JSValue.
          auto* event_target = DynamicTo<EventTarget>(binding_object);
          if (event_target) {
            return event_target->ToQuickJS();
          }
          break;
        }
        case JSPointerType::Others: {
          return JS_DupValue(context->ctx(), JS_MKPTR(JS_TAG_OBJECT, ptr));
        }
      }
      return JS_NULL;
    }
  }
  return JS_NULL;
}

ScriptValue::ScriptValue(JSContext* ctx, const NativeValue& native_value, bool shared_js_value)
    : runtime_(JS_GetRuntime(ctx)),
      value_(FromNativeValue(ExecutingContext::From(ctx), native_value, shared_js_value)) {}

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

ScriptValue ScriptValue::Undefined(JSContext* ctx) {
  return ScriptValue(ctx, JS_UNDEFINED);
}

ScriptValue::ScriptValue(const ScriptValue& value) {
  if (&value != this) {
    value_ = JS_DupValueRT(runtime_, value.value_);
  }
  runtime_ = value.runtime_;
}
ScriptValue& ScriptValue::operator=(const ScriptValue& value) {
  if (&value != this) {
    JS_FreeValueRT(runtime_, value_);
    value_ = JS_DupValueRT(runtime_, value.value_);
  }
  runtime_ = value.runtime_;
  return *this;
}

ScriptValue::ScriptValue(ScriptValue&& value) noexcept {
  if (&value != this) {
    value_ = JS_DupValueRT(runtime_, value.value_);
  }
  runtime_ = value.runtime_;
}
ScriptValue& ScriptValue::operator=(ScriptValue&& value) noexcept {
  if (&value != this) {
    JS_FreeValueRT(runtime_, value_);
    value_ = JS_DupValueRT(runtime_, value.value_);
  }
  runtime_ = value.runtime_;
  return *this;
}

JSValue ScriptValue::QJSValue() const {
  return value_;
}

ScriptValue ScriptValue::ToJSONStringify(JSContext* ctx, ExceptionState* exception) const {
  JSValue stringifyed = JS_JSONStringify(ctx, value_, JS_NULL, JS_NULL);
  ScriptValue result = ScriptValue(ctx, stringifyed);
  // JS_JSONStringify may return JS_EXCEPTION if object is not valid. Return JS_EXCEPTION and let quickjs to handle it.
  if (result.IsException()) {
    exception->ThrowException(ctx, result.value_);
    result = ScriptValue::Empty(ctx);
  }
  JS_FreeValue(ctx, stringifyed);
  return result;
}

AtomicString ScriptValue::ToString(JSContext* ctx) const {
  return {ctx, value_};
}

AtomicString ScriptValue::ToLegacyDOMString(JSContext* ctx) const {
  if (JS_IsNull(value_)) {
    return AtomicString::Empty();
  }
  return {ctx, value_};
}

std::unique_ptr<SharedNativeString> ScriptValue::ToNativeString(JSContext* ctx) const {
  return ToString(ctx).ToNativeString();
}

NativeValue ScriptValue::ToNative(JSContext* ctx, ExceptionState& exception_state, bool shared_js_value) const {
  int8_t tag = JS_VALUE_GET_TAG(value_);

  switch (tag) {
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      return Native_NewNull();
    case JS_TAG_BOOL:
      return Native_NewBool(JS_ToBool(ctx, value_));
    case JS_TAG_FLOAT64: {
      double v;
      JS_ToFloat64(ctx, &v, value_);
      return Native_NewFloat64(v);
    }
    case JS_TAG_INT: {
      int32_t v;
      JS_ToInt32(ctx, &v, value_);
      return Native_NewInt64(v);
    }
    case JS_TAG_STRING:
      // NativeString owned by NativeValue will be freed by users.
      return NativeValueConverter<NativeTypeString>::ToNativeValue(ctx, ToString(ctx));
    case JS_TAG_OBJECT: {
      if (JS_IsArray(ctx, value_)) {
        std::vector<ScriptValue> values = Converter<IDLSequence<IDLAny>>::FromValue(ctx, value_, ASSERT_NO_EXCEPTION());
        auto* result = new NativeValue[values.size()];
        for (int i = 0; i < values.size(); i++) {
          result[i] = values[i].ToNative(ctx, exception_state, shared_js_value);
        }
        return Native_NewList(values.size(), result);
      } else if (JS_IsObject(value_)) {
        if (QJSEventTarget::HasInstance(ExecutingContext::From(ctx), value_)) {
          auto* event_target = toScriptWrappable<EventTarget>(value_);
          return Native_NewPtr(JSPointerType::NativeBindingObject, event_target->bindingObject());
        }

        if (shared_js_value) {
          return Native_NewPtr(JSPointerType::Others, JS_VALUE_GET_PTR(value_));
        }

        return NativeValueConverter<NativeTypeJSON>::ToNativeValue(ctx, *this, exception_state);
      }
    }
    default:
      return Native_NewNull();
  }
}

double ScriptValue::ToDouble(JSContext* ctx) const {
  double v;
  JS_ToFloat64(ctx, &v, value_);
  return v;
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

bool ScriptValue::IsNumber() const {
  return JS_IsNumber(value_);
}

void ScriptValue::Trace(GCVisitor* visitor) const {
  visitor->TraceValue(value_);
}

}  // namespace webf
