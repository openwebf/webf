/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_PARTITION_ALLOC_BUILDFLAGS_H
#define WEBF_PARTITION_ALLOC_BUILDFLAGS_H

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/build_config.h" // IWYU pragma: export
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/buildflag.h" // IWYU pragma: export

#define PA_BUILDFLAG_INTERNAL_USE_PARTITION_ALLOC() (1)
#define PA_BUILDFLAG_INTERNAL_PA_DCHECK_IS_ON() (0)
#define PA_BUILDFLAG_INTERNAL_PA_DCHECK_IS_CONFIGURABLE() (0)

// https://chromium.googlesource.com/chromium/src/+/refs/tags/114.0.5719.0/build_overrides/partition_alloc.gni
#define PA_BUILDFLAG_INTERNAL_USE_RAW_PTR_BACKUP_REF_IMPL() (0)
#define PA_BUILDFLAG_INTERNAL_BACKUP_REF_PTR_EXTRA_OOB_CHECKS() (0)

#define PA_BUILDFLAG_INTERNAL_USE_ASAN_BACKUP_REF_PTR() (0)
#define PA_BUILDFLAG_INTERNAL_HAS_64_BIT_POINTERS() (1)
#define PA_BUILDFLAG_INTERNAL_USE_RAW_PTR_ASAN_UNOWNED_IMPL() (0)
#define PA_BUILDFLAG_INTERNAL_USE_RAW_PTR_HOOKABLE_IMPL() (0)

// - enable_backup_ref_ptr_slow_checks: enable additional safety checks that
//   are too expensive to have on by default.
// - enable_dangling_raw_ptr_checks: enable checking raw_ptr do not become
//   dangling during their lifetime.
// - backup_ref_ptr_poison_oob_ptr: poison out-of-bounds (OOB) pointers to
//   generate an exception in the event that an OOB pointer is dereferenced.
// - enable_backup_ref_ptr_instance_tracer: use a global table to track all
//   live raw_ptr/raw_ref instances to help debug dangling pointers at test
//   end.
#define PA_BUILDFLAG_INTERNAL_ENABLE_BACKUP_REF_PTR_SLOW_CHECKS() (0)
#define PA_BUILDFLAG_INTERNAL_BACKUP_REF_PTR_POISON_OOB_PTR() (0)

#define PA_BUILDFLAG_INTERNAL_HAS_MEMORY_TAGGING() (0)

// Enables a compile-time check that all raw_ptrs to which arithmetic
// operations are to be applied are annotated with the AllowPtrArithmetic
// trait,
#define PA_BUILDFLAG_INTERNAL_ENABLE_POINTER_ARITHMETIC_TRAIT_CHECK() (1)


#define PA_BUILDFLAG_INTERNAL_RAW_PTR_ZERO_ON_CONSTRUCT() (1)
#define PA_BUILDFLAG_INTERNAL_RAW_PTR_ZERO_ON_MOVE() (1)
#define PA_BUILDFLAG_INTERNAL_RAW_PTR_ZERO_ON_DESTRUCT() (0)

#define PA_BUILDFLAG_INTERNAL_ENABLE_BACKUP_REF_PTR_INSTANCE_TRACER() (0)

#endif  // WEBF_PARTITION_ALLOC_BUILDFLAGS_H
