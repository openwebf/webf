/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_PARTITION_OOM_H_
#define PARTITION_ALLOC_PARTITION_OOM_H_

#include <cstddef>

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/build_config.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/compiler_specific.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/component_export.h"

namespace partition_alloc {

using OomFunction = void (*)(size_t);

namespace internal {

// g_oom_handling_function is invoked when PartitionAlloc hits OutOfMemory.
extern OomFunction g_oom_handling_function;

[[noreturn]] PA_NOINLINE PA_COMPONENT_EXPORT(
    PARTITION_ALLOC) void PartitionExcessiveAllocationSize(size_t size);

#if !defined(ARCH_CPU_64_BITS)
[[noreturn]] PA_NOINLINE void PartitionOutOfMemoryWithLotsOfUncommitedPages(
    size_t size);
[[noreturn]] PA_NOINLINE void PartitionOutOfMemoryWithLargeVirtualSize(
    size_t virtual_size);
#endif

}  // namespace internal

}  // namespace partition_alloc

#endif  // PARTITION_ALLOC_PARTITION_OOM_H_
