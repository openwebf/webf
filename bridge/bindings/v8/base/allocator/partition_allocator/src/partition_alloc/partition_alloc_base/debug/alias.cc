/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/debug/alias.h"

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/compiler_specific.h"

namespace partition_alloc::internal::base::debug {

// This file/function should be excluded from LTO/LTCG to ensure that the
// compiler can't see this function's implementation when compiling calls to it.
PA_NOINLINE void Alias(const void* var) {}

}  // namespace partition_alloc::internal::base::debug

