/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/oom_callback.h"

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_check.h"

namespace partition_alloc {

namespace {
PartitionAllocOomCallback g_oom_callback;
}  // namespace

void SetPartitionAllocOomCallback(PartitionAllocOomCallback callback) {
  PA_DCHECK(!g_oom_callback);
  g_oom_callback = callback;
}

namespace internal {
void RunPartitionAllocOomCallback() {
  if (g_oom_callback) {
    g_oom_callback();
  }
}
}  // namespace internal

}  // namespace partition_alloc

