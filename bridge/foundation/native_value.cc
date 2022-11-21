/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "native_value.h"
#include "bindings/qjs/qjs_engine_patch.h"
#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"

namespace webf {

NativeValue Native_NewNull() {
  return (NativeValue){.u = {.int64 = 0}, .uint32 = 0, .tag = NativeTag::TAG_NULL};
}

NativeValue Native_NewString(NativeString* string) {
  return (NativeValue){
      .u = {.ptr = static_cast<void*>(string)},
      .uint32 = 0,
      .tag = NativeTag::TAG_STRING,
  };
}

NativeValue Native_NewCString(const std::string& string) {
  std::unique_ptr<NativeString> nativeString = stringToNativeString(string);
  // NativeString owned by NativeValue will be freed by users.
  return Native_NewString(nativeString.release());
}

NativeValue Native_NewFloat64(double value) {
  int64_t result;
  memcpy(&result, reinterpret_cast<void*>(&value), sizeof(double));

  return (NativeValue){
      .u = {.int64 = result},
      .uint32 = 0,
      .tag = NativeTag::TAG_FLOAT64,
  };
}

NativeValue Native_NewPtr(JSPointerType pointerType, void* ptr) {
  return (NativeValue){.u = {.ptr = ptr}, .uint32 = static_cast<uint32_t>(pointerType), .tag = NativeTag::TAG_POINTER};
}

NativeValue Native_NewBool(bool value) {
  return (NativeValue){
      .u = {.int64 = value ? 1 : 0},
      .uint32 = 0,
      .tag = NativeTag::TAG_BOOL,
  };
}

NativeValue Native_NewInt64(int64_t value) {
  return (NativeValue){
      .u = {.int64 = value},
      .uint32 = 0,
      .tag = NativeTag::TAG_INT,
  };
}

NativeValue Native_NewList(uint32_t argc, NativeValue* argv) {
  return (NativeValue){.u = {.ptr = reinterpret_cast<void*>(argv)}, .uint32 = argc, .tag = NativeTag::TAG_LIST};
}

NativeValue Native_NewJSON(const ScriptValue& value, ExceptionState& exception_state) {
  ScriptValue json = value.ToJSONStringify(&exception_state);
  if (exception_state.HasException()) {
    return Native_NewNull();
  }

  auto native_string = json.ToNativeString();
  NativeValue result = (NativeValue){
      .u = {.ptr = static_cast<void*>(native_string.release())},
      .uint32 = 0,
      .tag = NativeTag::TAG_JSON,
  };
  return result;
}

}  // namespace webf
