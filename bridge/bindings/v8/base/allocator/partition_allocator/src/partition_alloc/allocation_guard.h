/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_ALLOCATION_GUARD_H_
#define PARTITION_ALLOC_ALLOCATION_GUARD_H_

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/build_config.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/component_export.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_config.h"

namespace partition_alloc {

#if PA_CONFIG(HAS_ALLOCATION_GUARD)

// Disallow allocations in the scope. Does not nest.
class PA_COMPONENT_EXPORT(PARTITION_ALLOC) ScopedDisallowAllocations {
 public:
  ScopedDisallowAllocations();
  ~ScopedDisallowAllocations();
};

// Disallow allocations in the scope. Does not nest.
class PA_COMPONENT_EXPORT(PARTITION_ALLOC) ScopedAllowAllocations {
 public:
  ScopedAllowAllocations();
  ~ScopedAllowAllocations();

 private:
  bool saved_value_;
};

#else

struct [[maybe_unused]] ScopedDisallowAllocations {};
struct [[maybe_unused]] ScopedAllowAllocations {};

#endif  // PA_CONFIG(HAS_ALLOCATION_GUARD)

}  // namespace partition_alloc

namespace base::internal {

using ::partition_alloc::ScopedAllowAllocations;
using ::partition_alloc::ScopedDisallowAllocations;

}  // namespace base::internal

#endif  // PARTITION_ALLOC_ALLOCATION_GUARD_H_

