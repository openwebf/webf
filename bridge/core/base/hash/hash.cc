// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/base/hash/hash.h"

#include <cstddef>
#include <cstdint>
#include <limits>
#include <string>
#include <string_view>

#include "core/base/containers/span.h"
#include "third_party/cityhash/city.h"

namespace webf {

#define get16bits(d) ((((uint32_t)(((const uint8_t *)(d))[1])) << 8)\
+(uint32_t)(((const uint8_t *)(d))[0]) )

// Definition in base/third_party/superfasthash/superfasthash.c. (Third-party
// code did not come with its own header file, so declaring the function here.)
// Note: This algorithm is also in Blink under Source/wtf/StringHasher.h.
uint32_t SuperFastHash (const char * data, int len) {
  uint32_t hash = (uint32_t)len, tmp;
  int rem;

  if (len <= 0 || data == NULL) return 0;

  rem = len & 3;
  len >>= 2;

  /* Main loop */
  for (;len > 0; len--) {
    hash  += get16bits (data);
    tmp    = (uint32_t)(get16bits (data+2) << 11) ^ hash;
    hash   = (hash << 16) ^ tmp;
    data  += 2*sizeof (uint16_t);
    hash  += hash >> 11;
  }

  /* Handle end cases */
  switch (rem) {
    case 3: hash += get16bits (data);
    hash ^= hash << 16;
    hash ^= (uint32_t)(signed char)data[sizeof (uint16_t)] << 18;
    hash += hash >> 11;
    break;
    case 2: hash += get16bits (data);
    hash ^= hash << 11;
    hash += hash >> 17;
    break;
    case 1: hash += (uint32_t)((signed char)*data);
    hash ^= hash << 10;
    hash += hash >> 1;
  }

  /* Force "avalanching" of final 127 bits */
  hash ^= hash << 3;
  hash += hash >> 5;
  hash ^= hash << 4;
  hash += hash >> 17;
  hash ^= hash << 25;
  hash += hash >> 6;

  return hash;
}

