/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_STRING_BUILDER_H_
#define WEBF_FOUNDATION_STRING_BUILDER_H_

#include <codecvt>
#include <string>
#include <vector>
#include "foundation/macros.h"
#include "foundation/string_view.h"

namespace webf {

/**
 * Is this code point a BMP code point (U+0000..U+ffff)?
 * @param c 32-bit code point
 * @return true or false
 * @stable ICU 2.8
 */
#define U_IS_BMP(c) ((uint32_t)(c) <= 0xffff)

/**
 * Get the lead surrogate (0xd800..0xdbff) for a
 * supplementary code point (0x10000..0x10ffff).
 * @param supplementary 32-bit code point (U+10000..U+10ffff)
 * @return lead surrogate (U+d800..U+dbff) for supplementary
 * @stable ICU 2.4
 */
#define U16_LEAD(supplementary) (char16_t)(((supplementary) >> 10) + 0xd7c0)

/**
 * Get the trail surrogate (0xdc00..0xdfff) for a
 * supplementary code point (0x10000..0x10ffff).
 * @param supplementary 32-bit code point (U+10000..U+10ffff)
 * @return trail surrogate (U+dc00..U+dfff) for supplementary
 * @stable ICU 2.4
 */
#define U16_TRAIL(supplementary) (char16_t)(((supplementary) & 0x3ff) | 0xdc00)

class StringBuilder {
  WEBF_STACK_ALLOCATED();

 public:
  void Append(char16_t c) {
    if (c <= 0xFF) {
      Append(static_cast<char>(c));
      return;
    }
    assert(false);
  }

  void Append(const StringBuilder& other) {
    if (!other.length_)
      return;

    if (!length_ && !HasBuffer() && !other.string_.empty()) {
      string_ = other.string_;
      length_ = other.string_.length();
      return;
    }

    Append(other.string_);
  }

  void Append(unsigned char c) {
    EnsureBuffer8(1);
    string_.push_back(c);
    ++length_;
  }

  void Append(uint32_t c) {
    if (U_IS_BMP(c)) {
      Append(static_cast<char16_t>(c));
      return;
    }
    Append(U16_LEAD(c));
    Append(U16_TRAIL(c));
  }

  void Append(int64_t v) {
    Append(std::to_string(v));
  }

  void Append(int32_t v) {
    Append(std::to_string(v));
  }

  void Append(const std::string& string_view) {
    EnsureBuffer8(1);
    string_.append(string_view);
    length_ += string_view.size();
  }

  void Append(char c) {
    EnsureBuffer8(1);
    string_.push_back(c);
    length_ += 1;
  }


  void Append(double v) {
    Append(std::to_string(v));
  }

  const char* Characters8() const {
    if (!length_)
      return nullptr;
    DCHECK(has_buffer_);
    return string_.data();
  }

  operator StringView() const { return StringView(Characters8(), length_); }

  std::string ReleaseString() { return string_; }

  bool empty() const { return string_.empty(); }

  size_t length() const { return string_.length(); }

  void Reserve(unsigned new_size);

 private:
  static const unsigned kInlineBufferSize = 16;
  static unsigned InitialBufferSize() { return kInlineBufferSize; }

  void EnsureBuffer8(unsigned added_size) {
    if (!HasBuffer())
      CreateBuffer8(added_size);
  }

  bool HasBuffer() const { return has_buffer_; }
  void CreateBuffer8(unsigned added_size);

  friend bool operator==(const StringBuilder& a, const std::string& b);

  unsigned length_ = 0;
  std::string string_;
  bool has_buffer_ = false;
};

inline bool operator==(const StringBuilder& a, const std::string& b) {
  return a.string_ == b;
}

}  // namespace webf

#endif  // WEBF_FOUNDATION_STRING_BUILDER_H_
