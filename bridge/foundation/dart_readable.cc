/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_readable.h"
#include <cstdlib>
#include <memory>

#if WIN32
#include <Windows.h>
#endif

namespace webf {

void* dart_malloc(std::size_t size) {
#if WIN32
  return CoTaskMemAlloc(size);
#else
  return malloc(size);
#endif
}

void dart_free(void* ptr) {
#if WIN32
  return CoTaskMemFree(ptr);
#else
  return free(ptr);
#endif
}

void* DartReadable::operator new(std::size_t size) {
  return dart_malloc(size);
}

void DartReadable::operator delete(void* memory) noexcept {
  dart_free(memory);
}

}  // namespace webf
