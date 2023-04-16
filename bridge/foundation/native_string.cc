/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "native_string.h"
#include <string>

#if WIN32
#include <Windows.h>
#endif

namespace webf {

SharedNativeString::SharedNativeString(const uint16_t* string, uint32_t length) : length_(length), string_(string) {}

std::unique_ptr<SharedNativeString> SharedNativeString::FromTemporaryString(const uint16_t* string, uint32_t length) {
#if WIN32
  const auto* new_str = static_cast<const uint16_t*>(CoTaskMemAlloc(length * sizeof(uint16_t)));
#else
  const auto* new_str = static_cast<const uint16_t*>(malloc(length * sizeof(uint16_t)));
#endif
  memcpy((void*)new_str, string, length * sizeof(uint16_t));
  return std::make_unique<SharedNativeString>(new_str, length);
}

AutoFreeNativeString::~AutoFreeNativeString() {
  free();
}

void SharedNativeString::free() const {
#if WIN32
  CoTaskMemFree((LPVOID)string_);
#else
  delete[] string_;
#endif
}

void* SharedNativeString::operator new(std::size_t size) {
#if WIN32
  return CoTaskMemAlloc(size);
#else
  return malloc(size);
#endif
}

void SharedNativeString::operator delete(void* memory) noexcept {
#if WIN32
  return CoTaskMemFree(memory);
#else
  return free(memory);
#endif
}

}  // namespace webf
