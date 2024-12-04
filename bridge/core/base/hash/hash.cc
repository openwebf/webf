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

namespace webf {

#define get16bits(d) ((((uint32_t)(((const uint8_t*)(d))[1])) << 8) + (uint32_t)(((const uint8_t*)(d))[0]))

// Definition in base/third_party/superfasthash/superfasthash.c. (Third-party
// code did not come with its own header file, so declaring the function here.)
// Note: This algorithm is also in Blink under Source/wtf/StringHasher.h.
uint32_t SuperFastHash(const char* data, int len) {
  uint32_t hash = (uint32_t)len, tmp;
  int rem;

  if (len <= 0 || data == NULL)
    return 0;

  rem = len & 3;
  len >>= 2;

  /* Main loop */
  for (; len > 0; len--) {
    hash += get16bits(data);
    tmp = (uint32_t)(get16bits(data + 2) << 11) ^ hash;
    hash = (hash << 16) ^ tmp;
    data += 2 * sizeof(uint16_t);
    hash += hash >> 11;
  }

  /* Handle end cases */
  switch (rem) {
    case 3:
      hash += get16bits(data);
      hash ^= hash << 16;
      hash ^= (uint32_t)(signed char)data[sizeof(uint16_t)] << 18;
      hash += hash >> 11;
      break;
    case 2:
      hash += get16bits(data);
      hash ^= hash << 11;
      hash += hash >> 17;
      break;
    case 1:
      hash += (uint32_t)((signed char)*data);
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

}  // namespace webf
