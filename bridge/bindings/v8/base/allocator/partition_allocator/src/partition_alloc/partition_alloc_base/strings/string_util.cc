/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/strings/string_util.h"

#include <cstring>

namespace partition_alloc::internal::base::strings {

const char* FindLastOf(const char* text, const char* characters) {
  size_t length = strlen(text);
  const char* ptr = text + length - 1;
  while (ptr >= text) {
    if (strchr(characters, *ptr)) {
      return ptr;
    }
    --ptr;
  }
  return nullptr;
}

const char* FindLastNotOf(const char* text, const char* characters) {
  size_t length = strlen(text);
  const char* ptr = text + length - 1;
  while (ptr >= text) {
    if (!strchr(characters, *ptr)) {
      return ptr;
    }
    --ptr;
  }
  return nullptr;
}

}  // namespace partition_alloc::internal::base::strings

