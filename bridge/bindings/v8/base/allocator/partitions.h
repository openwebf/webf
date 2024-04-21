/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_PARTITIONS_H
#define WEBF_PARTITIONS_H


//#include "base/allocator/partition_allocator/src/partition_alloc/partition_alloc_forward.h"
//#include "base/check.h"
//#include "base/memory/scoped_refptr.h"
//#include "base/numerics/checked_math.h"
//#include "third_party/blink/renderer/platform/wtf/wtf_export.h"
#include "foundation/macros.h"
#include "bindings/v8/base/compiler_specific.h"
#include "bindings/v8/base/memory/scoped_refptr.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc//partition_alloc_forward.h"
#include "bindings/v8/base/numerics/checked_math.h"
#include <cassert>

namespace base {
class SequencedTaskRunner;
}

namespace webf {

class Partitions {
 public:
  // Name of allocator used by tracing for marking sub-allocations while take
  // memory snapshots.
  static const char* const kAllocatedObjectPoolName;

  // Should be called on the thread which is or will become the main one.
  static void Initialize();
  static void InitializeArrayBufferPartition();
  static void StartMemoryReclaimer(
      scoped_refptr<base::SequencedTaskRunner> task_runner);

  // The ArrayBufferPartition is initialized separately from the other
  // partitions and so may not always be available. This function can be used to
  // determine whether the partition has been initialized.
  ALWAYS_INLINE static bool ArrayBufferPartitionInitialized() {
    return array_buffer_root_ != nullptr;
  }

  ALWAYS_INLINE static partition_alloc::PartitionRoot* ArrayBufferPartition() {
    assert_m(initialized_, "initialized_ is nullptr");
    assert_m(ArrayBufferPartitionInitialized(), "array_buffer_root_ is nullptr");
    return array_buffer_root_;
  }

  ALWAYS_INLINE static partition_alloc::PartitionRoot* BufferPartition() {
    assert_m(initialized_, "initialized_ is nullptr");
    return buffer_root_;
  }

  ALWAYS_INLINE static size_t ComputeAllocationSize(size_t count, size_t size) {
    base::CheckedNumeric<size_t> total = count;
    total *= size;
    return total.ValueOrDie();
  }

  static size_t TotalSizeOfCommittedPages();

  static size_t TotalActiveBytes();

  static void DumpMemoryStats(bool is_light_dump,
                              partition_alloc::PartitionStatsDumper*);

  static void* PA_MALLOC_FN BufferMalloc(size_t n, const char* type_name);
  static void* BufferTryRealloc(void* p, size_t n, const char* type_name);
  static void BufferFree(void* p);
  static size_t BufferPotentialCapacity(size_t n);

  static void* PA_MALLOC_FN FastMalloc(size_t n, const char* type_name);
  static void* PA_MALLOC_FN FastZeroedMalloc(size_t n, const char* type_name);
  static void FastFree(void* p);

  static void HandleOutOfMemory(size_t size);

  // Adjusts the size of the partitions based on process state.
  static void AdjustPartitionsForForeground();
  static void AdjustPartitionsForBackground();

 private:
  ALWAYS_INLINE static partition_alloc::PartitionRoot* FastMallocPartition() {
    assert_m(initialized_, "initialized_ is nullptr");
    return fast_malloc_root_;
  }

  static bool InitializeOnce();

  static bool initialized_;
  static bool scan_is_enabled_;
  // See Allocator.md for a description of these partitions.
  static partition_alloc::PartitionRoot* fast_malloc_root_;
  static partition_alloc::PartitionRoot* array_buffer_root_;
  static partition_alloc::PartitionRoot* buffer_root_;
};

}  // namespace webf

#endif  // WEBF_PARTITIONS_H
