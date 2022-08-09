/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKENBRIDGE_NATIVE_STRING_H
#define KRAKENBRIDGE_NATIVE_STRING_H

#include <cinttypes>
#include <cstdlib>
#include <cstring>

#include "foundation/macros.h"

namespace kraken {

struct NativeString {
  NativeString(const uint16_t* string, uint32_t length);
  NativeString(const NativeString* source);
  ~NativeString();

  inline const uint16_t* string() const { return string_; }
  inline uint32_t length() const { return length_; }

 private:
  const uint16_t* string_;
  uint32_t length_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_NATIVE_STRING_H
