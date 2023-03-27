/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_FOUNDATION_STRING_VIEW_H_
#define BRIDGE_FOUNDATION_STRING_VIEW_H_

#include <string>
#include "ascii_types.h"
#include "native_string.h"

namespace webf {

class StringView final {
 public:
  StringView() = delete;

  explicit StringView(const std::string& string);
  explicit StringView(const SharedNativeString* string);
  explicit StringView(void* bytes, unsigned length, bool is_wide_char);

  bool Is8Bit() const { return is_8bit_; }

  bool IsLowerASCII() const {
    if (is_8bit_) {
      return webf::IsLowerASCII(Characters8(), length());
    }
    return webf::IsLowerASCII(Characters16(), length());
  }

  const char* Characters8() const { return static_cast<const char*>(bytes_); }

  const char16_t* Characters16() const { return static_cast<const char16_t*>(bytes_); }

  unsigned length() const { return length_; }
  bool Empty() const { return length_ == 0; }

 private:
  const void* bytes_;
  unsigned length_;
  unsigned is_8bit_ : 1;
};

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_STRING_VIEW_H_
