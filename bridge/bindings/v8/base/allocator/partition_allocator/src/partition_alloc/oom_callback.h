/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_OOM_CALLBACK_H_
#define PARTITION_ALLOC_OOM_CALLBACK_H_

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/component_export.h"

namespace partition_alloc {

using PartitionAllocOomCallback = void (*)();

// Registers a callback to be invoked during an OOM_CRASH(). OOM_CRASH is
// invoked by users of PageAllocator (including PartitionAlloc) to signify an
// allocation failure from the platform.
PA_COMPONENT_EXPORT(PARTITION_ALLOC)
void SetPartitionAllocOomCallback(PartitionAllocOomCallback callback);

namespace internal {
PA_COMPONENT_EXPORT(PARTITION_ALLOC) void RunPartitionAllocOomCallback();
}  // namespace internal

}  // namespace partition_alloc

#endif  // PARTITION_ALLOC_OOM_CALLBACK_H_

