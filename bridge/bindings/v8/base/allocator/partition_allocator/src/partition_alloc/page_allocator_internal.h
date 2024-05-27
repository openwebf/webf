/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_PAGE_ALLOCATOR_INTERNAL_H_
#define PARTITION_ALLOC_PAGE_ALLOCATOR_INTERNAL_H_

#include <cstddef>
#include <cstdint>

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/page_allocator.h"

namespace partition_alloc::internal {

uintptr_t SystemAllocPages(uintptr_t hint,
                           size_t length,
                           PageAccessibilityConfiguration accessibility,
                           PageTag page_tag,
                           int file_descriptor_for_shared_alloc = -1);

}  // namespace partition_alloc::internal

#endif  // PARTITION_ALLOC_PAGE_ALLOCATOR_INTERNAL_H_

