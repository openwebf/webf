/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/internal_allocator.h"

namespace partition_alloc::internal {
PA_COMPONENT_EXPORT(PARTITION_ALLOC)
PartitionRoot& InternalAllocatorRoot() {
  static internal::base::NoDestructor<PartitionRoot> allocator([]() {
    // Disable features using the internal root to avoid reentrancy issue.
    PartitionOptions opts;
    opts.thread_cache = PartitionOptions::kDisabled;
    opts.scheduler_loop_quarantine = PartitionOptions::kDisabled;
    return opts;
  }());

  return *allocator;
}

// static
void* InternalPartitionAllocated::operator new(size_t count) {
  return InternalAllocatorRoot().Alloc<AllocFlags::kNoHooks>(count);
}
// static
void* InternalPartitionAllocated::operator new(size_t count,
                                               std::align_val_t alignment) {
  return InternalAllocatorRoot().AlignedAlloc<AllocFlags::kNoHooks>(
      static_cast<size_t>(alignment), count);
}
// static
void InternalPartitionAllocated::operator delete(void* ptr) {
  InternalAllocatorRoot().Free<FreeFlags::kNoHooks>(ptr);
}
// static
void InternalPartitionAllocated::operator delete(void* ptr, std::align_val_t) {
  InternalAllocatorRoot().Free<FreeFlags::kNoHooks>(ptr);
}

// A deleter for `std::unique_ptr<T>`.
void InternalPartitionDeleter::operator()(void* ptr) const {
  InternalAllocatorRoot().Free<FreeFlags::kNoHooks>(ptr);
}
}  // namespace partition_alloc::internal