namespace {

// Helper function to check if a value is within the range of a target type
template <typename Dst, typename Src>
constexpr bool IsValueInRangeForNumericType(Src value) {
  if constexpr (std::is_integral_v<Src> && std::is_integral_v<Dst>) {
    return value >= std::numeric_limits<Dst>::min() && value <= std::numeric_limits<Dst>::max();
  } else if constexpr (std::is_floating_point_v<Src> && std::is_floating_point_v<Dst>) {
    return value >= -std::numeric_limits<Dst>::infinity() && value <= std::numeric_limits<Dst>::infinity();
  } else if constexpr (std::is_integral_v<Src> && std::is_floating_point_v<Dst>) {
    return value >= std::numeric_limits<Dst>::lowest() && value <= std::numeric_limits<Dst>::max();
  } else if constexpr (std::is_floating_point_v<Src> && std::is_integral_v<Dst>) {
    return value >= std::numeric_limits<Dst>::min() && value <= std::numeric_limits<Dst>::max() && std::floor(value) == value;
  } else {
    return false;
  }
}

// Default check handler that throws an exception on failure
struct DefaultCheckHandler {
  template <typename Dst>
  static Dst HandleFailure() {
    throw std::overflow_error("checked_cast: value out of range for target type");
  }
};

// checked_cast function using standard library
template <typename Dst, class CheckHandler = DefaultCheckHandler, typename Src>
constexpr Dst checked_cast(Src value) {
  using SrcType = std::decay_t<Src>;
  if constexpr (std::is_same_v<Dst, SrcType>) {
    return value;
  } else {
    if (IsValueInRangeForNumericType<Dst>(value)) {
      return static_cast<Dst>(value);
    } else {
      return CheckHandler::template HandleFailure<Dst>();
    }
  }
}

size_t FastHashImpl(webf::span<const uint8_t> data) {
  auto chars = as_chars(data);
  // We use the updated CityHash within our namespace (not the deprecated
  // version from third_party/smhasher).
  if constexpr (sizeof(size_t) > 4) {
    return base::internal::cityhash_v111::CityHash64(chars.data(),
                                                     chars.size());
  } else {
    return base::internal::cityhash_v111::CityHash32(chars.data(),
                                                     chars.size());
  }
}
// Implement hashing for pairs of at-most 32 bit integer values.
// When size_t is 32 bits, we turn the 64-bit hash code into 32 bits by using
// multiply-add hashing. This algorithm, as described in
// Theorem 4.3.3 of the thesis "Über die Komplexität der Multiplikation in
// eingeschränkten Branchingprogrammmodellen" by Woelfel, is:
//
//   h32(x32, y32) = (h64(x32, y32) * rand_odd64 + rand16 * 2^16) % 2^64 / 2^32
//
// Contact danakj@chromium.org for any questions.
size_t HashInts32Impl(uint32_t value1, uint32_t value2) {
  uint64_t value1_64 = value1;
  uint64_t hash64 = (value1_64 << 32) | value2;

  if (sizeof(size_t) >= sizeof(uint64_t))
    return static_cast<size_t>(hash64);

  uint64_t odd_random = 481046412LL << 32 | 1025306955LL;
  uint32_t shift_random = 10121U << 16;

  hash64 = hash64 * odd_random + shift_random;
  size_t high_bits =
      static_cast<size_t>(hash64 >> (8 * (sizeof(uint64_t) - sizeof(size_t))));
  return high_bits;
}

// Implement hashing for pairs of up-to 64-bit integer values.
// We use the compound integer hash method to produce a 64-bit hash code, by
// breaking the two 64-bit inputs into 4 32-bit values:
// http://opendatastructures.org/versions/edition-0.1d/ods-java/node33.html#SECTION00832000000000000000
// Then we reduce our result to 32 bits if required, similar to above.
size_t HashInts64Impl(uint64_t value1, uint64_t value2) {
  uint32_t short_random1 = 842304669U;
  uint32_t short_random2 = 619063811U;
  uint32_t short_random3 = 937041849U;
  uint32_t short_random4 = 3309708029U;

  uint32_t value1a = static_cast<uint32_t>(value1 & 0xffffffff);
  uint32_t value1b = static_cast<uint32_t>((value1 >> 32) & 0xffffffff);
  uint32_t value2a = static_cast<uint32_t>(value2 & 0xffffffff);
  uint32_t value2b = static_cast<uint32_t>((value2 >> 32) & 0xffffffff);

  uint64_t product1 = static_cast<uint64_t>(value1a) * short_random1;
  uint64_t product2 = static_cast<uint64_t>(value1b) * short_random2;
  uint64_t product3 = static_cast<uint64_t>(value2a) * short_random3;
  uint64_t product4 = static_cast<uint64_t>(value2b) * short_random4;

  uint64_t hash64 = product1 + product2 + product3 + product4;

  if (sizeof(size_t) >= sizeof(uint64_t))
    return static_cast<size_t>(hash64);

  uint64_t odd_random = 1578233944LL << 32 | 194370989LL;
  uint32_t shift_random = 20591U << 16;

  hash64 = hash64 * odd_random + shift_random;
  size_t high_bits =
      static_cast<size_t>(hash64 >> (8 * (sizeof(uint64_t) - sizeof(size_t))));
  return high_bits;
}

}  // namespace

size_t FastHash(webf::span<const uint8_t> data) {
  return FastHashImpl(data);
}

uint32_t Hash(webf::span<const uint8_t> data) {
  // Currently our in-memory hash is the same as the persistent hash. The
  // split between in-memory and persistent hash functions is maintained to
  // allow the in-memory hash function to be updated in the future.
  return PersistentHash(data);
}

uint32_t Hash(const std::string& str) {
  return PersistentHash(as_byte_span(str));
}

uint32_t PersistentHash(webf::span<const uint8_t> data) {
  // This hash function must not change, since it is designed to be persistable
  // to disk.
  if (data.size() > size_t{std::numeric_limits<int>::max()}) {
    //NOTREACHED_IN_MIGRATION();
    return 0;
  }
  auto chars = as_chars(data);
  if (chars.size() > std::numeric_limits<int>::min() &&
  chars.size() < std::numeric_limits<int>::max()) {
    return static_cast<int>(chars.size());
  } else {
    throw std::overflow_error("checked_cast: value out of range for target type");
  }
  return SuperFastHash(chars.data(), checked_cast<int>(chars.size()));
}

uint32_t PersistentHash(std::string_view str) {
  return PersistentHash(as_bytes(make_span(str)));
}

size_t HashInts32(uint32_t value1, uint32_t value2) {
  return HashInts32Impl(value1, value2);
}

size_t HashInts64(uint64_t value1, uint64_t value2) {
  return HashInts64Impl(value1, value2);
}

}  // namespace base
