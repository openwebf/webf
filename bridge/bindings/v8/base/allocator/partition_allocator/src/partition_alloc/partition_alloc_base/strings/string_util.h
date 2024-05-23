/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PARTITION_ALLOC_PARTITION_ALLOC_BASE_STRINGS_STRING_UTIL_H_
#define PARTITION_ALLOC_PARTITION_ALLOC_BASE_STRINGS_STRING_UTIL_H_

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/component_export.h"

namespace partition_alloc::internal::base::strings {

PA_COMPONENT_EXPORT(PARTITION_ALLOC_BASE)
const char* FindLastOf(const char* text, const char* characters);
PA_COMPONENT_EXPORT(PARTITION_ALLOC_BASE)
const char* FindLastNotOf(const char* text, const char* characters);

}  // namespace partition_alloc::internal::base::strings

#endif  // PARTITION_ALLOC_PARTITION_ALLOC_BASE_STRINGS_STRING_UTIL_H_

