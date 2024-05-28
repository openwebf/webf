/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_freelist_entry.h"

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/immediate_crash.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_check.h"

namespace partition_alloc::internal {

void FreelistCorruptionDetected(size_t slot_size) {
  // Make it visible in minidumps.
  PA_DEBUG_DATA_ON_STACK("slotsize", slot_size);
  PA_IMMEDIATE_CRASH();
}

}  // namespace partition_alloc::internal