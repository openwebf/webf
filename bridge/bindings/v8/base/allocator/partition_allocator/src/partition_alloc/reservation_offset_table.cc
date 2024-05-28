/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/reservation_offset_table.h"

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_buildflags.h"

namespace partition_alloc::internal {

#if PA_BUILDFLAG(HAS_64_BIT_POINTERS)
ReservationOffsetTable ReservationOffsetTable::singleton_;
#else
ReservationOffsetTable::_ReservationOffsetTable
    ReservationOffsetTable::reservation_offset_table_;
#endif  // PA_BUILDFLAG(HAS_64_BIT_POINTERS)

}  // namespace partition_alloc::internal
