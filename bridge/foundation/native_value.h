/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_NATIVE_VALUE_H
#define BRIDGE_NATIVE_VALUE_H

#include <quickjs/list.h>
#include <quickjs/quickjs.h>
#include <cinttypes>
#include <string>
#include "bindings/qjs/native_string_utils.h"
#include "foundation/dart_readable.h"

namespace webf {

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
  TAG_UINT8_BYTES = 10,
  TAG_UNDEFINED = 11,
};

enum class JSPointerType {
  NativeBindingObject = 0,
  DOMMatrix = 1,
  BoundingClientRect = 2,
  TextMetrics = 3,
  Screen = 4,
  ComputedCSSStyleDeclaration = 5,
  DOMPoint = 6,
  CanvasGradient = 7,
  CanvasPattern = 8,
  NativeByteData = 9,
  Others = 10
};

class ExecutingContext;
class ExceptionState;
class ScriptValue;

// Exchange data struct between dart and C++
struct NativeValue : public DartReadable {
  union {
    int64_t int64;
    double float64;
    void* ptr;
  } u;
  uint32_t uint32;
  int32_t tag;
};

NativeValue Native_NewNull();
NativeValue Native_NewUndefined();
NativeValue Native_NewString(SharedNativeString* string);
NativeValue Native_NewCString(const std::string& string);
NativeValue Native_NewFloat64(double value);
NativeValue Native_NewBool(bool value);
NativeValue Native_NewInt64(int64_t value);
NativeValue Native_NewList(uint32_t argc, NativeValue* argv);
NativeValue Native_NewPtr(JSPointerType pointerType, void* ptr);
NativeValue Native_NewJSON(JSContext* ctx, const ScriptValue& value, ExceptionState& exception_state);
NativeValue Native_NewUint8Bytes(uint32_t length, uint8_t* bytes);

JSPointerType GetPointerTypeOfNativePointer(NativeValue native_value);

}  // namespace webf

#endif  // BRIDGE_NATIVE_VALUE_H
