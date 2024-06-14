/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/v8/platform/util/allocator/partition_allocator.h"

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc.h"
#include "bindings/v8/platform/util/allocator/partitions.h"

namespace util {

void* PartitionAllocator::AllocateBacking(size_t size, const char* type_name) {
  return Partitions::BufferMalloc(size, type_name);
}

void PartitionAllocator::FreeBacking(void* address) {
  Partitions::BufferFree(address);
}

template <>
char* PartitionAllocator::AllocateVectorBacking<char>(size_t size) {
  return reinterpret_cast<char*>(
      AllocateBacking(size, "PartitionAllocator::allocateVectorBacking<char>"));
}

}  // namespace WTF