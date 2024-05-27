/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_REVERSE_BYTES_H_
#define PARTITION_ALLOC_REVERSE_BYTES_H_

// This header defines drop-in constexpr replacements for the
// byte-reversing routines that we used from `//base/sys_byteorder.h`.
// They will be made moot by C++23's <endian> header or by C++20's
// <bit> header.

#include <cstdint>

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/build_config.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_config.h"

namespace partition_alloc::internal {

constexpr uint32_t ReverseFourBytes(uint32_t value) {
#if PA_CONFIG(IS_NONCLANG_MSVC)
  return value >> 24 | (value >> 8 & 0xff00) | (value & 0xff00) << 8 |
         value << 24;
#else
  return __builtin_bswap32(value);
#endif  // PA_CONFIG(IS_NONCLANG_MSVC)
}

constexpr uint64_t ReverseEightBytes(uint64_t value) {
#if PA_CONFIG(IS_NONCLANG_MSVC)
  return value >> 56 | (value >> 40 & 0xff00) | (value >> 24 & 0xff0000) |
         (value >> 8 & 0xff000000) | (value & 0xff000000) << 8 |
         (value & 0xff0000) << 24 | (value & 0xff00) << 40 |
         (value & 0xff) << 56;
#else
  return __builtin_bswap64(value);
#endif  // PA_CONFIG(IS_NONCLANG_MSVC)
}

constexpr uintptr_t ReverseBytes(uintptr_t value) {
  if (sizeof(uintptr_t) == 4) {
    return ReverseFourBytes(static_cast<uint32_t>(value));
  }
  return ReverseEightBytes(static_cast<uint64_t>(value));
}

}  // namespace partition_alloc::internal

#endif  // PARTITION_ALLOC_REVERSE_BYTES_H_

