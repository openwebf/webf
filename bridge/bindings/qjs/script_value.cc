/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "script_value.h"

#include <core/geometry/dom_matrix.h>
#include <core/geometry/dom_point.h>
#include <core/html/canvas/canvas_gradient.h>
#include <core/html/canvas/canvas_pattern.h>
#include <core/html/canvas/text_metrics.h>
#include <quickjs/quickjs.h>
#include <vector>
#include "bindings/qjs/converter_impl.h"
#include "core/binding_object.h"
#include "core/executing_context.h"
#include "cppgc/gc_visitor.h"
#include "foundation/native_byte_data.h"
#include "foundation/native_value_converter.h"
#include "native_string_utils.h"
#include "qjs_bounding_client_rect.h"
#include "qjs_engine_patch.h"
#include "qjs_event_target.h"

#if defined(_WIN32)
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
#if defined(_WIN32)
        return CoTaskMemFree(ptr);
#else
        return free(ptr);
#endif
      };

      return JS_NewArrayBuffer(context->ctx(), (uint8_t*)native_value.u.ptr, native_value.uint32, free_func, nullptr, 0);
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
        case JSPointerType::DOMMatrix: {
          return MakeGarbageCollected<DOMMatrix>(context, ptr)->ToQuickJS();
        }
        case JSPointerType::BoundingClientRect: {
          return MakeGarbageCollected<BoundingClientRect>(context, ptr)->ToQuickJS();
        }
        case JSPointerType::Screen: {
          return MakeGarbageCollected<Screen>(context, ptr)->ToQuickJS();
        }
        case JSPointerType::TextMetrics: {
          return MakeGarbageCollected<TextMetrics>(context, ptr)->ToQuickJS();
        }
        case JSPointerType::ComputedCSSStyleDeclaration: {
          return MakeGarbageCollected<ComputedCssStyleDeclaration>(context, ptr)->ToQuickJS();
        }
        case JSPointerType::DOMPoint: {
          return MakeGarbageCollected<DOMPoint>(context, ptr)->ToQuickJS();
        }
        case JSPointerType::CanvasGradient: {
          return MakeGarbageCollected<CanvasGradient>(context, ptr)->ToQuickJS();
        }
        case JSPointerType::CanvasPattern: {
          return MakeGarbageCollected<CanvasPattern>(context, ptr)->ToQuickJS();
        }
        case JSPointerType::Others: {
          return JS_DupValue(context->ctx(), JS_MKPTR(JS_TAG_OBJECT, ptr));
        }
        case JSPointerType::NativeByteData:
          break;
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
  return ToString(ctx).ToNativeString(ctx);
}

namespace {

struct NativeByteDataFinalizerContext {
  DartIsolateContext* dart_isolate_context;
  ExecutingContext* context;
  JSValue value;
};

}  // namespace

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
      if (JS_IsArrayBuffer(value_)) {
        size_t byte_len;
        uint8_t* bytes = JS_GetArrayBuffer(ctx, &byte_len, value_);

        auto* context = ExecutingContext::From(ctx);
        auto* finalizer_context = new NativeByteDataFinalizerContext();
        finalizer_context->dart_isolate_context = context->dartIsolateContext();
        finalizer_context->context = context;
        // Keep a reference for JSValue to protect the bytes from JavaScript GC.
        finalizer_context->value = JS_DupValue(ctx, value_);

        auto* native_byte_data = NativeByteData::Create(
            bytes, byte_len,
            [](void* raw_finalizer_ptr) {
              WEBF_LOG(VERBOSE) << " CALL NATIVE FINALIZER " << raw_finalizer_ptr;
              auto* finalizer_context = static_cast<NativeByteDataFinalizerContext*>(raw_finalizer_ptr);

              // Check if the JS context is alive.
              if (!finalizer_context->context->IsContextValid() || !finalizer_context->context->IsCtxValid()) {
                return;
              }

              auto* context = finalizer_context->context;
              bool is_dedicated = context->isDedicated();
              finalizer_context->dart_isolate_context->dispatcher()->PostToJs(
                  is_dedicated, context->contextId(),
                  [](NativeByteDataFinalizerContext* finalizer_context) {
                    // The context or ctx may be finalized during the thread switch
                    if (!finalizer_context->context->IsContextValid() || !finalizer_context->context->IsCtxValid()) {
                      return;
                    }

                    // Free the JSValue reference when the JS heap and context is alive.
                    JS_FreeValue(finalizer_context->context->ctx(), finalizer_context->value);
                  },
                  finalizer_context);
            },
            finalizer_context);

        return Native_NewPtr(JSPointerType::NativeByteData, native_byte_data);

      } else if (JS_IsArray(ctx, value_)) {
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
  visitor->TraceValue(value_);
}

}  // namespace webf
