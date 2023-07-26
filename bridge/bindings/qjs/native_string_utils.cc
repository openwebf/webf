/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "native_string_utils.h"
#include "bindings/qjs/qjs_engine_patch.h"

namespace webf {

std::unique_ptr<SharedNativeString> jsValueToNativeString(JSContext* ctx, JSValue value) {
  bool isValueString = true;
  if (JS_IsNull(value)) {
    value = JS_NewString(ctx, "");
    isValueString = false;
  } else if (!JS_IsString(value)) {
    value = JS_ToString(ctx, value);
    isValueString = false;
  }

  uint32_t length;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &length);
  std::unique_ptr<SharedNativeString> ptr = std::make_unique<SharedNativeString>(buffer, length);

  if (!isValueString) {
    JS_FreeValue(ctx, value);
  }
  return ptr;
}

std::unique_ptr<SharedNativeString> stringToNativeString(const std::string& string) {
  std::u16string utf16;
  fromUTF8(string, utf16);
  SharedNativeString tmp{reinterpret_cast<const uint16_t*>(utf16.c_str()), static_cast<uint32_t>(utf16.size())};
  return SharedNativeString::FromTemporaryString(tmp.string(), tmp.length());
}

std::string nativeStringToStdString(const SharedNativeString* native_string) {
  std::u16string u16EventType =
      std::u16string(reinterpret_cast<const char16_t*>(native_string->string()), native_string->length());
  return toUTF8(u16EventType);
}

std::unique_ptr<SharedNativeString> atomToNativeString(JSContext* ctx, JSAtom atom) {
  JSValue stringValue = JS_AtomToString(ctx, atom);
  std::unique_ptr<SharedNativeString> string = jsValueToNativeString(ctx, stringValue);
  JS_FreeValue(ctx, stringValue);
  return string;
}

std::string jsValueToStdString(JSContext* ctx, JSValue& value) {
  const char* cString = JS_ToCString(ctx, value);
  std::string str = std::string(cString);
  JS_FreeCString(ctx, cString);
  return str;
}

}  // namespace webf
