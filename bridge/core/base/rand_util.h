// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef BASE_RAND_UTIL_H_
#define BASE_RAND_UTIL_H_

#include <stddef.h>
#include <stdint.h>

#include <algorithm>
#include <string>
#include <vector>

//#include "base/compiler_specific.h"
#include "core/base/containers/span.h"
//#include "base/gtest_prod_util.h"
//#include "build/build_config.h"

//#if !BUILDFLAG(IS_NACL)
//#include "third_party/boringssl/src/include/openssl/rand.h"
//#endif

namespace memory_simulator {
class MemoryHolder;
}

namespace webf {

class TimeDelta;

namespace internal {
/*
#if BUILDFLAG(IS_ANDROID)
// Sets the implementation of RandBytes according to the corresponding
// base::Feature. Thread safe: allows to switch while RandBytes() is in use.
void ConfigureRandBytesFieldTrial();
#endif

 */

//#if !BUILDFLAG(IS_NACL)
//void ConfigureBoringSSLBackedRandBytesFieldTrial();
//#endif

// Returns a random double in range [0, 1). For use in allocator shim to avoid
// infinite recursion. Thread-safe.
 double RandDoubleAvoidAllocation();

}  // namespace internal

// Returns a random number in range [0, UINT64_MAX]. Thread-safe.
 uint64_t RandUint64();

// Returns a random number between min and max (inclusive). Thread-safe.
//
// TODO(crbug.com/40283703): Change from fully-closed to half-closed (i.e.
// exclude `max`) to parallel other APIs here.
 int RandInt(int min, int max);

// Returns a random number in range [0, range).  Thread-safe.
 uint64_t RandGenerator(uint64_t range);

// Returns a random double in range [0, 1). Thread-safe.
 double RandDouble();

// Returns a random float in range [0, 1). Thread-safe.
 float RandFloat();
/*
// Returns a random duration in [`start`, `limit`). Thread-safe.
//
// REQUIRES: `start` < `limit`
 TimeDelta RandTimeDelta(TimeDelta start, TimeDelta limit);

// Returns a random duration in [`TimeDelta()`, `limit`). Thread-safe.
//
// REQUIRES: `limit.is_positive()`
 TimeDelta RandTimeDeltaUpTo(TimeDelta limit);
*/
// Given input |bits|, convert with maximum precision to a double in
// the range [0, 1). Thread-safe.
 double BitsToOpenEndedUnitInterval(uint64_t bits);

// Given input `bits`, convert with maximum precision to a float in the range
// [0, 1). Thread-safe.
 float BitsToOpenEndedUnitIntervalF(uint64_t bits);

// Fills `output` with cryptographically secure random data. Thread-safe.
//
// Although implementations are required to use a cryptographically secure
// random number source, code outside of base/ that relies on this should use
// crypto::RandBytes instead to ensure the requirement is easily discoverable.
 void RandBytes(span<uint8_t> output);
/*
// Creates a vector of `length` bytes, fills it with random data, and returns
// it. Thread-safe.
//
// Although implementations are required to use a cryptographically secure
// random number source, code outside of base/ that relies on this should use
// crypto::RandBytes instead to ensure the requirement is easily discoverable.
 std::vector<uint8_t> RandBytesAsVector(size_t length);

// DEPRECATED. Prefer RandBytesAsVector() above.
// Fills a string of length |length| with random data and returns it.
// Thread-safe.
//
// Note that this is a variation of |RandBytes| with a different return type.
// The returned string is likely not ASCII/UTF-8. Use with care.
//
// Although implementations are required to use a cryptographically secure
// random number source, code outside of base/ that relies on this should use
// crypto::RandBytes instead to ensure the requirement is easily discoverable.
 std::string RandBytesAsString(size_t length);
*/
// An STL UniformRandomBitGenerator backed by RandUint64.
class RandomBitGenerator {
 public:
  using result_type = uint64_t;
  static constexpr result_type min() { return 0; }
  static constexpr result_type max() { return UINT64_MAX; }
  result_type operator()() const { return RandUint64(); }

