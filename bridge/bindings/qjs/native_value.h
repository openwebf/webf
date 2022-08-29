/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_NATIVE_VALUE_H
#define BRIDGE_NATIVE_VALUE_H

#include "executing_context.h"

enum NativeTag {
  TAG_STRING = 0,
  TAG_INT = 1,
  TAG_BOOL = 2,
  TAG_NULL = 3,
  TAG_FLOAT64 = 4,
  TAG_JSON = 5,
  TAG_LIST = 6,
  TAG_POINTER = 7,
  TAG_FUNCTION = 8,
  TAG_ASYNC_FUNCTION = 9,
};

enum class JSPointerType { AsyncContextContext = 0, NativeFunctionContext = 1, NativeBoundingClientRect = 2, NativeCanvasRenderingContext2D = 3, NativeBindingObject = 4 };

namespace webf::binding::qjs {

// Exchange data struct between dart and C++
struct NativeValue {
  union {
    uint64_t uint64;
    double float64;
  } u;
  int64_t int64;
  int64_t tag;
};

struct NativeFunctionContext;

using CallNativeFunction = void (*)(NativeFunctionContext* functionContext, int32_t argc, NativeValue* argv, NativeValue* returnValue);

static void call_native_function(NativeFunctionContext* functionContext, int32_t argc, NativeValue* argv, NativeValue* returnValue);

struct NativeFunctionContext {
  CallNativeFunction call;
  NativeFunctionContext(ExecutionContext* context, JSValue callback);
  ~NativeFunctionContext();
  JSValue m_callback{JS_NULL};
  ExecutionContext* m_context{nullptr};
  JSContext* m_ctx{nullptr};
  list_head link;
};

NativeValue Native_NewNull();
NativeValue Native_NewString(NativeString* string);
NativeValue Native_NewCString(std::string string);
NativeValue Native_NewFloat64(double value);
NativeValue Native_NewBool(bool value);
NativeValue Native_NewInt32(int32_t value);
NativeValue Native_NewPtr(JSPointerType pointerType, void* ptr);
NativeValue Native_NewJSON(ExecutionContext* context, JSValue& value);
NativeValue jsValueToNativeValue(JSContext* ctx, JSValue& value);
JSValue nativeValueToJSValue(ExecutionContext* context, NativeValue& value);

std::string nativeStringToStdString(NativeString* nativeString);

}  // namespace webf::binding::qjs

#endif  // BRIDGE_NATIVE_VALUE_H
