/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef RUST_READABLE_H
#define RUST_READABLE_H

#include <cinttypes>

namespace webf {

// Shared C struct which can be read by rust through Dart FFI.
struct RustReadable {
  // Dart FFI use ole32 as it's allocator, we need to override the default allocator to compact with Dart FFI.
  static void* operator new(size_t size);
  static void operator delete(void* memory) noexcept;
};

}  // namespace webf

#endif  // RUST_READABLE_H
