/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_NATIVE_STRING_H
#define BRIDGE_NATIVE_STRING_H

#include <cinttypes>
#include <cstdlib>
#include <cstring>

#include "foundation/macros.h"

namespace webf {

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

}  // namespace webf

#endif  // BRIDGE_NATIVE_STRING_H
