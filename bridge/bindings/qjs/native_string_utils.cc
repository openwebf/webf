/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "native_string_utils.h"

#include <cstring>

#include "foundation/dart_readable.h"
#include "foundation/string/wtf_string.h"

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

  std::unique_ptr<SharedNativeString> ptr;
  if (JS_ValueGetStringLen(value) == 0) {
    uint16_t tmp[] = {0};
    ptr = SharedNativeString::FromTemporaryString(tmp, 0);
  } else {
    uint32_t length;
    uint16_t* buffer = JS_ToUnicode(ctx, value, &length);
    ptr = std::make_unique<SharedNativeString>(buffer, length);
  }

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

std::unique_ptr<SharedNativeString> stringToNativeString(const String& string) {
  uint32_t length = string.length();
  if (length == 0) {
    return std::make_unique<SharedNativeString>(nullptr, 0);
  }

  auto* buffer = static_cast<uint16_t*>(dart_malloc(sizeof(uint16_t) * length));
  if (string.Is8Bit()) {
    const LChar* p = string.Characters8();
    for (uint32_t i = 0; i < length; ++i) {
      buffer[i] = static_cast<uint16_t>(p[i]);
    }
  } else {
    const UChar* p = string.Characters16();
    std::memcpy(buffer, p, sizeof(uint16_t) * length);
  }

  return std::make_unique<SharedNativeString>(buffer, length);
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
