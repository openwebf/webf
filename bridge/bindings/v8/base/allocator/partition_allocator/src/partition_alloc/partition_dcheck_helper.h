/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_PARTITION_DCHECK_HELPER_H_
#define PARTITION_ALLOC_PARTITION_DCHECK_HELPER_H_

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/compiler_specific.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/component_export.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_forward.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_lock.h"

namespace partition_alloc::internal {

struct PartitionSuperPageExtentEntry;

#if PA_BUILDFLAG(PA_DCHECK_IS_ON)

// To allow these asserts to have empty bodies in no-DCHECK() builds, while
// avoiding issues with circular includes.
#define PA_EMPTY_BODY_IF_DCHECK_IS_OFF()
// Export symbol if dcheck-is-on. Because the body is not empty.
#define PA_EXPORT_IF_DCHECK_IS_ON() PA_COMPONENT_EXPORT(PARTITION_ALLOC)

#else  // PA_BUILDFLAG(PA_DCHECK_IS_ON)

// The static_assert() eats follow-on semicolons.
#define PA_EMPTY_BODY_IF_DCHECK_IS_OFF() \
  {}                                     \
  static_assert(true)
// inline if dcheck-is-off so it's no overhead.
#define PA_EXPORT_IF_DCHECK_IS_ON() PA_ALWAYS_INLINE

#endif  // PA_BUILDFLAG(PA_DCHECK_IS_ON)

PA_EXPORT_IF_DCHECK_IS_ON()
void DCheckIsValidSlotSpan(internal::SlotSpanMetadata* slot_span)
    PA_EMPTY_BODY_IF_DCHECK_IS_OFF();

PA_EXPORT_IF_DCHECK_IS_ON()
void DCheckIsWithInSuperPagePayload(uintptr_t address)
    PA_EMPTY_BODY_IF_DCHECK_IS_OFF();

PA_EXPORT_IF_DCHECK_IS_ON()
void DCheckNumberOfPartitionPagesInSuperPagePayload(
    const PartitionSuperPageExtentEntry* entry,
    const PartitionRoot* root,
    size_t number_of_nonempty_slot_spans) PA_EMPTY_BODY_IF_DCHECK_IS_OFF();

PA_EXPORT_IF_DCHECK_IS_ON()
void DCheckIsValidShiftFromSlotStart(internal::SlotSpanMetadata* slot_span,
                                     size_t shift_from_slot_start)
    PA_EMPTY_BODY_IF_DCHECK_IS_OFF();

// Checks that the object is a multiple of slot size (i.e. at a slot start).
PA_EXPORT_IF_DCHECK_IS_ON()
void DCheckIsValidObjectAddress(internal::SlotSpanMetadata* slot_span,
                                uintptr_t object_addr)
    PA_EMPTY_BODY_IF_DCHECK_IS_OFF();

PA_EXPORT_IF_DCHECK_IS_ON()
void DCheckRootLockIsAcquired(PartitionRoot* root)
    PA_EMPTY_BODY_IF_DCHECK_IS_OFF();

}  // namespace partition_alloc::internal

#endif  // PARTITION_ALLOC_PARTITION_DCHECK_HELPER_H_

