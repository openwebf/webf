/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <memory>
#include "plugin_api/rust_readable.h"

#if WIN32
#include <Windows.h>
#endif

namespace webf {

void* RustReadable::operator new(std::size_t size) {
#if WIN32
  return HeapAlloc(GetProcessHeap(), HEAP_GENERATE_EXCEPTIONS, size);
#else
  return malloc(size);
#endif
}

void RustReadable::operator delete(void* memory) noexcept {
#if WIN32
  HeapFree(GetProcessHeap(), 0, memory);
#else
#endif
}

}  // namespace webf