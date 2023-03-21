/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "native_string.h"
#include <string>

namespace webf {

SharedNativeString::SharedNativeString(const uint16_t* string, uint32_t length) : length_(length), string_(string) {}

std::unique_ptr<SharedNativeString> SharedNativeString::FromTemporaryString(const uint16_t* string, uint32_t length) {
  const auto* new_str = static_cast<const uint16_t*>(malloc(length * sizeof(uint16_t)));
  memcpy((void*)new_str, string, length * sizeof(uint16_t));
  return std::make_unique<SharedNativeString>(new_str, length);
}

AutoFreeNativeString::AutoFreeNativeString(const uint16_t* string, uint32_t length)
    : SharedNativeString(string, length) {}

AutoFreeNativeString::AutoFreeNativeString(void* raw) : SharedNativeString() {
  auto* p = static_cast<AutoFreeNativeString*>(raw);
  length_ = p->length();
  string_ = p->string_;
}

AutoFreeNativeString::~AutoFreeNativeString() {
  free();
}

}  // namespace webf
