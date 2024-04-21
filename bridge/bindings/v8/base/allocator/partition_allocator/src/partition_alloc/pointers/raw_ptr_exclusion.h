/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BASE_ALLOCATOR_PARTITION_ALLOCATOR_SRC_PARTITION_ALLOC_POINTERS_RAW_PTR_EXCLUSION_H_
#define BASE_ALLOCATOR_PARTITION_ALLOCATOR_SRC_PARTITION_ALLOC_POINTERS_RAW_PTR_EXCLUSION_H_

// This header will be leakily included even when
// `!use_partition_alloc`, which is okay because it's a leaf header.
#include "bindings/v8/for_build/build_config.h"
#include "bindings/v8/for_build/buildflag.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/compiler_specific.h"  // nogncheck
//#include "partition_alloc/partition_alloc_buildflags.h"

#define RAW_PTR_EXCLUSION
/*TODO fix BUILDFLAG(FORCE_ENABLE_RAW_PTR_EXCLUSION) error
#if PA_HAS_ATTRIBUTE(annotate)
#if defined(OFFICIAL_BUILD) && !BUILDFLAG(FORCE_ENABLE_RAW_PTR_EXCLUSION)
// The annotation changed compiler output and increased binary size so disable
// for official builds.
// TODO(crbug.com/40836910): Remove when issue is resolved.
#define RAW_PTR_EXCLUSION
#else
// Marks a field as excluded from the `raw_ptr<T>` usage enforcement via
// Chromium Clang plugin.
//
// Example:
//     RAW_PTR_EXCLUSION Foo* foo_;
//
// `RAW_PTR_EXCLUSION` should be avoided, as exclusions makes it significantly
// easier for any bug involving the pointer to become a security vulnerability.
// For additional guidance please see the "When to use raw_ptr<T>" section of
// `//base/memory/raw_ptr.md`.
#define RAW_PTR_EXCLUSION __attribute__((annotate("raw_ptr_exclusion")))
#endif
#else
#define RAW_PTR_EXCLUSION
#endif
*/
#endif  // BASE_ALLOCATOR_PARTITION_ALLOCATOR_SRC_PARTITION_ALLOC_POINTERS_RAW_PTR_EXCLUSION_H_