/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_NATIVE_STRING_UTILS_H
#define BRIDGE_NATIVE_STRING_UTILS_H

#include <quickjs/quickjs.h>
#include <memory>
#include <string>

#include "foundation/native_string.h"
#include "core/base/strings/utf_string_conversion_utils.h"

namespace webf {

class String;

// Convert to string and return a full copy of NativeString from JSValue.
std::unique_ptr<SharedNativeString> jsValueToNativeString(JSContext* ctx, JSValue value);

// Encode utf-8 to utf-16, and return a full copy of NativeString.
std::unique_ptr<SharedNativeString> stringToNativeString(const std::string& string);

// Copies a WebF String to a NativeString (UTF-16) without interning.
// Prefer this over AtomicString(value).ToNativeString() for transient values
// (e.g. style values) to avoid growing the AtomicString table.
std::unique_ptr<SharedNativeString> stringToNativeString(const String& string);

std::string nativeStringToStdString(const SharedNativeString* native_string);

template <typename T>
std::string toUTF8(const std::basic_string<T, std::char_traits<T>, std::allocator<T>>& source) {
  static_assert(sizeof(T) == sizeof(char16_t), "toUTF8 only supports UTF-16 input");
  const char16_t* src = reinterpret_cast<const char16_t*>(source.data());
  const size_t src_len = source.size();

  std::string result;
  base::PrepareForUTF8Output(src, src_len, &result);

  size_t index = 0;
  while (index < src_len) {
    int32_t code_point = 0;
    if (!base::ReadUnicodeCharacter(src, src_len, &index, &code_point)) {
      // Use replacement character on invalid sequence.
      code_point = 0xFFFD;
    }
    base::WriteUnicodeCharacter(code_point, &result);
    ++index;
  }
  return result;
}

template <typename T>
void fromUTF8(const std::string& source, std::basic_string<T, std::char_traits<T>, std::allocator<T>>& result) {
  static_assert(sizeof(T) == sizeof(char16_t), "fromUTF8 only supports UTF-16 output");
  const char* src = source.data();
  const size_t src_len = source.size();

  result.clear();
  base::PrepareForUTF16Or32Output(src, src_len, &result);

  size_t index = 0;
  while (index < src_len) {
    int32_t code_point = 0;
    if (!base::ReadUnicodeCharacter(src, src_len, &index, &code_point)) {
      // Use replacement character on invalid sequence.
      code_point = 0xFFFD;
    }
    base::WriteUnicodeCharacter(code_point, &result);
    ++index;
  }
}

}  // namespace webf

#endif  // BRIDGE_NATIVE_STRING_UTILS_H
