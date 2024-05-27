/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "random.h"

#include <type_traits>

#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/rand_util.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_alloc_base/thread_annotations.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/partition_root.h"

namespace partition_alloc {

class RandomGenerator {
 public:
  constexpr RandomGenerator() {}

  uint32_t RandomValue() {
    ::partition_alloc::internal::ScopedGuard guard(lock_);
    return GetGenerator()->RandUint32();
  }

  void SeedForTesting(uint64_t seed) {
    ::partition_alloc::internal::ScopedGuard guard(lock_);
    GetGenerator()->ReseedForTesting(seed);
  }

 private:
  ::partition_alloc::internal::Lock lock_ = {};
  bool initialized_ PA_GUARDED_BY(lock_) = false;
  union {
    internal::base::InsecureRandomGenerator instance_ PA_GUARDED_BY(lock_);
    uint8_t instance_buffer_[sizeof(
        internal::base::InsecureRandomGenerator)] PA_GUARDED_BY(lock_) = {};
  };

  internal::base::InsecureRandomGenerator* GetGenerator()
      PA_EXCLUSIVE_LOCKS_REQUIRED(lock_) {
    if (!initialized_) {
      new (instance_buffer_) internal::base::InsecureRandomGenerator();
      initialized_ = true;
    }
    return &instance_;
  }
};

// Note: this is redundant, since the anonymous union is incompatible with a
// non-trivial default destructor. Not meant to be destructed anyway.
static_assert(std::is_trivially_destructible_v<RandomGenerator>, "");

namespace {

RandomGenerator g_generator = {};

}  // namespace

namespace internal {

uint32_t RandomValue() {
  return g_generator.RandomValue();
}

}  // namespace internal

void SetMmapSeedForTesting(uint64_t seed) {
  return g_generator.SeedForTesting(seed);
}

}  // namespace partition_alloc
