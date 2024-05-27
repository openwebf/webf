/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_oom.h"

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/build_config.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/oom.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/compiler_specific.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/debug/alias.h"

namespace partition_alloc::internal {

OomFunction g_oom_handling_function = nullptr;

PA_NOINLINE PA_NOT_TAIL_CALLED void PartitionExcessiveAllocationSize(
    size_t size) {
  PA_NO_CODE_FOLDING();
  OOM_CRASH(size);
}

#if !defined(ARCH_CPU_64_BITS)
PA_NOINLINE PA_NOT_TAIL_CALLED void
PartitionOutOfMemoryWithLotsOfUncommitedPages(size_t size) {
  PA_NO_CODE_FOLDING();
  OOM_CRASH(size);
}

[[noreturn]] PA_NOT_TAIL_CALLED PA_NOINLINE void
PartitionOutOfMemoryWithLargeVirtualSize(size_t virtual_size) {
  PA_NO_CODE_FOLDING();
  OOM_CRASH(virtual_size);
}

#endif  // !defined(ARCH_CPU_64_BITS)

}  // namespace partition_alloc::internal

