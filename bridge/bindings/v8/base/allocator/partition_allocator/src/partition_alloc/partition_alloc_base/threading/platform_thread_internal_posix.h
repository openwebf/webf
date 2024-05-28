/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_PARTITION_ALLOC_BASE_THREADING_PLATFORM_THREAD_INTERNAL_POSIX_H_
#define PARTITION_ALLOC_PARTITION_ALLOC_BASE_THREADING_PLATFORM_THREAD_INTERNAL_POSIX_H_

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/build_config.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/component_export.h"

namespace partition_alloc::internal::base::internal {

#if BUILDFLAG(IS_LINUX) || BUILDFLAG(IS_CHROMEOS)
// Current thread id is cached in thread local storage for performance reasons.
// In some rare cases it's important to invalidate that cache explicitly (e.g.
// after going through clone() syscall which does not call pthread_atfork()
// handlers).
// This can only be called when the process is single-threaded.
PA_COMPONENT_EXPORT(PARTITION_ALLOC_BASE) void InvalidateTidCache();
#endif  // BUILDFLAG(IS_LINUX) || BUILDFLAG(IS_CHROMEOS)

}  // namespace partition_alloc::internal::base::internal

#endif  // PARTITION_ALLOC_PARTITION_ALLOC_BASE_THREADING_PLATFORM_THREAD_INTERNAL_POSIX_H_