  RandomBitGenerator() = default;
  ~RandomBitGenerator() = default;
};
/*
#if !BUILDFLAG(IS_NACL)
class NonAllocatingRandomBitGenerator {
 public:
  using result_type = uint64_t;
  static constexpr result_type min() { return 0; }
  static constexpr result_type max() { return UINT64_MAX; }
  result_type operator()() const {
    uint64_t result;
    RAND_get_system_entropy_for_custom_prng(reinterpret_cast<uint8_t*>(&result),
                                            sizeof(result));
    return result;
  }

  NonAllocatingRandomBitGenerator() = default;
  ~NonAllocatingRandomBitGenerator() = default;
};
#endif

 */

// Shuffles [first, last) randomly. Thread-safe.
template <typename Itr>
void RandomShuffle(Itr first, Itr last) {
  std::shuffle(first, last, RandomBitGenerator());
}

//#if BUILDFLAG(IS_POSIX)
// int GetUrandomFD();
//#endif

class MetricsSubSampler;

// Fast, insecure pseudo-random number generator.
//
// WARNING: This is not the generator you are looking for. This has significant
// caveats:
//   - It is non-cryptographic, so easy to miuse
//   - It is neither fork() nor clone()-safe.
//   - Synchronization is up to the client.
//
// Always prefer base::Rand*() above, unless you have a use case where its
// overhead is too high, or system calls are disallowed.
//
// Performance: As of 2021, rough overhead on Linux on a desktop machine of
// base::RandUint64() is ~800ns per call (it performs a system call). On Windows
// it is lower. On the same machine, this generator's cost is ~2ns per call,
// regardless of platform.
//
// This is different from |Rand*()| above as it is guaranteed to never make a
// system call to generate a new number, except to seed it.  This should *never*
// be used for cryptographic applications, and is not thread-safe.
//
// It is seeded using base::RandUint64() in the constructor, meaning that it
// doesn't need to be seeded. It can be re-seeded though, with
// ReseedForTesting(). Its period is long enough that it should not need to be
// re-seeded during use.
//
// Uses the XorShift128+ generator under the hood.
class  InsecureRandomGenerator {
 public:
  // Never use outside testing, not enough entropy.
  void ReseedForTesting(uint64_t seed);

  uint32_t RandUint32();
  uint64_t RandUint64();
  // In [0, 1).
  double RandDouble();

 private:
  InsecureRandomGenerator();
  // State.
  uint64_t a_ = 0, b_ = 0;

  // Before adding a new friend class, make sure that the overhead of
  // base::Rand*() is too high, using something more representative than a
  // microbenchmark.

  // Uses the generator to fill memory pages with random content to make them
  // hard to compress, in a simulation tool not bundled with Chrome. CPU
  // overhead must be minimized to correctly measure memory effects.
  friend class memory_simulator::MemoryHolder;
  // Uses the generator to sub-sample metrics.
  friend class MetricsSubSampler;
/*
  FRIEND_TEST_ALL_PREFIXES(RandUtilTest,
                           InsecureRandomGeneratorProducesBothValuesOfAllBits);
  FRIEND_TEST_ALL_PREFIXES(RandUtilTest, InsecureRandomGeneratorChiSquared);
  FRIEND_TEST_ALL_PREFIXES(RandUtilTest, InsecureRandomGeneratorRandDouble);
  FRIEND_TEST_ALL_PREFIXES(RandUtilPerfTest, InsecureRandomRandUint64);

 */
};

class  MetricsSubSampler {
 public:
  MetricsSubSampler();
  bool ShouldSample(double probability);

  // Make any call to ShouldSample for any instance of MetricsSubSampler
  // return true for testing. Cannot be used in conjunction with
  // ScopedNeverSampleForTesting.
  class ScopedAlwaysSampleForTesting {
   public:
    ScopedAlwaysSampleForTesting();
    ~ScopedAlwaysSampleForTesting();
  };

  // Make any call to ShouldSample for any instance of MetricsSubSampler
  // return false for testing. Cannot be used in conjunction with
  // ScopedAlwaysSampleForTesting.
  class ScopedNeverSampleForTesting {
   public:
    ScopedNeverSampleForTesting();
    ~ScopedNeverSampleForTesting();
  };

 private:
  InsecureRandomGenerator generator_;
};

}  // namespace webf

#endif  // BASE_RAND_UTIL_H_
