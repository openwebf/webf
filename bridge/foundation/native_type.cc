/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "native_type.h"

#if WIN32
#include <Windows.h>
#endif

namespace webf {

void* DartReadable::operator new(std::size_t size) {
#if WIN32
  return CoTaskMemAlloc(size);
#else
  return malloc(size);
#endif
}

void DartReadable::operator delete(void* memory) noexcept {
#if WIN32
  return CoTaskMemFree(memory);
#else
  return free(memory);
#endif
}

}  // namespace webf